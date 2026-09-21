#!/usr/bin/env python3
import json
import os
from http.server import BaseHTTPRequestHandler, ThreadingHTTPServer


class Handler(BaseHTTPRequestHandler):
    def do_GET(self):  # noqa: N802 - BaseHTTPRequestHandler API
        if self.path == "/addons/self/options/config":
            with open("/fixtures/options.json", encoding="utf-8") as options_file:
                self.respond(200, json.load(options_file))
            return

        if self.path == "/services/mqtt":
            service = os.environ.get("MQTT_SERVICE_JSON")
            if service:
                self.respond(200, json.loads(service))
            else:
                self.respond(404, {}, result="error")
            return

        self.respond(200, {})

    def respond(self, status, data, result="ok"):
        body = json.dumps({"result": result, "data": data}).encode()
        self.send_response(status)
        self.send_header("Content-Type", "application/json")
        self.send_header("Content-Length", str(len(body)))
        self.end_headers()
        self.wfile.write(body)

    def log_message(self, _format, *_args):
        return


ThreadingHTTPServer(("0.0.0.0", 80), Handler).serve_forever()
