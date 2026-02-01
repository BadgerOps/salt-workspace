# Compatibility wrapper for users without flakes enabled.
# Prefer using `nix develop` with flake.nix for better reproducibility.
#
# Usage:
#   nix-shell
#
# Or with direnv:
#   echo "use nix" >> .envrc
#   direnv allow

{ pkgs ? import <nixpkgs> {} }:

let
  pythonEnv = pkgs.python311.withPackages (ps: with ps; [
    pyyaml
    jinja2
  ]);
in
pkgs.mkShell {
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
    echo "Note: For better reproducibility, consider using 'nix develop' with flakes."
    echo ""
  '';
}
