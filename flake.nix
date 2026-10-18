{
    inputs = {
        nixpkgs.url = "github:NixOS/nixpkgs/nixos-26.05";
        NopSCADlib = {
          flake = false;
          url = "git+file:./libs/NopSCADlib";
        };
    };
    outputs = {self, nixpkgs, NopSCADlib }:
        let
            system = "x86_64-linux";
            pkgs = import nixpkgs {
              inherit system;
            };
            python = pkgs.python314;
            localFont = pkgs.stdenv.mkDerivation {
              pname = "nopscad-7seg-font";
              version = "1.0";
              src = NopSCADlib;
              installPhase = ''
                mkdir -p $out/share/fonts/truetype
                cp -r $src/docs/*.TTF $out/share/fonts/truetype
              '';
            };
            fontsConf = pkgs.makeFontsConf {
              fontDirectories = [
                localFont
              ];
            };
        in {
            devShells.${system}.default = pkgs.mkShell {
                buildInputs = with pkgs; [
                    bashInteractive
                    imagemagick
                    localFont
                    openscad

                    python
                    pkgs.stdenv.cc.cc.lib # for python C extensions
                ];
                shellHook = ''
                  if [ ! -d venv ]; then
                    python -m venv venv
                  fi
                  source venv/bin/activate
                  pip install --upgrade pip
                  pip install colorama
                  pip install codespell
                  pip install markdown
                  export FONTCONFIG_FILE="${fontsConf}"
                  export OPENSCADPATH="`realpath libs`"
                  export PATH=$PATH:"`realpath libs/NopSCADlib/scripts`"
                '';
            };
        };
}

