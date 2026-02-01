# Quick Start Guide

Get up and running with Salt Workspace in minutes.

## Prerequisites

### Option A: Nix (Recommended)

If you have [Nix](https://nixos.org/) installed, all dependencies are provided automatically:

```bash
# Enter the development environment (all tools included)
nix develop

# Or with direnv for automatic activation
direnv allow
```

Skip to [Clone & Build](#1-clone--build) if using Nix.

### Option B: Manual Installation

Install these tools before starting:

| Tool | macOS | Ubuntu/Debian | Purpose |
|------|-------|---------------|---------|
| [VirtualBox](https://www.virtualbox.org/wiki/Downloads) | `brew install virtualbox` | [Download](https://www.virtualbox.org/wiki/Linux_Downloads) | VM hypervisor |
| [Vagrant](https://www.vagrantup.com/downloads) | `brew install vagrant` | `apt install vagrant` | VM management |
| [Docker](https://docs.docker.com/get-docker/) | `brew install docker` | `apt install docker.io` | Test runner |
| Python 3 | `brew install python3` | `apt install python3 python3-pip` | Scripts |
| PyYAML | `pip3 install pyyaml` | `pip3 install pyyaml` | YAML parsing |

After installing Vagrant, add the hostmanager plugin:

```bash
vagrant plugin install vagrant-hostmanager
```

## 1. Clone & Build

```bash
git clone https://github.com/BadgerOps/salt-workspace.git
cd salt-workspace
make
```

## 2. Run Tests

```bash
make test
```

## 3. Start VMs

```bash
vagrant up
```

This starts:
- **saltmaster** - Salt master server
- **linux-1** - Test minion (AlmaLinux 8 by default)

## 4. Connect to Minion

```bash
vagrant ssh linux-1
sudo salt-call state.highstate
```

## Common Tasks

### Test a Role

Edit `/etc/salt/grains` on the minion:

```yaml
roles:
  - base
  - your_role
```

Then apply:

```bash
sudo salt-call state.highstate
```

### Multiple Minions

```bash
export LINUX_MINION_COUNT=3
vagrant up
```

### Different OS

```bash
# Ubuntu
export LINUX_DISTRO=ubuntu
export LINUX_VERSION=22.10
vagrant up

# AlmaLinux 9
export LINUX_DISTRO=almalinux
export LINUX_VERSION=9
vagrant up
```

### More Memory

```bash
export LINUX_BOX_RAM=2048
vagrant up
```

## Makefile Commands

| Command | Description |
|---------|-------------|
| `make` | Build dist/ directory |
| `make test` | Run all tests |
| `make lint` | Run linting only |
| `make docker` | Run Docker tests |
| `make coverage` | Show test coverage |
| `make clean` | Remove dist/ |
| `make help` | Show all commands |

## Project Structure

```
salt-workspace/
├── salt/           # Salt states
│   ├── top.sls     # State assignments
│   └── roles/      # Role definitions
├── formulas/       # Reusable formulas
├── pillar/         # Configuration data
├── config/         # Salt master/minion configs
├── tests/          # Test scripts
└── dist/           # Built output (generated)
```

## Creating a Formula

1. Create formula directory:
   ```bash
   mkdir -p formulas/myformula/tests
   ```

2. Add state file `formulas/myformula/init.sls`:
   ```yaml
   myformula_package:
     pkg.installed:
       - name: mypackage
   ```

3. Add pillar example `formulas/myformula/pillar.example`:
   ```yaml
   myformula:
     enabled: true
   ```

4. Add test `formulas/myformula/tests/init.yaml`:
   ```yaml
   myformula:
     package:
       installed: true
       name: mypackage
   ```

5. Build and test:
   ```bash
   make test
   ```

## Troubleshooting

**make test fails with YAML errors:**
```bash
pip3 install pyyaml
```

**Vagrant can't find boxes:**
```bash
vagrant box update
```

**Salt commands fail:**
```bash
vagrant provision  # Re-run provisioning
```

## Next Steps

- Read the [full README](README.md) for detailed documentation
- Check out the [blog series](https://blog.badgerops.net) for tutorials
- Explore the [motd formula](formulas/motd/) as an example
- Review [CONTRIBUTING.md](CONTRIBUTING.md) to contribute
