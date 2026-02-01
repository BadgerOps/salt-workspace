# Compatibility wrapper for users without flakes enabled.
# Prefer using `nix develop` with flake.nix for better reproducibility.
#
# Usage:
#   nix-shell              # Default (Docker-based)
#   nix-shell --arg withVagrant true   # Include Vagrant
#   nix-shell --arg withLima true      # Include Lima
#
# Or with direnv:
#   echo "use nix" >> .envrc
#   direnv allow

{ pkgs ? import <nixpkgs> { config.allowUnfree = true; }
, withVagrant ? false
, withLima ? false
}:

let
  pythonEnv = pkgs.python311.withPackages (ps: with ps; [
    pyyaml
    jinja2
  ]);

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

  optionalPackages =
    (if withVagrant then [ pkgs.vagrant ] else []) ++
    (if withLima then [ pkgs.lima ] else []);

  shellType =
    if withVagrant then "withVagrant"
    else if withLima then "withLima"
    else "default";

in
pkgs.mkShell {
  name = "salt-workspace";

  buildInputs = basePackages ++ optionalPackages;

  shellHook = ''
    echo ""
    echo "Salt Workspace Development Environment"
    echo "======================================="
    echo ""
    echo "Shell: ${shellType}"
    echo ""
    echo "Available commands:"
    echo "  make          - Build dist/ directory"
    echo "  make test     - Run full test suite (lint + docker)"
    echo "  make lint     - Run linting checks"
    echo "  make docker   - Run Docker-based formula tests"
    echo "  make coverage - Show test coverage"
    echo "  make help     - Show all make commands"
    echo ""
    ${if withVagrant then ''
    echo "Vagrant commands (requires VirtualBox):"
    echo "  vagrant up           - Start Salt master and minion VMs"
    echo "  vagrant ssh linux-1  - Connect to minion"
    echo ""
    '' else ""}
    ${if withLima then ''
    echo "Lima commands:"
    echo "  limactl start        - Start default Lima VM"
    echo "  limactl shell        - Open shell in Lima VM"
    echo "  limactl start template://almalinux-8  - Start AlmaLinux VM"
    echo ""
    '' else ""}
    echo "Environment:"
    echo "  Python: $(python3 --version)"
    echo "  Make:   $(make --version | head -1)"
    echo "  Docker: $(docker --version 2>/dev/null || echo 'not running')"
    echo ""
    ${if !withVagrant && !withLima then ''
    echo "For VMs, use: nix-shell --arg withVagrant true"
    echo "          or: nix-shell --arg withLima true"
    echo ""
    '' else ""}
    echo "Note: For better reproducibility, use 'nix develop' with flakes."
    echo ""
  '';
}
