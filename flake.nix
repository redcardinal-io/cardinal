{
  description = "Cardinal- Authentication service of RedCardinal";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs?ref=nixos-unstable";
    flake-utils.url = "github:numtide/flake-utils";
  };

  outputs = { self, nixpkgs, flake-utils, ... }:

    flake-utils.lib.eachDefaultSystem (system:
      let
        pkgs = import nixpkgs {
          inherit system;
        };
      in
      {
        devShells.default = pkgs.mkShell {
          buildInputs = with pkgs; [
            # rust tools
            rustc
            cargo
            rust-analyzer
            rustfmt
            clippy

            # build tools
            pkg-config
            cmake
            gcc

            # dependencies
            openssl
            openssl.dev

            # database tools
            sqlx-cli

            # dev utils
            cargo-watch
            tokei
            docker-compose
          ];

          shellHook = ''
            export RUST_BACKTRACE=1
            export PKG_CONFIG_PATH="${pkgs.openssl.dev}/lib/pkgconfig"
            export DATABASE_URL="postgresql://cardinal:cardinal@localhost:5432/cardinal"
            export SQLX_OFFLINE=true
            export LD_LIBRARY_PATH="${pkgs.lib.makeLibraryPath [ pkgs.openssl.dev ]}"
            
            echo "Cardinal development environment loaded"
         
          '';

        };
      }
    );
}
