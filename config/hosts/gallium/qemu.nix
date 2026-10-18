{
  flake.alloyModules.infra = { ... }: {
    hosts.gallium = { ... }: { };
  };

  flake.alloyModules.infra-prod = { ... }: {
    hosts.gallium = { ... }: { };
  };

  flake.alloyModules.infra-test = { ... }: {
    hosts.gallium = { config, ... }: {
      qemu.nets."main" = { };

      qemu.memory = 4096;
      qemu.cores = 4;
      qemu.variant = "direct-boot";

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
