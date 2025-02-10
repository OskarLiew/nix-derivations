{ pkgs ? import <nixpkgs> {} }:

let
  lanterna = pkgs.fetchurl {
    url = "https://search.maven.org/remotecontent?filepath=com/googlecode/lanterna/lanterna/3.1.1/lanterna-3.1.1.jar";
    hash = "sha256-7zxCeXYW5v9ritnvkwRpPKdgSptCmkT3HJOaNgQHUmQ=";
  };
in
pkgs.stdenv.mkDerivation (finalAttrs: {
  pname = "filebot";
  version = "4.8.5";

  src = pkgs.fetchurl {
    url = "https://github.com/barry-allen07/FB-Mod/releases/download/4.8.5/FileBot_4.8.5-Linux-Portable.tar.xz";
    hash = "sha256-nznuMgz3njyu/nxxQVzaXQG/Sbzdi8zhXZAiN2wFd+A=";
  };

  unpackPhase = "tar xvf $src";

  nativeBuildInputs = with pkgs; [
    makeWrapper
    autoPatchelfHook
  ];

  buildInputs = with pkgs;[
    zlib
    libzen
    libmediainfo
    curlWithGnuTls
    libmms
    glib
  ];

  postPatch = ''
    # replace lanterna.jar to be able to specify `com.googlecode.lanterna.terminal.UnixTerminal.sttyCommand`
    cp ${lanterna} jar/lanterna.jar
  '';

  dontBuild = true;
  installPhase = with pkgs; ''
    mkdir -p $out/opt $out/bin
    # Since FileBot has dependencies on relative paths between files, all required files are copied to the same location as is.
    cp -r filebot.sh lib/ jar/ $out/opt/
    # Filebot writes to $APP_DATA, which fails due to read-only filesystem. Using current user .local directory instead.
    substituteInPlace $out/opt/filebot.sh \
      --replace 'APP_DATA="$FILEBOT_HOME/data/$USER"' 'APP_DATA=''${XDG_DATA_HOME:-$HOME/.local/share}/filebot/data' \
      --replace '$FILEBOT_HOME/data/.license' '$APP_DATA/.license' \
      --replace '-jar "$FILEBOT_HOME/jar/filebot.jar"' '-Dcom.googlecode.lanterna.terminal.UnixTerminal.sttyCommand=${coreutils}/bin/stty -jar "$FILEBOT_HOME/jar/filebot.jar"'
    wrapProgram $out/opt/filebot.sh \
      --prefix PATH : ${lib.makeBinPath [ (pkgs.jdk17.override { enableJavaFX = true; }) ]}
    # Expose the binary in bin to make runnable.
    ln -s $out/opt/filebot.sh $out/bin/filebot
  '';

  passthru.updateScript = pkgs.genericUpdater {
    versionLister = pkgs.writeShellScript "filebot-versionLister" ''
      curl -s https://www.filebot.net \
        | sed -rne 's,^.*FileBot_([0-9]*\.[0-9]+\.[0-9]+)-portable.tar.xz.*,\1,p'
    '';
  };

  meta = with pkgs.lib; {
    description = "Ultimate TV and Movie Renamer";
    longDescription = ''
      FileBot is the ultimate tool for organizing and renaming your Movies, TV
      Shows and Anime as well as fetching subtitles and artwork. It's smart and
      just works.
    '';
    homepage = "https://filebot.net";
    changelog = "https://www.filebot.net/forums/viewforum.php?f=7";
    sourceProvenance = with sourceTypes; [
      binaryBytecode
      binaryNativeCode
    ];
    license = licenses.free;
    maintainers = with maintainers; [
      gleber
      felschr
    ];
    platforms = platforms.linux;
    mainProgram = "filebot";
  };
})
