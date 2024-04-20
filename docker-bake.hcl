variable "INFINITUDE_IMAGE_NAME" {
  default = "infinitude-ha-addon"
}

variable "IMAGE_NAME" {
  default = "infinitude_ha_addon"
}

variable "VERSION" {
}

target "ci" {
  pull = true

  platforms = ["linux/amd64", "linux/arm64"]

  context = "docker"
}

target "infinitude-base" {
  pull = true

  platforms = ["linux/amd64", "linux/arm64"]

  context = "infinitude-src"

  tags = [
    "${INFINITUDE_IMAGE_NAME}",
  ]

}

target "release" {
  pull = true

  platforms = ["linux/amd64", "linux/arm64"]

  args = {
    INFINITUDE_BASE = "${INFINITUDE_IMAGE_NAME}"
  }

  context = "docker"

  tags = [
    "${IMAGE_NAME}:${VERSION}",
  ]
}
