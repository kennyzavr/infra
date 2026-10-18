{
  flake.alloyModules.infra =
    { config, ... }:
    let
      alloy = config;
    in
    {
      services.dns-edge."public" = {
        routes."public" = {
          zone = "public";
          upstream.endpoint = alloy.services.dns-auth."public".endpoint;
        };
        routes."public-acme" = {
          zone = "public-acme";
          upstream.endpoint = alloy.services.dns-acme."public".endpoint;
        };
      };

      services.dns-auth."public" = {
        zones = [
          "public"
        ];
        hosts."iridium" = { };
        hosts."gallium" = { };
        overlays."main" = { };
      };

      services.dns-acme."public" = {
        zones = [
          "public-acme"
        ];
        host = "iridium";
        overlays."main" = { };
      };
    };
}
