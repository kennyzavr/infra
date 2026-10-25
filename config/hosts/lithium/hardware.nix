{ lib, inputs, ... }: {
  flake.alloyModules.infra =
    { config, ... }:
    {
      hosts.lithium = { ... }: { };
    };

  flake.alloyModules.infra-prod = { ... }: {
    hosts.lithium = { ... }: {
      nixosModule =
        {
          modulesPath,
          pkgs,
          config,
          ...
        }:
        {
          imports = [
            (modulesPath + "/installer/scan/not-detected.nix")
          ];

          boot.initrd.availableKernelModules = [
            "xhci_pci"
            "nvme"
            "rtsx_usb_sdmmc"
          ];
          boot.kernelModules = [ "kvm-intel" ];

          hardware.cpu.intel.updateMicrocode = lib.mkDefault config.hardware.enableRedistributableFirmware;
        };
    };
  };

  flake.alloyModules.infra-test = { ... }: {
    hosts.lithium = { ... }: { };
  };
}
