{ self, ... }:
{
  flake.wrappers.kitty =
    {
      wlib,
      lib,
      pkgs,
      config,
      ...
    }:
    let
      colors = config.style.colors.withHashtag;
    in
    {
      imports = [
        wlib.wrapperModules.kitty
        self.wrapperModules.style
      ];

      config = {
        env = {
          FONTCONFIG_FILE = pkgs.makeFontsConf {
            fontDirectories = [
              pkgs.nerd-fonts.jetbrains-mono
              pkgs.noto-fonts
              pkgs.noto-fonts-cjk-sans
              pkgs.noto-fonts-color-emoji
            ];
          };
        };

        font = {
          name = "JetBrainsMono Nerd Font";
          size = 12;
        };

        settings = {
          foreground = colors.base05;
          background = colors.base00;
          cursor = colors.base05;
          cursor_text_color = colors.base00;
          selection_foreground = colors.base06;
          selection_background = colors.base02;
          url_color = colors.cyan;
          active_border_color = colors.magenta;
          inactive_border_color = colors.base03;
          bell_border_color = colors.red;
          active_tab_foreground = colors.base00;
          active_tab_background = colors.blue;
          inactive_tab_foreground = colors.base04;
          inactive_tab_background = colors.base01;
          tab_bar_background = colors.base00;

          color0 = colors.base00;
          color1 = colors.red;
          color2 = colors.green;
          color3 = colors.yellow;
          color4 = colors.blue;
          color5 = colors.magenta;
          color6 = colors.cyan;
          color7 = colors.base05;
          color8 = colors.base03;
          color9 = colors.bright-red;
          color10 = colors.bright-green;
          color11 = colors.bright-yellow;
          color12 = colors.bright-blue;
          color13 = colors.bright-magenta;
          color14 = colors.bright-cyan;
          color15 = colors.base07;
        };
      };
    };
}
