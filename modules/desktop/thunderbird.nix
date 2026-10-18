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
                programs.thunderbird = {
                  enable = true;
                };
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
