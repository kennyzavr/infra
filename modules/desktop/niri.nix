{
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
      outputSubmodule = {
        options = {
          position = lib.mkOption {
            default = null;
            type = lib.types.nullOr (
              lib.types.submodule {
                options = {
                  x = lib.mkOption {
                    type = lib.types.int;
                  };
                  y = lib.mkOption {
                    type = lib.types.int;
                  };
                };
              }
            );
          };
          scale = lib.mkOption {
            default = 1.0;
            type = lib.types.nullOr lib.types.number;
          };
          mode = lib.mkOption {
            default = null;
            type = lib.types.nullOr (
              lib.types.submodule {
                options = {
                  width = lib.mkOption {
                    type = lib.types.int;
                  };
                  height = lib.mkOption {
                    type = lib.types.int;
                  };
                  refreshRate = lib.mkOption {
                    default = null;
                    type = lib.types.nullOr lib.types.int;
                  };
                };
              }
            );
          };
          extraConfig = lib.mkOption {
            default = "";
            type = lib.types.str;
          };
        };
      };

      hostSubmodule =
        { config, name, ... }:
        let
          host = config;
        in
        {
          options.desktop = {
            outputs = lib.mkOption {
              default = { };
              type = lib.types.attrsOf (lib.types.submodule outputSubmodule);
            };
          };
          config = lib.mkIf host.desktop.enable {
            nixosModule =
              { pkgs, config, ... }:
              let
                inputs' = withSystem pkgs.stdenv.hostPlatform.system ({ inputs', ... }: inputs');

                colors = host.style.colors;

                cfg = host.desktop;

                noctaliaPkg = inputs'.noctalia.packages.default;
                noctaliaExe = lib.getExe noctaliaPkg;

                niriPkg = pkgs.niri.overrideAttrs (old: {
                  postInstall = (old.postInstall or "") + ''
                    substituteInPlace $out/bin/niri-session \
                      --replace-fail \
                        'systemctl --user import-environment' \
                        'systemctl --user import-environment $(printenv | cut -d= -f1)'
                  '';
                });
                niriCfg = ''
                  prefer-no-csd
                  screenshot-path "~/Pictures/Screenshots/Screenshot from %Y-%m-%d %H-%M-%S.png"

                  environment {
                      NIXOS_OZONE_WL "1"
                  }

                  clipboard {
                      disable-primary
                  }

                  window-rule {
                      geometry-corner-radius 8
                      clip-to-geometry true
                  }

                  window-rule {
                      match app-id="dev.noctalia.Noctalia"
                      open-floating true
                      default-column-width { fixed 1080; }
                      default-window-height { fixed 920; }
                  }

                  ${lib.pipe cfg.outputs [
                    (lib.mapAttrsToList (
                      outputName: output: ''
                        output "${outputName}" {
                          ${lib.optionalString (output.mode != null) ''
                            mode "${toString output.mode.width}x${toString output.mode.height}${
                              lib.optionalString (output.mode.refreshRate != null) "@${output.mode.refreshRate}"
                            }"
                          ''}
                          ${lib.optionalString (output.scale != null) ''
                            scale "${toString output.scale}"
                          ''}
                          ${lib.optionalString (output.position != null) ''
                            position x=${output.position.x} y=${output.position.y}
                          ''}
                          ${output.extraConfig}
                        }
                      ''
                    ))
                    (lib.concatStringsSep "\n")
                  ]}

                  layout {
                      gaps 14

                      struts {
                          left 0
                          top 0
                          bottom 0
                          right 0
                      }

                      always-center-single-column

                      preset-column-widths {
                          proportion 0.33333
                          proportion 0.5
                          proportion 0.66666
                          proportion 0.8
                      }

                      default-column-width {
                          proportion 0.5
                      }

                      preset-window-heights {
                          proportion 0.33333
                          proportion 0.5
                          proportion 0.66666
                          proportion 0.8
                      }

                      border {
                          off
                      }

                      focus-ring {
                          width 2
                          active-color "#${colors.base0D}"
                          inactive-color "#${colors.base0D}"
                          urgent-color "#${colors.base08}"
                      }

                      insert-hint {
                          color "#${colors.base0B}"
                      }
                  }

                  overview {
                      zoom 0.5
                      backdrop-color "#262626"
                      workspace-shadow {
                          softness 40
                          spread 10
                          offset x=0 y=0
                          color "#00000050"
                      }
                  }

                  recent-windows {
                      highlight {
                          active-color "#${colors.base0D}"
                          urgent-color "#${colors.base08}"
                          padding 30
                      }

                      previews {
                          max-height 1080
                          max-scale 0.75
                      }

                      binds {
                          Mod+Tab { next-window; }
                          Mod+Shift+Tab { previous-window; }
                          Mod+Grave { next-window filter="app-id"; }
                          Mod+Shift+Grave { next-window filter="app-id"; }
                      }
                  }

                  hotkey-overlay {
                      skip-at-startup
                      hide-not-bound
                  }

                  input {
                      touchpad {
                          tap
                          natural-scroll
                          tap-button-map "left-right-middle"
                      }

                      keyboard {
                          xkb {
                              layout "us,ru"
                              options "grp:win_space_toggle,caps:ctrl_modifier"
                          }
                      }
                  }

                  binds {
                      Mod+D { spawn "${whichKeyExe}" "${whichKeyCfg}"; }
                      Mod+S { screenshot; }
                      Mod+Shift+S { screenshot-screen; }
                      Mod+Alt+S { screenshot-window; }

                      XF86AudioRaiseVolume allow-when-locked=true { spawn "${noctaliaExe}" "msg" "volume-up 10"; }
                      Alt+XF86AudioRaiseVolume allow-when-locked=true { spawn "${noctaliaExe}" "msg" "volume-up 5"; }
                      XF86AudioLowerVolume allow-when-locked=true { spawn "${noctaliaExe}" "msg" "volume-down 10"; }
                      Alt+XF86AudioLowerVolume allow-when-locked=true { spawn "${noctaliaExe}" "msg" "volume-down 5"; }
                      XF86AudioMute allow-when-locked=true { spawn "${noctaliaExe}" "msg" "volume-mute"; }
                      XF86AudioMicMute allow-when-locked=true { spawn "${noctaliaExe}" "msg" "mic-mute"; }
                      XF86AudioPlay allow-when-locked=true { spawn "${noctaliaExe}" "msg" "media" "play"; }
                      XF86AudioStop allow-when-locked=true { spawn "${noctaliaExe}" "msg" "media" "stop"; }
                      XF86AudioPrev allow-when-locked=true { spawn "${noctaliaExe}" "msg" "media" "previous"; }
                      XF86AudioNext allow-when-locked=true { spawn "${noctaliaExe}" "msg" "media" "next"; }

                      XF86MonBrightnessUp allow-when-locked=true { spawn "${noctaliaExe}" "msg" "brightness-up" "current" "10"; }
                      Alt+XF86MonBrightnessUp allow-when-locked=true { spawn "${noctaliaExe}" "msg" "brightness-up" "current" "5"; }
                      XF86MonBrightnessDown allow-when-locked=true { spawn "${noctaliaExe}" "msg" "brightness-down" "current" "10"; }
                      Alt+XF86MonBrightnessDown allow-when-locked=true { spawn "${noctaliaExe}" "msg" "brightness-down" "current" "5"; }

                      Mod+Shift+E { quit skip-confirmation=true; }
                      Ctrl+Alt+Delete { quit skip-confirmation=true; }

                      Mod+Escape allow-inhibiting=false { toggle-keyboard-shortcuts-inhibit; }

                      Mod+Shift+Slash { show-hotkey-overlay; }
                      Mod+Shift+P { power-off-monitors; }

                      Mod+O repeat=false { toggle-overview; }
                      Mod+Q repeat=false { close-window; }

                      Mod+Equal { set-column-width "+5%"; }
                      Mod+Minus { set-column-width "-5%"; }
                      Mod+Shift+Equal { set-window-height "+5%"; }
                      Mod+Shift+Minus { set-window-height "-5%"; }

                      Mod+R { switch-preset-column-width; }
                      Mod+Shift+R { switch-preset-window-height; }
                      Mod+Ctrl+R { reset-window-height; }
                      Mod+F { maximize-column; }
                      Mod+Shift+F { fullscreen-window; }
                      Mod+Ctrl+F { expand-column-to-available-width; }
                      Mod+M { maximize-window-to-edges; }
                      Mod+C { center-column; }
                      Mod+Ctrl+C { center-visible-columns; }

                      Mod+V { switch-focus-between-floating-and-tiling; }
                      Mod+Shift+V { toggle-window-floating; }

                      Mod+H { focus-column-left; }
                      Mod+J { focus-window-or-workspace-down; }
                      Mod+K { focus-window-or-workspace-up; }
                      Mod+L { focus-column-right; }

                      Mod+Ctrl+H { move-column-left; }
                      Mod+Ctrl+J { move-window-down-or-to-workspace-down; }
                      Mod+Ctrl+K { move-window-up-or-to-workspace-up; }
                      Mod+Ctrl+L { move-column-right; }

                      Mod+Shift+H { focus-monitor-left; }
                      Mod+Shift+J { focus-monitor-down; }
                      Mod+Shift+K { focus-monitor-up; }
                      Mod+Shift+L { focus-monitor-right; }

                      Mod+Shift+Ctrl+H { move-column-to-monitor-left; }
                      Mod+Shift+Ctrl+J { move-column-to-monitor-down; }
                      Mod+Shift+Ctrl+K { move-column-to-monitor-up; }
                      Mod+Shift+Ctrl+L { move-column-to-monitor-right; }

                      Mod+Left { focus-column-left; }
                      Mod+Down { focus-window-or-workspace-down; }
                      Mod+Up { focus-window-or-workspace-up; }
                      Mod+Right { focus-column-right; }

                      Mod+Ctrl+Left { move-column-left; }
                      Mod+Ctrl+Down { move-window-down-or-to-workspace-down; }
                      Mod+Ctrl+Up { move-window-up-or-to-workspace-up; }
                      Mod+Ctrl+Right { move-column-right; }

                      Mod+Shift+Left { focus-monitor-left; }
                      Mod+Shift+Down { focus-monitor-down; }
                      Mod+Shift+Up { focus-monitor-up; }
                      Mod+Shift+Right { focus-monitor-right; }

                      Mod+Shift+Ctrl+Left { move-column-to-monitor-left; }
                      Mod+Shift+Ctrl+Down { move-column-to-monitor-down; }
                      Mod+Shift+Ctrl+Up { move-column-to-monitor-up; }
                      Mod+Shift+Ctrl+Right { move-column-to-monitor-right; }

                      Mod+Page_Down { focus-workspace-down; }
                      Mod+Page_Up { focus-workspace-up; }
                      Mod+Ctrl+U { move-workspace-down; }
                      Mod+Ctrl+I { move-workspace-up; }
                      Mod+Ctrl+Page_Down { move-workspace-down; }
                      Mod+Ctrl+Page_Up { move-workspace-up; }

                      Mod+Home { focus-column-first; }
                      Mod+End { focus-column-last; }
                      Mod+Ctrl+Home { move-column-to-first; }
                      Mod+Ctrl+End { move-column-to-last; }

                      Mod+WheelScrollDown cooldown-ms=150 { focus-workspace-down; }
                      Mod+WheelScrollUp cooldown-ms=150 { focus-workspace-up; }
                      Mod+Shift+WheelScrollDown { focus-column-right; }
                      Mod+Shift+WheelScrollUp { focus-column-left; }
                      Mod+WheelScrollLeft { focus-column-left; }
                      Mod+WheelScrollRight { focus-column-right; }

                      Mod+1 { focus-workspace 1; }
                      Mod+2 { focus-workspace 2; }
                      Mod+3 { focus-workspace 3; }
                      Mod+4 { focus-workspace 4; }
                      Mod+5 { focus-workspace 5; }
                      Mod+6 { focus-workspace 6; }
                      Mod+7 { focus-workspace 7; }
                      Mod+8 { focus-workspace 8; }
                      Mod+9 { focus-workspace 9; }

                      Mod+Ctrl+1 { move-column-to-workspace 1; }
                      Mod+Ctrl+2 { move-column-to-workspace 2; }
                      Mod+Ctrl+3 { move-column-to-workspace 3; }
                      Mod+Ctrl+4 { move-column-to-workspace 4; }
                      Mod+Ctrl+5 { move-column-to-workspace 5; }
                      Mod+Ctrl+6 { move-column-to-workspace 6; }
                      Mod+Ctrl+7 { move-column-to-workspace 7; }
                      Mod+Ctrl+8 { move-column-to-workspace 8; }
                      Mod+Ctrl+9 { move-column-to-workspace 9; }

                      Mod+BracketLeft { consume-or-expel-window-left; }
                      Mod+BracketRight { consume-or-expel-window-right; }

                      Mod+Comma { consume-window-into-column; }
                      Mod+Period { expel-window-from-column; }

                      MouseMiddle { close-window; }
                  }

                  gestures {
                      dnd-edge-view-scroll {
                          trigger-width 30
                          delay-ms 100
                          max-speed 1500
                      }
                      dnd-edge-workspace-switch {
                          trigger-height 50
                          delay-ms 100
                          max-speed 1500
                      }
                      hot-corners {
                          top-left
                          top-right
                          bottom-left
                          bottom-right
                      }
                  }
                '';

                whichKeyPkg = pkgs.wlr-which-key;
                whichKeyExe = lib.getExe whichKeyPkg;
                whichKeyCfg = (pkgs.formats.yaml { }).generate "wlr-which-key.yaml" {
                  font = "Inter";
                  background = colors.withHashtag.base00;
                  color = colors.withHashtag.base05;
                  border = colors.withHashtag.base0D;
                  anchor = "center";
                  border_width = 2;
                  corner_r = 8;
                  padding = 16;
                  inhibit_compositor_keyboard_shortcuts = true;
                  menu = [
                    {
                      key = "t";
                      desc = "Terminal";
                      cmd = lib.getExe pkgs.xdg-terminal-exec;
                    }
                    {
                      key = "c";
                      desc = "Control center";
                      cmd = "${noctaliaExe} msg panel-toggle control-center";
                    }
                    {
                      key = "l";
                      desc = "Launcher";
                      cmd = "${noctaliaExe} msg panel-toggle launcher";
                    }
                    {
                      key = "s";
                      desc = "Session";
                      submenu = [
                        {
                          key = "l";
                          desc = "Lock";
                          cmd = "${noctaliaExe} msg session lock";
                        }
                        {
                          key = "s";
                          desc = "Lock and Suspend";
                          cmd = "${noctaliaExe} msg session lock-and-suspend";
                        }
                        {
                          key = "p";
                          desc = "Poweroff";
                          cmd = "${noctaliaExe} msg session shutdown";
                        }
                      ];
                    }
                  ];
                };
              in
              {
                environment.systemPackages = [
                  niriPkg
                  pkgs.xdg-utils
                  pkgs.xdg-user-dirs
                ];

                services.displayManager.sessionPackages = [
                  niriPkg
                ];

                systemd.packages = [
                  niriPkg
                ];

                environment.etc."niri/config.kdl" = {
                  text = niriCfg;
                };

                xdg.portal = {
                  enable = true;
                  xdgOpenUsePortal = true;
                  extraPortals = [
                    pkgs.xdg-desktop-portal-gnome
                    pkgs.xdg-desktop-portal-gtk
                  ];
                  configPackages = [
                    niriPkg
                  ];
                };

                hardware.graphics.enable = true;
              };
          };
        };
    in
    {
      options.hosts = lib.mkOption {
        type = lib.types.attrsOf (lib.types.submodule hostSubmodule);
      };
    };
}
