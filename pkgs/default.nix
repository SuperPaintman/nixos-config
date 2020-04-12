{ pkgs, ... }:

with pkgs; rec {
  # Data.
  jetbrains-mono = callPackage ./data/fonts/jetbrains-mono {};
}
