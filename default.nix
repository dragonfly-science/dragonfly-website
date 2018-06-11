let
  reflex-platform = import ((import <nixpkgs> {}).pkgs.fetchFromGitHub {
      owner = "reflex-frp";
      repo = "reflex-platform";
      rev = "f003577699ad5a47f8275dad4f05cdb15c4bcdf5";
      sha256 = "1fwg9cfz6p6zrlk1j5648r9hc5s2m62cwwv036sc7byb3pdhlxdr";
    }) {};
  nixpkgs = reflex-platform.nixpkgs;
  project = reflex-platform.project ({ pkgs, ... }: {
    packages = {
      dragonfly-website = ./haskell;
    };

    overrides = self: super: {
      pandoc = pkgs.haskell.lib.doJailbreak super.pandoc;
    };

    shells = {
     ghc = ["dragonfly-website"];
     ghcjs = [];
    };
  });

in project
