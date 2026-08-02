// Cloudflare Pages Function: GET /install[?os=linux|macos|windows]
//
// A single stable endpoint that serves the right install script as plain
// text, so it can be piped straight into a shell:
//
//   curl -fsSL https://kite-lang.pages.dev/install?os=macos | sh
//
// Without ?os=, it defaults to the Linux script (the common case for
// `curl | sh` one-liners). Windows users should use install.ps1 directly
// (curl/`irm` can't be told apart by User-Agent alone), but ?os=windows is
// still supported for scripted/CI use.
//
// The actual script bodies live as static files in this same Pages project
// (install.sh, install-macos.sh, install.ps1) -- this function just picks
// one and re-serves it with a plain-text content type and no caching, so
// editing those files always ships instantly without redeploying anything
// else.

const SCRIPTS = {
  linux: "/install.sh",
  macos: "/install-macos.sh",
  windows: "/install.ps1",
};

export async function onRequestGet({ request, env }) {
  const url = new URL(request.url);
  const os = (url.searchParams.get("os") || "linux").toLowerCase();
  const path = SCRIPTS[os];

  if (!path) {
    return new Response(`unknown os '${os}' -- expected one of: linux, macos, windows\n`, {
      status: 400,
      headers: { "content-type": "text/plain; charset=utf-8" },
    });
  }

  const assetUrl = new URL(path, url.origin);
  const response = await env.ASSETS.fetch(new Request(assetUrl, request));

  return new Response(response.body, {
    status: response.status,
    headers: {
      "content-type": "text/plain; charset=utf-8",
      "cache-control": "no-cache",
    },
  });
}
