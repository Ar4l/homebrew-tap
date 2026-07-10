cask "chai" do
  version "3.4.0"
  sha256 "bb43849531f9956cb39218a8578e71d6f6569f403d87c54a0f6f2914b5c68f86"

  url "https://github.com/Ar4l/chai/releases/download/v#{version}/Chai-#{version}.zip"
  name "Chai"
  desc "Menu bar utility to prevent the system from going to sleep (fork with lid-closed and battery options)"
  homepage "https://github.com/Ar4l/chai"

  depends_on macos: :sonoma

  app "Chai.app"

  postflight do
    system_command "/usr/bin/xattr",
                   args: ["-dr", "com.apple.quarantine", "#{appdir}/Chai.app"],
                   sudo: false
  end

  caveats <<~EOS
    Chai is ad-hoc signed and not notarized; the quarantine attribute is
    removed on install so Gatekeeper does not block it.

    The "Keep Awake When Lid Is Closed" preference needs administrator
    privileges to run `pmset disablesleep`. For unattended timed sessions,
    add a passwordless sudoers rule:

      echo "$USER ALL=(root) NOPASSWD: /usr/bin/pmset disablesleep 0, /usr/bin/pmset disablesleep 1" \\
        | sudo tee /etc/sudoers.d/chai
  EOS

  zap trash: [
    "~/Library/Preferences/me.villani.lorenzo.Chai.plist",
  ]
end
