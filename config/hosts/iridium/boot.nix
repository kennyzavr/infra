{
  flake.alloyModules.infra =
    { config, ... }:
    {
      hosts.iridium = { ... }: { };
    };

  flake.alloyModules.infra-prod = { ... }: {
    hosts.iridium = { ... }: {
      nixosModule = { ... }: {
        boot.loader.grub = {
          enable = true;
          efiSupport = false;
        };
      };
    };
  };

  flake.alloyModules.infra-test = { ... }: {
    hosts.iridium = { ... }: { };
  };
}
