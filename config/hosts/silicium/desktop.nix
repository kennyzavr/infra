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

      users.kennyzavr.home.module =
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

          programs.ssh = {
            enable = true;
            enableDefaultConfig = false;

            settings."github.com" = {
              User = "git";
              IdentityFile = "~/.ssh/id_ed25519_sk_yk_1";
              IdentitiesOnly = true;
              IdentityAgent = "none";
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
