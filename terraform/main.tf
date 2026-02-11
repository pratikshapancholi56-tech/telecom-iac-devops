terraform {
  required_providers {
    docker = {
      source  = "kreuzwerker/docker"
      version = "~> 3.0"
    }
  }
}

provider "docker" {}

resource "docker_image" "telecom" {
  name = "telecom-app"
}

resource "docker_container" "telecom_container" {
  name  = "telecom"
  image = docker_image.telecom.name
  ports {
    internal = 5000
    external = 5000
  }
}
