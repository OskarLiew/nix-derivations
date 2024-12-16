{ pkgs ? import <nixpkgs> {} }:

pkgs.buildGoModule rec {
  pname = "html2markdown";
  version = "2.2.1";

  # Replace with the URL to your module's source code
  src = pkgs.fetchFromGitHub {
    owner = "JohannesKaufmann";
    repo = "html-to-markdown";
    rev = "v${version}";
    sha256 = "sha256-PikJxSRasPe3NiMf6QW/MOT22PrH69X739jXcqJ+hAk=";
  };

  subPackages = [
    "cli"
  ];

  # Specify dependencies from `go.mod`
  vendorHash = "sha256-/iIG77PPdkTzWuLMmRPN0Ojxrz4AvEfmaZi+Lo8Ouj0=";

  postInstall = ''
    mv $out/bin/cli $out/bin/html2markdown
  '';

}

