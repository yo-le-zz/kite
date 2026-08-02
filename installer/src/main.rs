use std::fs;
use std::path::{Path, PathBuf};
use std::time::{SystemTime, UNIX_EPOCH};

use iced::widget::{button, checkbox, column, container, image, row, text, text_input, Space};
use iced::{window, Alignment, Element, Length, Task};

mod archive;
mod metadata;
mod net;

const KITE_ICON: &[u8] = include_bytes!("../assets/logo/256/kite-256.png");

#[derive(Debug, Clone, serde::Serialize, serde::Deserialize)]
struct InstallMetadata {
    version: String,
    install_path: String,
    installed_at: String,
    os: String,
    arch: String,
}

#[allow(dead_code)]
#[derive(Debug, Clone)]
enum InstallationState {
    NotInstalled,
    Installed {
        path: PathBuf,
        version: String,
        installed_at: String,
    },
    Broken {
        path: PathBuf,
        message: String,
    },
}

#[derive(Debug, Clone, PartialEq, Eq)]
enum Page {
    Welcome,
    Options,
    Progress,
    Done,
}

#[derive(Debug, Clone)]
enum Message {
    GoToOptions,
    GoToWelcome,
    PathChanged(String),
    ToggleDesktopShortcut(bool),
    ToggleStartMenu(bool),
    ToggleAddToPath(bool),
    StartInstall,
    InstallFinished(Result<String, String>),
    Uninstall,
    RefreshStatus,
    Quit,
}

struct Installer {
    page: Page,
    title: String,
    install_path: String,
    desktop_shortcut: bool,
    start_menu: bool,
    add_to_path: bool,
    status: String,
    install_state: InstallationState,
    result_message: Option<Result<String, String>>,
}

fn default_install_dir() -> PathBuf {
    if cfg!(windows) {
        dirs::data_local_dir()
            .unwrap_or_else(|| dirs::home_dir().unwrap_or_else(|| PathBuf::from(".")))
            .join("Kite")
    } else if cfg!(target_os = "macos") {
        dirs::home_dir()
            .unwrap_or_else(|| PathBuf::from("."))
            .join("Applications")
            .join("Kite")
    } else {
        dirs::data_local_dir()
            .unwrap_or_else(|| dirs::home_dir().unwrap_or_else(|| PathBuf::from(".")))
            .join("Kite")
    }
}

fn format_timestamp() -> String {
    let now = SystemTime::now()
        .duration_since(UNIX_EPOCH)
        .unwrap_or_default();
    let secs = now.as_secs();
    let ts = chrono::DateTime::<chrono::Utc>::from_timestamp(secs as i64, 0)
        .unwrap_or_else(|| chrono::DateTime::<chrono::Utc>::from_timestamp(0, 0).unwrap());
    ts.format("%Y-%m-%d %H:%M:%S UTC").to_string()
}

fn detect_installation_state(dir: &Path) -> InstallationState {
    let marker = dir.join(".kite-installed.json");
    match fs::read_to_string(&marker) {
        Ok(contents) => match serde_json::from_str::<InstallMetadata>(&contents) {
            Ok(metadata) => InstallationState::Installed {
                path: dir.to_path_buf(),
                version: metadata.version,
                installed_at: metadata.installed_at,
            },
            Err(err) => InstallationState::Broken {
                path: dir.to_path_buf(),
                message: format!("installation marker is corrupted: {err}"),
            },
        },
        Err(err) if err.kind() == std::io::ErrorKind::NotFound => InstallationState::NotInstalled,
        Err(err) => InstallationState::Broken {
            path: dir.to_path_buf(),
            message: format!("unable to inspect installation state: {err}"),
        },
    }
}

