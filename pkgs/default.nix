{ pkgs, lib, ... }:

with pkgs; rec {
  # Data.
  jetbrains-mono = callPackage ./data/fonts/jetbrains-mono {};

  # Development.
  go_1_14 = callPackage ./development/compilers/go/1.14.nix ({
    inherit (darwin.apple_sdk.frameworks) Security Foundation;
  } // lib.optionalAttrs stdenv.isAarch64 {
    stdenv = gcc8Stdenv;
    buildPackages = buildPackages // { stdenv = gcc8Stdenv; };
  });

  go = go_1_14;
}
