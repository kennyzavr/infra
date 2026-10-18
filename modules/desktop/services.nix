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
                environment.systemPackages = [
                  pkgs.wl-clipboard
                ];

                services.gnome.gnome-keyring.enable = true;
                security.pam.services.greetd.enableGnomeKeyring = true;

                services.pipewire = {
                  enable = true;
                  alsa.enable = true;
                  alsa.support32Bit = true;
                  pulse.enable = true;
                  jack.enable = true;
                  wireplumber.enable = true;
                };
                security.rtkit = {
                  enable = true;
                };

                networking.networkmanager = {
                  enable = true;
                  wifi.backend = "iwd";
                  unmanaged = lib.pipe host.nets [
                    (lib.filterAttrs (_: net: !net.managed))
                    (lib.mapAttrsToList (_: net: net.iface))
                  ];
                  dns = "systemd-resolved";
                };

                hardware.bluetooth = {
                  enable = true;
                  settings = {
                    General = {
                      Experimental = true;
                    };
                  };
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
