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

        boot.initrd.systemd.enable = true;

        boot.loader.systemd-boot.enable = lib.mkForce false;

        boot.lanzaboote = {
          enable = true;
          configurationLimit = 4;
          pkiBundle = "/var/lib/sbctl";
          autoGenerateKeys.enable = true;
          autoEnrollKeys = {
            enable = true;
            autoReboot = true;
          };
          measuredBoot = {
            enable = true;
            pcrs = [
              0
              4
              7
            ];
          };
        };
      };
    };
  };

  flake.alloyModules.infra-test = { ... }: {
    hosts.silicium = { ... }: { };
  };
}
