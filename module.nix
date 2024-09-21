let
  # Lib Functions using only builtins without importing nixpkgs
  nameValuePair = name: value: {inherit name value;};

  filterAttrs = pred: set:
    builtins.listToAttrs (builtins.concatMap (name: let
      v = set.${name};
    in
      if pred name v
      then [(nameValuePair name v)]
      else []) (builtins.attrNames set));


  jsonFiles = builtins.map (file: ./layouts + "/${file}") (builtins.attrNames (builtins.readDir ./layouts));

  layouts = builtins.listToAttrs (map (file: {
      name = builtins.replaceStrings [".json"] [""] (builtins.baseNameOf file);
      value = builtins.fromJSON (builtins.readFile file);
    })
    jsonFiles);

  getLayout = layout: builtins.getAttr layout layouts;
  getAttrName = list: builtins.toString (builtins.head (builtins.attrNames list));
  getKeycode = layout: keyname: builtins.getAttr (filterAttrs (name: _value: name == keyname) (getLayout layout));

  convert = layout: keycode: filterAttrs (_name: value: value == keycode) (getLayout layout);
in {
  config = {
    convertKeycode = layout: keycode: getAttrName (convert layout keycode);
    convertLayout = fromLayout: toLayout: keyname: getAttrName (convert toLayout (getKeycode fromLayout keyname));
  };
}
