{ lib, inputs, ... }: {
  flake.alloyModules.infra =
    { config, ... }:
    {
      hosts.silicium = { ... }: { };
    };

  flake.alloyModules.infra-prod = { ... }: {
    hosts.silicium = { ... }: {
      nixosModule = { pkgs, ... }: {
        imports = [
          inputs.lanzaboote.nixosModules.lanzaboote
        ];

        environment.systemPackages = [
          pkgs.sbctl
        ];

        boot.loader.systemd-boot.enable = lib.mkForce false;

        boot.lanzaboote = {
          enable = true;
          pkiBundle = "/var/lib/sbctl";
          autoGenerateKeys.enable = true;
          autoEnrollKeys = {
            enable = true;
            autoReboot = true;
          };
        };
      };
    };
  };

  flake.alloyModules.infra-test = { ... }: {
    hosts.silicium = { ... }: { };
  };
}
