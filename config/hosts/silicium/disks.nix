{
  flake.alloyModules.infra =
    { config, ... }:
    {
      hosts.silicium = { ... }: { };
    };

  flake.alloyModules.infra-prod = { ... }: {
    hosts.silicium = {
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
          devices.disk.home = {
            type = "disk";
            device = "/dev/disk/by-id/nvme-ADATA_SX6000LNP_2K3029ASJQNW";
            content = {
              type = "gpt";
              partitions = {
                data = {
                  size = "100%";
                  content = {
                    type = "luks";
                    name = "crypthome";
                    settings = { };
                    askPassword = true;
                    content = {
                      type = "filesystem";
                      format = "ext4";
                      mountpoint = "/home";
                    };
                  };
                };
              };
            };
          };
        };
      };

      nixosModule = {
        fileSystems."/media" = {
          device = "/dev/disk/by-id/ata-KingDian_S280_240GB_2018070201235";
          fsType = "ext4";
          options = [ "nofail" ];
        };
      };
    };
  };

  flake.alloyModules.infra-test = { ... }: {
    hosts.silicium = { ... }: { };
  };
}
