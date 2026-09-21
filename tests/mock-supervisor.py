#!/usr/bin/env python3
import json
import os
import re
from http.server import BaseHTTPRequestHandler, ThreadingHTTPServer


def validate_options(addon_config, supplied_options):
    schema = addon_config.get("schema", {})
    options = {}

    for key, value in supplied_options.items():
        if key not in schema:
            continue
        options[key] = validate_option(key, schema[key], value)

    for key, value_type in schema.items():
        if key not in options and not value_type.endswith("?"):
            raise ValueError(f"missing required option: {key}")

    return options


def validate_option(key, value_type, value):
    value_type = value_type.removesuffix("?")

    if value_type.startswith(("str", "password")):
        if not isinstance(value, str):
            raise ValueError(f"option {key} must be a string")
        return value

    if value_type.startswith("int"):
        try:
            value = int(value)
        except (TypeError, ValueError):
            raise ValueError(f"option {key} must be an integer") from None

        bounds = re.fullmatch(r"int\((-?\d*)?,(-?\d*)?\)", value_type)
        if bounds:
            minimum, maximum = bounds.groups()
            if minimum and value < int(minimum):
                raise ValueError(f"option {key} is below its minimum")
            if maximum and value > int(maximum):
                raise ValueError(f"option {key} is above its maximum")
        return value

    choices = re.fullmatch(r"list\((.+)\)", value_type)
    if choices and str(value) in choices.group(1).split("|"):
        return str(value)

    raise ValueError(f"option {key} has an invalid value")


class Handler(BaseHTTPRequestHandler):
    def do_GET(self):  # noqa: N802 - BaseHTTPRequestHandler API
        if self.path == "/addons/self/options/config":
            with open("/fixtures/options.json", encoding="utf-8") as options_file:
                options = json.load(options_file)
            try:
                options = validate_options(self.addon_config(), options)
            except ValueError as err:
                self.respond(
                    400,
                    {},
                    result="error",
                    message=str(err),
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


if __name__ == "__main__":
    ThreadingHTTPServer(("0.0.0.0", 80), Handler).serve_forever()
