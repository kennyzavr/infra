{ self, ... }: {
  flake.alloyModules.infra = { ... }: {
    imports = [
      self.alloyModules.desktop
    ];

    hosts.silicium = { ... }: {
      desktop = {
        enable = true;
      };
    };
  };

  flake.alloyModules.infra-prod = { ... }: {
    hosts.silicium = { ... }: { };
  };

  flake.alloyModules.infra-test = { ... }: {
    hosts.silicium = { ... }: { };
  };
}
