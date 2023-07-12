packer {
  required_plugins {
    openstack = {
      version = ">= 1.0.0"
      source  = "github.com/hashicorp/openstack"
    }
  }
}

variable "cloud_auth_url" {
  type    = string
  default = null
}

variable "cloud_tenant" {
  type    = string
  default = null
}

variable "cloud_user" {
  type    = string
  default = null
}

variable "cloud_pass" {
  type    = string
  default = null
}

variable "source_ami_filter_name" {
  type    = string
  default = null
}

variable "source_ami_filter_product_code" {
  type    = string
  default = null
}

variable "source_ami_filter_owner" {
  type    = string
  default = null
}

variable "ansible_roles_path" {
  type    = string
  default = ".galaxy"
}

variable "arch" {
  type    = string
  default = "x86_64"
}

variable "base_image" {
  type = string
  default = null
}

variable "cloud_network" {
  type = string
  default = null
}

variable "cloud_region" {
  type    = string
  default = "ca-ymq-1"
}

variable "cloud_user_data" {
  type = string
  default = null
}

variable "distro" {
  type = string
  default = null
}

variable "docker_source_image" {
  type = string
  default = null
}

variable "flavor" {
  type    = string
  default = "v2-highcpu-1"
}

variable "ssh_proxy_host" {
  type    = string
  default = ""
}

variable "ssh_user" {
  type = string
  default = null
}

variable "vm_image_disk_format" {
  type    = string
  default = ""
}

variable "vm_use_block_storage" {
  type    = string
  default = "true"
}

variable "vm_volume_size" {
  type    = string
  default = "20"
}

source "docker" "redis" {
  changes = ["ENTRYPOINT [\"\"]", "CMD [\"\"]"]
  commit  = true
  image   = "${var.docker_source_image}"
}

source "openstack" "redis" {
  domain_name       = "Default"
  flavor            = "v1-standard-1"
  identity_endpoint = "${var.cloud_auth_url}"
  image_name        = "${var.distro} - redis - ${var.arch} - ${legacy_isotime("20180101-1003")}"
  metadata = {
    ci_managed = "yes"
  }
  networks          = ["${var.cloud_network}"]
  password          = "${var.cloud_pass}"
  region            = "ca-ymq-1"
  source_image_name = "${var.base_image}"
  ssh_proxy_host    = "${var.ssh_proxy_host}"
  ssh_username      = "${var.ssh_user}"
  tenant_name       = "${var.cloud_tenant}"
  user_data_file    = "${var.cloud_user_data}"
  username          = "${var.cloud_user}"
}

build {
  sources = ["source.docker.redis", "source.openstack.redis"]

  provisioner "shell" {
    execute_command = "chmod +x {{ .Path }}; if [ \"$UID\" == \"0\" ]; then {{ .Vars }} '{{ .Path }}'; else {{ .Vars }} sudo -E '{{ .Path }}'; fi"
    scripts         = ["common-packer/provision/install-python.sh"]
  }

  provisioner "shell-local" {
    command = "./common-packer/ansible-galaxy.sh ${var.ansible_roles_path}"
  }

  provisioner "ansible" {
    ansible_env_vars   = [
      "ANSIBLE_NOCOWS=1",
      "ANSIBLE_PIPELINING=True",
      "ANSIBLE_ROLES_PATH=${var.ansible_roles_path}",
      "ANSIBLE_CALLBACK_WHITELIST=profile_tasks",
      "ANSIBLE_STDOUT_CALLBACK=debug"
    ]
    command            = "./common-packer/ansible-playbook.sh"
    extra_arguments    = [
      "--scp-extra-args", "'-O'",
      "--ssh-extra-args", "-o IdentitiesOnly=yes -o HostKeyAlgorithms=+ssh-rsa -o PubkeyAcceptedAlgorithms=+ssh-rsa"
    ]
    playbook_file      = "provision/redis.yaml"
    skip_version_check = true
  }
}
