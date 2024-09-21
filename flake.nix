{
  description = "Manage Keyboard Layouts";

  outputs = { self }: {
    nixosModules = {
      layouts = import ./module.nix;
    };
  };
}
