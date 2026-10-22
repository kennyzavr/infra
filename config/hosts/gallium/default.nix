{
  imports = [
    ./ssh.nix
    ./boot.nix
    ./disk.nix
    ./hardware.nix
    ./qemu.nix
  ];

  flake.alloyModules.infra = { ... }: {
    hosts.gallium = { config, ... }: {
      system = "x86_64-linux";
      stateVersion = "26.05";

      nets."public" = {
        primary = true;
        managed = true;
      };

      overlays."main" = {
        wg.endpoint = config.nets."public".v4.advertiseAddress;
      };

      users."admin" = {
        isAdmin = true;
      };
    };
  };

  flake.alloyModules.infra-prod =
    { lib, config, ... }:
    let
      alloy = config;
    in
    {
      hosts.gallium = { config, ... }: {
        nets."public" = {
          primary = true;
          default = true;
          iface = "ens3";
          v4 = {
            mode.static = {
              address = "144.31.103.78";
              prefixLength = 32;
              gateway = "10.0.0.1";
              gatewayOnLink = true;
            };
          };
        };

        deploy = {
          enable = true;
          activation.policy = "warn";
          defaultConnection = "ssh";
          connections.ssh = {
            address = config.nets."public".v4.advertiseAddress;
            port = 22;
            user = "admin";
          };
          signingKeys = [
            "silicium-builder-1"
          ];
        };
      };
    };

  flake.alloyModules.infra-test =
    { config, ... }:
    let
      alloy = config;
    in
    {
      hosts.gallium = { ... }: {
        workspace.secrets.age.keyPairs = [
          {
            identity = alloy.facts."test_ssh_key".path;
            recipient = alloy.facts."test_ssh_pub_key".path;
          }
        ];

        facts."test_ssh_key" = {
          permissions.mode = "0600";
        };

        boot.facts."test_ssh_key" = { };
      };
    };
}
