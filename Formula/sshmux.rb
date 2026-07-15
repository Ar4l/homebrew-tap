# One-command connect for sshmux (https://aral.cc/sshmux/).
#
# Installs a prebuilt `sshmux` binary — no Rust toolchain or C compiler needed.
# Supported: macOS arm64 (Apple Silicon), Linux x86_64, and Linux arm64.
class Sshmux < Formula
  desc "One-command QR/URL connect for the sshmux in-browser SSH client"
  homepage "https://aral.cc/sshmux/"
  license "MIT"

  depends_on "cloudflared"

  on_macos do
    on_arm do
      url "https://github.com/Ar4l/sshmux/releases/download/v0.1.4/sshmux-aarch64-apple-darwin.tar.gz"
      sha256 "961a82cc9f11fdced52e4b373aaff962761885f81e1cdf059a3fa6b5ca7007fb"
    end
  end

  on_linux do
    on_arm do
      url "https://github.com/Ar4l/sshmux/releases/download/v0.1.4/sshmux-aarch64-unknown-linux-musl.tar.gz"
      sha256 "847256e175f3a60ca86f2941bc3ab1548aa7b8099589a23328e841f5e477f364"
    end
    on_intel do
      url "https://github.com/Ar4l/sshmux/releases/download/v0.1.4/sshmux-x86_64-unknown-linux-musl.tar.gz"
      sha256 "3b57e7a2c0991da3699275ec51c40ef4c6d6a532c282429f9553f65b53cde5e6"
    end
  end

  def install
    bin.install "sshmux"
  end

  def caveats
    <<~EOS
      sshmux starts a token-gated ws->tcp relay in front of your local sshd and
      exposes it through a cloudflared quick tunnel, then prints a QR + URL that
      open the sshmux web app pre-filled. No inbound port is opened.

      Make sure sshd is reachable on this machine:
        - macOS: System Settings > General > Sharing > enable "Remote Login"
        - Linux: sudo systemctl enable --now ssh

      The printed URL contains a one-time relay access token — treat the whole
      URL like a password. It stops working when you Ctrl-C sshmux.

      Try it locally without exposing anything to the internet:
        sshmux --local-only
    EOS
  end

  test do
    assert_match "0.1.4", shell_output("#{bin}/sshmux --version")
    assert_match "--local-only", shell_output("#{bin}/sshmux --help")
  end
end
