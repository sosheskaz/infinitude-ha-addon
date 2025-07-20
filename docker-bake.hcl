variable "IMAGE_NAME" {
  default = "infinitude_ha_addon"
}

variable "VERSION" {
}

target "ci" {
  pull = true
}

target "release" {
  pull = true

  platforms = ["linux/amd64", "linux/arm64"]

  tags = [
    "${IMAGE_NAME}:${VERSION}",
  ]
}
