# infinitude-ha-addon

This is a Home Assistant Addon implementation for [nebulous/infinitude](https://github.com/nebulous/infinitude).
It is not a part of the original project.

[![Open your Home Assistant instance and show the add add-on repository dialog with a specific repository URL pre-filled.](https://my.home-assistant.io/badges/supervisor_add_addon_repository.svg)](https://my.home-assistant.io/redirect/supervisor_add_addon_repository/?repository_url=https%3A%2F%2Fgithub.com%2Fsosheskaz%2Finfinitude-ha-addon)

This addon is rolling-release, and will track upstream infinitude.

## Caveats

Serial devices are not yet supported, as I do not have a serial device to test against.

## Usage

For common usage, leaving the defaults is generally fine. Once Infinitude is running, you will need
to configure your thermostat to use a HTTP proxy at `${home_assistant_ip}:34500`. Infinitude's UI
can be accessed at `http://${home_assistant_ip}:34500`.

Some of the options from infinitude are included in this add-on. Defaults are generally the same as
upstream. Configure those settings as appropriate for your installation. To enable extra logging,
set `mode` to `Development`.

This add-on exposes infinitude on a port (by default `34500`) on the home assistant machine.
Consider any network security implications there may be.
