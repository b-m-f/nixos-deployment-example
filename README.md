# Example repo for Nix deployment setup

**WARNING: this is highly addictive Cyber gourmet stuff**

This repo sets up a single VPS that hosts a SSH, WireGuard and [Gitea](https://about.gitea.com/) server.
Only the SSH and WireGuard Ports are reachable from the Internet, the Gitea server is only reachable on the WireGuard network.

Depending on your skill the initial deployment can take up to 1 hour (install nix, install direnv, new SSH, new GPG key, new Hetzner Account) or just 5 minutes.
Subsequent deployments will be done in a single command.

Deployment is done with [colmena](https://github.com/zhaofengli/colmena).
Spawn a local environment easily with the provided `flake.nix` and `bootstrap/flake.nix` or by leveraging [direnv](https://direnv.net/) and the provided `.envrc`.

Encryption via [pass](https://www.passwordstore.org/).

# Steps
- Have [nix](https://nixos.org/) and direnv installed.
## Bootstrap
- Make sure to initialize the store with `pass init GPG_ID`. The store will be local in `secret_store`. This is set up in the `flake.nix` with an *ENV variable*.
- Go into bootstrap dir and set up your SSH key to use for the VPS in `main.tf`.
- Set your Hetzner API key in `bootstrap/flake.nix`
- Deploy VPS with `tofu plan` followed by `tofu apply`
- Save the printed *IPv6* address into `bootstrap/vps.nix` - see
  [below](#cloud-servers)
- Add your SSH public key into `bootstrap/vps.nix`
- Save the printed *IPv4* into `flake.nix` to tell colmena where to deploy to
- add an entry in your `~/.ssh/config` to allow colmena to connect to your VPS
  automatically

  ```
  #Example
  Host VPS_IPv4
    User root
    IdentityFile ~/.ssh/SSH_KEY
  ```

- Bootstrap the server with `nixos-anywhere -i PATH_TO_YOUR_SSH_KEY --flake .#vps root@VPS_IPv4`

The server is now up and running in its Barebones config -> SSH only.

## Generate WireGuard network
- Add the VPS *IPv4* in `wireguard.toml`
- Create WireGuard configurations with `wired -c wireguard.toml`

## Deploy final configuration

- Commit all your changes with git (`.gitignore` makes sure no secrets are
  commited)
- Deploy with `colmena apply` - the created WireGuard configs are already
  imported in `vps.nix`

## Test

- Use the provided `.conf` file or the QR code to connect to the WireGuard
  network and verify that you can see the gitea instance at `http://10.0.0.1`, but that you can not reach it via the VPS public IP.

- Done


# Changing things

If you want to play around with Nix on that VPS, simply use the `vps.nix` in the root as your playground.
Simply run `colmena apply` to deploy.

That configuration will always import the base setup from the bootstrap folder and the WireGuard network.

This way it will be easy to roll back to a clean state - just use git to go back to the commit you checked in earlier and deploy (Or remove the changes you do not like and redeploy).
Nix is just awesome for that easy rollback that keeps your system clean.

# Tools
## Cloud servers

Hetzners VPS follow: https://nix-community.github.io/srvos/installation/hetzner_cloud/.

They use https://github.com/nix-community/nixos-anywhere,
https://github.com/nix-community/disko, and
https://github.com/nix-community/srvos .

Before they can be managed they need to be bootstrapped for further use.
The configs for that are in the bootstrap folder

# Thanks

To everyone working on the projects involved. This mix has become such a timesaver in my life and 
I am very grateful for all the work and creativity that the developers and maintainers have poured into the Nix ecosystem.

Simply amazing.
