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
      url "https://github.com/Ar4l/sshmux/releases/download/v0.1.6/sshmux-aarch64-apple-darwin.tar.gz"
      sha256 "6932d9155be5ff25597a8ff6dcb968939962c77e7ec04812a00607f5444df94f"
    end
  end

  on_linux do
    on_arm do
      url "https://github.com/Ar4l/sshmux/releases/download/v0.1.6/sshmux-aarch64-unknown-linux-musl.tar.gz"
      sha256 "8c7f46be22a2f4567939030e01ef44fa2f898ef23da999cb0e03f6e569b7d999"
    end
    on_intel do
      url "https://github.com/Ar4l/sshmux/releases/download/v0.1.6/sshmux-x86_64-unknown-linux-musl.tar.gz"
      sha256 "1d88caab29b4b1db1bcd67c55cbeec469149776298bb17d3a539a45b01e0752a"
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
    assert_match "0.1.6", shell_output("#{bin}/sshmux --version")
    assert_match "--local-only", shell_output("#{bin}/sshmux --help")
  end
end