/// Downloads the right release asset for this OS/arch, extracts the `kite`
/// binary into `dir`, and wires up the shortcuts/PATH entry requested.
/// Blocking (network + disk I/O) -- called from an async `Task`.
fn perform_install(
    dir: PathBuf,
    create_desktop_shortcut_flag: bool,
    create_start_menu_flag: bool,
    add_to_path: bool,
) -> Result<String, String> {
    let asset = net::fetch_latest_asset().map_err(|e| e.to_string())?;
    let bytes = net::download(&asset.download_url).map_err(|e| e.to_string())?;

    fs::create_dir_all(&dir).map_err(|e| e.to_string())?;
    let kite_bin = archive::extract_binary(&bytes, &asset.file_name, &dir).map_err(|e| e.to_string())?;

    let icon_path = dir.join("kite-icon.png");
    fs::write(&icon_path, KITE_ICON).map_err(|e| e.to_string())?;

    let marker = dir.join(".kite-installed.json");
    let metadata = InstallMetadata {
        version: asset.version.clone(),
        install_path: dir.to_string_lossy().to_string(),
        installed_at: format_timestamp(),
        os: metadata::OS.to_string(),
        arch: metadata::ARCH.to_string(),
    };
    fs::write(&marker, serde_json::to_string_pretty(&metadata).map_err(|e| e.to_string())?)
        .map_err(|e| e.to_string())?;

    let launcher_path = dir.join(if cfg!(windows) { "kite-launcher.bat" } else { "kite-launcher" });
    let kite_bin_str = kite_bin.display().to_string();
    if cfg!(windows) {
        fs::write(&launcher_path, format!("@echo off\r\n\"{kite_bin_str}\" %*\r\n")).map_err(|e| e.to_string())?;
    } else {
        fs::write(&launcher_path, format!("#!/usr/bin/env sh\nexec \"{kite_bin_str}\" \"$@\"\n"))
            .map_err(|e| e.to_string())?;
        #[cfg(unix)]
        {
            use std::os::unix::fs::PermissionsExt;
            let mut permissions = fs::metadata(&launcher_path).map_err(|e| e.to_string())?.permissions();
            permissions.set_mode(0o755);
            fs::set_permissions(&launcher_path, permissions).map_err(|e| e.to_string())?;
        }
    }

    if create_desktop_shortcut_flag {
        create_desktop_shortcut(&dir, &icon_path, &kite_bin).map_err(|e| e.to_string())?;
    }
    if create_start_menu_flag {
        create_start_menu_shortcut(&dir, &icon_path, &kite_bin).map_err(|e| e.to_string())?;
    }
    if add_to_path {
        add_dir_to_path(&dir).map_err(|e| e.to_string())?;
    }

    Ok(format!(
        "Kite {} installed successfully in {}.",
        asset.version,
        dir.display()
    ))
}

fn uninstall_kite(dir: &Path) -> anyhow::Result<()> {
    let marker = dir.join(".kite-installed.json");
    if marker.exists() {
        fs::remove_file(&marker)?;
    }

    for entry in [
        dir.join("kite"),
        dir.join("kite.exe"),
        dir.join("kite-launcher"),
        dir.join("kite-launcher.bat"),
        dir.join("kite-icon.png"),
        dir.join("Kite.desktop"),
        dir.join("kite.desktop"),
        dir.join("Kite-Desktop-Shortcut.bat"),
    ] {
        if entry.exists() {
            let _ = fs::remove_file(entry);
        }
    }

    if dir.exists() {
        let remaining = fs::read_dir(dir)?.count();
        if remaining == 0 {
            fs::remove_dir(dir)?;
        }
    }

    Ok(())
}

fn create_desktop_shortcut(dir: &Path, icon_path: &Path, kite_bin: &Path) -> anyhow::Result<()> {
    if cfg!(windows) {
        let shortcut = dir.join("Kite-Desktop-Shortcut.bat");
        let exe = kite_bin.display().to_string();
        fs::write(shortcut, format!("@echo off\r\nstart \"\" \"{exe}\"\r\n"))?;
        return Ok(());
    }

    let desktop_file = dir.join("Kite.desktop");
    let exec = dir.join("kite-launcher").display().to_string();
    let icon = icon_path.display().to_string();
    let file = format!(
        "[Desktop Entry]\nVersion=1.0\nType=Application\nName=Kite\nComment=Launch Kite\nExec={exec}\nIcon={icon}\nTerminal=true\nCategories=Development;Utility;\n"
    );
    fs::write(&desktop_file, file)?;

    #[cfg(unix)]
    {
        use std::os::unix::fs::PermissionsExt;
        let mut permissions = fs::metadata(&desktop_file)?.permissions();
        permissions.set_mode(0o755);
        fs::set_permissions(&desktop_file, permissions)?;
    }

    Ok(())
}

