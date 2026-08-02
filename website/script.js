(() => {
  const COMMANDS = {
    linux: {
      title: "linux — sh",
      command: "curl -fsSL https://kite-lang.pages.dev/install.sh | sh",
      hint: 'Installe dans <code>~/.local/bin</code>. Nécessite <code>curl</code> et <code>tar</code>.',
    },
    macos: {
      title: "macos — sh",
      command: "curl -fsSL https://kite-lang.pages.dev/install-macos.sh | sh",
      hint: 'Installe dans <code>~/.local/bin</code>. Lève automatiquement la quarantaine Gatekeeper.',
    },
    windows: {
      title: "windows — powershell",
      command: "irm https://kite-lang.pages.dev/install.ps1 | iex",
      hint: 'Installe dans <code>%LOCALAPPDATA%\\Kite\\bin</code> et l\u2019ajoute au PATH utilisateur.',
    },
  };

  const tabs = document.querySelectorAll(".tab");
  const commandEl = document.getElementById("command");
  const titleEl = document.getElementById("terminal-title");
  const hintEl = document.getElementById("hint");
  const copyBtn = document.getElementById("copy-btn");

  function detectOS() {
    const ua = navigator.userAgent || "";
    const platform = navigator.platform || "";
    if (/Win/i.test(platform) || /Windows/i.test(ua)) return "windows";
    if (/Mac/i.test(platform) || /Macintosh/i.test(ua)) return "macos";
    return "linux";
  }

  function selectOS(os) {
    const entry = COMMANDS[os] || COMMANDS.linux;
    commandEl.textContent = entry.command;
    titleEl.textContent = entry.title;
    hintEl.innerHTML = entry.hint;
    tabs.forEach((tab) => {
      tab.setAttribute("aria-selected", String(tab.dataset.os === os));
    });
  }

  tabs.forEach((tab) => {
    tab.addEventListener("click", () => selectOS(tab.dataset.os));
  });

  copyBtn.addEventListener("click", async () => {
    try {
      await navigator.clipboard.writeText(commandEl.textContent);
    } catch {
      const range = document.createRange();
      range.selectNode(commandEl);
      window.getSelection().removeAllRanges();
      window.getSelection().addRange(range);
      document.execCommand("copy");
      window.getSelection().removeAllRanges();
    }
    copyBtn.textContent = "Copié";
    copyBtn.classList.add("copied");
    setTimeout(() => {
      copyBtn.textContent = "Copier";
      copyBtn.classList.remove("copied");
    }, 1600);
  });

  selectOS(detectOS());
})();
