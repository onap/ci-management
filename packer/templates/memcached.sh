{
  "variables": {
    "stack_tenant": null,
    "stack_user": null,
    "stack_pass": null,
    "stack_network": null,
    "base_image": null,
    "cloud_user": null,
    "distro": null,
    "cloud_user_data": null
  },
  "builders": [
    {
      "type": "openstack",
      "identity_endpoint": "https://auth.vexxhost.net/v2.0/",
      "tenant_name": "{{user `stack_tenant`}}",
      "username": "{{user `stack_user`}}",
      "password": "{{user `stack_pass`}}",
      "region": "ca-ymq-1",
      "ssh_username": "{{user `cloud_user`}}",
      "image_name": "{{user `distro`}} - memcached - {{isotime \"20060102-1504\"}}",
      "source_image_name": "{{user `base_image`}}",
      "flavor": "v1-standard-1",
      "availability_zone": "ca-ymq-2",
      "networks": [
        "{{user `stack_network`}}"
      ],
      "user_data_file": "{{user `cloud_user_data`}}"
    }
  ],
  "provisioners": [
    {
      "type": "shell",
      "inline": [
        "mkdir -p /tmp/packer"
      ]
    },
    {
      "type": "file",
      "source": "provision/basebuild/",
      "destination": "/tmp/packer"
    },
    {
      "type": "shell",
      "scripts": [
        "provision/baseline.sh",
        "provision/basebuild.sh",
        "provision/memcached.sh",
        "provision/system_reseal.sh"
      ],
      "execute_command": "chmod +x {{ .Path }}; if [ \"$UID\" == \"0\" ]; then {{ .Vars }} '{{ .Path }}'; else {{ .Vars }} sudo -E '{{ .Path }}'; fi"
    }
  ]
}