fn create_start_menu_shortcut(dir: &Path, icon_path: &Path, kite_bin: &Path) -> anyhow::Result<()> {
    let _ = kite_bin;
    let entry = dir.join("kite.desktop");
    let exec = dir.join("kite-launcher").display().to_string();
    let icon = icon_path.display().to_string();
    let content = format!(
        "[Desktop Entry]\nVersion=1.0\nType=Application\nName=Kite\nComment=Launch Kite\nExec={exec}\nIcon={icon}\nTerminal=true\nCategories=Development;Utility;\n"
    );
    fs::write(entry, content)?;
    Ok(())
}

/// Best-effort "add to PATH": on Unix, symlink the binary into `~/.local/bin`
/// (already on PATH for most modern distros/macOS shells, and needs no admin
/// rights); on Windows, prepend the install dir to the *user* PATH via
/// PowerShell (no admin rights needed either).
fn add_dir_to_path(dir: &Path) -> anyhow::Result<()> {
    #[cfg(windows)]
    {
        let dir_str = dir.display().to_string();
        let ps_cmd = format!(
            "$p = [Environment]::GetEnvironmentVariable('Path','User'); \
             if ($p -notlike '*{dir_str}*') {{ \
                [Environment]::SetEnvironmentVariable('Path', \"$p;{dir_str}\", 'User') \
             }}"
        );
        std::process::Command::new("powershell")
            .args(["-NoProfile", "-Command", &ps_cmd])
            .status()?;
    }

    #[cfg(unix)]
    {
        let target = dir.join("kite");
        let local_bin = dirs::home_dir()
            .unwrap_or_else(|| PathBuf::from("."))
            .join(".local")
            .join("bin");
        fs::create_dir_all(&local_bin)?;
        let link = local_bin.join("kite");
        let _ = fs::remove_file(&link);
        std::os::unix::fs::symlink(&target, &link)?;
    }

    Ok(())
}

pub fn main() -> iced::Result {
    let initial_dir = default_install_dir();
    let initial_state = detect_installation_state(&initial_dir);
    iced::application(|state: &Installer| state.title.clone(), update, view)
        .window(window::Settings {
            size: iced::Size::new(860.0, 560.0),
            resizable: false,
            icon: load_icon(),
            ..Default::default()
        })
        .run_with(move || {
            let message = match &initial_state {
                InstallationState::Installed { version, .. } => format!("Kite {} is already installed.", version),
                InstallationState::Broken { message, .. } => format!("Detected a broken installation: {message}"),
                InstallationState::NotInstalled => "Kite is not installed yet.".to_string(),
            };

            (
                Installer {
                    page: Page::Welcome,
                    title: format!(
                        "{} Installer ({} - {})",
                        metadata::NAME,
                        metadata::ARCH,
                        metadata::OS
                    ),
                    install_path: initial_dir.to_string_lossy().to_string(),
                    desktop_shortcut: true,
                    start_menu: true,
                    add_to_path: true,
                    status: message,
                    install_state: initial_state,
                    result_message: None,
                },
                Task::none(),
            )
        })
}

fn load_icon() -> Option<window::icon::Icon> {
    window::icon::from_file_data(KITE_ICON, None).ok()
}

