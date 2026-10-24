{ self, ... }: {
  flake.alloyModules.infra = { ... }: {
    imports = [
      self.alloyModules.desktop
    ];

    hosts.lithium = { ... }: {
      desktop = {
        enable = true;
      };
    };
  };

  flake.alloyModules.infra-prod = { ... }: {
    hosts.lithium = { ... }: { };
  };

  flake.alloyModules.infra-test = { ... }: {
    hosts.lithium = { ... }: { };
  };
}
