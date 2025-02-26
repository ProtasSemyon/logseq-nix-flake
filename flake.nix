{
  description = "Logseq";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
  };

  outputs = {self, nixpkgs}:
  let 
    system = "x86_64-linux";
    version = "0.10.9";

    pkgs = import nixpkgs {inherit system;};

    logseqAppImage = pkgs.appimageTools.wrapType2 {
      pname = "logseq";
      inherit version;

      src = pkgs.fetchurl{
        url = "https://github.com/logseq/logseq/releases/download/${version}/Logseq-linux-x64-${version}.AppImage";
        sha256 = "5d13ae6364652a71af2b554dbf36ae1ee2c98af79754aac860fa69a33f1f0a67";
      };

      extraPkgs = pkgs: with pkgs; [
        mesa
        libglvnd
        vulkan-loader
        libva
        wayland
      ];
    };

    logseq = pkgs.stdenv.mkDerivation {
      pname = "logseq";
      inherit version;

      src = ./.;

      nativeBuildInputs = [ pkgs.makeWrapper ];
      desktopFile = ./logseq.desktop;

      installPhase = ''
        mkdir -p $out/bin $out/share/applications $out/share/icons/hicolor/256x256/apps

        ln -s ${logseqAppImage}/bin/logseq $out/bin/logseq
        cp $desktopFile $out/share/applications/logseq.desktop
        ''
        #ln -s ${logseqAppImage}/share/icons/hicolor/256x256/apps/logseq.png $out/share/icons/hicolor/256x256/apps/logseq.png
      ;
    };
  in {
    packages.${system}.default = logseq;
  };
}