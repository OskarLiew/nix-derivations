{ pkgs ? import <nixpkgs> {} }:

pkgs.stdenv.mkDerivation {
  name = "OpenFreezeCenter";
  src = pkgs.fetchFromGitHub {
    owner = "YoCodingMonster";
    repo = "OpenFreezeCenter";
    rev = "2ffc7cc49299e3a6f0188e989663b5b717baebce";
    sha256 = "sha256-QwB5amoDBsGnGzTGUPhLUa10Y9F2kgcFq56x0ZZq2bw=";
  };
  installPhase = ''
    mkdir -p $out
    chmod +x file_1.sh
    chmod +x file_2.sh
    chmod +x install.sh
    cp -R ./* $out/
    cd $out/
    ./install.sh
  '';
}

