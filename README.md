# Kite distribution kit

Tout ce qu'il faut pour distribuer `kite` : installateur GUI, scripts en
ligne de commande, et site web d'installation pour Cloudflare Pages.

**Hypothèse à vérifier** : tous les fichiers ci-dessous supposent que le
dépôt GitHub est `yo-le-zz/Kite` (constante `REPO` répétée dans chaque
fichier). Si ce n'est pas le bon nom, remplace `yo-le-zz/Kite` partout où
il apparaît (`grep -rn "yo-le-zz/Kite" .`) :
- `installer/src/net.rs` (constante `REPO`)
- `scripts/install.sh`, `scripts/install-macos.sh` (`KITE_REPO` par défaut)
- `scripts/install.ps1` (`$Repo` par défaut)
- `website/index.html` (lien "Releases GitHub")

## Arborescence

```
installer/          Installateur GUI (Rust + iced), copie enrichie de celui fourni
  Cargo.toml         + ureq/tar/flate2/zip pour télécharger et extraire la vraie release
  src/main.rs         Assistant en 4 étapes : Bienvenue → Options → Progression → Terminé
  src/net.rs          Résout la dernière release GitHub, télécharge l'asset pour l'OS/arch
  src/archive.rs       Extrait le binaire kite d'un .tar.gz ou .zip
  build.sh             Cross-compile l'installateur (11 cibles), package .tar.gz/.zip/.deb
  assets/              Logos/icônes (inchangés)

scripts/             Scripts d'installation en une commande
  install.sh           Linux : curl -fsSL .../install.sh | sh
  install-macos.sh      macOS : gère aussi la quarantaine Gatekeeper
  install.ps1            Windows : irm .../install.ps1 | iex

website/             Site statique à déployer sur Cloudflare Pages
  index.html, style.css, script.js   Page avec onglets Windows/Linux/macOS + commande à copier
  install.sh / install-macos.sh / install.ps1   copies statiques, servies telles quelles
  functions/install.js                Endpoint dynamique GET /install?os=... (Pages Function)
```

## Vérifications déjà faites ici

- `bash -n` / `dash -n` sur tous les `.sh` → syntaxe OK.
- `node --check` sur `script.js` et `functions/install.js` → syntaxe OK.
- Pas de toolchain Rust dans cet environnement, donc **`installer/` n'a
  pas été compilé de mon côté** — un build réel chez toi a confirmé que
  8/10 cibles passent, avec deux limites structurelles (voir ci-dessous).
  Point encore à surveiller si `iced` râle : les appels
  `.center_x(Length::Fill)` / `.center_y(Length::Fill)` sur
  `container(...)` dans `src/main.rs` (`view_welcome`, `view_progress`,
  `view_done`) — si ta version d'iced 0.13 n'a pas cette méthode avec cet
  argument, remplace par `.width(Length::Fill).height(Length::Fill)`.

## Limites connues de `installer/build.sh` (pas réparables depuis le script)

- **macOS (`macos-x64`, `macos-arm64`)** : `cargo-zigbuild`/`zig` ne peuvent
  pas linker `AppKit`/`Metal`/le runtime Objective-C (`libobjc`) — ce sont
  des bibliothèques propriétaires Apple que zig n'embarque pas légalement.
  Ça fonctionne pour `kite` (CLI pur, aucune dépendance GUI) mais pas pour
  cet installateur GUI. **Solution : `.github/workflows/build-installer-macos.yml`**,
  qui build sur de vrais runners `macos-13`/`macos-14` GitHub Actions et
  produit les mêmes noms de fichiers que `build.sh` (`kite-installer-<version>-macos-<arch>.tar.gz`).
  Déclenche-le manuellement (onglet Actions) ou en poussant un tag `v*`.
- **`windows-arm64` (MSVC)** : retiré de la matrice de `installer/build.sh`.
  `ring` (tiré par `ureq`→`rustls` pour le téléchargement HTTPS) casse sous
  `cargo-xwin` pour cette cible précise (bug d'interaction clang-cl/`/imsvc`,
  pas un problème de config). `kite`'s propre `build.sh` n'a pas ce souci
  (pas de dépendance `ureq`) et build `windows-arm64` normalement. Pour
  l'installateur sur cette cible, il faut soit une vraie machine
  Windows-on-ARM avec MSVC, soit attendre un correctif upstream de
  `cargo-xwin`/`ring`.


## Comment ça s'articule

1. `kite`'s propre `build.sh` (déjà livré précédemment) publie
   `kite-<version>-<os>-<arch>.tar.gz/.zip` et `kite_<version>_<arch>.deb`
   comme assets de la release GitHub.
2. `installer/` (le GUI) et `scripts/*.sh|ps1` téléchargent ces mêmes
   assets par leur nom exact — aucun changement de convention de nommage
   entre les deux `build.sh`.
3. `website/` affiche la commande à copier selon l'OS, et sert aussi les
   scripts bruts en statique (+ un endpoint `/install?os=...` qui fait la
   même chose dynamiquement).

## Déployer le site sur Cloudflare Pages

1. Pousse le dossier `website/` (tel quel, à la racine du dépôt Pages) sur
   GitHub, ou utilise `wrangler pages deploy website/`.
2. Aucune configuration de build n'est nécessaire (site 100% statique +
   une Function) — output directory = `website/`.
3. Une fois déployé, remplace les URLs `https://kite-lang.pages.dev/...`
   dans `index.html`, `script.js` et les 3 scripts par ton domaine réel
   si différent.
