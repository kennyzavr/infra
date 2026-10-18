{
  flake.alloyModules.infra =
    { config, ... }:
    {
      hosts.gallium = { ... }: { };
    };

  flake.alloyModules.infra-prod = { ... }: {
    hosts.gallium = { ... }: {
      nixosModule = { ... }: {
        boot.loader.grub = {
          enable = true;
          efiSupport = false;
        };
      };
    };
  };

  flake.alloyModules.infra-test = { ... }: {
    hosts.gallium = { ... }: { };
  };
}
