# infinitude-ha-addon

This is a Home Assistant Addon implementation for [nebulous/infinitude](https://github.com/nebulous/infinitude).
It is not a part of the original project.

[![Open your Home Assistant instance and show the add add-on repository dialog with a specific repository URL pre-filled.](https://my.home-assistant.io/badges/supervisor_add_addon_repository.svg)](https://my.home-assistant.io/redirect/supervisor_add_addon_repository/?repository_url=https%3A%2F%2Fgithub.com%2Fsosheskaz%2Finfinitude-ha-addon)

## Caveats

Serial devices are not yet supported, as I do not have a serial device to test against.

This addon is in early/immature stages and does not have a clean release lifecycle yet.

## Usage

Some of the options from infinitude are included in this add-on. Configure those settings as
appropriate for your installation.

This addon works by building an image with `docker.io/nebulous/infinitude:latest` as a base. Because
of this, you may want to `Rebuild` occasionally to pull new changes. It is recommended to back up
before rebuilding.

This exposes infinitude on a port (by default `34500`) on the home assistant machine. Consider any
network security implications there may be.
