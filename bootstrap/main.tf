# Server on Hetzner
resource "hcloud_ssh_key" "default" {
  name       = "Deploy key colmena-test"
  #TODO: Change to path of your ssh key
  public_key = file("~/.ssh/ssh-key.pub")
}

resource "hcloud_server" "vps" {
  name        = "nix-deploy-example"
  image       = "debian-12"
  server_type = "cx22"
  backups     = false
  public_net {
    ipv4_enabled = true
    ipv6_enabled = true
  }
  ssh_keys  = [hcloud_ssh_key.default.id]
}

output "vps-v4" {
    value = hcloud_server.vps.ipv4_address
  
}

output "vps-v6" {
    value = format("%s/128",hcloud_server.vps.ipv6_address)
}

output "ssh-public-key" {
    value = hcloud_ssh_key.default.public_key
}
