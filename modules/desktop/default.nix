{
  withSystem,
  inputs,
  self,
  ...
}:
{
  imports = [
    ./style.nix
    ./services.nix
    ./niri.nix
    ./noctalia.nix
    ./tuigreet.nix
    ./nautilus.nix
    ./firefox.nix
    ./keepassxc.nix
    ./thunderbird.nix
  ];

  flake.alloyModules.desktop =
    {
      alib,
      lib,
      config,
      ...
    }:
    let
      hostSubmodule =
        { config, name, ... }:
        let
          host = config;
        in
        {
          options.desktop = {
            enable = lib.mkOption {
              default = false;
              type = lib.types.bool;
            };
          };
          config = lib.mkIf host.desktop.enable {
            home.enable = true;

            nixosModule = { pkgs, ... }: {
              environment.systemPackages =
                [ ]
                ++ (withSystem pkgs.stdenv.hostPlatform.system (
                  { inputs', self', ... }: [
                    (self.wrappers.kitty.wrap {
                      pkgs = inputs'.nixpkgs-unstable.legacyPackages;
                      style.palette = host.style.palette;
                    })
                    (self.wrappers.gdevenv.wrap {
                      pkgs = inputs'.nixpkgs-unstable.legacyPackages;
                      style.palette = host.style.palette;
                    })
                    (self.wrappers.devenv.wrap {
                      pkgs = inputs'.nixpkgs-unstable.legacyPackages;
                      style.palette = host.style.palette;
                    })
                  ]
                ));

              xdg.terminal-exec.settings = {
                default = [
                  "kitty.desktop"
                ];
              };
            };

            qemu.nixosModule = {
              virtualisation.qemu.options = lib.optionals host.qemu.graphics [
                "-device virtio-vga-gl -display sdl,gl=on"
              ];
            };
          };
        };
    in
    {
      imports = [
        inputs.alloy.alloyModules.home-manager
      ];

      options.hosts = lib.mkOption {
        type = lib.types.attrsOf (lib.types.submodule hostSubmodule);
      };
    };
}
