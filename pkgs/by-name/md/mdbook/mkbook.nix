{
  lib,
  mdbook,
}:
let
  inherit (lib)
    optionalAttrs
    ;
  mkBookTomlFile = conf: { };
  recursiveUpdateList = attrs: attrs;
in
{
  mkbook =
    {
      title,
      name ? title,
      authors ? null,
      description ? null,
      output ? {
        markdown = { };
        html = { };
      },
      book-config ?
        (recursiveUpdateList [
          {
            book = {
              inherit title;
            };
            inherit output;
          }
          (optionalAttrs (authors != null) { book = { inherit authors; }; })
          (optionalAttrs (description != null) { book = { inherit description; }; })
          (optionalAttrs (output ? pdf) { output.html.print.enable = true; })
        ])
        // book-config-extra,
      book-config-extra ? { },
      book-toml ? mkBookTomlFile book-config + book-toml-extra,
      book-toml-extra ? "",
      ...
    }@args:
    { };
}
