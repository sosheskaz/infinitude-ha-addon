variable "IMAGE_NAME" {
  default = "ghcr.io/sosheskaz/infinitude-ha-addon"
}

variable "VERSION" {
  default = "dev"
}

variable "REVISION" {
  default = "unknown"
}

variable "BUILD_DATE" {
  default = "unknown"
}

target "ci" {
  pull    = true
  context = "docker"
  args = {
    BUILD_DATE    = BUILD_DATE
    BUILD_REF     = REVISION
    BUILD_VERSION = VERSION
  }
  tags = ["infinitude-ha-addon:ci"]
}

target "release" {
  pull      = true
  platforms = ["linux/amd64", "linux/arm64"]
  context   = "docker"
  args = {
    BUILD_DATE    = BUILD_DATE
    BUILD_REF     = REVISION
    BUILD_VERSION = VERSION
  }
  tags = ["${IMAGE_NAME}:${VERSION}"]
}
