{
  description = "Salt Workspace - SaltStack configuration management development environment";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-24.05";
    flake-utils.url = "github:numtide/flake-utils";
  };

  outputs = { self, nixpkgs, flake-utils }:
    flake-utils.lib.eachDefaultSystem (system:
      let
        pkgs = nixpkgs.legacyPackages.${system};

        # Python environment with required packages
        pythonEnv = pkgs.python311.withPackages (ps: with ps; [
          pyyaml
          jinja2
        ]);

      in
      {
        devShells.default = pkgs.mkShell {
          name = "salt-workspace";

          buildInputs = with pkgs; [
            # Python environment
            pythonEnv

            # Build tools
            gnumake
            rsync
            coreutils
            findutils
            gnugrep
            gawk

            # Version control
            git

            # Container tools
            docker
            docker-compose

            # Linting and validation
            yamllint
            shellcheck

            # Vagrant (optional - requires VirtualBox on host)
            vagrant

            # Utilities
            jq
            yq-go
            curl
            wget
          ];

          shellHook = ''
            echo ""
            echo "Salt Workspace Development Environment"
            echo "======================================="
            echo ""
            echo "Available commands:"
            echo "  make          - Build dist/ directory"
            echo "  make test     - Run full test suite (lint + docker)"
            echo "  make lint     - Run linting checks"
            echo "  make docker   - Run Docker-based formula tests"
            echo "  make coverage - Show test coverage"
            echo "  make help     - Show all make commands"
            echo ""
            echo "Vagrant commands (requires VirtualBox):"
            echo "  vagrant up    - Start Salt master and minion VMs"
            echo "  vagrant ssh linux-1 - Connect to minion"
            echo ""
            echo "Environment:"
            echo "  Python: $(python3 --version)"
            echo "  Make:   $(make --version | head -1)"
            echo "  Docker: $(docker --version 2>/dev/null || echo 'not running')"
            echo ""
          '';

          # Environment variables
          SALT_WORKSPACE = toString ./.;
        };

        # Expose packages for nix build
        packages.default = pkgs.stdenv.mkDerivation {
          pname = "salt-workspace";
          version = "1.0.0";
          src = ./.;

          buildInputs = [ pkgs.rsync pkgs.coreutils ];

          buildPhase = ''
            make
          '';

          installPhase = ''
            mkdir -p $out
            cp -r dist/* $out/
          '';
        };
      }
    );
}
