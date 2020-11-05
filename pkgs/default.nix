{ pkgs, lib, ... }:

with pkgs; rec {
  # Applications.
  _1password = callPackage ./applications/misc/1password/default.nix {};

  tdesktop = qt5.callPackage ./applications/networking/instant-messengers/telegram/tdesktop {
    inherit tl-expected;
  };

  gh = callPackage ./applications/version-management/git-and-tools/gh/default.nix {};

  # Development.
  flutterPackages =
    recurseIntoAttrs (callPackage ./development/compilers/flutter {});
  flutter = flutterPackages.stable;

  dart = callPackage ./development/interpreters/dart {};

  tl-expected = callPackage ./development/libraries/tl-expected {};

  rustup-openssl = callPackage ./development/tools/rust/rustup-openssl {};
}
