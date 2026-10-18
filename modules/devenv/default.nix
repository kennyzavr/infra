{ self, lib, ... }:
let
  mkPackageOption =
    name: palette: pkgs:
    lib.mkOption {
      type = lib.types.package;
      default = self.wrappers.${name}.wrap {
        inherit pkgs;
        style.palette = palette;
      };
      description = "${name} package used inside devenv.";
    };
in
{
  imports = [
    ./fish.nix
    ./zellij.nix
    ./yazi.nix
    ./helix.nix
  ];

  flake.wrappers.devenv =
    {
      wlib,
      lib,
      pkgs,
      config,
      ...
    }:
    {
      imports = [
        wlib.modules.default
        self.wrapperModules.style
      ];

      options = {
        fishPackage = mkPackageOption "fish" config.style.palette pkgs;
        zellijPackage = mkPackageOption "zellij" config.style.palette pkgs;
        helixPackage = mkPackageOption "helix" config.style.palette pkgs;
        yaziPackage = mkPackageOption "yazi" config.style.palette pkgs;
        lazygitPackage = lib.mkOption {
          type = lib.types.package;
          default = pkgs.lazygit;
          description = "Lazygit package used inside devenv.";
        };
      };

      config = {
        package = config.zellijPackage;
        binName = "devenv";

        runtimePkgs =
          map
            (package: {
              data = package;
              prefix = true;
            })
            [
              config.fishPackage
              config.zellijPackage
              config.helixPackage
              config.yaziPackage
              config.lazygitPackage
            ];

        env = {
          EDITOR = lib.getExe' config.helixPackage "hx";
          VISUAL = lib.getExe' config.helixPackage "hx";
          SHELL = lib.getExe' config.fishPackage "fish";
        };
      };
    };

  flake.wrappers.gdevenv =
    {
      wlib,
      lib,
      pkgs,
      config,
      ...
    }:
    {
      imports = [
        self.wrapperModules.kitty
      ];

      options = {
        fishPackage = mkPackageOption "fish" config.style.palette pkgs;
        zellijPackage = mkPackageOption "zellij" config.style.palette pkgs;
        helixPackage = mkPackageOption "helix" config.style.palette pkgs;
        yaziPackage = mkPackageOption "yazi" config.style.palette pkgs;
        lazygitPackage = lib.mkOption {
          type = lib.types.package;
          default = pkgs.lazygit;
          description = "Lazygit package used inside devenv.";
        };
      };

      config = {
        package = pkgs.kitty;
        binName = "gdevenv";

        constructFiles.desktopItem = {
          relPath = "share/applications/gdevenv.desktop";
          content = ''
            [Desktop Entry]
            Categories=Development;
            Exec=${placeholder config.outputName}/bin/${config.binName}
            GenericName=Development Environment
            Name=DevEnv
            Type=Application
          '';
        };

        runtimePkgs =
          map
            (package: {
              data = package;
              prefix = true;
            })
            [
              config.fishPackage
              config.zellijPackage
              config.helixPackage
              config.yaziPackage
              config.lazygitPackage
            ];

        env = {
          EDITOR = lib.getExe' config.helixPackage "hx";
          VISUAL = lib.getExe' config.helixPackage "hx";
          SHELL = lib.getExe' config.fishPackage "fish";
        };

        settings = {
          shell = lib.escapeShellArgs [ (lib.getExe' config.zellijPackage "zellij") ];
        };
      };
    };
}
