# Changelog

## 2.0.0 (2026-09-23)

### Upgrading from v2025 releases

This release switches from date-based versions (`v2025.*`) to semantic versions (`v2.0.0`). Home Assistant may show **Update available** while the update dialog says **Up-to-date** and disables the update because its version comparison treats `v2025.*` as newer than `v2.0.0`.

To install the Stable Infinitude update, open **Settings → Tools → Actions**, choose **Install update**, and select the Stable Infinitude update entity. Find its exact entity ID under **Settings → Tools → States**. Set `backup: true` before running the action. After installation, confirm the Stable Infinitude add-on is running version `v2.0.0`.

See [Upgrading to v2.0.0](https://github.com/sosheskaz/infinitude-ha-addon#upgrading-to-v200) for the required YAML and supported architectures.

### ⚠ BREAKING CHANGES

* **runtime:** armv7 and i386 are no longer supported. Supported architectures are aarch64 and amd64.

### Features

* **mqtt:** add Home Assistant discovery ([8f49900](https://github.com/sosheskaz/infinitude-ha-addon/commit/8f499008b8385ed9d98771d275c0307d9ee3d46c))
* **runtime:** migrate to Infinitude 2026.9.0 on s6 ([4f01e06](https://github.com/sosheskaz/infinitude-ha-addon/commit/4f01e06a836ff56e72a7f36c457b00ad1a1b7649))


### Bug Fixes

* **mqtt:** reject unsupported TLS and MQTT 3.1 service details ([8f49900](https://github.com/sosheskaz/infinitude-ha-addon/commit/8f499008b8385ed9d98771d275c0307d9ee3d46c))
* **mqtt:** support anonymous Supervisor MQTT services ([8f49900](https://github.com/sosheskaz/infinitude-ha-addon/commit/8f499008b8385ed9d98771d275c0307d9ee3d46c))
* **runtime:** honor serial_socket configuration ([4f01e06](https://github.com/sosheskaz/infinitude-ha-addon/commit/4f01e06a836ff56e72a7f36c457b00ad1a1b7649))
