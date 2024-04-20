variable "VERSION" {
}

target "ci" {
  pull = true

  platforms = ["linux/amd64", "linux/arm64"]

  context = "docker"
}

target "infinitude" {
  pull = true

  platforms = ["linux/amd64", "linux/arm64"]

  context = "infinitude-src"

  tags = [
    "docker.io/sosheskaz/infinitude:${VERSION}",
  ]

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