fn update(state: &mut Installer, message: Message) -> Task<Message> {
    match message {
        Message::GoToOptions => {
            state.page = Page::Options;
        }
        Message::GoToWelcome => {
            state.page = Page::Welcome;
        }
        Message::PathChanged(path) => {
            state.install_path = path;
            state.install_state = detect_installation_state(Path::new(&state.install_path));
            state.status = match &state.install_state {
                InstallationState::Installed { version, .. } => format!("Kite {} already installed at {}.", version, state.install_path),
                InstallationState::Broken { message, .. } => format!("Broken install at {}: {message}", state.install_path),
                InstallationState::NotInstalled => format!("Ready to install into {}.", state.install_path),
            };
        }
        Message::ToggleDesktopShortcut(value) => {
            state.desktop_shortcut = value;
        }
        Message::ToggleStartMenu(value) => {
            state.start_menu = value;
        }
        Message::ToggleAddToPath(value) => {
            state.add_to_path = value;
        }
        Message::StartInstall => {
            state.page = Page::Progress;
            state.status = "Downloading the latest Kite release...".to_string();
            let dir = PathBuf::from(&state.install_path);
            let desktop = state.desktop_shortcut;
            let start_menu = state.start_menu;
            let add_to_path = state.add_to_path;
            return Task::perform(
                async move { perform_install(dir, desktop, start_menu, add_to_path) },
                Message::InstallFinished,
            );
        }
        Message::InstallFinished(result) => {
            state.install_state = detect_installation_state(Path::new(&state.install_path));
            state.status = match &result {
                Ok(msg) => msg.clone(),
                Err(err) => format!("Installation failed: {err}"),
            };
            state.result_message = Some(result);
            state.page = Page::Done;
        }
        Message::Uninstall => {
            let dir = Path::new(&state.install_path);
            let result = uninstall_kite(dir);
            match result {
                Ok(()) => {
                    state.install_state = detect_installation_state(dir);
                    state.status = format!("Kite was uninstalled from {}.", state.install_path);
                }
                Err(err) => {
                    state.install_state = InstallationState::Broken {
                        path: dir.to_path_buf(),
                        message: err.to_string(),
                    };
                    state.status = format!("Uninstall failed: {err}");
                }
            }
        }
        Message::RefreshStatus => {
            state.install_state = detect_installation_state(Path::new(&state.install_path));
            state.status = match &state.install_state {
                InstallationState::Installed { version, .. } => format!("Kite {} is installed at {}.", version, state.install_path),
                InstallationState::Broken { message, .. } => format!("Issue detected: {message}"),
                InstallationState::NotInstalled => format!("Ready to install into {}.", state.install_path),
            };
        }
        Message::Quit => {
            std::process::exit(0);
        }
    }

    Task::none()
}

fn logo() -> Element<'static, Message> {
    image(image::Handle::from_bytes(KITE_ICON)).width(96).height(96).into()
}

fn view(state: &Installer) -> Element<'_, Message> {
    match state.page {
        Page::Welcome => view_welcome(state),
        Page::Options => view_options(state),
        Page::Progress => view_progress(state),
        Page::Done => view_done(state),
    }
}

fn view_welcome(state: &Installer) -> Element<'_, Message> {
    let state_label = match &state.install_state {
        InstallationState::Installed { version, .. } => format!("Already installed (version {version})"),
        InstallationState::Broken { .. } => "A previous installation needs attention".to_string(),
        InstallationState::NotInstalled => "Not installed yet".to_string(),
    };

    let content = column![
        Space::with_height(20),
        logo(),
        text("Welcome to the Kite installer").size(28),
        text("This will download the latest Kite release for your platform and set it up.").size(15),
        Space::with_height(10),
        text(format!("Status: {state_label}")).size(14),
        Space::with_height(30),
        row![
            button("Uninstall").on_press(Message::Uninstall),
            Space::with_width(Length::Fill),
            button("Continue").on_press(Message::GoToOptions),
        ]
        .width(520)
    ]
    .align_x(Alignment::Center)
    .spacing(10)
    .padding(20);

    container(content)
        .width(Length::Fill)
        .height(Length::Fill)
        .center_x(Length::Fill)
        .into()
}

