# frozen_string_literal: true

class EBashNight < Formula
  desc "Comprehensive Bash script enhancement framework (nightly/latest)"
  homepage "https://github.com/OleksandrKucherenko/e-bash"
  url "https://github.com/OleksandrKucherenko/e-bash/archive/refs/tags/v2.0.0.tar.gz"
  version "2.0.0-nightly"
  sha256 "b5ce1c797750ed0c1533665bc48650266cdd991c259399412a3afe0f6bd7f69b"
  license "MIT"

  depends_on "bash"
  depends_on "coreutils"
  depends_on "git"
  depends_on "jq"
  depends_on "curl"

  on_macos do
    depends_on "gawk"
    depends_on "gnu-sed"
    depends_on "grep"
  end

  def install
    # Install everything to libexec (Homebrew standard location)
    libexec.install Dir["*"]
    libexec.install ".scripts" if Dir.exist?(".scripts")

    # Remove development artifacts to save space
    rm_rf libexec / ".claude"
    rm_rf libexec / ".clavix"
    rm_rf libexec / ".github"
    rm_rf libexec / ".lefthook"
    rm_rf libexec / ".idea"
    rm_rf libexec / ".secrets"
    rm_rf libexec / ".vscode"
    rm_rf libexec / ".worktrees"
    rm_rf libexec / "patches"
    rm_rf libexec / "report"
    rm_rf libexec / "spec"
    rm_rf [
      libexec / ".codecov.yml",
      libexec / ".editorconfig",
      libexec / ".edocsrc",
      libexec / ".env.secrets.json",
      libexec / ".lefthook.yml",
      libexec / ".mailmap",
      libexec / ".prompts.md",
      libexec / ".shellcheckrc",
      libexec / ".shellspec",
      libexec / ".shellspec-quick.log",
      libexec / "AGENTS.md",
      libexec / "CLAUDE.md",
      libexec / "mise.toml"
    ].compact

    # Create 'e-bash' convenience command
    # On first run, uses official installer to set up ~/.e-bash
    (bin / "e-bash").write <<~EOS
      #!/bin/bash

      E_BASH_HOME="$HOME/.e-bash"

      # Handle --force-init flag (for reinstall)
      if [ "$1" = "--force-init" ]; then
          echo "Removing existing ~/.e-bash..."
          rm -rf "$E_BASH_HOME"
          shift
      fi

      # Initialize ~/.e-bash if not exists using official installer
      if [ ! -d "$E_BASH_HOME/.git" ] || [ ! -d "$E_BASH_HOME/.scripts" ]; then
          curl -sSL https://git.new/e-bash | bash -s -- --global install master
      fi

      # Delegate to the install script in ~/.e-bash
      exec "$E_BASH_HOME/bin/install.e-bash.sh" "$@"
    EOS
    chmod 0755, bin / "e-bash"
  end

  def caveats
    <<~EOS
      ⚠️  Run this command to complete installation:
        e-bash versions

      This initializes ~/.e-bash and upgrades to latest master.

      On first run, the installer will add these lines to your shell profile:
        export E_BASH="$HOME/.e-bash/.scripts"
        export PATH="$HOME/.e-bash/bin:$PATH"

      To force reinstallation (after brew reinstall):
        e-bash --force-init versions

      To upgrade to latest development version:
        e-bash --global upgrade latest

      To switch to a stable version:
        e-bash --global upgrade v2.0.0
    EOS
  end

  test do
    assert_path_exists libexec / ".scripts/_logger.sh"
  end
end
