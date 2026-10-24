{
  lib,
  self,
  inputs,
  ...
}:
let
  infraProd = inputs.alloy.lib.evalModule self.alloyModules.infra-prod;
in
{
  imports = [
    ./hosts
    ./services
    ./dns.nix
    ./qemu.nix
    ./overlay.nix
    ./users.nix
    ./tls.nix
  ];

  flake.alloyModules.infra =
    { lib, ... }:
    let
      hostSubmodule = {
        nixosModule = { pkgs, ... }: {
          nix.settings.experimental-features = [
            "flakes"
            "nix-command"
          ];

          environment.systemPackages = [
            pkgs.dig
            pkgs.tcpdump
            pkgs.helix
          ];
        };
      };
    in
    {
      options.hosts = lib.mkOption {
        type = lib.types.attrsOf (lib.types.submodule hostSubmodule);
      };

      config = {
        workspace = {
          root = "${self}";
        };
      };
    };

  flake.alloyCli.instances."infra-prod" = {
    runtimeInputs = { pkgs, ... }: [
      pkgs.age-plugin-yubikey
    ];
  };

  flake.nixosConfigurations = lib.mapAttrs' (
    hostName: host: lib.nameValuePair "infra-prod-${hostName}" host.nixosConfiguration
  ) infraProd.config.hosts;

  flake.alloyModules.infra-prod = { config, ... }: {
    imports = [
      self.alloyModules.infra
    ];

    name = "d108";

    workspace = {
      baseDir = "storage/prod";
      secrets.age.keyPairs = [
        {
          identity = self + "/storage/yubikey-1-identity.pub";
          recipient = "age1yubikey1q0y509tcp0nphlxmu3mdeeh82s7k2z9l22jajrqlp2k9uf222am66wgypp4";
        }
        {
          identity = self + "/storage/yubikey-2-identity.pub";
          recipient = "age1yubikey1qf748v8xqs53adt8ke3qvjmld0jhdhljd54f4gkl94wtt4njrfdjk8l43lp";
        }
      ];
    };

    facts."ssh/keys/yubikey_1.pub" = {
      file = "storage/yubikey-1-ed25519.pub";
    };
    facts."ssh/keys/yubikey_2.pub" = {
      file = "storage/yubikey-2-ed25519.pub";
    };

    deploy.signingKeys."silicium-builder-1" = { };
  };

  flake.alloyCli.instances."infra-test" = { };

  flake.alloyModules.infra-test =
    { lib, config, ... }:
    let
      alloy = config;
    in
    {
      imports = [
        self.alloyModules.infra
      ];

      name = "d108-test";

      workspace = {
        baseDir = "storage/test";
        secrets.age.keyPairs = [
          {
            identity = alloy.facts."test_ssh_key".path;
            recipient = alloy.facts."test_ssh_pub_key".path;
          }
        ];
      };

      facts = {
        "test_ssh_key" = {
          file = "storage/test-ed25519";
        };
        "test_ssh_pub_key" = {
          file = "storage/test-ed25519.pub";
        };
      };
    };
}