fn view_options(state: &Installer) -> Element<'_, Message> {
    let header = row![
        logo(),
        column![
            text(state.title.clone()).size(24),
            text(format!("Target directory: {}", state.install_path)).size(14),
        ]
        .spacing(4)
        .padding(iced::Padding::new(8.0)),
    ]
    .align_y(Alignment::Center);

    let options = column![
        text("Installation options").size(18),
        text_input("Custom install directory", &state.install_path)
            .on_input(Message::PathChanged)
            .padding(8),
        checkbox("Create desktop shortcut", state.desktop_shortcut)
            .on_toggle(Message::ToggleDesktopShortcut),
        checkbox("Create start menu / applications entry", state.start_menu)
            .on_toggle(Message::ToggleStartMenu),
        checkbox("Add 'kite' to PATH", state.add_to_path)
            .on_toggle(Message::ToggleAddToPath),
    ]
    .spacing(10)
    .padding(iced::Padding::new(8.0));

    let actions = row![
        button("Back").on_press(Message::GoToWelcome),
        Space::with_width(Length::Fill),
        button("Refresh status").on_press(Message::RefreshStatus),
        button("Install Kite").on_press(Message::StartInstall),
    ]
    .spacing(12)
    .padding(iced::Padding::new(8.0));

    let content = column![
        header,
        text(state.status.clone()).size(15).width(760),
        options,
        actions
    ]
    .spacing(14);

    container(content).padding(20).into()
}

fn view_progress(state: &Installer) -> Element<'_, Message> {
    let content = column![
        Space::with_height(Length::FillPortion(1)),
        logo(),
        text("Installing Kite...").size(24),
        text(state.status.clone()).size(15),
        Space::with_height(Length::FillPortion(1)),
    ]
    .align_x(Alignment::Center)
    .spacing(14);

    container(content)
        .width(Length::Fill)
        .height(Length::Fill)
        .center_x(Length::Fill)
        .center_y(Length::Fill)
        .into()
}

fn view_done(state: &Installer) -> Element<'_, Message> {
    let (title, ok) = match &state.result_message {
        Some(Ok(_)) => ("Installation complete", true),
        Some(Err(_)) => ("Installation failed", false),
        None => ("Done", true),
    };

    let content = column![
        Space::with_height(20),
        logo(),
        text(title).size(26),
        text(state.status.clone()).size(15).width(700),
        Space::with_height(20),
        row![
            if !ok {
                button("Back").on_press(Message::GoToOptions)
            } else {
                button("Close").on_press(Message::Quit)
            },
            if ok {
                button("Close").on_press(Message::Quit)
            } else {
                button("Retry").on_press(Message::StartInstall)
            },
        ]
        .spacing(12),
    ]
    .align_x(Alignment::Center)
    .spacing(10)
    .padding(20);

    container(content)
        .width(Length::Fill)
        .height(Length::Fill)
        .center_x(Length::Fill)
        .into()
}

#[cfg(test)]
mod tests {
    use super::*;
    use std::fs;
    use std::time::{SystemTime, UNIX_EPOCH};

    #[test]
    fn default_install_dir_uses_platform_specific_path() {
        let dir = default_install_dir();
        assert!(!dir.as_os_str().is_empty());
        assert!(dir.to_string_lossy().contains("Kite") || dir.to_string_lossy().contains("kite"));
    }

    #[test]
    fn detect_installation_state_returns_installed_for_marker_file() {
        let temp = std::env::temp_dir().join(format!(
            "kite-installer-test-{}",
            SystemTime::now()
                .duration_since(UNIX_EPOCH)
                .unwrap()
                .as_nanos()
        ));
        let _ = fs::remove_dir_all(&temp);
        fs::create_dir_all(&temp).unwrap();
        fs::write(
            temp.join(".kite-installed.json"),
            "{\"version\":\"0.1.0\",\"install_path\":\"/tmp/kite\",\"installed_at\":\"2026-01-01\",\"os\":\"linux\",\"arch\":\"x86_64\"}",
        )
        .unwrap();

        let state = detect_installation_state(&temp);
        assert!(matches!(state, InstallationState::Installed { .. }));

        let _ = fs::remove_dir_all(&temp);
    }

    #[test]
    fn target_short_name_matches_known_platforms() {
        // Just make sure it doesn't panic and returns Some(..) on the CI
        // platforms kite actually publishes builds for.
        let _ = net::target_short_name();
    }
}