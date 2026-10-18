{
  self,
  inputs,
  ...
}:
{
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
          config = lib.mkIf host.desktop.enable {
            home.sharedModule =
              { pkgs, config, ... }:
              {
                stylix = {
                  targets = {
                    gtk.enable = true;
                    qt.enable = true;
                    gnome.enable = true;
                  };
                };
              };

            nixosModule =
              { pkgs, config, ... }:
              let
                colors = host.style.colors;
              in
              {
                imports = [
                  inputs.stylix.nixosModules.stylix
                ];

                stylix = {
                  enable = true;
                  autoEnable = false;
                  polarity = "dark";
                  homeManagerIntegration = {
                    autoImport = true;
                    followSystem = true;
                  };
                  icons = {
                    enable = true;
                    package = pkgs.papirus-icon-theme;
                    dark = "Papirus-Dark";
                    light = "Papirus";
                  };
                  cursor = {
                    package = pkgs.bibata-cursors;
                    name = "Bibata-Original-Classic";
                    size = 24;
                  };
                  fonts = {
                    serif = {
                      package = pkgs.noto-fonts;
                      name = "Noto Serif";
                    };
                    sansSerif = {
                      package = pkgs.inter;
                      name = "Inter";
                    };
                    monospace = {
                      package = pkgs.nerd-fonts.jetbrains-mono;
                      name = "JetBrainsMono Nerd Font";
                    };
                    emoji = {
                      package = pkgs.noto-fonts-color-emoji;
                      name = "Noto Color Emoji";
                    };
                  };
                  base16Scheme = {
                    inherit (colors)
                      base00
                      base01
                      base02
                      base03
                      base04
                      base05
                      base06
                      base07
                      base08
                      base09
                      base0A
                      base0B
                      base0C
                      base0D
                      base0E
                      base0F
                      ;
                  };
                  targets = {
                    console.enable = true;
                    font-packages.enable = true;
                    fontconfig.enable = true;
                    gtk.enable = true;
                    qt.enable = true;
                    gnome.enable = true;
                  };
                };
              };
          };
        };
    in
    {
      imports = [
        self.alloyModules.style
      ];

      options.hosts = lib.mkOption {
        type = lib.types.attrsOf (lib.types.submodule hostSubmodule);
      };
    };
}
