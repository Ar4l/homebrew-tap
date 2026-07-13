cask "chai" do
  version "3.5.0"
  sha256 "d0d0248183023bba4842194795df09d8369f5c050f7eb38de835eb24d6882cfd"

  url "https://github.com/Ar4l/chai/releases/download/v#{version}/Chai-#{version}.zip"
  name "Chai"
  desc "Keep-awake menu bar utility (fork with lid-closed and battery options)"
  homepage "https://github.com/Ar4l/chai"

  depends_on macos: :sonoma

  app "Chai.app"

  postflight do
    system_command "/usr/bin/xattr",
                   args: ["-dr", "com.apple.quarantine", "#{appdir}/Chai.app"],
                   sudo: false
  end

  zap trash: "~/Library/Preferences/me.villani.lorenzo.Chai.plist"

  caveats <<~EOS
    Chai is ad-hoc signed and not notarized; the quarantine attribute is
    removed on install so Gatekeeper does not block it.

    The "Keep Awake When Lid Is Closed" preference needs administrator
    privileges to run `pmset disablesleep`. For unattended timed sessions,
    Chai offers to install a passwordless sudoers rule in-app
    (/etc/sudoers.d/chai) after a single administrator prompt.

    If you installed that rule, remove it on uninstall with:
      sudo rm /etc/sudoers.d/chai
  EOS
end
