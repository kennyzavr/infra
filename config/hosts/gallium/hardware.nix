{
  flake.alloyModules.infra =
    { config, ... }:
    {
      hosts.gallium = { ... }: { };
    };

  flake.alloyModules.infra-prod = { ... }: {
    hosts.gallium = { config, ... }: {
      nixosModule = { modulesPath, pkgs, ... }: {
        imports = [
          (modulesPath + "/profiles/qemu-guest.nix")
        ];
      };
    };
  };

  flake.alloyModules.infra-test = { ... }: {
    hosts.gallium = { ... }: { };
  };
}
