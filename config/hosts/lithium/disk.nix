{
  flake.alloyModules.infra =
    { config, ... }:
    {
      hosts.lithium = { ... }: { };
    };

  flake.alloyModules.infra-prod = { ... }: {
    hosts.lithium = {
      disko = {
        enable = true;
        settings = { ... }: {
          devices.disk.main = {
            type = "disk";
            device = "/dev/disk/by-id/nvme-SAMSUNG_MZVLB256HAHQ-00000_S444NX0KB50828";
            content = {
              type = "gpt";
              partitions = {
                efi = {
                  size = "512M";
                  type = "EF00";
                  content = {
                    type = "filesystem";
                    format = "vfat";
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
    hosts.lithium = { ... }: { };
  };
}
