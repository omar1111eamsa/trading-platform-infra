# SSH Key
resource "ovh_cloud_project_sshkey" "app_key" {
  service_name = var.ovh_service_name
  name         = "platform-key"
  public_key   = var.ssh_public_key
}

# VPS Instance
resource "ovh_cloud_project_instance" "app_vps" {
  service_name = var.ovh_service_name
  region       = var.region
  name         = var.vps_name

  flavor {
    flavor_id = data.ovh_cloud_project_flavor.flavor.id
  }

  image {
    image_id = data.ovh_cloud_project_image.image.id
  }

  ssh_key {
    name = ovh_cloud_project_sshkey.app_key.name
  }

  network {
    public = true
  }

  user_data = file("${path.module}/cloud-init.yaml")
}

# Lookup flavor
data "ovh_cloud_project_flavor" "flavor" {
  service_name = var.ovh_service_name
  region       = var.region
  name         = var.vps_flavor
}

# Lookup image
data "ovh_cloud_project_image" "image" {
  service_name = var.ovh_service_name
  region       = var.region
  name         = var.vps_image
}
