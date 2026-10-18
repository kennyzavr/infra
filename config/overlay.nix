{
  flake.alloyModules.infra = { ... }: {
    overlays."main".links = [
      {
        a.host = "silicium";
        b.host = "iridium";
        a.wg.persistentKeepalive = 25;
      }
      {
        a.host = "silicium";
        b.host = "gallium";
        a.wg.persistentKeepalive = 25;
      }
      {
        a.host = "iridium";
        b.host = "gallium";
      }
    ];
  };
}
