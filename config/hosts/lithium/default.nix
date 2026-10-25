{ inputs, ... }: {
  imports = [
    ./desktop.nix
    ./xray.nix
    ./qemu.nix
    ./disk.nix
    ./boot.nix
    ./hardware.nix
  ];

  flake.alloyModules.infra = { ... }: {
    hosts.lithium = {
      system = "x86_64-linux";
      stateVersion = "26.05";

      overlays."main" = { };

      users."kennyzavr" = {
        isAdmin = true;
      };
    };
  };

  flake.alloyModules.infra-prod = { lib, config, ... }: {
    imports = [
      inputs.alloy.alloyModules.disko
    ];

    hosts.lithium = { config, ... }: {
      ssh.keys."host" = { };

      workspace.secrets.age.keyPairs = [
        {
          identity = config.ssh.keys."host".path;
          recipient = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAINgzkaREqGKt8NFJNeNbEUF3fijtcGjARSOTB5r+cwf7";
        }
      ];

      qemu.memory = 8096;
      qemu.cores = 4;
      qemu.variant = "direct-boot";
      qemu.graphics = true;
    };
  };

  flake.alloyModules.infra-test =
    { config, ... }:
    let
      alloy = config;
    in
    {
      hosts.lithium =
        { ... }:
        {
          nets."public" = {
            primary = true;
            managed = true;
          };

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
