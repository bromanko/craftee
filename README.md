# Craftee

A terminal-based TUI application for managing concurrent AI coding agents.

## Development Setup

This project uses [devenv](https://devenv.sh) for managing the development environment and [direnv](https://direnv.net) for automatic environment activation.

### Prerequisites

- [Nix](https://nixos.org/download.html) package manager
- [direnv](https://direnv.net/#getting-started)
- [devenv](https://devenv.sh/getting-started/)

### Getting Started

1. Clone the repository and navigate to the project directory:
   ```bash
   cd craftee
   ```

2. Allow direnv (if not already done):
   ```bash
   direnv allow
   ```

   The environment will automatically activate when you enter the directory.

3. Build the project:
   ```bash
   cargo build
   ```
   or use the devenv script:
   ```bash
   build
   ```

4. Run the application:
   ```bash
   cargo run
   ```
   or:
   ```bash
   run
   ```

### Available Commands

The devenv environment provides several convenient scripts:

- `build` - Build the project
- `run` - Run the application
- `test` - Run tests
- `check` - Run clippy linter
- `format` - Format code with rustfmt

### Pre-commit Hooks

Git hooks are automatically installed to run `rustfmt` and `clippy` before commits.

## Project Structure

```
craftee/
├── src/           # Source code
├── devenv.nix     # Development environment configuration
├── devenv.yaml    # Devenv inputs configuration
├── .envrc         # Direnv configuration
├── Cargo.toml     # Rust package manifest
└── SPEC.md        # Project specification
```

## Technology Stack

- **Language**: Rust
- **Error Handling**: [anyhow](https://github.com/dtolnay/anyhow)

## License

MIT OR Apache-2.0
