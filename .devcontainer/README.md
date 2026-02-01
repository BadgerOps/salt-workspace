# Dev Container for Salt Workspace

This directory contains configuration for [VS Code Dev Containers](https://code.visualstudio.com/docs/devcontainers/containers) and [GitHub Codespaces](https://github.com/features/codespaces).

## Features

- Python 3.11 with PyYAML pre-installed
- Docker-in-Docker for running formula tests
- VS Code extensions for Salt/YAML development
- Automatic project build on container creation

## Using with VS Code

1. Install the [Dev Containers extension](https://marketplace.visualstudio.com/items?itemName=ms-vscode-remote.remote-containers)
2. Open this repository in VS Code
3. Click "Reopen in Container" when prompted (or use Command Palette: "Dev Containers: Reopen in Container")

## Using with GitHub Codespaces

1. Go to the repository on GitHub
2. Click "Code" → "Codespaces" → "Create codespace on master"
3. Wait for the environment to build

## What's Included

- **Python 3.11**: For running tests and scripts
- **Docker**: For formula testing with `make docker`
- **Git**: For version control
- **PyYAML**: Required for lint tests
- **VS Code Extensions**:
  - YAML support
  - Python support
  - SaltStack syntax highlighting
  - EditorConfig support
  - GitHub PR integration

## Limitations

Note: Vagrant/VirtualBox is not available in Dev Containers. For full VM testing, use a local development environment.

Available commands:
- `make` - Build the project
- `make test` - Run lint tests
- `make docker` - Run Docker-based formula tests
- `make coverage` - Show test coverage
