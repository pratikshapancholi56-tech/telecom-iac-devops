terraform {
  required_providers {
    docker = {
      source  = "kreuzwerker/docker"
      version = "~> 3.0"
    }
  }
}

provider "docker" {
  host = "unix:///var/run/docker.sock"
}

# Build the Docker image
resource "docker_image" "telecom_app" {
  name = "telecom-app:latest"
  build {
    context    = "../docker"
    dockerfile = "Dockerfile"
    tag        = ["telecom-app:latest"]
  }
}

# Create the container
resource "docker_container" "telecom_container" {
  name  = "telepay-terraform"
  image = docker_image.telecom_app.image_id
  
  ports {
    internal = 5000
    external = 8080
  }
  
  restart = "unless-stopped"
  
  healthcheck {
    test     = ["CMD", "curl", "-f", "http://localhost:5000"]
    interval = "30s"
    timeout  = "10s"
    retries  = 3
  }
}

# Output the application URL
output "application_url" {
  description = "URL to access the TelePay application"
  value       = "http://localhost:8080"
}

output "container_id" {
  description = "Docker container ID"
  value       = docker_container.telecom_container.id
}

output "container_name" {
  description = "Docker container name"
  value       = docker_container.telecom_container.name
}
