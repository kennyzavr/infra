{
  flake.alloyModules.infra =
    { config, ... }:
    {
      hosts.iridium = { ... }: { };
    };

  flake.alloyModules.infra-prod = { ... }: {
    hosts.iridium = {
      disko = {
        enable = true;
        settings = { ... }: {
          devices.disk.main = {
            type = "disk";
            device = "/dev/disk/by-id/virtio-d6690489b4d91d80";
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
    hosts.iridium = { ... }: { };
  };
}
