# Homebrew Formula for statbar
#
# To publish:
#   1. Create repo: github.com/beyond-infra/homebrew-tap
#   2. Copy this file to homebrew-tap/Formula/statbar.rb
#   3. Update `url` and `sha256` for each release
#
# Users install with:
#   brew tap beyond-infra/tap
#   brew install statbar

class Statbar < Formula
  desc "macOS menu bar CPU & memory monitor"
  homepage "https://github.com/beyond-infra/statbar"
  url "https://github.com/beyond-infra/statbar/archive/refs/tags/v0.1.0.tar.gz"
  sha256 "2404217bfa53bd8f29d7f3aae4fde5884e98e069ad4243793ac45cf31b26aa6f"
  license "MIT"

  depends_on macos: :ventura
  uses_from_macos "swift"

  def install
    system "make"
    bin.install "statbar"
  end

  def post_install
    plist = etc/"com.statbar.plist"
    plist.write <<~EOS
      <?xml version="1.0" encoding="UTF-8"?>
      <!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "https://www.apple.com/DTDs/PropertyList-1.0.dtd">
      <plist version="1.0">
      <dict>
        <key>Label</key>
        <string>com.statbar</string>
        <key>Program</key>
        <string>#{opt_bin}/statbar</string>
        <key>RunAtLoad</key>
        <true/>
        <key>KeepAlive</key>
        <true/>
      </dict>
      </plist>
    EOS

    launch_dir = "#{Dir.home}/Library/LaunchAgents"
    target = "#{launch_dir}/com.statbar.plist"
    system "mkdir", "-p", launch_dir
    system "cp", plist, target
    system "launchctl", "bootstrap", "gui/#{Process.uid}", target
    ohai "statbar installed — menu bar should appear immediately"
  end

  def caveats
    <<~EOS
      statbar will auto-start on login. To stop it:
        launchctl bootout gui/#{Process.uid}/com.statbar

      Uninstall:
        brew uninstall statbar
        rm ~/Library/LaunchAgents/com.statbar.plist
    EOS
  end

  test do
    system "#{bin}/statbar", "--version"
  end
end
