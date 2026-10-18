{
  flake.alloyModules.infra =
    { config, ... }:
    let
      alloy = config;
    in
    {
      dns.zones."public" = {
        apex = "d108.internal";
        rname = "me.d108.internal";
        email = "me@d108.internal";
      };
      dns.zones."public-acme" = {
        apex = "acme.d108.internal";
        rname = alloy.dns.zones."public".rname;
        parentZone = "public";
      };
    };
}
