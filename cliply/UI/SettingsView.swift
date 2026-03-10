import SwiftUI
import ServiceManagement

/// Settings window for Cliply
/// Opens with ⌘⇧⇥
struct SettingsView: View {
    
    @State private var launchAtLogin: Bool = false
    @State private var isEnabled: Bool = true
    @AppStorage("cliplyEnabled") private var cliplyEnabled: Bool = true
    @StateObject private var updateManager = UpdateManager.shared
    
    var body: some View {
        VStack(spacing: 0) {
            // Header mit Icon
            headerView
                .padding(.top, 30)
                .padding(.bottom, 20)
            
            Divider()
                .padding(.horizontal, 40)
            
            // Settings
            settingsContent
                .padding(.horizontal, 40)
                .padding(.vertical, 25)
            
            Divider()
                .padding(.horizontal, 40)
            
            // Footer
            footerView
                .padding(.horizontal, 40)
                .padding(.vertical, 20)
        }
        .frame(width: 580, height: 700)
        .background(Color.scDarkGreen)
        .onAppear {
            loadLaunchAtLoginStatus()
        }
    }
    
    // MARK: - Header
    
    private var headerView: some View {
        VStack(spacing: 12) {
            // App Icon (wenn vorhanden)
            if let appIcon = NSImage(named: "AppIcon") {
                Image(nsImage: appIcon)
                    .resizable()
                    .frame(width: 80, height: 80)
                    .cornerRadius(16)
                    .shadow(color: .black.opacity(0.3), radius: 10, x: 0, y: 5)
            } else {
                // Fallback Icon
                Circle()
                    .fill(Color.scLightBeige.opacity(0.15))
                    .frame(width: 80, height: 80)
                    .overlay(
                        Image(systemName: "doc.on.clipboard.fill")
                            .font(.system(size: 36))
                            .foregroundColor(.scLightBeige)
                    )
            }
            
            Text("Cliply")
                .font(.system(size: 28, weight: .bold))
                .foregroundColor(.scLightBeige)
            
            Text("Clipboard History Manager")
                .font(.system(size: 13))
                .foregroundColor(.scSecondary)
        }
    }
    
    // MARK: - Settings Content
    
    private var settingsContent: some View {
        VStack(spacing: 20) {
            // Launch at Login
            settingRow(
                icon: "power",
                title: "Launch at Login",
                subtitle: "Start Cliply automatically when you log in"
            ) {
                Toggle("", isOn: $launchAtLogin)
                    .toggleStyle(SwitchToggleStyle(tint: Color.scMediumBeige))
                    .labelsHidden()
                    .onChange(of: launchAtLogin) { newValue in
                        setLaunchAtLogin(enabled: newValue)
                    }
            }
            
            Divider()
                .background(Color.scBorder)
            
            // Enable/Disable Cliply
            settingRow(
                icon: "power.circle",
                title: "Enable Cliply",
                subtitle: "Activate or deactivate clipboard monitoring"
            ) {
                Toggle("", isOn: $cliplyEnabled)
                    .toggleStyle(SwitchToggleStyle(tint: Color.scMediumBeige))
                    .labelsHidden()
                    .onChange(of: cliplyEnabled) { newValue in
                        if newValue {
                            HotkeyManager.shared.registerHotkeys()
                            ClipboardManager.shared.startMonitoring()
                        } else {
                            HotkeyManager.shared.unregisterHotkeys()
                            ClipboardManager.shared.stopMonitoring()
                        }
                    }
            }
            
            Divider()
                .background(Color.scBorder)
            
            // Auto-Update Section
            VStack(alignment: .leading, spacing: 10) {
                HStack {
                    Image(systemName: "arrow.triangle.2.circlepath")
                        .font(.system(size: 16))
                        .foregroundColor(.scMediumBeige)
                        .frame(width: 24)
                    
                    Text("Auto-Update")
                        .font(.system(size: 14, weight: .semibold))
                        .foregroundColor(.scLightBeige)
                    
                    Spacer()
                    
                    if updateManager.isCheckingForUpdates {
                        ProgressView()
                            .scaleEffect(0.7)
                            .frame(width: 20, height: 20)
                    } else if updateManager.updateAvailable {
                        Circle()
                            .fill(Color.green)
                            .frame(width: 8, height: 8)
                    }
                }
                
                Text("Check for updates from GitHub releases")
                    .font(.system(size: 11))
                    .foregroundColor(.scSecondary)
                    .padding(.leading, 36)
                
                HStack(spacing: 8) {
                    Button(action: {
                        updateManager.checkForUpdates(showAlertIfNoUpdate: true)
                    }) {
                        HStack(spacing: 6) {
                            Image(systemName: "arrow.clockwise")
                                .font(.system(size: 11))
                            Text("Check for Updates")
                                .font(.system(size: 12, weight: .medium))
                        }
                        .foregroundColor(.scDarkGreen)
                        .padding(.horizontal, 12)
                        .padding(.vertical, 6)
                        .background(
                            RoundedRectangle(cornerRadius: 6, style: .continuous)
                                .fill(Color.scMediumBeige)
                        )
                    }
                    .buttonStyle(PlainButtonStyle())
                    .disabled(updateManager.isCheckingForUpdates)
                    
                    if let latestVersion = updateManager.latestVersion {
                        Text("Latest: v\(latestVersion)")
                            .font(.system(size: 11))
                            .foregroundColor(.scSecondary)
                    }
                    
                    Spacer()
                }
                .padding(.leading, 36)
            }
            
            Divider()
                .background(Color.scBorder)
            
            // Keyboard Shortcuts Info
            VStack(alignment: .leading, spacing: 10) {
                HStack {
                    Image(systemName: "keyboard")
                        .font(.system(size: 16))
                        .foregroundColor(.scMediumBeige)
                        .frame(width: 24)
                    
                    Text("Keyboard Shortcuts")
                        .font(.system(size: 14, weight: .semibold))
                        .foregroundColor(.scLightBeige)
                }
                
                VStack(alignment: .leading, spacing: 6) {
                    shortcutRow(keys: "⌘⇧C", description: "Copy & Save to History")
                    shortcutRow(keys: "⌘⇧V", description: "Show Clipboard History")
                }
                .padding(.leading, 36)
            }
        }
    }
    
