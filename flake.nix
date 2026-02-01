{
  description = "Salt Workspace - SaltStack configuration management development environment";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-24.05";
    flake-utils.url = "github:numtide/flake-utils";
  };

  outputs = { self, nixpkgs, flake-utils }:
    flake-utils.lib.eachDefaultSystem (system:
      let
        pkgs = import nixpkgs {
          inherit system;
          config = {
            # Vagrant uses BSL 1.1 license (considered unfree by Nix)
            allowUnfree = true;
          };
        };

        # Python environment with required packages
        pythonEnv = pkgs.python311.withPackages (ps: with ps; [
          pyyaml
          jinja2
        ]);

        # Base packages shared across all dev shells
        basePackages = with pkgs; [
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

          # Utilities
          jq
          yq-go
          curl
          wget
        ];

        # Base shell hook
        baseShellHook = ''
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
        '';

        # Create a dev shell with optional VM tools
        mkDevShell = { name, extraPackages ? [], extraHook ? "" }: pkgs.mkShell {
          inherit name;
          buildInputs = basePackages ++ extraPackages;
          shellHook = baseShellHook + extraHook + ''
            echo "Environment:"
            echo "  Python: $(python3 --version)"
            echo "  Make:   $(make --version | head -1)"
            echo "  Docker: $(docker --version 2>/dev/null || echo 'not running')"
            echo ""
          '';
          SALT_WORKSPACE = toString ./.;
        };

      in
      {
        # Default: Docker-based testing (no VM tools, works everywhere)
        devShells.default = mkDevShell {
          name = "salt-workspace";
          extraHook = ''
            echo "Shell: default (Docker-based testing)"
            echo "  For VMs: nix develop .#withVagrant or .#withLima"
            echo ""
          '';
        };

        # With Vagrant: Full VM testing (requires VirtualBox installed separately)
        devShells.withVagrant = mkDevShell {
          name = "salt-workspace-vagrant";
          extraPackages = [ pkgs.vagrant ];
          extraHook = ''
            echo "Shell: withVagrant (requires VirtualBox)"
            echo ""
            echo "Vagrant commands:"
            echo "  vagrant up           - Start Salt master and minion VMs"
            echo "  vagrant ssh linux-1  - Connect to minion"
            echo "  vagrant destroy      - Remove all VMs"
            echo ""
          '';
        };

        # With Lima: Lightweight Linux VMs (macOS/Linux, no VirtualBox needed)
        devShells.withLima = mkDevShell {
          name = "salt-workspace-lima";
          extraPackages = [ pkgs.lima ];
          extraHook = ''
            echo "Shell: withLima (lightweight Linux VMs)"
            echo ""
            echo "Lima commands:"
            echo "  limactl start        - Start default Lima VM"
            echo "  limactl shell        - Open shell in Lima VM"
            echo "  lima nerdctl ...     - Run containers in Lima"
            echo ""
            echo "Quick start for Salt testing:"
            echo "  limactl start template://almalinux-8"
            echo "  limactl shell almalinux-8"
            echo ""
          '';
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
