import importlib.util
from pathlib import Path
import unittest


MODULE_PATH = Path(__file__).with_name("mock-supervisor.py")
SPEC = importlib.util.spec_from_file_location("mock_supervisor", MODULE_PATH)
mock_supervisor = importlib.util.module_from_spec(SPEC)
SPEC.loader.exec_module(mock_supervisor)


class ValidateOptionsTest(unittest.TestCase):
    config = {
        "schema": {
            "name": "str",
            "count": "int(0,)",
            "mode": "list(Development|Production)",
            "password": "password?",
        }
    }

    def test_drops_unknown_options_and_coerces_values(self):
        self.assertEqual(
            {
                "name": "Infinitude",
                "count": 3,
                "mode": "Production",
            },
            mock_supervisor.validate_options(
                self.config,
                {
                    "name": "Infinitude",
                    "count": "3",
                    "mode": "Production",
                    "unknown": "ignored",
                },
            ),
        )

    def test_rejects_missing_required_option(self):
        with self.assertRaisesRegex(ValueError, "missing required option: count"):
            mock_supervisor.validate_options(
                self.config,
                {"name": "Infinitude", "mode": "Production"},
            )

    def test_rejects_invalid_option_values(self):
        for key, value in (("count", -1), ("mode", "Unsupported")):
            with self.subTest(key=key), self.assertRaises(ValueError):
                options = {
                    "name": "Infinitude",
                    "count": 1,
                    "mode": "Production",
                }
                options[key] = value
                mock_supervisor.validate_options(self.config, options)


if __name__ == "__main__":
    unittest.main()
