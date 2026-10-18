{
  flake.alloyModules.infra = { ... }: {
    hosts.silicium = { ... }: {
      xray."main" = {
        enable = true;
        client = "me-silicium";
        defaultTarget = "default-tun";
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
