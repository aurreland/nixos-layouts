{
  description = "Manage Keyboard Layouts";

  inputs.nixpkgs.url = "github:NixOS/nixpkgs/nixos-24.05";

  outputs = {self, nixpkgs}: {
    lib = let
      inherit (nixpkgs.lib.attrset) filterAttrs;
      jsonFiles = builtins.map (file: ./layouts + "/${file}") (builtins.attrNames (builtins.readDir ./layouts));
      layouts = builtins.listToAttrs (map (file: {
          name = builtins.replaceStrings [".json"] [""] (builtins.baseNameOf file);
          value = builtins.fromJSON (builtins.readFile file);
        })
        jsonFiles);

      getLayout = layout: builtins.getAttr layout layouts;
      getKeycode = layout: keyname: builtins.getAttr (builtins.head (filterAttrs (name: _value: name == keyname) (getLayout layout)));
      getAttrName = list: builtins.toString (builtins.head (builtins.attrNames list));

      convert = layout: keycode: filterAttrs (_name: value: value == keycode) (getLayout layout);
    in {
      convertKeycode = layout: keycode: getAttrName (convert layout keycode);
      convertLayout = fromLayout: toLayout: keyname: getAttrName (convert toLayout (getKeycode fromLayout keyname));
    };
  };
}
