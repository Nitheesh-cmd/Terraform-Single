provider "vsphere" {
  user = "${var.username}"
  password = "${var.pass}"
  vsphere_server = "dummy.lab"
  version = "1.15"
  # If you have a self-signed cert
  allow_unverified_ssl = true

}

data "vsphere_datacenter" "dc" {
  name = "dummy"
}

data "vsphere_datastore_cluster" "datastore_cluster" {
  name          = "dummy"
  datacenter_id = "${data.vsphere_datacenter.dc.id}"
}

data "vsphere_datastore" "datastore" {
  name          = "dummy"
  datacenter_id = "${data.vsphere_datacenter.dc.id}"
}

data "vsphere_datastore" "iso_datastore" {
  name          = "ISO"
  datacenter_id = "${data.vsphere_datacenter.dc.id}"
}

data "vsphere_resource_pool" "pool" {
  name          = "dummy"
  datacenter_id = "${data.vsphere_datacenter.dc.id}"
}

data "vsphere_network" "network" {
  name          = "dummy"
  datacenter_id = "${data.vsphere_datacenter.dc.id}"
}

data "vsphere_virtual_machine" "template" {
  name          = "dummy"
  datacenter_id = "${data.vsphere_datacenter.dc.id}"
}

resource "vsphere_virtual_machine" "NewVM" {
  name                 = "dummy"
# hostname             = "dummy.dummy.lab"
  resource_pool_id     = "${data.vsphere_resource_pool.pool.id}"
# datastore_id        = data.vsphere_datastore.datastore.id
  datastore_cluster_id = "${data.vsphere_datastore_cluster.datastore_cluster.id}"
# resource_pool_id = data.vsphere_compute_cluster.cluster.resource_pool_id
  num_cpus             = 1
  memory               = 1024
  guest_id             = "${data.vsphere_virtual_machine.template.guest_id}"
  folder               = "dummy"
  annotation           = "dummy"
  scsi_type           = "${data.vsphere_virtual_machine.template.scsi_type}"
  
network_interface {
    network_id = "${data.vsphere_network.network.id}"
    #network_id = "${var.vlab_network_id}"
    adapter_type = "${data.vsphere_virtual_machine.template.network_interface_types[0]}"
  }

  disk {
    label            = "disk0"
    size             = "${data.vsphere_virtual_machine.template.disks.0.size}"
    eagerly_scrub    = "${data.vsphere_virtual_machine.template.disks.0.eagerly_scrub}"
    thin_provisioned = "${data.vsphere_virtual_machine.template.disks.0.thin_provisioned}"
  }

  clone {
    template_uuid = "${data.vsphere_virtual_machine.template.id}"

    customize {
      linux_options {
        host_name = "dummy"
        domain = "dummy.dummy.lab"                                                     # Define Time Zone
        time_zone = "Asia/Kolkata"
      }
      network_interface{}
	dns_suffix_list = ["dummy.lab"]
    }
  }
provisioner "remote-exec" {
    connection {
      host = "${self.default_ip_address}"
      type = "ssh"
      user = "root"
      password = "dummy"
      private_key = ""
      timeout = "3m"
    }

    inline = ["sudo hostnamectl set-hostname dummy.dummy.lab",
		"sudo reboot &"
]
}
} 
