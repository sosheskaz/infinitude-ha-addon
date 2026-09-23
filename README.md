# infinitude-ha-addon

This is a Home Assistant Addon implementation for [nebulous/infinitude](https://github.com/nebulous/infinitude).
It is not a part of the original project.

[![Open your Home Assistant instance and show the add add-on repository dialog with a specific repository URL pre-filled.](https://my.home-assistant.io/badges/supervisor_add_addon_repository.svg)](https://my.home-assistant.io/redirect/supervisor_add_addon_repository/?repository_url=https%3A%2F%2Fgithub.com%2Fsosheskaz%2Finfinitude-ha-addon)

This add-on follows upstream Infinitude through reviewed, digest-pinned updates. New releases are
built and verified before they can enter either channel:

- **Infinitude (Experimental)** receives a reviewed activation pull request after its release image
  is available for every supported architecture.
- **Infinitude** receives a separate draft promotion pull request after the Experimental version has
  had time to soak.

## Upgrading to v2.0.0 from v2025 releases

Version `v2.0.0` switches the add-on from date-based versions to semantic versioning and updates
upstream Infinitude to `2026.9.0`. It supports amd64 and aarch64; armv7 and i386 are no longer
supported. Check your Home Assistant host's architecture before upgrading.

Home Assistant may show **Update available** for an installed `v2025.*` add-on while its update
dialog says **Up-to-date** and disables the Update button. Home Assistant compares the old
date-based version as newer than `v2.0.0`. If this happens, use **Settings → Tools → Actions**, select
**Install update**, switch to YAML mode, and run:

```yaml
action: update.install
target:
  entity_id: update.infinitude_experimental_update
data:
  backup: true
```

The entity ID above is for Infinitude (Experimental). For the Stable add-on, use its own update
entity ID, which you can find under **Settings → Tools → States**. After the action completes,
confirm that the add-on's Info page shows `v2.0.0` and **Running**.

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

## MQTT / Home Assistant Discovery

Infinitude can publish thermostat entities through Home Assistant MQTT Discovery.

- **Automatic:** When a compatible Home Assistant MQTT service is available, the add-on uses its
  broker and credentials automatically. No MQTT options are required.
- **External broker:** Set `mqtt_broker` to `host:port`; add `mqtt_user` and `mqtt_pass` when the
  broker requires authentication. `mqtt_prefix` and `mqtt_topic` override Infinitude's discovery
  defaults.
- **Off:** When neither `mqtt_broker` nor a Home Assistant MQTT service is available, MQTT remains
  disabled.

TLS-enabled MQTT brokers are not currently supported.
