{
  flake.alloyModules.infra =
    { config, ... }:
    {
      hosts.iridium = { ... }: { };
    };

  flake.alloyModules.infra-prod = { ... }: {
    hosts.iridium = { config, ... }: {
      nixosModule = { modulesPath, pkgs, ... }: {
        imports = [
          (modulesPath + "/profiles/qemu-guest.nix")
        ];
      };
    };
  };

  flake.alloyModules.infra-test = { ... }: {
    hosts.iridium = { ... }: { };
  };
}
