{
  description = "Zen Browser";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs?ref=nixos-unstable";
  };

  outputs = {
    self,
    nixpkgs,
  }: let
    inherit (nixpkgs) lib;

    inherit (lib.trivial) warn;
    inherit (lib.attrsets) genAttrs;
    inherit (lib.strings) split;
    inherit (builtins) elemAt fromJSON readFile;

    systems = ["aarch64-linux" "x86_64-linux"];
    eachSystem = genAttrs systems;
    pkgs = nixpkgs.legacyPackages;

    info = fromJSON (readFile ./info.json);

    mkZen = system: sourceInfo: pkgs.${system}.callPackage ./package.nix {inherit sourceInfo;};

    warningMessage = variant: "zen-browser-flake: the `${variant}` package is no longer available. Use the `zen` package instead.";
  in {
    packages = eachSystem (system: {
      zen = mkZen system {
        src = info."${elemAt (split "-" system) 0}";
        inherit (info) version;
      };
      default = self.packages.${system}.zen;
      generic = warn (warningMessage "generic") self.packages.${system}.zen;
      specific = warn (warningMessage "specific") self.packages.${system}.zen;
    });
  };
}
