variable "INFINITUDE_IMAGE_NAME" {
  default = "nebulous/infinitude:latest"
}

variable "IMAGE_NAME" {
  default = "infinitude_ha_addon"
}

variable "VERSION" {
  default = "latest"
}

target "ci" {
  args = {
    INFINITUDE_BASE = "${INFINITUDE_IMAGE_NAME}"
  }

  context = "docker"
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
