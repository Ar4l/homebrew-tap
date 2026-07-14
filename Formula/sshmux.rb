# One-command connect for sshmux (https://aral.cc/sshmux/).
class Sshmux < Formula
  desc "One-command QR/URL connect for the sshmux in-browser SSH client"
  homepage "https://aral.cc/sshmux/"
  url "https://github.com/Ar4l/sshmux/archive/refs/tags/v0.1.0.tar.gz"
  sha256 "a0763a55b80c76a1ad26f676f4056db09295c0899a2bf2ca4c0514a953839796"
  license "MIT"
  head "https://github.com/Ar4l/sshmux.git", branch: "main"

  depends_on "rust" => :build
  depends_on "cloudflared"

  def install
    # Build only the CLI workspace member; the wasm web crate is not compiled.
    system "cargo", "install", "--path", "cli", "--root", prefix
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
    # --help must list the safety flag.
    assert_match "--local-only", shell_output("#{bin}/sshmux --help")
  end
end
