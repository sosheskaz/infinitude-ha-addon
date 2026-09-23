# Changelog

## 2.0.0 (2026-09-23)

### Upgrading from v2025 releases

This release switches the add-on from date-based versions to semantic versioning. Home Assistant
may show **Update available** but disable the Update button because it compares `v2025.*` as newer
than `v2.0.0`. If that happens, go to **Settings → Tools → Actions** and run **Install update** for
`update.infinitude_experimental_update` with `backup: true`. Confirm the add-on shows `v2.0.0` and
**Running** afterward. See the [upgrade guide](https://github.com/sosheskaz/infinitude-ha-addon#upgrading-to-v200)
for the exact action YAML and architecture requirements.


### ⚠ BREAKING CHANGES

* **runtime:** armv7 and i386 are no longer supported. Supported architectures are aarch64 and amd64.

### Features

* **mqtt:** add Home Assistant discovery ([8f49900](https://github.com/sosheskaz/infinitude-ha-addon/commit/8f499008b8385ed9d98771d275c0307d9ee3d46c))
* **runtime:** migrate to Infinitude 2026.9.0 on s6 ([4f01e06](https://github.com/sosheskaz/infinitude-ha-addon/commit/4f01e06a836ff56e72a7f36c457b00ad1a1b7649))


### Bug Fixes

* **mqtt:** reject unsupported TLS and MQTT 3.1 service details ([8f49900](https://github.com/sosheskaz/infinitude-ha-addon/commit/8f499008b8385ed9d98771d275c0307d9ee3d46c))
* **mqtt:** support anonymous Supervisor MQTT services ([8f49900](https://github.com/sosheskaz/infinitude-ha-addon/commit/8f499008b8385ed9d98771d275c0307d9ee3d46c))
* **runtime:** honor serial_socket configuration ([4f01e06](https://github.com/sosheskaz/infinitude-ha-addon/commit/4f01e06a836ff56e72a7f36c457b00ad1a1b7649))
