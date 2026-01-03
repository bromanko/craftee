{ pkgs, lib, config, inputs, ... }:

{
  # https://devenv.sh/basics/
  env.GREET = "craftee development environment";

  # https://devenv.sh/packages/
  packages = with pkgs; [
  ];

  # https://devenv.sh/languages/
  languages.rust = {
    enable = true;
    channel = "stable";
    components = [ "rustc" "cargo" "clippy" "rustfmt" "rust-analyzer" ];
  };

  # https://devenv.sh/processes/
  # processes.cargo-watch.exec = "cargo-watch";

  # https://devenv.sh/services/
  # services.postgres.enable = true;

  # https://devenv.sh/scripts/
  scripts.hello.exec = ''
    echo hello from $GREET
  '';

  scripts.build.exec = ''
    cargo build
  '';

  scripts.run.exec = ''
    cargo run
  '';

  scripts.test.exec = ''
    cargo test
  '';

  scripts.check.exec = ''
    cargo clippy -- -D warnings
  '';

  scripts.format.exec = ''
    cargo fmt
  '';

  enterShell = ''
    echo "🎨 Welcome to craftee development environment"
    echo ""
    echo "Available commands:"
    echo "  build  - Build the project"
    echo "  run    - Run the application"
    echo "  test   - Run tests"
    echo "  check  - Run clippy linter"
    echo "  format - Format code with rustfmt"
    echo ""
  '';

  # https://devenv.sh/tests/
  enterTest = ''
    echo "Running tests"
    cargo test
  '';

  # https://devenv.sh/pre-commit-hooks/
  git-hooks.hooks = {
    rustfmt.enable = true;
    clippy.enable = true;
  };

  # See full reference at https://devenv.sh/reference/options/
}
