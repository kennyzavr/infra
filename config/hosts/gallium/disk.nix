{
  flake.alloyModules.infra =
    { config, ... }:
    {
      hosts.gallium = { ... }: { };
    };

  flake.alloyModules.infra-prod = { ... }: {
    hosts.gallium = {
      disko = {
        enable = true;
        settings = { ... }: {
          devices.disk.main = {
            type = "disk";
            device = "/dev/vda";
            content = {
              type = "gpt";
              partitions = {
                bios = {
                  size = "1M";
                  type = "EF02";
                };
                boot = {
                  size = "512M";
                  type = "8300";
                  content = {
                    type = "filesystem";
                    format = "ext4";
                    mountpoint = "/boot";
                  };
                };
                root = {
                  size = "100%";
                  content = {
                    type = "luks";
                    name = "cryptroot";
                    settings = { };
                    askPassword = true;
                    content = {
                      type = "filesystem";
                      format = "ext4";
                      mountpoint = "/";
                    };
                  };
                };
              };
            };
          };
        };
      };
    };

  };

  flake.alloyModules.infra-test = { ... }: {
    hosts.gallium = { ... }: { };
  };
}
