{
  flake.alloyModules.infra = { ... }: {
    hosts.silicium = { ... }: {
      xray."main" = {
        enable = true;
        client = "me-silicium";
        defaultTarget = "msk-tun-bypass";
      };
    };
  };

  flake.alloyModules.infra-prod = { ... }: {
    hosts.silicium = { ... }: { };
  };

  flake.alloyModules.infra-test = { ... }: {
    hosts.silicium = { ... }: { };
  };
}
