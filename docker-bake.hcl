variable "VERSION" {
}

target "ci" {
  pull = true

  platforms = ["linux/amd64", "linux/arm64"]

  context = "docker"
}

target "release" {
  pull = true

  platforms = ["linux/amd64", "linux/arm64"]

  context {
    dockerfile = "Dockerfile"
  }

  tags = [
    "docker.io/sosheskaz/ha-infinitude:${VERSION}",
    // "docker.io/sosheskaz/ha-infinitude:latest"
  ]
}

target "latest" {
  extends = "release"
}
