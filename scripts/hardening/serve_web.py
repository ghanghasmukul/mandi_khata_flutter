#!/usr/bin/env python3
"""Serves a built web bundle the way Cloudflare Pages will: the headers from
web/_headers (COOP / COEP for the PowerSync WASM worker) and the SPA fallback
from web/_redirects. Local check only.

    flutter build web --release --dart-define-from-file=.env.dev
    python3 scripts/hardening/serve_web.py apps/mandi_khata_app/build/web 8099
"""
import http.server
import os
import sys

root = os.path.abspath(sys.argv[1] if len(sys.argv) > 1 else "build/web")
port = int(sys.argv[2]) if len(sys.argv) > 2 else 8099


class Handler(http.server.SimpleHTTPRequestHandler):
    extensions_map = {
        **http.server.SimpleHTTPRequestHandler.extensions_map,
        ".wasm": "application/wasm",
        ".js": "text/javascript",
        ".mjs": "text/javascript",
    }

    def __init__(self, *args, **kwargs):
        super().__init__(*args, directory=root, **kwargs)

    def translate_path(self, path):
        real = super().translate_path(path)
        # SPA fallback: unknown paths without a file extension get index.html.
        if not os.path.exists(real) and "." not in os.path.basename(real):
            return os.path.join(root, "index.html")
        return real

    def end_headers(self):
        self.send_header("Cross-Origin-Opener-Policy", "same-origin")
        self.send_header("Cross-Origin-Embedder-Policy", "credentialless")
        self.send_header("Cache-Control", "no-cache")
        super().end_headers()


print(f"Serving {root} on http://localhost:{port} (COOP/COEP + SPA fallback)")
http.server.ThreadingHTTPServer(("127.0.0.1", port), Handler).serve_forever()
