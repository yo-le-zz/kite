use std::io::Read;

use anyhow::{Context, Result};
use serde::Deserialize;

/// GitHub "owner/repo" that publishes the `kite-<version>-<os>-<arch>.(tar.gz|zip)`
/// and `kite_<version>_<arch>.deb` assets built by `kite`'s own `build.sh`.
/// Adjust this if the repository is renamed or moved.
pub const REPO: &str = "yo-le-zz/Kite";

#[derive(Debug, Deserialize)]
struct ReleaseAsset {
    name: String,
    browser_download_url: String,
}

#[derive(Debug, Deserialize)]
struct Release {
    tag_name: String,
    assets: Vec<ReleaseAsset>,
}

pub struct ResolvedAsset {
    pub version: String,
    pub download_url: String,
    pub file_name: String,
}

/// Maps the running OS/arch to the short target name used by `kite`'s
/// `build.sh` (e.g. "linux-x64", "macos-arm64", "windows-x86"), which is
/// also the naming scheme used for the release asset file names.
pub fn target_short_name() -> Option<String> {
    let os = match std::env::consts::OS {
        "windows" => "windows",
        "macos" => "macos",
        "linux" => "linux",
        _ => return None,
    };
    let arch = match std::env::consts::ARCH {
        "x86_64" => "x64",
        "aarch64" => "arm64",
        "x86" => "x86",
        _ => return None,
    };
    Some(format!("{os}-{arch}"))
}

/// Looks up the latest GitHub release and finds the asset matching this
/// machine's OS/architecture.
pub fn fetch_latest_asset() -> Result<ResolvedAsset> {
    let short = target_short_name().context(
        "this OS/architecture isn't one of kite's published build targets",
    )?;
    let ext = if std::env::consts::OS == "windows" {
        "zip"
    } else {
        "tar.gz"
    };

    let api_url = format!("https://api.github.com/repos/{REPO}/releases/latest");
    let release: Release = ureq::get(&api_url)
        .set("User-Agent", "kite-installer")
        .set("Accept", "application/vnd.github+json")
        .call()
        .context("could not reach GitHub -- check your internet connection")?
        .into_json()
        .context("could not parse the release metadata returned by GitHub")?;

    let version = release.tag_name.trim_start_matches('v').to_string();
    let file_name = format!("kite-{version}-{short}.{ext}");

    let asset = release
        .assets
        .into_iter()
        .find(|a| a.name == file_name)
        .with_context(|| {
            format!(
                "release {} has no asset named '{file_name}' -- this platform may not \
                 be published yet",
                release.tag_name
            )
        })?;

    Ok(ResolvedAsset {
        version,
        download_url: asset.browser_download_url,
        file_name: asset.name,
    })
}

/// Downloads a URL fully into memory. Release archives for a single CLI
/// binary are a few hundred KB to a couple MB, so buffering is fine.
pub fn download(url: &str) -> Result<Vec<u8>> {
    let mut buf = Vec::new();
    ureq::get(url)
        .set("User-Agent", "kite-installer")
        .call()
        .context("failed to download the release asset")?
        .into_reader()
        .read_to_end(&mut buf)
        .context("failed to read the downloaded file")?;
    Ok(buf)
}
