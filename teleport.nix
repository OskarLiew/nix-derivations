{ pkgs ? import <nixpkgs> {} }:

with pkgs; stdenv.mkDerivation {
  pname = "tsh";
  version = "1.0.0"; # Replace with the appropriate version

  src = fetchurl {
    url = "https://cdn.teleport.dev/teleport-v15.1.1-linux-amd64-bin.tar.gz";
    sha256 = "sha256-vQ7hUE2+ZWqe9D22t8ZXWSWWmkNPa7RaQRS0aKwY+b8=";
  };

  nativeBuildInputs = [ 
    autoPatchelfHook
  ];

  buildInputs = [ ];

  installPhase = ''
    # Create the bin directory in the output path
    mkdir -p $out/bin
    
    # Unpack the tarball
    tar -xzf $src # Copy the tsh binary to the bin directory
    cp teleport/tsh $out/bin/ # Adjust the path if necessary
  '';
}
