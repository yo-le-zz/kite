mod styles;

use console::Term;

pub fn clear() {
    let term = Term::stdout();
    let _ = term.clear_screen();
}

pub fn compiling(name: &str, version: &str) {
    println!(
        "{} {} {}",
        styles::cyan().apply_to("Compiling"),
        name,
        styles::dim().apply_to(format!("v{}", version))
    );
}

pub fn success(message: &str) {
    println!(
        "{} {}",
        styles::green().apply_to("✓"),
        message
    );
}

pub fn info(message: &str) {
    println!(
        "{} {}",
        styles::cyan().apply_to("→"),
        message
    );
}

pub fn error(message: &str) {
    eprintln!(
        "{} {}",
        styles::red().apply_to("error:"),
        message
    );
}