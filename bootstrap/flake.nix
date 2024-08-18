{
  description = "Nix flake for infra deployment with terraform";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixpkgs-unstable";
    nixos-anywhere.url = "github:nix-community/nixos-anywhere";
    srvos.url = "github:nix-community/srvos";
    disko.url = "github:nix-community/disko";
  };

  outputs =
    {
      self,
      nixos-anywhere,
      nixpkgs,
      srvos,
      disko,
    }:

    let
      system = "x86_64-linux";
      pkgs = import nixpkgs { inherit system; };

      #TODO: Add hetzner API token here
      hcloud_token = "";

      tofu = pkgs.writers.writeBashBin "tofu" ''
        export HCLOUD_TOKEN=${hcloud_token}
        ${pkgs.opentofu}/bin/tofu "$@"
      '';
    in
    {
      devShells.x86_64-linux.default = pkgs.mkShell {
        system = "x86_64-linux";
        buildInputs = [ tofu ];
        packages = [ nixos-anywhere.packages.x86_64-linux.default ];

      };
      nixosConfigurations.vps = nixpkgs.lib.nixosSystem {
        system = "x86_64-linux";
        modules = [
          srvos.nixosModules.hardware-hetzner-cloud
          srvos.nixosModules.server
          disko.nixosModules.disko

          ./vps.nix
        ];
      };
    };
}
