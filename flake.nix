{
  description = "Replacement for the double conversion project";
  inputs.haskellNix.url = "github:input-output-hk/haskell.nix";
  inputs.nixpkgs-path.url = "nixpkgs/release-23.05";
  inputs.flake-utils.url = "github:numtide/flake-utils";
  outputs = { self, nixpkgs-path, flake-utils, haskellNix }: 
    let
      inherit (flake-utils.lib.system) 
        x86_64-linux 
        x86_64-darwin 
        aarch64-darwin;
    in flake-utils.lib.eachSystem [ x86_64-linux x86_64-darwin aarch64-darwin ] (system: 
      let
        overlays = [ haskellNix.overlay
          (final: prev: {
            # This overlay adds our project to pkgs
            double-conversion-hs =
              final.haskell-nix.project' {
                src = ./.;
                compiler-nix-name = "ghc945";
                # This is used by `nix develop .` to open a shell for use with
                # `cabal`, `hlint` and `haskell-language-server`
                shell.tools = {
                  cabal = { };
                  ghcid = { };
                };
                # Non-Haskell shell tools go here
                shell.buildInputs = with pkgs; [
                  nixpkgs-fmt
                  prev.zlib.dev
                ];
              };
          })
        ];
        pkgs = import nixpkgs-path { inherit system overlays; inherit (haskellNix) config; };
        flake = pkgs.double-conversion-hs.flake {
        };
    in flake // {
        # Built by `nix build .`
        packages.default = flake.packages."double-conversion-hs:lib:double-conversion-hs";
    });

  nixConfig = {
    extra-substituters = ["https://cache.iog.io"];
    extra-trusted-substituters = ["https://cache.iog.io"];
    extra-trusted-public-keys = ["hydra.iohk.io:f/Ea+s+dFdN+3Y/G+FDgSq+a5NEWhJGzdjvKNGv0/EQ="];
    allow-import-from-derivation = "true";
    bash-prompt-prefix = "double-conversion-hs >";
  };

}