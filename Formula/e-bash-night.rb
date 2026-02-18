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
    # Install to ~/.e-bash (matches install script --global mode)
    e_bash_home = Pathname.new(Dir.home) / ".e-bash"

    # Create directory structure
    e_bash_home.mkpath
    (e_bash_home / ".versions").mkpath

    # Install all files to ~/.e-bash
    e_bash_home.install Dir["*"]
    e_bash_home.install ".scripts" if Dir.exist?(".scripts")

    # Remove development artifacts to save space
    rm_rf e_bash_home / ".claude"
    rm_rf e_bash_home / ".clavix"
    rm_rf e_bash_home / ".github"
    rm_rf e_bash_home / ".lefthook"
    rm_rf e_bash_home / ".idea"
    rm_rf e_bash_home / ".secrets"
    rm_rf e_bash_home / ".vscode"
    rm_rf e_bash_home / ".worktrees"
    rm_rf e_bash_home / "patches"
    rm_rf e_bash_home / "report"
    rm_rf e_bash_home / "spec"
    rm_rf [
      e_bash_home / ".codecov.yml",
      e_bash_home / ".editorconfig",
      e_bash_home / ".edocsrc",
      e_bash_home / ".env.secrets.json",
      e_bash_home / ".lefthook.yml",
      e_bash_home / ".mailmap",
      e_bash_home / ".prompts.md",
      e_bash_home / ".shellcheckrc",
      e_bash_home / ".shellspec",
      e_bash_home / ".shellspec-quick.log",
      e_bash_home / "AGENTS.md",
      e_bash_home / "CLAUDE.md",
      e_bash_home / "mise.toml"
    ].compact

    # Create .gitignore to exclude .versions/ (as install script does)
    File.write(e_bash_home / ".gitignore", <<~EOS
      # exclude .versions worktree folder from git
      .versions/
    EOS
    )

    # Initialize git repo (required for install script detection)
    Dir.chdir e_bash_home do
      system "git", "init"
      system "git", "config", "user.email", "homebrew@local"
      system "git", "config", "user.name", "Homebrew"
      system "git", "add", "."
      system "git", "commit", "-m", "Installed via Homebrew (nightly)"
      system "git", "remote", "add", "e-bash",
             "https://github.com/OleksandrKucherenko/e-bash.git"
      system "git", "fetch", "e-bash", "--tags"
    end

    # Symlink binaries to Homebrew bin
    bin.install_symlink Dir[e_bash_home / "bin/*"]

    # Create 'e-bash' convenience command pointing to install script
    # Allows: e-bash --global upgrade latest
    # Note: Use $HOME at runtime, not build-time path
    (bin / "e-bash").write <<~EOS
      #!/bin/bash
      exec "$HOME/.e-bash/bin/install.e-bash.sh" "$@"
    EOS
    chmod 0755, bin / "e-bash"

    # Upgrade to latest (nightly) version after installation
    system "#{bin}/e-bash", "--global", "upgrade", "latest"
  end

  def caveats
    <<~EOS
      e-bash nightly is installed to ~/.e-bash and upgraded to the latest master.

      Add to your shell profile:
        export E_BASH="$HOME/.e-bash/.scripts"
        export PATH="$HOME/.e-bash/bin:$PATH"

      This formula automatically upgrades to the latest development version.

      To switch to a stable version:
        e-bash --global upgrade v2.0.0

      To list available versions:
        e-bash versions
    EOS
  end

  test do
    assert_path_exists Dir.home / ".e-bash/.scripts/_logger.sh"
  end
end
