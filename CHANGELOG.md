# Changelog

## Unreleased

## 24.22.23

This release is focused on operational improvements to make this add-on maintainable in the logner
term. It is the first supportable release.

* Build images based on infinitude and upload them to GHCR, so HA instances do not have to build their own image.
* Use idempotent versions so upgrades can be pushed to HA instances.
* Switch images to use the official HA addon base image.
* Automate the process of updating source code in future.
* Automate the process of building new images on release.
* Automate the process of promoting images from experimental to stable.
