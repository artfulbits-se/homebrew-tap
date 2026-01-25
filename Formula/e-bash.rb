class EBash < Formula
  desc "Comprehensive Bash script enhancement framework"
  homepage "https://github.com/OleksandrKucherenko/e-bash"
  url "https://github.com/OleksandrKucherenko/e-bash/archive/refs/tags/v2.0.0.tar.gz"
  sha256 "b5ce1c797750ed0c1533665bc48650266cdd991c259399412a3afe0f6bd7f69b"
  license "MIT"

  bottle :unneeded

  depends_on "bash"

  def install
    # Install core scripts to libexec (private)
    libexec.install Dir[".scripts/*"]

    # Install binaries
    bin.install Dir["bin/*"].reject { |f| File.directory?(f) }

    # Documentation and Demos
    doc.install "README.md", "LICENSE"
    (pkgshare/"demos").install Dir["demos/*"] if Dir.exist?("demos")
  end

  def caveats
    <<~EOS
      e-bash is installed to #{libexec}.
      Add the following to your shell profile:
        export E_BASH="#{opt_libexec}"
    EOS
  end

  test do
    assert_predicate libexec/"_logger.sh", :exist?
    system "#{bin}/e-bash", "help"
  end
end
