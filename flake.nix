{
  description = "Zen Browser";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs?ref=nixos-unstable";
  };

  outputs = {
    self,
    nixpkgs,
  }: let
    systems = ["aarch64-linux" "x86_64-linux"];
    eachSystem = nixpkgs.lib.genAttrs systems;
    pkgs = nixpkgs.legacyPackages;

    info = builtins.fromJSON (builtins.readFile ./info.json);

    mkZen = system: sourceInfo: pkgs.${system}.callPackage ./package.nix {inherit sourceInfo;};
  in {
    packages = eachSystem (system: {
      zen = mkZen system {
        src = info.x86_64;
        inherit (info) version;
      };
      default = self.packages.${system}.zen;
    });
  };
}
