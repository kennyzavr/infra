{
  flake.alloyModules.infra =
    { config, ... }:
    {
      services.dns-edge."public" = {
        hosts."iridium".net = "public";
        hosts."gallium".net = "public";
      };

      services.http-edge."public" = {
        hosts."iridium".net = "public";
        hosts."gallium".net = "public";
      };

      services.tls-edge."public" = {
        hosts."iridium".net = "public";
        hosts."gallium".net = "public";
      };

      services.smtp-edge."public" = {
        hostname = {
          zone = "public";
          name = "mail";
        };
        explicitTLS = {
          mode = "require";
          cert = "mail";
        };
        dkim.enable = true;
        hosts."iridium".net = "public";
        hosts."gallium".net = "public";
      };
    };
}
