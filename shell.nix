{ pkgs ? import <nixpkgs> {} }:

pkgs.mkShell rec {
  inputsFrom = with pkgs; [
    hivemind
    nodejs
    yarn
  ];
}
