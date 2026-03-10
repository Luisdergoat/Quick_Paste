import Foundation
import AppKit

/// Manages automatic updates by checking GitHub releases
final class UpdateManager: ObservableObject {
    
    static let shared = UpdateManager()
    
    @Published var isCheckingForUpdates = false
    @Published var updateAvailable = false
    @Published var latestVersion: String?
    @Published var downloadURL: URL?
    @Published var releaseNotes: String?
    @Published var currentVersion: String
    
    private let githubRepoOwner = "Luisdergoat"
    private let githubRepoName = "Quick_Paste"
    
    private init() {
        // Get current version from Info.plist
        if let version = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String {
            self.currentVersion = version
        } else {
            self.currentVersion = "1.0.2 Beta"
        }
    }
    
    // MARK: - Check for Updates
    
    /// Checks GitHub for the latest release
    func checkForUpdates(showAlertIfNoUpdate: Bool = false) {
        guard !isCheckingForUpdates else { return }
        
        isCheckingForUpdates = true
        updateAvailable = false
        
        let urlString = "https://api.github.com/repos/\(githubRepoOwner)/\(githubRepoName)/releases/latest"
        
        guard let url = URL(string: urlString) else {
            print("❌ UpdateManager: Invalid GitHub API URL")
            isCheckingForUpdates = false
            return
        }
        
        print("🔍 UpdateManager: Checking for updates at \(urlString)")
        
        var request = URLRequest(url: url)
        request.setValue("application/vnd.github.v3+json", forHTTPHeaderField: "Accept")
        
        URLSession.shared.dataTask(with: request) { [weak self] data, response, error in
            guard let self = self else { return }
            
            DispatchQueue.main.async {
                self.isCheckingForUpdates = false
            }
            
            if let error = error {
                print("❌ UpdateManager: Error checking for updates: \(error.localizedDescription)")
                return
            }
            
            guard let data = data else {
                print("❌ UpdateManager: No data received")
                return
            }
            
            do {
                guard let json = try JSONSerialization.jsonObject(with: data) as? [String: Any] else {
                    print("❌ UpdateManager: Invalid JSON response")
                    return
                }
                
                self.parseReleaseResponse(json, showAlertIfNoUpdate: showAlertIfNoUpdate)
                
            } catch {
                print("❌ UpdateManager: Error parsing JSON: \(error.localizedDescription)")
            }
            
        }.resume()
    }
    
    private func parseReleaseResponse(_ json: [String: Any], showAlertIfNoUpdate: Bool) {
        guard let tagName = json["tag_name"] as? String else {
            print("❌ UpdateManager: No tag_name in response")
            return
        }
        
        // Remove 'v' prefix if present (e.g., "v1.0.1" -> "1.0.1")
        let versionString = tagName.hasPrefix("v") ? String(tagName.dropFirst()) : tagName
        
        print("📦 UpdateManager: Latest version on GitHub: \(versionString)")
        print("📱 UpdateManager: Current version: \(currentVersion)")
        
        DispatchQueue.main.async {
            self.latestVersion = versionString
            self.releaseNotes = json["body"] as? String
            
            // Find DMG asset in release
            if let assets = json["assets"] as? [[String: Any]] {
                for asset in assets {
                    if let name = asset["name"] as? String,
                       name.hasSuffix(".dmg"),
                       let downloadURLString = asset["browser_download_url"] as? String,
                       let downloadURL = URL(string: downloadURLString) {
                        self.downloadURL = downloadURL
                        print("💿 UpdateManager: Found DMG: \(downloadURL)")
                        break
                    }
                }
            }
            
            // Compare versions
            if self.isNewerVersion(versionString, than: self.currentVersion) {
                print("🎉 UpdateManager: Update available!")
                self.updateAvailable = true
                self.showUpdateAlert()
            } else {
                print("✅ UpdateManager: Already up to date")
                if showAlertIfNoUpdate {
                    self.showNoUpdateAlert()
                }
            }
        }
    }
    
    // MARK: - Version Comparison
    
    private func isNewerVersion(_ version1: String, than version2: String) -> Bool {
        // Remove "Beta" suffix for comparison
        let v1 = version1.replacingOccurrences(of: " Beta", with: "")
        let v2 = version2.replacingOccurrences(of: " Beta", with: "")
        
        let components1 = v1.split(separator: ".").compactMap { Int($0) }
        let components2 = v2.split(separator: ".").compactMap { Int($0) }
        
        // Compare each version component
        for i in 0..<max(components1.count, components2.count) {
            let num1 = i < components1.count ? components1[i] : 0
            let num2 = i < components2.count ? components2[i] : 0
            
            if num1 > num2 {
                return true
            } else if num1 < num2 {
                return false
            }
        }
        
        return false
    }
    
    // MARK: - Download and Install
    
