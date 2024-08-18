{
  modulesPath,
  lib,
  pkgs,
  ...
}:
{
  imports = [
    ./bootstrap/vps.nix
    ./wired/example/server.nix
  ];
  networking.firewall.allowedTCPPorts = [ 80 ];
  services.gitea.enable = true;
  services.gitea.settings.server.HTTP_ADDR = "127.0.0.1";
  services.gitea.settings.server.HTTP_PORT = 8080;
  services.nginx = {
    enable = true;
    recommendedProxySettings = true;
    virtualHosts."10.0.0.1" = {
      listen = [
        {
          addr = "10.0.0.1";
          port = 80;
        }
      ];
      enableACME = false;
      forceSSL = false;
      locations."/" = {
        proxyPass = "http://127.0.0.1:8080";
      };
    };
  };

}
