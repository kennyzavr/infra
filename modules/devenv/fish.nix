{ self, ... }:
{
  flake.wrappers.fish =
    {
      wlib,
      pkgs,
      lib,
      config,
      ...
    }:
    let
      colors = config.style.colors;
      fzfColorOption =
        "--color="
        + lib.concatStringsSep "," (
          lib.mapAttrsToList (name: value: "${name}:${value}") (
            with colors.withHashtag;
            {
              bg = base00;
              "bg+" = base01;
              fg = base05;
              "fg+" = base06;
              hl = yellow;
              "hl+" = yellow;
              border = base03;
              gutter = base00;
              header = base04;
              info = blue;
              label = base04;
              marker = green;
              pointer = magenta;
              prompt = green;
              query = base05;
              separator = base03;
              spinner = orange;
            }
          )
        );
      starshipConfig = (pkgs.formats.toml { }).generate "devenv-fish-starship.toml" {
        add_newline = false;
        format = "$directory$character";

        directory = {
          style = colors.withHashtag.blue;
          read_only = "";
          truncation_length = 0;
          truncate_to_repo = false;
        };

        time = {
          disabled = false;
          time_format = "%H:%M:%S";
          format = "[$time]($style)";
          style = colors.withHashtag.base04;
        };

        character = {
          success_symbol = "[>](${colors.withHashtag.green})";
          error_symbol = "[>](${colors.withHashtag.red})";
        };
      };
    in
    {
      imports = [
        wlib.wrapperModules.fish
        self.wrapperModules.style
      ];

      runtimePkgs =
        map
          (package: {
            data = package;
            prefix = true;
          })
          [
            pkgs.fzf
            pkgs.starship
          ];

      env.STARSHIP_CONFIG = starshipConfig;

      configFile.content = ''
        # A separate history session; never write universal settings with set -U.
        set -g fish_history devenv
        set -g fish_greeting

        if not status is-interactive
          return
        end

        # --no-config also enables private mode in fish 4.7.
        # Restore persistent history for this wrapper's separate session.
        set -eg fish_private_mode

        set -l devenv_cache "$HOME/.cache/devenv/fish"
        if set -q XDG_CACHE_HOME; and test -n "$XDG_CACHE_HOME"
          set devenv_cache "$XDG_CACHE_HOME/devenv/fish"
        end
        set -gx STARSHIP_CACHE "$devenv_cache/starship"
        ${pkgs.coreutils}/bin/mkdir -p "$STARSHIP_CACHE"

        fish_default_key_bindings

        # Explicit process-local colors replace the theme skipped by --no-config.
        set -g fish_color_normal ${colors.base05}
        set -g fish_color_autosuggestion ${colors.base03}
        set -g fish_color_cancel --reverse
        set -g fish_color_command ${colors.blue}
        set -g fish_color_comment ${colors.base03}
        set -g fish_color_cwd ${colors.green}
        set -g fish_color_cwd_root ${colors.red}
        set -g fish_color_end ${colors.green}
        set -g fish_color_error ${colors.red}
        set -g fish_color_escape ${colors.cyan}
        set -g fish_color_history_current --bold
        set -g fish_color_host ${colors.base05}
        set -g fish_color_host_remote ${colors.yellow}
        set -g fish_color_keyword ${colors.magenta}
        set -g fish_color_operator ${colors.cyan}
        set -g fish_color_option ${colors.cyan}
        set -g fish_color_param ${colors.base05}
        set -g fish_color_quote ${colors.yellow}
        set -g fish_color_redirection ${colors.cyan} --bold
        set -g fish_color_search_match ${colors.base06} --background=${colors.base02} --bold
        set -g fish_color_selection ${colors.base06} --background=${colors.base02} --bold
        set -g fish_color_status ${colors.red}
        set -g fish_color_user ${colors.green}
        set -g fish_color_valid_path --underline
        set -g fish_pager_color_description ${colors.yellow} --italics
        set -g fish_pager_color_prefix ${colors.base05} --bold --underline
        set -g fish_pager_color_progress ${colors.base06} --background=${colors.base02} --bold
        set -g fish_pager_color_selected_background --background=${colors.base02}

        # Only bind Ctrl+R; leave file completion and directory bindings alone.
        set -g FZF_CTRL_T_COMMAND ""
        set -g FZF_ALT_C_COMMAND ""
        set -g FZF_CTRL_R_OPTS ${lib.escapeShellArg "--height=40% --layout=reverse --border=rounded --info=inline ${fzfColorOption}"}
        source ${pkgs.fzf}/share/fzf/key-bindings.fish

        ${pkgs.starship}/bin/starship init fish | source

        function starship_transient_prompt_func
          ${pkgs.starship}/bin/starship module character
        end

        function starship_transient_rprompt_func
          ${pkgs.starship}/bin/starship module time
        end

        enable_transience
      '';
    };
}
