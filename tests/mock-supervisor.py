#!/usr/bin/env python3
import json
import os
from http.server import BaseHTTPRequestHandler, ThreadingHTTPServer


class Handler(BaseHTTPRequestHandler):
    def do_GET(self):  # noqa: N802 - BaseHTTPRequestHandler API
        if self.path == "/addons/self/options/config":
            with open("/fixtures/options.json", encoding="utf-8") as options_file:
                options = json.load(options_file)
            schema = self.addon_config().get("schema", {})
            unknown = sorted(set(options) - set(schema))
            if unknown:
                self.respond(
                    400,
                    {},
                    result="error",
                    message=f"options missing from schema: {', '.join(unknown)}",
                )
                return
            self.respond(200, options)
            return

        if self.path == "/services/mqtt":
            if "mqtt:want" not in self.addon_config().get("services", []):
                self.respond(
                    403,
                    {},
                    result="error",
                    message="mqtt service is not declared",
                )
                return
            service = os.environ.get("MQTT_SERVICE_JSON")
            if service:
                self.respond(200, json.loads(service))
            else:
                self.respond(404, {}, result="error")
            return

        self.respond(200, {})

    @staticmethod
    def addon_config():
        return json.loads(os.environ["ADDON_CONFIG_JSON"])

    def respond(self, status, data, result="ok", message=None):
        response = {"result": result, "data": data}
        if message:
            response["message"] = message
        body = json.dumps(response).encode()
        self.send_response(status)
        self.send_header("Content-Type", "application/json")
        self.send_header("Content-Length", str(len(body)))
        self.end_headers()
        self.wfile.write(body)

    def log_message(self, _format, *_args):
        return


ThreadingHTTPServer(("0.0.0.0", 80), Handler).serve_forever()
