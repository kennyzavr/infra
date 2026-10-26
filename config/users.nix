{
  flake.alloyModules.infra = { config, ... }: {
    services.postbox."public".admin = "me";
    services.postbox."public".users = {
      me = { };
    };

    services.xray."main".clients = {
      me-silicium = { };
      me-lithium = { };
      me-pixel9 = { };
      aine-1 = { };
      aine-2 = { };
      tane-1 = { };
      tane-2 = { };
      luna-1 = { };
      luna-2 = { };
      luna-3 = { };
      leon-1 = { };
      leon-2 = { };
      leon-3 = { };
    };
  };
}
