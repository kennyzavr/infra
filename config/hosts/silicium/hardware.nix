{ lib, inputs, ... }: {
  flake.alloyModules.infra =
    { config, ... }:
    {
      hosts.silicium = { ... }: { };
    };

  flake.alloyModules.infra-prod = { ... }: {
    hosts.silicium = { ... }: {
      nixosModule =
        {
          config,
          modulesPath,
          pkgs,
          ...
        }:
        {
          imports = [
            (modulesPath + "/installer/scan/not-detected.nix")
          ];

          boot.initrd.availableKernelModules = [
            "nvme"
            "xhci_pci"
            "ahci"
            "usbhid"
            "usb_storage"
            "sd_mod"
          ];
          boot.initrd.kernelModules = [ "dm-snapshot" ];
          boot.kernelModules = [ "kvm-amd" ];

          hardware.cpu.amd.updateMicrocode = lib.mkDefault config.hardware.enableRedistributableFirmware;
        };
    };
  };

  flake.alloyModules.infra-test = { ... }: {
    hosts.silicium = { ... }: { };
  };
}
