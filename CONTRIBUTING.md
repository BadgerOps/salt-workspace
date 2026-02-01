# Contributing to Salt Workspace

Thank you for your interest in contributing! This guide will help you get started.

## Code of Conduct

Be respectful and constructive in all interactions. We're all here to learn.

## Getting Started

1. Fork the repository on GitHub
2. Clone your fork locally:
   ```bash
   git clone https://github.com/YOUR_USERNAME/salt-workspace.git
   cd salt-workspace
   ```
3. Set up the development environment (see [QUICKSTART.md](QUICKSTART.md))
4. Create a feature branch:
   ```bash
   git checkout -b feature/your-feature-name
   ```

## Development Workflow

### Before Making Changes

1. Ensure your fork is up to date:
   ```bash
   git fetch upstream
   git checkout master
   git merge upstream/master
   ```

2. Run the tests to ensure everything works:
   ```bash
   make test
   ```

### Making Changes

1. Make your changes in your feature branch
2. Follow the coding standards (see below)
3. Test your changes:
   ```bash
   make          # Build
   make test     # Run tests
   ```

### Submitting Changes

1. Commit your changes with a clear message:
   ```bash
   git add .
   git commit -m "feat: add new formula for nginx"
   ```

2. Push to your fork:
   ```bash
   git push origin feature/your-feature-name
   ```

3. Open a Pull Request on GitHub

## Coding Standards

### Salt States (.sls files)

- Use 2-space indentation
- Quote file modes: `'0644'` not `0644`
- Use descriptive state IDs
- Include comments for complex logic

```yaml
# Good example
install_nginx:
  pkg.installed:
    - name: nginx

configure_nginx:
  file.managed:
    - name: /etc/nginx/nginx.conf
    - source: salt://nginx/files/nginx.conf
    - mode: '0644'
    - user: root
    - group: root
    - require:
      - pkg: install_nginx
```

### Formulas

Every formula must have:

1. **init.sls** - Main state file
2. **pillar.example** - Example pillar configuration
3. **tests/** - Directory with test files

### Python Scripts

- Use Python 3
- Use `yaml.safe_load()` not `yaml.load()`
- Follow PEP 8 style guidelines
- Include docstrings for functions

### Shell Scripts

- Use `#!/usr/bin/env bash`
- Use `set -e` for error handling
- Quote variables: `"${var}"` not `$var`

## Commit Message Format

Use conventional commit format:

```
type: short description

Longer description if needed.
```

Types:
- `feat`: New feature
- `fix`: Bug fix
- `docs`: Documentation only
- `style`: Formatting, no code change
- `refactor`: Code restructuring
- `test`: Adding tests
- `chore`: Maintenance tasks

Examples:
```
feat: add users formula for managing system users
fix: correct file permissions in motd formula
docs: update quickstart with Docker instructions
```

## Adding a New Formula

1. Create the formula structure:
   ```bash
   mkdir -p formulas/myformula/tests
   ```

2. Create the state file (`formulas/myformula/init.sls`)

3. Create pillar example (`formulas/myformula/pillar.example`)

4. Create at least one test (`formulas/myformula/tests/init.yaml`)

5. Update pillar to include your formula if needed

6. Test:
   ```bash
   make test
   vagrant up
   vagrant ssh linux-1
   sudo salt-call state.apply myformula
   ```

## Testing

### Running Tests

```bash
make test      # Full test suite (lint + docker)
make lint      # Linting only
make docker    # Docker tests only
make coverage  # Show test coverage
```

### Writing Tests

Tests are YAML files in `formulas/*/tests/` that verify:

- Files exist with correct permissions
- Packages are installed
- Services are running

Example test file:
```yaml
nginx:
  package:
    installed: true
    name: nginx
  service:
    running: true
    enabled: true
  file:
    path: /etc/nginx/nginx.conf
    exists: true
    mode: '0644'
```

## Questions?

- Open an issue on GitHub
- Check the [blog series](https://blog.badgerops.net) for tutorials
- Review existing formulas for examples

## License

By contributing, you agree that your contributions will be licensed under the MIT License.
