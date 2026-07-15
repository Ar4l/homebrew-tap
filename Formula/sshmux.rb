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
      url "https://github.com/Ar4l/sshmux/releases/download/v0.1.3/sshmux-aarch64-apple-darwin.tar.gz"
      sha256 "e9953cfcd9a4f964d13c01c38d96705f670d75bd8d230bb8da24b92716b0429d"
    end
    on_intel do
      # No prebuilt Intel-macOS binary yet — build from source.
      url "https://github.com/Ar4l/sshmux/archive/refs/tags/v0.1.3.tar.gz"
      sha256 "e174e693484fde2cc1bd1b24011f40669dcf04a2594be6b6faacf8bdcb7bc72d"
      depends_on "rust" => :build
    end
  end

  on_linux do
    on_arm do
      # No prebuilt linux-arm64 binary for v0.1.3 (CI musl-tools step failed) —
      # build from source until the next release publishes the asset.
      url "https://github.com/Ar4l/sshmux/archive/refs/tags/v0.1.3.tar.gz"
      sha256 "e174e693484fde2cc1bd1b24011f40669dcf04a2594be6b6faacf8bdcb7bc72d"
      depends_on "rust" => :build
    end
    on_intel do
      url "https://github.com/Ar4l/sshmux/releases/download/v0.1.3/sshmux-x86_64-unknown-linux-musl.tar.gz"
      sha256 "723cd99eed7d8308933a7275f99ef10c95e0f27d8205d98d15c6a8376be74db1"
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
    assert_match "0.1.3", shell_output("#{bin}/sshmux --version")
    assert_match "--local-only", shell_output("#{bin}/sshmux --help")
  end
end
