{
  description = "Replacement for the double conversion project";
  inputs.nixpkgs-path.url = "nixpkgs/release-23.05";
  inputs.flake-utils.url = "github:numtide/flake-utils";
  outputs = { self, nixpkgs-path, flake-utils }: 
    let
      inherit (flake-utils.lib.system) 
        x86_64-linux 
        x86_64-darwin 
        aarch64-darwin;
    in flake-utils.lib.eachSystem [ x86_64-linux x86_64-darwin aarch64-darwin ] (system: 
    let
      nixpkgs = import nixpkgs-path { inherit system; };
      inherit (nixpkgs) callPackage;
      buildSettings =
        _: hprev: {
          mkDerivation = args: hprev.mkDerivation ({
            doCheck = false;
            doBenchmark = false;
            doHoogle = false;
            doHaddock = false;
            enableLibraryProfiling = false;
            enableExecutableProfiling = false;
          } // args);
        };
      shellBuildSettings = (old: {
        overrides = nixpkgs.lib.composeExtensions (old.overrides or (_: _: { })) (_: hprev: {
            mkDerivation = args:
              hprev.mkDerivation ({
                doCheck = false;
                doBenchmark = false;
                doHoogle = true;
                doHaddock = true;
                enableLibraryProfiling = false;
                enableExecutableProfiling = false;
              } // args);
          });
      });
      # empty for now
      haskellPkgSetOverlay = nixpkgs.callPackage (_: (_:_: {})) { };
      double-conversion-overlay = hfinal: hprev: 
        let
          inherit (hfinal) callCabal2nix; 
        in { double-conversion-hs = callCabal2nix "double-conversion-hs" ./. { }; };
      haskell-pkgs = nixpkgs.haskell.packages.ghc944.override (
          old: {
            overrides = builtins.foldl' nixpkgs.lib.composeExtensions (old.overrides or (_: _: { })) [buildSettings haskellPkgSetOverlay double-conversion-overlay];
          }
        );
      double-conversion-hs = haskell-pkgs.double-conversion-hs;
    in {
        packages.default = double-conversion-hs;
        packages.double-conversion-hs = double-conversion-hs;
        devShells.default = (haskell-pkgs.override shellBuildSettings).shellFor {
          buildInputs = builtins.attrValues (
            { 
              inherit(haskell-pkgs)
                cabal-install
                ghcid;
            }
          );

          packages = p: [p.double-conversion-hs];
        };
    });

  nixConfig = {
    extra-substituters = ["https://cache.iog.io"];
    extra-trusted-substituters = ["https://cache.iog.io"];
    extra-trusted-public-keys = ["hydra.iohk.io:f/Ea+s+dFdN+3Y/G+FDgSq+a5NEWhJGzdjvKNGv0/EQ="];
    allow-import-from-derivation = "true";
    bash-prompt-prefix = "double-conversion-hs ";
  };

}