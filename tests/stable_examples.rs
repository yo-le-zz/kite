//! Runs every `examples/{lang5,stable}/*.ki` program through the compiler
//! and compares its stdout with the recorded `.out` file.

use std::path::Path;
use std::process::Command;

fn run_example(path: &Path) -> String {
    let dir = std::env::temp_dir().join(format!(
        "kite_stable_{}_{}",
        std::process::id(),
        path.file_stem().unwrap().to_string_lossy()
    ));
    let _ = std::fs::remove_dir_all(&dir);
    std::fs::create_dir_all(dir.join("src")).unwrap();
    std::fs::copy(path, dir.join("src/main.ki")).unwrap();
    std::fs::write(
        dir.join("kite.toml"),
        "[package]\nname = \"probe\"\nversion = \"0.1.0\"\n",
    )
    .unwrap();
    let out = Command::new(env!("CARGO_BIN_EXE_kite"))
        .args(["run", "-q"])
        .current_dir(&dir)
        .output()
        .expect("failed to launch kite");
    let _ = std::fs::remove_dir_all(&dir);
    let mut s = String::from_utf8_lossy(&out.stdout).to_string();
    s.push_str(&String::from_utf8_lossy(&out.stderr));
    s
}

#[test]
fn recorded_examples_still_produce_the_same_output() {
    let root = Path::new(env!("CARGO_MANIFEST_DIR")).join("examples");
    let mut checked = 0;
    for sub in ["lang5", "stable"] {
        for entry in std::fs::read_dir(root.join(sub)).unwrap() {
            let p = entry.unwrap().path();
            if p.extension().and_then(|e| e.to_str()) != Some("ki") {
                continue;
            }
            let expected = std::fs::read_to_string(p.with_extension("out")).unwrap();
            let got = run_example(&p);
            let head: String = expected.lines().take(25).collect::<Vec<_>>().join("\n");
            let got_head: String = got.lines().take(25).collect::<Vec<_>>().join("\n");
            assert_eq!(head.trim(), got_head.trim(), "output changed for {}", p.display());
            checked += 1;
        }
    }
    assert!(checked >= 10, "expected at least 10 examples, found {checked}");
}
