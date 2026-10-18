{ self, ... }:
{
  flake.wrappers.yazi =
    { wlib, config, ... }:
    let
      colors = config.style.colors.withHashtag;
    in
    {
      imports = [
        wlib.wrapperModules.yazi
        self.wrapperModules.style
      ];

      settings.yazi.mgr.show_hidden = true;

      settings.theme = with colors; {
        mgr = {
          cwd.fg = cyan;
          find_keyword = {
            fg = green;
            bold = true;
          };
          find_position.fg = magenta;
          symlink_target = {
            fg = base04;
            italic = true;
          };
          marker_selected = {
            fg = yellow;
            bg = yellow;
          };
          marker_copied = {
            fg = green;
            bg = green;
          };
          marker_cut = {
            fg = red;
            bg = red;
          };
          marker_marked = {
            fg = cyan;
            bg = cyan;
          };
          border_style.fg = base04;
          count_copied = {
            fg = base00;
            bg = green;
          };
          count_cut = {
            fg = base00;
            bg = red;
          };
          count_selected = {
            fg = base00;
            bg = yellow;
          };
        };

        indicator = {
          parent.bg = base02;
          current = {
            bg = base02;
            bold = true;
          };
          preview = {
            bg = base02;
            bold = true;
          };
          padding = {
            open = "▐";
            close = "▌";
          };
        };

        tabs = {
          active = {
            fg = base00;
            bg = blue;
            bold = true;
          };
          inactive = {
            fg = blue;
            bg = base01;
          };
        };

        mode = {
          normal_main = {
            fg = base00;
            bg = blue;
            bold = true;
          };
          normal_alt = {
            fg = blue;
            bg = base00;
          };
          select_main = {
            fg = base00;
            bg = green;
            bold = true;
          };
          select_alt = {
            fg = green;
            bg = base00;
          };
          unset_main = {
            fg = base00;
            bg = brown;
            bold = true;
          };
          unset_alt = {
            fg = brown;
            bg = base00;
          };
        };

        status = {
          overall = {
            fg = base05;
            bg = base00;
          };
          progress_label = {
            fg = base05;
            bg = base00;
          };
          progress_normal = {
            fg = base05;
            bg = base00;
          };
          progress_error = {
            fg = red;
            bg = base00;
          };
          perm_type.fg = blue;
          perm_read.fg = yellow;
          perm_write.fg = red;
          perm_exec.fg = green;
          perm_sep.fg = cyan;
          sep_left = {
            open = "▐";
            close = "▌";
          };
          sep_right = {
            open = "▐";
            close = "▌";
          };
        };

        pick = {
          border.fg = blue;
          active.fg = magenta;
          inactive.fg = base05;
        };

        input = {
          border.fg = blue;
          title.fg = base05;
          value.fg = base05;
          selected.bg = base03;
        };

        cmp = {
          border.fg = blue;
          active = {
            fg = magenta;
            bg = base03;
          };
          inactive.fg = base05;
        };

        tasks = {
          border.fg = blue;
          title.fg = base05;
          hovered = {
            fg = base05;
            bg = base03;
          };
        };

        which = {
          mask.bg = base02;
          cand.fg = cyan;
          rest.fg = brown;
          desc.fg = base05;
          separator_style.fg = base04;
        };

        confirm = {
          border.fg = blue;
          title.fg = base05;
          body.fg = base05;
          list.fg = base05;
          btn_yes = {
            fg = base00;
            bg = green;
          };
          btn_no = {
            fg = base05;
            bg = base02;
          };
        };

        spot = {
          border.fg = blue;
          title.fg = base05;
          tbl_col.fg = blue;
          tbl_cell = {
            fg = base05;
            bg = base03;
          };
        };

        notify = {
          title_info.fg = green;
          title_warn.fg = yellow;
          title_error.fg = red;
        };

        help = {
          on.fg = magenta;
          run.fg = cyan;
          desc.fg = base05;
          hovered = {
            fg = base05;
            bg = base03;
          };
          footer.fg = base05;
        };

        filetype.rules = [
          {
            mime = "image/*";
            fg = cyan;
          }
          {
            mime = "{audio,video}/*";
            fg = yellow;
          }
          {
            mime = "application/{zip,gzip,x-gzip,tar,x-tar,bzip,bzip2,x-bzip,x-bzip2,7z-compressed,x-7z-compressed,rar,vnd.rar,x-rar,x-rar-compressed,xz,x-xz,zstd,x-zstd}";
            fg = magenta;
          }
          {
            mime = "application/{doc,pdf,rtf,msword,vnd.*}";
            fg = green;
          }
          {
            url = "*";
            is = "orphan";
            fg = red;
          }
          {
            url = "*";
            is = "exec";
            fg = green;
          }
          {
            url = "*/";
            fg = blue;
            bold = true;
          }
          {
            url = "*";
            fg = base05;
          }
        ];

        icon = {
          dirs = [
            {
              name = ".config";
              text = "";
              fg = orange;
            }
            {
              name = ".git";
              text = "";
              fg = cyan;
            }
            {
              name = ".github";
              text = "";
              fg = blue;
            }
            {
              name = ".npm";
              text = "";
              fg = blue;
            }
            {
              name = "Desktop";
              text = "";
              fg = cyan;
            }
            {
              name = "Development";
              text = "";
              fg = cyan;
            }
            {
              name = "Documents";
              text = "";
              fg = cyan;
            }
            {
              name = "Downloads";
              text = "";
              fg = cyan;
            }
            {
              name = "Library";
              text = "";
              fg = cyan;
            }
            {
              name = "Movies";
              text = "";
              fg = cyan;
            }
            {
              name = "Music";
              text = "";
              fg = cyan;
            }
            {
              name = "Pictures";
              text = "";
              fg = cyan;
            }
            {
              name = "Public";
              text = "";
              fg = cyan;
            }
            {
              name = "Videos";
              text = "";
              fg = cyan;
            }
          ];
          conds = [
            {
              "if" = "orphan";
              text = "";
              fg = base05;
            }
            {
              "if" = "link";
              text = "";
              fg = base04;
            }
            {
              "if" = "block";
              text = "";
              fg = yellow;
            }
            {
              "if" = "char";
              text = "";
              fg = yellow;
            }
            {
              "if" = "fifo";
              text = "";
              fg = yellow;
            }
            {
              "if" = "sock";
              text = "";
              fg = yellow;
            }
            {
              "if" = "sticky";
              text = "";
              fg = yellow;
            }
            {
              "if" = "dummy";
              text = "";
              fg = red;
            }
            {
              "if" = "dir";
              text = "";
              fg = blue;
            }
            {
              "if" = "exec";
              text = "";
              fg = green;
            }
            {
              "if" = "!dir";
              text = "";
              fg = base05;
            }
          ];
        };
      };
    };
}
