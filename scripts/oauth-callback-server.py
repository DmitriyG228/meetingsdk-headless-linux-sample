#!/usr/bin/env python3
"""One-off HTTP server to capture Zoom OAuth redirect and print the ?code=."""
import urllib.parse
from http.server import HTTPServer, BaseHTTPRequestHandler

CODE_FILE = "/tmp/zoom_oauth_code.txt"

class Handler(BaseHTTPRequestHandler):
    def do_GET(self):
        parsed = urllib.parse.urlparse(self.path)
        params = urllib.parse.parse_qs(parsed.query)
        code = params.get("code", [None])[0]
        if code:
            with open(CODE_FILE, "w") as f:
                f.write(code)
            self.send_response(200)
            self.send_header("Content-type", "text/html")
            self.end_headers()
            self.wfile.write(b"<h1>Authorization code received</h1><p>You can close this tab.</p>")
        else:
            self.send_response(400)
            self.end_headers()
        return
    def log_message(self, format, *args):
        pass

if __name__ == "__main__":
    server = HTTPServer(("127.0.0.1", 8080), Handler)
    server.handle_request()
