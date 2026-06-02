{
  description = "My personal/technical blog.";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-26.05";

    # Externally extensible flake systems. See <https://github.com/nix-systems/nix-systems>.
    systems.url = "github:nix-systems/default";
  };

  outputs = {
    # self,
    systems,
    nixpkgs,
    ...
  }: let
    # Nixpkgs library functions.
    lib = nixpkgs.lib;

    # Iterate over each system, configured via the `systems` input.
    eachSystem = lib.genAttrs (import systems);
  in {
    packages = eachSystem (
      system: let
        pkgs = nixpkgs.legacyPackages.${system};
      in {
        default = pkgs.buildNpmPackage {
          pname = "jawad-ahmed.dev";
          version = "0.0.1";
          src = ./.;
          npmDepsHash = "sha256-q32elFX+TLVLPcPWQSVcq7MPw58hxaXPo+qg4vCAhOs=";
          installPhase = ''
            mkdir -p $out
            cp -r dist/* $out/
          '';
        };
      }
    );
    devShells =
      eachSystem
      (system: let
        pkgs = nixpkgs.legacyPackages.${system};
      in {
        default = pkgs.mkShell {
          # inputsFrom = lib.attrValues self.packages.${system};
          packages = [pkgs.nodejs pkgs.typescript-go pkgs.typescript-language-server pkgs.astro-language-server];
        };
      });
  };
}