    func downloadAndInstall() {
        guard let downloadURL = downloadURL else {
            print("❌ UpdateManager: No download URL available")
            return
        }
        
        print("⬇️ UpdateManager: Downloading update from \(downloadURL)")
        
        // Show progress alert
        DispatchQueue.main.async {
            self.showDownloadingAlert()
        }
        
        let downloadTask = URLSession.shared.downloadTask(with: downloadURL) { [weak self] localURL, response, error in
            guard let self = self else { return }
            
            if let error = error {
                print("❌ UpdateManager: Download error: \(error.localizedDescription)")
                DispatchQueue.main.async {
                    self.showDownloadErrorAlert()
                }
                return
            }
            
            guard let localURL = localURL else {
                print("❌ UpdateManager: No local file URL")
                return
            }
            
            // Move DMG to Downloads folder
            let downloadsURL = FileManager.default.urls(for: .downloadsDirectory, in: .userDomainMask).first!
            let destinationURL = downloadsURL.appendingPathComponent("Cliply-Update.dmg")
            
            do {
                // Remove old DMG if exists
                if FileManager.default.fileExists(atPath: destinationURL.path) {
                    try FileManager.default.removeItem(at: destinationURL)
                }
                
                try FileManager.default.moveItem(at: localURL, to: destinationURL)
                
                print("✅ UpdateManager: DMG downloaded to \(destinationURL.path)")
                
                DispatchQueue.main.async {
                    self.showInstallInstructions(dmgPath: destinationURL)
                }
                
            } catch {
                print("❌ UpdateManager: Error moving DMG: \(error.localizedDescription)")
            }
        }
        
        downloadTask.resume()
    }
    
    // MARK: - Alerts
    
    private func showUpdateAlert() {
        let alert = NSAlert()
        alert.messageText = "Update Available! 🎉"
        alert.informativeText = """
        A new version of Cliply is available!
        
        Current Version: \(currentVersion)
        Latest Version: \(latestVersion ?? "Unknown")
        
        Would you like to download and install the update?
        """
        alert.alertStyle = .informational
        alert.addButton(withTitle: "Download & Install")
        alert.addButton(withTitle: "View Release Notes")
        alert.addButton(withTitle: "Later")
        
        let response = alert.runModal()
        
        if response == .alertFirstButtonReturn {
            downloadAndInstall()
        } else if response == .alertSecondButtonReturn {
            if let releaseURL = URL(string: "https://github.com/\(githubRepoOwner)/\(githubRepoName)/releases/latest") {
                NSWorkspace.shared.open(releaseURL)
            }
        }
    }
    
    private func showNoUpdateAlert() {
        let alert = NSAlert()
        alert.messageText = "You're Up to Date! ✅"
        alert.informativeText = "Cliply \(currentVersion) is the latest version."
        alert.alertStyle = .informational
        alert.addButton(withTitle: "OK")
        alert.runModal()
    }
    
    private func showDownloadingAlert() {
        let alert = NSAlert()
        alert.messageText = "Downloading Update..."
        alert.informativeText = "Please wait while the update is being downloaded."
        alert.alertStyle = .informational
        
        // This alert is just informational, will be dismissed when download completes
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
            if let window = NSApp.windows.first(where: { $0.isModalPanel }) {
                window.close()
            }
        }
    }
    
    private func showDownloadErrorAlert() {
        let alert = NSAlert()
        alert.messageText = "Download Failed"
        alert.informativeText = "Could not download the update. Please try again later or download manually from GitHub."
        alert.alertStyle = .warning
        alert.addButton(withTitle: "Open GitHub")
        alert.addButton(withTitle: "OK")
        
        let response = alert.runModal()
        if response == .alertFirstButtonReturn {
            if let releaseURL = URL(string: "https://github.com/\(githubRepoOwner)/\(githubRepoName)/releases/latest") {
                NSWorkspace.shared.open(releaseURL)
            }
        }
    }
    
    private func showInstallInstructions(dmgPath: URL) {
        let alert = NSAlert()
        alert.messageText = "Update Downloaded! 🎉"
        alert.informativeText = """
        The update has been downloaded to:
        \(dmgPath.path)
        
        To install:
        1. Quit Cliply
        2. Open the DMG file
        3. Drag Cliply to Applications folder
        4. Replace the old version
        5. Restart Cliply
        
        Would you like to open the Downloads folder?
        """
        alert.alertStyle = .informational
        alert.addButton(withTitle: "Open Downloads")
        alert.addButton(withTitle: "Quit & Install")
        alert.addButton(withTitle: "Later")
        
        let response = alert.runModal()
        
        if response == .alertFirstButtonReturn {
            NSWorkspace.shared.selectFile(dmgPath.path, inFileViewerRootedAtPath: "")
        } else if response == .alertSecondButtonReturn {
            NSWorkspace.shared.selectFile(dmgPath.path, inFileViewerRootedAtPath: "")
            NSApp.terminate(nil)
        }
    }
}
