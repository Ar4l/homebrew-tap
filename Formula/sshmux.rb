# One-command connect for sshmux (https://aral.cc/sshmux/).
#
# Installs a prebuilt `sshmux` binary — no Rust toolchain or C compiler needed —
# except on Intel macOS, which falls back to a source build until a prebuilt
# binary for that arch is published.
class Sshmux < Formula
  desc "One-command QR/URL connect for the sshmux in-browser SSH client"
  homepage "https://aral.cc/sshmux/"
  version "0.1.1"
  license "MIT"

  on_macos do
    on_arm do
      url "https://github.com/Ar4l/sshmux/releases/download/v0.1.1/sshmux-aarch64-apple-darwin.tar.gz"
      sha256 "64f9bf0c56c2aad1dd77ced4cbc3858744dbb517bef6cab46a32379b4e186a43"
    end
    on_intel do
      # No prebuilt Intel-macOS binary yet — build from source.
      url "https://github.com/Ar4l/sshmux/archive/refs/tags/v0.1.1.tar.gz"
      sha256 "d8b43e556548d0364e96dacc45896e9287f749bb53793298cf27b033f3b7b1dc"
      depends_on "rust" => :build
    end
  end

  on_linux do
    on_arm do
      url "https://github.com/Ar4l/sshmux/releases/download/v0.1.1/sshmux-aarch64-unknown-linux-musl.tar.gz"
      sha256 "de88c8ddf69f95a99b0a31bda1f93cb93dd4f4d20eb2479f9de4cf30ddf78826"
    end
    on_intel do
      url "https://github.com/Ar4l/sshmux/releases/download/v0.1.1/sshmux-x86_64-unknown-linux-musl.tar.gz"
      sha256 "af5ff96bddceddfa149930a215d0bdcf3823e00e4f43804b08df2597942630c8"
    end
  end

  depends_on "cloudflared"

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
    assert_match "sshmux", shell_output("#{bin}/sshmux --version")
    assert_match "--local-only", shell_output("#{bin}/sshmux --help")
  end
end
