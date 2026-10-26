{ withSystem, self, ... }: {
  flake.alloyModules.infra = { ... }: {
    imports = [
      self.alloyModules.desktop
    ];

    hosts.silicium = { ... }: {
      desktop = {
        enable = true;
      };

      nixosModule =
        { pkgs, ... }:
        let
          pkgsUnstable = withSystem pkgs.stdenv.hostPlatform.system (
            { inputs', ... }: inputs'.nixpkgs-unstable.legacyPackages
          );
        in
        {
          environment.systemPackages = [
            pkgsUnstable.codex
          ];
        };

      home.sharedModule =
        { pkgs, ... }:
        let
          pkgsUnstable = withSystem pkgs.stdenv.hostPlatform.system (
            { inputs', ... }: inputs'.nixpkgs-unstable.legacyPackages
          );
        in
        {
          home.packages = [
            pkgs.strawberry
          ];

          programs.chromium = {
            enable = true;
          };

          programs.vesktop = {
            enable = true;
            package = pkgsUnstable.vesktop;
            settings = {
              discordBranch = "canary";
              webRTCIPHandlingPolicy = "default_public_interface_only";
            };
          };
        };
    };
  };

  flake.alloyModules.infra-prod = { ... }: {
    hosts.silicium = { ... }: { };
  };

  flake.alloyModules.infra-test = { ... }: {
    hosts.silicium = { ... }: { };
  };
}
