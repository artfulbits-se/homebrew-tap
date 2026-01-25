class EBash < Formula
  desc "Comprehensive Bash script enhancement framework"
  homepage "https://github.com/OleksandrKucherenko/e-bash"
  url "https://github.com/OleksandrKucherenko/e-bash/archive/refs/tags/v2.0.0.tar.gz"
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
    # Install everything to libexec to preserve structure
    libexec.install Dir["*"]
    libexec.install ".scripts" if Dir.exist?(".scripts")

    # Install binaries as symlinks
    bin.install_symlink Dir[libexec/"bin/*"]
  end

  def caveats
    <<~EOS
      e-bash is installed to #{libexec}.
      Add the following to your shell profile:
        export E_BASH="#{opt_libexec}/.scripts"
    EOS
  end

  test do
    assert_predicate libexec/".scripts/_logger.sh", :exist?
  end
end
