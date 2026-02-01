# Salt Workspace

[![CI](https://github.com/BadgerOps/salt-workspace/actions/workflows/ci.yml/badge.svg)](https://github.com/BadgerOps/salt-workspace/actions/workflows/ci.yml)
[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](https://opensource.org/licenses/MIT)
[![Salt Version](https://img.shields.io/badge/Salt-3006.7-blue.svg)](https://docs.saltproject.io/)

A learning workspace for [SaltStack](https://saltproject.io/) configuration management, developed alongside a [blog series](https://blog.badgerops.net).

## Quick Start

**New to this project? Start with [QUICKSTART.md](QUICKSTART.md) for step-by-step setup instructions.**

```bash
# Clone and build
git clone https://github.com/BadgerOps/salt-workspace.git
cd salt-workspace
make

# Run tests
make test

# Start VMs
vagrant up
```

## Project Structure

```
salt-workspace/
├── salt/               # Salt states
│   ├── top.sls         # State assignments
│   └── roles/          # Role-based states
├── formulas/           # Reusable Salt formulas
│   ├── motd/           # Message of the Day
│   ├── packages/       # Package management
│   └── users/          # User management
├── pillar/             # Configuration data
├── config/             # Salt master/minion configs
├── tests/              # Test scripts
├── .devcontainer/      # VS Code / Codespaces config
└── .github/workflows/  # CI/CD pipeline
```

## Prerequisites

**Option A: Use Nix (recommended)** - All tools included automatically:

```bash
nix develop  # or: direnv allow
```

**Option B: Manual installation:**

| Tool | Purpose |
|------|---------|
| [VirtualBox](https://www.virtualbox.org/) | VM hypervisor |
| [Vagrant](https://www.vagrantup.com/) | VM management |
| [Docker](https://www.docker.com/) | Formula testing |
| Python 3 + PyYAML | Lint scripts |

```bash
# Install Vagrant plugin
vagrant plugin install vagrant-hostmanager
```

## Make Commands

| Command | Description |
|---------|-------------|
| `make` | Build dist/ directory |
| `make test` | Run full test suite |
| `make lint` | Linting checks only |
| `make docker` | Docker formula tests |
| `make coverage` | Test coverage report |
| `make package` | Create tarball |
| `make clean` | Remove dist/ |
| `make help` | Show all commands |

## Development

### Workflow

1. Make changes in `salt/`, `formulas/`, or `pillar/`
2. Build: `make`
3. Test: `make test`
4. Apply in VM: `vagrant ssh linux-1` → `sudo salt-call state.highstate`

### Environment Variables

| Variable | Default | Description |
|----------|---------|-------------|
| `LINUX_DISTRO` | almalinux | OS distribution |
| `LINUX_VERSION` | 8 | OS version |
| `LINUX_MINION_COUNT` | 1 | Number of minions |
| `LINUX_BOX_RAM` | 1024 | RAM per VM (MB) |
| `SALT_VERSION` | 3006.7 | Salt version |

### Multiple Minions

```bash
export LINUX_MINION_COUNT=3
vagrant up /linux/
```

### Different Distributions

```bash
# Ubuntu
export LINUX_DISTRO=ubuntu LINUX_VERSION=22.10 && vagrant up

# AlmaLinux 9
export LINUX_DISTRO=almalinux LINUX_VERSION=9 && vagrant up
```

## Creating Formulas

Every formula needs:

```
formulas/myformula/
├── init.sls          # Main state file
├── pillar.example    # Example configuration
└── tests/
    └── init.yaml     # Test definitions
```

See the [packages](formulas/packages/) and [users](formulas/users/) formulas for examples.

## Testing Roles

1. SSH into a minion: `vagrant ssh linux-1`
2. Edit grains: `sudo vim /etc/salt/grains`
   ```yaml
   roles:
     - base
     - your_role
   ```
3. Apply: `sudo salt-call state.highstate`

## Encrypting Secrets

Use GPG for sensitive pillar data:

```bash
# Generate key (one-time setup)
gpg --gen-key --homedir /etc/salt/gpgkeys

# Encrypt a value
echo -n 'mysecret' | gpg --armor --encrypt -r 'Salt Master'
```

Add `#!yaml|gpg` shebang to pillar files with encrypted values.

## Contributing

See [CONTRIBUTING.md](CONTRIBUTING.md) for guidelines.

## Development Environment

### Nix (Recommended)

This project includes a [Nix flake](https://nixos.wiki/wiki/Flakes) for reproducible development environments. All dependencies are pinned and isolated from your system.

**Available shells:**

| Shell | Command | Description |
|-------|---------|-------------|
| Default | `nix develop` | Docker-based testing (works everywhere) |
| Vagrant | `nix develop .#withVagrant` | Full VMs (requires VirtualBox) |
| Lima | `nix develop .#withLima` | Lightweight VMs (macOS/Linux) |

**Quick start:**

```bash
# Default shell (Docker-based, recommended for most users)
nix develop

# Run tests directly
nix develop --command make test

# If you need full VMs for testing
nix develop .#withLima        # Lightweight VMs, no VirtualBox needed
nix develop .#withVagrant     # Traditional Vagrant VMs
```

**With nix-shell (legacy):**

```bash
nix-shell                              # Default
nix-shell --arg withLima true          # With Lima
nix-shell --arg withVagrant true       # With Vagrant
```

**With direnv (automatic activation):**

```bash
direnv allow    # One-time setup, then auto-activates on cd
```

**What's included:**

| Tool | Purpose |
|------|---------|
| Python 3.11 + PyYAML | Scripts and linting |
| Docker + docker-compose | Container-based testing |
| yamllint, shellcheck | Linting and validation |
| make, rsync, git | Build tools |
| jq, yq | YAML/JSON utilities |
| Lima (optional) | Lightweight Linux VMs |
| Vagrant (optional) | Full VM management |

**Installing Nix:**

```bash
# Linux/macOS (multi-user installation)
sh <(curl -L https://nixos.org/nix/install) --daemon

# Enable flakes (add to ~/.config/nix/nix.conf)
experimental-features = nix-command flakes
```

See the [Nix installation guide](https://nixos.org/download.html) for more options.

### VS Code / GitHub Codespaces

This project includes a [Dev Container](.devcontainer/) configuration for instant development environments:

- **VS Code**: Install the Dev Containers extension, then "Reopen in Container"
- **Codespaces**: Click "Code" → "Codespaces" → "Create codespace"

### Local Setup

Follow the instructions in [QUICKSTART.md](QUICKSTART.md).

## Resources

- [Blog Series](https://blog.badgerops.net) - Tutorials and guides
- [Salt Documentation](https://docs.saltproject.io/) - Official docs
- [Salt Formulas](https://github.com/saltstack-formulas) - Community formulas

## License

[MIT License](LICENSE) - see LICENSE file for details.
