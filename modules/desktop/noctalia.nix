{
  self,
  inputs,
  withSystem,
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
            nixosModule =
              { pkgs, config, ... }:
              let
                inputs' = withSystem pkgs.stdenv.hostPlatform.system ({ inputs', ... }: inputs');

                colors = host.style.colors;

                noctaliaPkg = inputs'.noctalia.packages.default;
                noctaliaExe = lib.getExe noctaliaPkg;
                noctaliaSettings = {
                  location = {
                    auto_locate = false;
                  };
                  weather = {
                    enabled = false;
                  };
                  lockscreen = {
                    enabled = true;
                  };
                  control_center = {
                    sidebar = "full";
                    sidebar_section = "full";
                  };
                  shell = {
                    font_family = "Inter";
                    offline_mode = true;
                    telemetry_enabled = false;
                    setup_wizard_enabled = false;
                    show_location = false;
                    launch_apps_as_systemd_services = true;
                    polkit_agent = lib.mkDefault false;
                    clipboard_enabled = false;
                    niri_overview_type_to_launch_enabled = true;
                    screenshot = {
                      copy_to_clipboard = true;
                      freeze_screen = true;
                      confirm_region = true;
                    };
                    panel = {
                      borders = true;
                      shadow = false;
                      control_center_placement = "floating";
                      control_center_position = "auto";
                      open_near_click_control_center = true;
                      session_placement = "floating";
                      session_position = "auto";
                      wallpaper_placement = "floating";
                      wallpaper_position = "auto";
                    };
                    animation = {
                      enabled = true;
                      speed = 3.0;
                    };
                  };
                  osd = {
                    position = "top_center";
                    position_vertical = "top_center";
                    orientation = "horizontal";
                    scale = 1.0;
                    background_opacity = 1.0;
                  };
                  keybinds = {
                    cancel = [ "escape" ];
                    validate = [
                      "return"
                      "kp_enter"
                    ];
                    left = [
                      "left"
                      "ctrl+h"
                    ];
                    right = [
                      "right"
                      "ctrl+l"
                    ];
                    up = [
                      "up"
                      "ctrl+k"
                      "ctrl+p"
                    ];
                    down = [
                      "down"
                      "ctrl+j"
                      "ctrl+n"
                    ];
                    tab_next = [ "tab" ];
                    tab_previous = [
                      "shift+tab"
                      "iso_left_tab"
                    ];
                  };
                  theme = {
                    mode = "dark";
                    source = "custom";
                    custom_palette = "default";
                  };
                  wallpaper = {
                    enabled = false;
                  };
                  widget = {
                    clock = {
                      format = "%a, %e %b  %H:%M:%S";
                    };
                    network = {
                      show_label = true;
                    };
                    control-center = {
                      glyph = "adjustments-alt";
                    };
                    privacy = {
                      hide_inactive = true;
                    };
                    workspaces = {
                      capsule = false;
                    };
                    media = {
                      max_length = 330;
                    };
                    cpu-stat = {
                      display = "gauge";
                      type = "sysmon";
                      stat = "cpu_usage";
                    };
                    ram-stat = {
                      display = "gauge";
                      type = "sysmon";
                      stat = "ram_used";
                    };
                  };
                  bar.main = {
                    position = "bottom";
                    enabled = true;
                    auto_hide = false;
                    show_on_workspace_switch = true;
                    reserve_space = true;
                    layer = "top";
                    thickness = 30;
                    background_opacity = 1.0;
                    shadow = false;
                    radius = 0;
                    margin_ends = 0;
                    margin_edge = 0;
                    margin_opposite_edge = 0;
                    padding = 12;
                    widget_spacing = 8;
                    start = [
                      "launcher"
                      "workspaces"
                      "active_window"
                    ];
                    center = [ "clock" ];
                    end = [
                      "media"
                      "volume"
                      "cpu-stat"
                      "ram-stat"
                      "keyboard_layout"
                      "battery"
                      "tray"
                      "privacy"
                      "control-center"
                    ];
                  };
                };

                noctaliaDefaultPalette = with colors.withHashtag; {
                  dark = {
                    mPrimary = base0D;
                    mOnPrimary = base00;
                    mSecondary = base0E;
                    mOnSecondary = base00;
                    mTertiary = base0C;
                    mOnTertiary = base00;
                    mError = base08;
                    mOnError = base00;
                    mSurface = base00;
                    mOnSurface = base05;
                    mHover = base0C;
                    mOnHover = base00;
                    mSurfaceVariant = base01;
                    mOnSurfaceVariant = base04;
                    mOutline = base03;
                    mShadow = base00;
                    terminal = {
                      foreground = base05;
                      background = base00;
                      cursor = base05;
                      cursorText = base00;
                      selectionFg = base05;
                      selectionBg = base02;
                      normal = {
                        black = base00;
                        red = base08;
                        green = base0B;
                        yellow = base0A;
                        blue = base0D;
                        magenta = base0E;
                        cyan = base0C;
                        white = base05;
                      };
                      bright = {
                        black = base03;
                        red = base08;
                        green = base0B;
                        yellow = base0A;
                        blue = base0D;
                        magenta = base0E;
                        cyan = base0C;
                        white = base07;
                      };
                    };
                  };
                };

              in
              {
                environment.systemPackages = [
                  noctaliaPkg
                  pkgs.brightnessctl
                ];

                systemd.user.services.noctalia = {
                  description = "Noctalia - A lightweight Wayland shell and bar";
                  documentation = [ "https://docs.noctalia.dev/noctalia/" ];
                  partOf = [ "graphical-session.target" ];
                  after = [ "graphical-session.target" ];
                  wantedBy = [ "graphical-session.target" ];
                  restartTriggers = [
                    noctaliaPkg
                    config.environment.etc."desktop/noctalia/settings.toml".source
                    config.environment.etc."desktop/noctalia/palettes/default.json".source
                  ];

                  environment.PATH = lib.mkForce null;
                  environment.NOCTALIA_CONFIG_HOME = "/etc/desktop";

                  serviceConfig = {
                    ExecStart = noctaliaExe;
                    Restart = "on-failure";
                  };
                };

                environment.etc."desktop/noctalia/settings.toml".source =
                  (pkgs.formats.toml { }).generate "settings.json"
                    noctaliaSettings;
                environment.etc."desktop/noctalia/palettes/default.json".text =
                  builtins.toJSON noctaliaDefaultPalette;

                services.pipewire = {
                  enable = true;
                  alsa.enable = true;
                  alsa.support32Bit = true;
                  pulse.enable = true;
                  jack.enable = true;
                  wireplumber.enable = true;
                };

                security.polkit = {
                  enable = true;
                };

                security.pam.services.login = { };

                services.blueman.enable = true;

                services.playerctld = {
                  enable = true;
                };

                services.upower = {
                  enable = true;
                };

                services.power-profiles-daemon = {
                  enable = true;
                };
              };
          };
        };
    in
    {
      imports = [
        self.alloyModules.style
        inputs.alloy.alloyModules.home-manager
      ];

      options.hosts = lib.mkOption {
        type = lib.types.attrsOf (lib.types.submodule hostSubmodule);
      };
    };
}
