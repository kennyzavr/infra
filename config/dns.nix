{
  flake.alloyModules.infra =
    { config, ... }:
    let
      alloy = config;
    in
    {
      dns.zones."public" = {
        apex = "d108.dev";
        rname = "me.d108.dev";
        email = "me@d108.dev";
      };
      dns.zones."public-acme" = {
        apex = "acme.d108.dev";
        rname = alloy.dns.zones."public".rname;
        parentZone = "public";
      };
    };
}
