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
      url "https://github.com/Ar4l/sshmux/releases/download/v0.1.5/sshmux-aarch64-apple-darwin.tar.gz"
      sha256 "5d7c6ad2fc9435712a0b0494a41d9bedea845e19ece6c2b2eff3ebce9859b349"
    end
  end

  on_linux do
    on_arm do
      url "https://github.com/Ar4l/sshmux/releases/download/v0.1.5/sshmux-aarch64-unknown-linux-musl.tar.gz"
      sha256 "bfaa39eb946c2bb9bb1014b4079f257b220f0825b3334c61054e26ddc76113e2"
    end
    on_intel do
      url "https://github.com/Ar4l/sshmux/releases/download/v0.1.5/sshmux-x86_64-unknown-linux-musl.tar.gz"
      sha256 "98bb56a9d1f3bad6d7bad0e0db836d36a89597ef6b1fa3b0e7d167ad896020a3"
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
    assert_match "0.1.5", shell_output("#{bin}/sshmux --version")
    assert_match "--local-only", shell_output("#{bin}/sshmux --help")
  end
end