    private func settingRow<Content: View>(
        icon: String,
        title: String,
        subtitle: String,
        @ViewBuilder trailing: () -> Content
    ) -> some View {
        HStack(spacing: 12) {
            Image(systemName: icon)
                .font(.system(size: 16))
                .foregroundColor(.scMediumBeige)
                .frame(width: 24)
            
            VStack(alignment: .leading, spacing: 2) {
                Text(title)
                    .font(.system(size: 14, weight: .semibold))
                    .foregroundColor(.scLightBeige)
                
                Text(subtitle)
                    .font(.system(size: 11))
                    .foregroundColor(.scSecondary)
            }
            
            Spacer()
            
            trailing()
        }
    }
    
    private func shortcutRow(keys: String, description: String) -> some View {
        HStack(spacing: 8) {
            Text(keys)
                .font(.system(size: 11, weight: .bold, design: .rounded))
                .foregroundColor(.scDarkGreen)
                .padding(.horizontal, 8)
                .padding(.vertical, 4)
                .background(
                    RoundedRectangle(cornerRadius: 4, style: .continuous)
                        .fill(Color.scMediumBeige)
                )
            
            Text(description)
                .font(.system(size: 11))
                .foregroundColor(.scSecondary)
            
            Spacer()
        }
    }
    
    // MARK: - Footer
    
    private var footerView: some View {
        VStack(spacing: 12) {
            // Version
            Text("Version 1.0.1 Beta")
                .font(.system(size: 11, weight: .medium))
                .foregroundColor(.scSecondary)
            
            // GitHub Link
            Link(destination: URL(string: "https://github.com/Luisdergoat")!) {
                HStack(spacing: 6) {
                    Image(systemName: "link")
                        .font(.system(size: 10))
                    Text("GitHub @Luisdergoat")
                        .font(.system(size: 12, weight: .medium))
                }
                .foregroundColor(.scMediumBeige)
                .padding(.horizontal, 12)
                .padding(.vertical, 6)
                .background(
                    RoundedRectangle(cornerRadius: 6, style: .continuous)
                        .fill(Color.scCardBackground)
                )
            }
            .buttonStyle(PlainButtonStyle())
            
            // Copyright
            Text("© 2024 Cliply. MIT License.")
                .font(.system(size: 10))
                .foregroundColor(.scSecondary.opacity(0.7))
        }
    }
    
    // MARK: - Launch at Login
    
    private func loadLaunchAtLoginStatus() {
        if #available(macOS 13.0, *) {
            launchAtLogin = SMAppService.mainApp.status == .enabled
        }
    }
    
    private func setLaunchAtLogin(enabled: Bool) {
        if #available(macOS 13.0, *) {
            do {
                if enabled {
                    try SMAppService.mainApp.register()
                } else {
                    try SMAppService.mainApp.unregister()
                }
            } catch {
                print("❌ Failed to \(enabled ? "enable" : "disable") launch at login: \(error)")
            }
        }
    }
}

// MARK: - Preview

struct SettingsView_Previews: PreviewProvider {
    static var previews: some View {
        SettingsView()
    }
}
