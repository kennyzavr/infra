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
            nixosModule =
              { pkgs, config, ... }:
              {
                environment.systemPackages = [ pkgs.tuigreet ];

                services.greetd = {
                  enable = true;
                  settings.default_session.command = "${pkgs.tuigreet}/bin/tuigreet --time --remember --remember-session --sessions ${config.services.displayManager.sessionData.desktops}/share/wayland-sessions --theme 'container=black;border=darkgray;text=white;prompt=blue;time=cyan;action=green;button=magenta;asterisks=red'";
                };

                boot.kernelParams = [
                  "vt.global_cursor_default=0"
                ];
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
