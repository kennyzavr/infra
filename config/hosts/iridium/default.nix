{
  imports = [
    ./ssh.nix
    ./disk.nix
    ./boot.nix
    ./hardware.nix
    ./qemu.nix
  ];

  flake.alloyModules.infra =
    { config, ... }:
    {
      hosts.iridium = { config, ... }: {
        system = "x86_64-linux";
        stateVersion = "26.05";

        nets."public" = {
          primary = true;
        };

        overlays."main" = {
          wg.endpoint = config.nets."public".v4.advertiseAddress;
        };

        users."admin" = {
          isAdmin = true;
        };
      };
    };

  flake.alloyModules.infra-prod = { ... }: {
    hosts.iridium = { config, ... }: {
      nets."public" = {
        primary = true;
        managed = true;
        default = true;
        iface = "enp3s0";
        v4 = {
          mode.static = {
            address = "10.0.0.5";
            prefixLength = 24;
            gateway = "10.0.0.1";
          };
          advertiseAddress = "37.230.192.77";
        };
      };
    };
  };

  flake.alloyModules.infra-test =
    { lib, config, ... }:
    let
      alloy = config;
    in
    {
      hosts.iridium =
        { config, ... }:
        {
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
