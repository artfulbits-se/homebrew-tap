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
    # On first run, initializes ~/.e-bash from libexec, then delegates to it
    (bin / "e-bash").write <<~EOS
      #!/bin/bash

      E_BASH_HOME="$HOME/.e-bash"
      LIBEXEC="#{libexec}"

      # Initialize ~/.e-bash if not exists
      if [ ! -d "$E_BASH_HOME/.git" ] || [ ! -d "$E_BASH_HOME/.scripts" ]; then
          echo "Initializing e-bash to ~/.e-bash..."
          mkdir -p "$E_BASH_HOME/.versions"
          cp -r "$LIBEXEC/"* "$E_BASH_HOME/" 2>/dev/null || true
          [ -d "$LIBEXEC/.scripts" ] && cp -r "$LIBEXEC/.scripts" "$E_BASH_HOME/" 2>/dev/null || true

          # Create .gitignore
          cat > "$E_BASH_HOME/.gitignore" << 'GITIGNORE'
      # exclude .versions worktree folder from git
      .versions/
      GITIGNORE

          # Initialize git repo
          cd "$E_BASH_HOME"
          git init -q -b master
          git config user.email "homebrew@local" 2>/dev/null || true
          git config user.name "Homebrew" 2>/dev/null || true
          git add -A 2>/dev/null
          git commit -q -m "Installed via Homebrew (nightly)" 2>/dev/null || true
          git remote add origin https://github.com/OleksandrKucherenko/e-bash.git 2>/dev/null || true
          git fetch -q origin --tags 2>/dev/null || true
          git branch --set-upstream-to=origin/master master 2>/dev/null || true

          echo "e-bash initialized. Upgrading to latest master..."
          "$E_BASH_HOME/bin/install.e-bash.sh" --global --force upgrade latest 2>/dev/null || echo "Upgrade skipped (network issue or already up to date)"
          echo ""
      fi

      # Delegate to the install script in ~/.e-bash
      exec "$E_BASH_HOME/bin/install.e-bash.sh" "$@"
    EOS
    chmod 0755, bin / "e-bash"
  end

  def caveats
    <<~EOS
      e-bash nightly installs to ~/.e-bash on first run.

      Add to your shell profile:
        export E_BASH="$HOME/.e-bash/.scripts"
        export PATH="$HOME/.e-bash/bin:$PATH"

      Run 'e-bash versions' to initialize and see available versions.

      To upgrade to latest development version:
        e-bash --global upgrade latest

      To switch to a stable version:
        e-bash --global upgrade v2.0.0
    EOS
  end

  test do
    assert_predicate libexec / ".scripts/_logger.sh", :exist?
  end
end
