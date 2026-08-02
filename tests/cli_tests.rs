//! CLI tests: `kite init`, `build`, `run`, `check`, `clean`, and the
//! package-manager commands, driven the same way a user would from a
//! shell.

use assert_cmd::Command;
use predicates::str::contains;
use tempfile::tempdir;

fn kite() -> Command {
    Command::cargo_bin("kite").expect("kite binary should build")
}

#[test]
fn version_flag_works() {
    kite().arg("--version").assert().success();
}

#[test]
fn help_flag_lists_subcommands() {
    kite()
        .arg("--help")
        .assert()
        .success()
        .stdout(contains("build"))
        .stdout(contains("init"));
}

#[test]
fn init_creates_project_scaffold() {
    let dir = tempdir().unwrap();
    kite()
        .current_dir(dir.path())
        .args(["init", "hello"])
        .assert()
        .success();

    let project = dir.path().join("hello");
    assert!(project.join("kite.toml").is_file());
    assert!(project.join("src/main.ki").is_file());
    let manifest = std::fs::read_to_string(project.join("kite.toml")).unwrap();
    assert!(manifest.contains("name = \"hello\""));
}

#[test]
fn init_refuses_to_overwrite_existing_project() {
    let dir = tempdir().unwrap();
    kite()
        .current_dir(dir.path())
        .args(["init", "hello"])
        .assert()
        .success();
    kite()
        .current_dir(dir.path())
        .args(["init", "hello"])
        .assert()
        .failure();
}

#[test]
fn check_reports_no_errors_for_the_default_template() {
    let dir = tempdir().unwrap();
    kite()
        .current_dir(dir.path())
        .args(["init", "hello"])
        .assert()
        .success();
    let project = dir.path().join("hello");
    kite().current_dir(&project).arg("check").assert().success();
}

#[test]
fn check_reports_a_type_error() {
    let dir = tempdir().unwrap();
    kite()
        .current_dir(dir.path())
        .args(["init", "hello"])
        .assert()
        .success();
    let project = dir.path().join("hello");
    std::fs::write(
        project.join("src/main.ki"),
        "make main():\n    x = 1 + \"nope\"\n",
    )
    .unwrap();
    kite()
        .current_dir(&project)
        .arg("check")
        .assert()
        .failure()
        .stderr(contains("error"));
}

#[test]
fn clean_removes_the_target_directory() {
    let dir = tempdir().unwrap();
    kite()
        .current_dir(dir.path())
        .args(["init", "hello"])
        .assert()
        .success();
    let project = dir.path().join("hello");
    std::fs::create_dir_all(project.join("target")).unwrap();
    kite().current_dir(&project).arg("clean").assert().success();
    assert!(!project.join("target").exists());
}

#[test]
fn add_and_remove_dependency() {
    let dir = tempdir().unwrap();
    kite()
        .current_dir(dir.path())
        .args(["init", "hello"])
        .assert()
        .success();
    let project = dir.path().join("hello");

    kite()
        .current_dir(&project)
        .args(["add", "http@1.0.0"])
        .assert()
        .success();
    let manifest = std::fs::read_to_string(project.join("kite.toml")).unwrap();
    assert!(manifest.contains("http = \"1.0.0\""));
    assert!(project.join("kite.lock").is_file());

    kite()
        .current_dir(&project)
        .args(["remove", "http"])
        .assert()
        .success();
    let manifest = std::fs::read_to_string(project.join("kite.toml")).unwrap();
    assert!(!manifest.contains("http ="));
}

#[test]
fn update_succeeds_with_no_dependencies() {
    let dir = tempdir().unwrap();
    kite()
        .current_dir(dir.path())
        .args(["init", "hello"])
        .assert()
        .success();
    let project = dir.path().join("hello");
    kite()
        .current_dir(&project)
        .arg("update")
        .assert()
        .success();
}

#[test]
fn build_outside_a_project_fails_with_a_clear_message() {
    let dir = tempdir().unwrap();
    kite()
        .current_dir(dir.path())
        .arg("build")
        .assert()
        .failure()
        .stderr(contains("kite.toml"));
}

#[test]
fn build_and_run_hello_world_end_to_end() {
    if !Command::new("clang")
        .arg("--version")
        .output()
        .map(|o| o.status.success())
        .unwrap_or(false)
    {
        eprintln!("skipping: clang not found on PATH");
        return;
    }
    let dir = tempdir().unwrap();
    kite()
        .current_dir(dir.path())
        .args(["init", "hello"])
        .assert()
        .success();
    let project = dir.path().join("hello");

    kite().current_dir(&project).arg("build").assert().success();
    assert!(project.join("target/hello").is_file());

    kite()
        .current_dir(&project)
        .arg("run")
        .assert()
        .success()
        .stdout(contains("Hello, Kite!"));
}
