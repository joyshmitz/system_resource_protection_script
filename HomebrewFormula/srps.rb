class Srps < Formula
  desc "System Resource Protection Script (Ananicy-cpp + helpers)"
  homepage "https://github.com/Dicklesworthstone/system_resource_protection_script"
  url "https://github.com/Dicklesworthstone/system_resource_protection_script/archive/refs/tags/v1.1.5.tar.gz"
  sha256 "77a0ac912ba825f1690f4b3bf8c6013ae32b6b6a2bb40fc0efc0d2ec4b725c47"
  license "MIT"

  head "https://github.com/Dicklesworthstone/system_resource_protection_script.git", branch: "main"

  depends_on "bash"
  depends_on "git"
  depends_on "jq"

  def install
    libexec.install "install.sh", "verify.sh", "README.md"
    bin.install_symlink libexec/"install.sh" => "srps-install"
    bin.install_symlink libexec/"verify.sh" => "srps-verify"
  end

  def caveats
    <<~EOS
      Usage:
        srps-verify latest   # verify release integrity
        srps-install --plan  # dry-run the installer
        srps-install         # run installer (prompts for sudo)

      Note: installer makes system-wide changes (ananicy rules, sysctl).
    EOS
  end

  test do
    assert_predicate libexec/"install.sh", :exist?
  end
end
