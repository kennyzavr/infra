{ self, ... }:
{
  flake.wrappers.zellij =
    {
      wlib,
      pkgs,
      config,
      ...
    }:
    let
      colors = config.style.colors.withHashtag;
      configDir = pkgs.writeTextDir "config.kdl" (
        ''
          show_startup_tips false
          show_startup_notes false
          theme "devenv"

          themes {
            devenv {
              text_unselected {
                base "${colors.base05}"
                background "${colors.base01}"
                emphasis_0 "${colors.orange}"
                emphasis_1 "${colors.cyan}"
                emphasis_2 "${colors.green}"
                emphasis_3 "${colors.brown}"
              }
              text_selected {
                base "${colors.base05}"
                background "${colors.base04}"
                emphasis_0 "${colors.orange}"
                emphasis_1 "${colors.cyan}"
                emphasis_2 "${colors.green}"
                emphasis_3 "${colors.brown}"
              }
              ribbon_selected {
                base "${colors.base01}"
                background "${colors.magenta}"
                emphasis_0 "${colors.red}"
                emphasis_1 "${colors.orange}"
                emphasis_2 "${colors.brown}"
                emphasis_3 "${colors.blue}"
              }
              ribbon_unselected {
                base "${colors.base01}"
                background "${colors.base05}"
                emphasis_0 "${colors.red}"
                emphasis_1 "${colors.base05}"
                emphasis_2 "${colors.blue}"
                emphasis_3 "${colors.brown}"
              }
              table_title {
                base "${colors.magenta}"
                background "${colors.base00}"
                emphasis_0 "${colors.orange}"
                emphasis_1 "${colors.cyan}"
                emphasis_2 "${colors.green}"
                emphasis_3 "${colors.brown}"
              }
              table_cell_selected {
                base "${colors.base05}"
                background "${colors.base04}"
                emphasis_0 "${colors.orange}"
                emphasis_1 "${colors.cyan}"
                emphasis_2 "${colors.green}"
                emphasis_3 "${colors.brown}"
              }
              table_cell_unselected {
                base "${colors.base05}"
                background "${colors.base01}"
                emphasis_0 "${colors.orange}"
                emphasis_1 "${colors.cyan}"
                emphasis_2 "${colors.green}"
                emphasis_3 "${colors.brown}"
              }
              list_selected {
                base "${colors.base05}"
                background "${colors.base04}"
                emphasis_0 "${colors.orange}"
                emphasis_1 "${colors.cyan}"
                emphasis_2 "${colors.green}"
                emphasis_3 "${colors.brown}"
              }
              list_unselected {
                base "${colors.base05}"
                background "${colors.base01}"
                emphasis_0 "${colors.orange}"
                emphasis_1 "${colors.cyan}"
                emphasis_2 "${colors.green}"
                emphasis_3 "${colors.brown}"
              }
              frame_unselected {
                base "${colors.base03}"
                background "${colors.base00}"
                emphasis_0 "${colors.orange}"
                emphasis_1 "${colors.cyan}"
                emphasis_2 "${colors.brown}"
                emphasis_3 "${colors.base00}"
              }
              frame_selected {
                base "${colors.magenta}"
                background "${colors.base00}"
                emphasis_0 "${colors.orange}"
                emphasis_1 "${colors.cyan}"
                emphasis_2 "${colors.brown}"
                emphasis_3 "${colors.base00}"
              }
              frame_highlight {
                base "${colors.red}"
                background "${colors.base00}"
                emphasis_0 "${colors.brown}"
                emphasis_1 "${colors.orange}"
                emphasis_2 "${colors.orange}"
                emphasis_3 "${colors.orange}"
              }
              exit_code_success {
                base "${colors.green}"
                background "${colors.base00}"
                emphasis_0 "${colors.cyan}"
                emphasis_1 "${colors.base01}"
                emphasis_2 "${colors.brown}"
                emphasis_3 "${colors.blue}"
              }
              exit_code_error {
                base "${colors.red}"
                background "${colors.base00}"
                emphasis_0 "${colors.yellow}"
                emphasis_1 "${colors.base00}"
                emphasis_2 "${colors.base00}"
                emphasis_3 "${colors.base00}"
              }
              multiplayer_user_colors {
                player_1 "${colors.brown}"
                player_2 "${colors.blue}"
                player_3 "${colors.base00}"
                player_4 "${colors.yellow}"
                player_5 "${colors.cyan}"
                player_6 "${colors.base00}"
                player_7 "${colors.red}"
                player_8 "${colors.base00}"
                player_9 "${colors.base00}"
                player_10 "${colors.base00}"
              }
            }
          }
        ''
        + builtins.readFile ./zellij/keybinds.kdl
      );
    in
    {
      imports = [
        wlib.modules.default
        self.wrapperModules.style
      ];

      package = pkgs.zellij;
      env = {
        ZELLIJ_CONFIG_DIR = configDir;
        ZELLIJ_CONFIG_FILE = "${configDir}/config.kdl";
      };
    };
}
