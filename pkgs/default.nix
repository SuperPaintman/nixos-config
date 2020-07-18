{ pkgs, lib, ... }:

with pkgs; rec {
  # Applications.
  tdesktop = qt5.callPackage ./applications/networking/instant-messengers/telegram/tdesktop {
    inherit tl-expected;
  };

  # Development.
  flutterPackages =
    recurseIntoAttrs (callPackage ./development/compilers/flutter {});
  flutter = flutterPackages.stable;

  dart = callPackage ./development/interpreters/dart {};

  tl-expected = callPackage ./development/libraries/tl-expected {};
}
