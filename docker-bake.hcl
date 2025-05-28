variable "INFINITUDE_IMAGE_NAME" {
  default = "nebulous/infinitude:latest"
}

variable "IMAGE_NAME" {
  default = "infinitude_ha_addon"
}

variable "VERSION" {
}

target "ci" {
  args = {
    INFINITUDE_BASE = "${INFINITUDE_IMAGE_NAME}"
  }

  context = "docker"
}

target "infinitude-base" {
  pull = true

  platforms = ["linux/amd64", "linux/arm64"]

  context = "infinitude-src"

  args = {
    BASE_IMAGE = "ghcr.io/hassio-addons/debian-base:stable"
  }

  tags = [
    "${INFINITUDE_IMAGE_NAME}",
  ]

}

target "release" {
  platforms = ["linux/amd64", "linux/arm64"]

  args = {
    INFINITUDE_BASE = "${INFINITUDE_IMAGE_NAME}"
  }

  context = "docker"

  tags = [
    "${IMAGE_NAME}:${VERSION}",
  ]
}
