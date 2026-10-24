{
  flake.alloyModules.infra =
    { config, ... }:
    {
      hosts.lithium = { ... }: { };
    };

  flake.alloyModules.infra-prod = { ... }: {
    hosts.lithium = { ... }: {
      nixosModule = { ... }: {
        boot.loader.systemd-boot = {
          enable = true;
        };
      };
    };
  };

  flake.alloyModules.infra-test = { ... }: {
    hosts.lithium = { ... }: { };
  };
}
