{
  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";

    disko.url = "github:nix-community/disko";
    colmena.url = "github:zhaofengli/colmena";
    wired.url = "github:b-m-f/wired";
  };
  outputs =
    {
      nixpkgs,
      disko,
      colmena,
      wired,
      ...
    }:

    let
      system = "x86_64-linux";
      pkgs = import nixpkgs { inherit system; };
      wired-build = pkgs.rustPlatform.buildRustPackage {
        pname = "wired";
        version = "2.0.0";

        src = wired;

        cargoHash = "sha256-K8d/FbaDKBA20u9wFO+8JcW7B317zFcVuKvJWTtI82A=";

        meta = {
          description = "WireGuard configuration generator";
          homepage = "https://github.com/b-m-f/wired";
        };
      };

    in
    {
      devShells.x86_64-linux.default = pkgs.mkShell {
        packages = [
          colmena.packages.x86_64-linux.colmena
          wired-build
          pkgs.pass
          pkgs.wireguard-tools
        ];
        shellHook = ''
          export PASSWORD_STORE_DIR=./secret_store
        '';

      };
      colmena = {
        meta = {
          nixpkgs = import nixpkgs { system = "x86_64-linux"; };
        };
        defaults =
          { pkgs, ... }:
          {
            environment.systemPackages = with pkgs; [
              vim
              wget
              curl
            ];
          };

        vps =
          {
            name,
            nodes,
            pkgs,
            ...
          }:
          {
            nixpkgs.system = "x86_64-linux";
            deployment = {
              # TODO: update IPv4 here
              targetHost = "";
              targetPort = 22;
              targetUser = "root";
            };
            imports = [
              disko.nixosModules.disko
              ./vps.nix
            ];
          };
      };
    };
}
