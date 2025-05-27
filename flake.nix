# SPDX-License-Identifier: Unlicense
{
  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixpkgs-unstable";
  };

  outputs =
    {
      self,
      nixpkgs,
      flake-utils,
    }:
    flake-utils.lib.eachSystem nixpkgs.lib.systems.flakeExposed (
      system:
      let
        pkgs = import nixpkgs {
          inherit system;
          config.android_sdk.accept_license = true;
          config.allowUnfree = true;
        };
      in
      {
        packages = flake-utils.lib.flattenTree { inherit (pkgs) hello; };

        devShells.default = pkgs.mkShell {
          buildInputs = with pkgs; [
            flutter
            pkg-config
            zenity
            dart
            jdk17
          ];
        };
      }
    );
}
