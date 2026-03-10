cask "cliply" do
  version "1.0.0"
  sha256 :no_check

  url "https://github.com/luisdergoat/cliply/releases/latest/download/Cliply.dmg"
  name "Cliply"
  desc "Advanced clipboard manager with hotkey support for macOS"
  homepage "https://github.com/luisdergoat/cliply"

  livecheck do
    url :url
    strategy :github_latest
  end

  app "Cliply.app"

  zap trash: [
    "~/Library/Preferences/com.luisdergoat.cliply.plist",
    "~/Library/Application Support/Cliply",
    "~/Library/Caches/com.luisdergoat.cliply",
  ]
end
