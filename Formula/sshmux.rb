# One-command connect for sshmux (https://aral.cc/sshmux/).
#
# Installs a prebuilt `sshmux` binary — no Rust toolchain or C compiler needed —
# except on Intel macOS, which falls back to a source build until a prebuilt
# binary for that arch is published.
class Sshmux < Formula
  desc "One-command QR/URL connect for the sshmux in-browser SSH client"
  homepage "https://aral.cc/sshmux/"
  license "MIT"

  depends_on "cloudflared"

  on_macos do
    on_arm do
      url "https://github.com/Ar4l/sshmux/releases/download/v0.1.2/sshmux-aarch64-apple-darwin.tar.gz"
      sha256 "a37b53fc85ffaca235fb30eef64b4790de1e363afe096b6c34628145bbf802d8"
    end
    on_intel do
      # No prebuilt Intel-macOS binary yet — build from source.
      url "https://github.com/Ar4l/sshmux/archive/refs/tags/v0.1.2.tar.gz"
      sha256 "0bf1b399bc1400427d171eea89ae3f2c5818a2b689702078f068c56cd0860f6a"
      depends_on "rust" => :build
    end
  end

  on_linux do
    on_arm do
      url "https://github.com/Ar4l/sshmux/releases/download/v0.1.2/sshmux-aarch64-unknown-linux-musl.tar.gz"
      sha256 "1af7a2ea5397469e1295dca47328af46e2d263d4c2343ac2ef95bfed22381447"
    end
    on_intel do
      url "https://github.com/Ar4l/sshmux/releases/download/v0.1.2/sshmux-x86_64-unknown-linux-musl.tar.gz"
      sha256 "99d7135c57833817eddb113b358944c40ae6c6e8c969f88e3176e6db1efd4971"
    end
  end

  def install
    # Source tarball (Intel macOS) has a Cargo workspace; prebuilt tarballs are
    # just the binary.
    if File.exist?("Cargo.toml")
      system "cargo", "install", "--path", "cli", "--root", prefix
    else
      bin.install "sshmux"
    end
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
    assert_match "0.1.2", shell_output("#{bin}/sshmux --version")
    assert_match "--local-only", shell_output("#{bin}/sshmux --help")
  end
end
