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
    hosts.lithium = { config, ... }: {
      qemu.nets."main" = { };
      qemu.memory = 8096;
      qemu.cores = 4;
      qemu.variant = "direct-boot";
      qemu.graphics = true;

      nets."slipr" = {
        default = true;
        managed = true;
        iface = "eth0";
        v4.mode.static = {
          address = "10.0.2.15";
          prefixLength = 24;
          gateway = "10.0.2.2";
        };
      };

      nets."public" = {
        managed = true;
        iface = config.qemu.nets."main".iface;
        v4.mode.static = {
          address = "192.168.100.${toString config.idx}";
          prefixLength = 24;
        };
      };
    };
  };
}
