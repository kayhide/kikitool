with import <nixpkgs> {};

stdenv.mkDerivation rec {
  pname = "kikitool-shell";
  version = "0.1.0";
  buildInputs = with pkgs; [
    hivemind
    yarn
  ];
}
