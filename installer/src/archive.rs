use std::io::Cursor;
use std::path::{Path, PathBuf};

use anyhow::{bail, Context, Result};

/// Extracts a `.tar.gz` or `.zip` archive (format inferred from `file_name`)
/// and writes the `kite`/`kite.exe` binary it contains into `dest_dir`.
/// Returns the path to the extracted binary.
pub fn extract_binary(bytes: &[u8], file_name: &str, dest_dir: &Path) -> Result<PathBuf> {
    std::fs::create_dir_all(dest_dir).context("could not create the install directory")?;
    let bin_name = if file_name.ends_with(".zip") {
        "kite.exe"
    } else {
        "kite"
    };

    if file_name.ends_with(".zip") {
        extract_from_zip(bytes, bin_name, dest_dir)
    } else {
        extract_from_tar_gz(bytes, bin_name, dest_dir)
    }
}

fn extract_from_zip(bytes: &[u8], bin_name: &str, dest_dir: &Path) -> Result<PathBuf> {
    let mut archive =
        zip::ZipArchive::new(Cursor::new(bytes)).context("the downloaded .zip is invalid")?;

    for i in 0..archive.len() {
        let mut entry = archive.by_index(i)?;
        let entry_name = entry.name().to_string();
        if entry_name.ends_with(bin_name) {
            let out_path = dest_dir.join(bin_name);
            let mut out = std::fs::File::create(&out_path)?;
            std::io::copy(&mut entry, &mut out)?;
            return Ok(out_path);
        }
    }

    bail!("could not find '{bin_name}' inside the downloaded .zip")
}

fn extract_from_tar_gz(bytes: &[u8], bin_name: &str, dest_dir: &Path) -> Result<PathBuf> {
    let decoder = flate2::read::GzDecoder::new(Cursor::new(bytes));
    let mut archive = tar::Archive::new(decoder);

    for entry in archive.entries()? {
        let mut entry = entry?;
        let path = entry.path()?.to_path_buf();
        if path.file_name().map(|n| n == bin_name).unwrap_or(false) {
            let out_path = dest_dir.join(bin_name);
            let mut out = std::fs::File::create(&out_path)?;
            std::io::copy(&mut entry, &mut out)?;

            #[cfg(unix)]
            {
                use std::os::unix::fs::PermissionsExt;
                std::fs::set_permissions(&out_path, std::fs::Permissions::from_mode(0o755))?;
            }

            return Ok(out_path);
        }
    }

    bail!("could not find '{bin_name}' inside the downloaded .tar.gz")
}
