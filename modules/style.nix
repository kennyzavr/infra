{ lib, ... }:
let
  defaultPalette = {
    base00 = "292828";
    base01 = "32302f";
    base02 = "504945";
    base03 = "665c54";
    base04 = "bdae93";
    base05 = "ddc7a1";
    base06 = "ebdbb2";
    base07 = "fbf1c7";
    base08 = "ea6962";
    base09 = "e78a4e";
    base0A = "d8a657";
    base0B = "a9b665";
    base0C = "89b482";
    base0D = "7daea3";
    base0E = "d3869b";
    base0F = "bd6f3e";

    red = "ea6962";
    orange = "e78a4e";
    yellow = "d8a657";
    green = "a9b665";
    cyan = "89b482";
    blue = "7daea3";
    magenta = "d3869b";
    brown = "bd6f3e";

    bright-red = "ea6962";
    bright-orange = "e78a4e";
    bright-yellow = "d8a657";
    bright-green = "a9b665";
    bright-cyan = "89b482";
    bright-blue = "7daea3";
    bright-magenta = "d3869b";
    bright-brown = "bd6f3e";
  };

  paletteType =
    paletteDefault:
    lib.types.submodule {
      options = lib.mapAttrs (
        name: _:
        lib.mkOption {
          type = lib.types.strMatching "[0-9a-fA-F]{6}";
          default = paletteDefault.${name};
          description = "${name} color, as six hexadecimal digits without #.";
        }
      ) defaultPalette;
    };

  aliasColor =
    value:
    lib.mkOption {
      type = lib.types.str;
      readOnly = true;
      default = value;
    };

  mkStyleOptions = paletteDefault: palette: {
    palette = lib.mkOption {
      type = paletteType paletteDefault;
      default = { };
      description = "Base16 palette shared by the configured applications.";
    };
    colors = lib.mapAttrs (_: aliasColor) palette // {
      withHashtag = lib.mapAttrs (_: value: aliasColor "#${value}") palette;
    };
  };
in
{
  flake.wrappers.style = { config, ... }: {
    options.style = mkStyleOptions defaultPalette config.style.palette;
  };

  perSystem.wrappers = {
    control_type = "exclude";
    packages.style = true;
  };

  flake.alloyModules.style =
    { config, ... }:
    let
      alloy = config;
    in
    {
      options.style.palette = lib.mkOption {
        type = paletteType defaultPalette;
        default = { };
      };

      options.hosts = lib.mkOption {
        type = lib.types.attrsOf (
          lib.types.submodule (
            { config, ... }: {
              options.style = mkStyleOptions alloy.style.palette config.style.palette;
            }
          )
        );
      };
    };
}
