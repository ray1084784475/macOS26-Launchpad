//
//  ContentView.swift
//  launcher
//
//  Created by 刘波 on 2025/12/6.
//

import SwiftUI
import AppKit
import Combine

// macOS 视觉效果视图
struct VisualEffectView: NSViewRepresentable {
    let material: NSVisualEffectView.Material
    let blendingMode: NSVisualEffectView.BlendingMode
    
    func makeNSView(context: Context) -> NSVisualEffectView {
        let view = NSVisualEffectView()
        view.material = material
        view.blendingMode = blendingMode
        view.state = .active
        return view
    }
    
    func updateNSView(_ nsView: NSVisualEffectView, context: Context) {
        nsView.material = material
        nsView.blendingMode = blendingMode
    }
}

struct AppItem: Identifiable {
    let id = UUID()
    let name: String
    let bundleIdentifier: String
    let icon: NSImage?
}

struct ContentView: View {
    @EnvironmentObject var settingsManager: SettingsManager
    @State private var apps: [AppItem] = []
    @State private var searchText = ""
    
    let columns = [
        GridItem(.adaptive(minimum: 80, maximum: 100), spacing: 20)
    ]
    
    var filteredApps: [AppItem] {
        if searchText.isEmpty {
            return apps
        } else {
            return apps.filter { $0.name.localizedCaseInsensitiveContains(searchText) }
        }
    }
    
    var body: some View {
        ZStack {
            // 液态玻璃浅灰色背景
            VisualEffectView(material: .hudWindow, blendingMode: .behindWindow)
                .overlay(Color(white: 0.10).opacity(0.3))
                .contentShape(Rectangle())
                .onTapGesture {
                    NSApplication.shared.terminate(nil) // 点击空白退出应用
                }
                .ignoresSafeArea()
            
            // 内容层
            VStack(spacing: 20) {
                // 搜索框
                HStack(spacing: 8) {
                    // 搜索图标
                    Image(systemName: "magnifyingglass")
                        .foregroundColor(.white)
                        .font(.system(size: 14))
                        .padding(.top, 40)
                    
                    // 文本输入框
                    TextField("搜索应用", text: $searchText)
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                        .padding(.horizontal)
                        .padding(.top, 40)
                        .frame(maxWidth: 400)
                }
                .padding(.top, 0)
                .frame(maxWidth: 500)
                
                // 应用网格
                ScrollView {
                    LazyVGrid(columns: columns, spacing: 50) {
                        ForEach(filteredApps) { app in
                            AppIconView(app: app)
                                .onTapGesture {
                                    openApplication(app)
                                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                                        NSApplication.shared.terminate(nil) // 启动应用后退出
                                    }
                                }
                        }
                    }
                    .padding(.horizontal, 100)
                    .padding(.bottom, 80)
                    .padding(.top, 40)
                }
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .onAppear {
            loadApplications()
            makeWindowFullscreen()
            
            // 监听刷新通知
            NotificationCenter.default.addObserver(forName: NSNotification.Name("RefreshMainView"),
                                                 object: nil,
                                                 queue: .main) { _ in
                print("收到刷新通知，重新加载应用列表")
                self.loadApplications()
            }
        }
        .onChange(of: settingsManager.hiddenApps) { newValue in
            print("隐藏应用列表变化: \(newValue)")
            loadApplications()
        }
        .onExitCommand {
            NSApplication.shared.terminate(nil) // 按ESC键退出
        }
    }
    
    private func makeWindowFullscreen() {
        if let window = NSApplication.shared.windows.first {
            window.styleMask.remove([.titled, .closable, .miniaturizable, .resizable])
            window.level = .floating
            window.collectionBehavior = [.canJoinAllSpaces, .fullScreenPrimary]
            window.setFrame(NSScreen.main?.frame ?? .zero, display: true)
            
            // 允许点击穿透到其他窗口
            window.ignoresMouseEvents = false
            window.isOpaque = false
            window.backgroundColor = .clear
        }
    }
    
    private func openApplication(_ app: AppItem) {
        let workspace = NSWorkspace.shared
        
        if let appURL = workspace.urlForApplication(withBundleIdentifier: app.bundleIdentifier) {
            let configuration = NSWorkspace.OpenConfiguration()
            configuration.activates = true
            
            workspace.openApplication(at: appURL, configuration: configuration) { _, error in
                if let error = error {
                    print("打开应用失败: \(error)")
                }
            }
        } else {
            // 备用方法：直接尝试打开应用
            let paths = ["/System/Applications/", "/Applications/", "/Applications/Utilities/"]
            
            for path in paths {
                let appPath = path + app.name + ".app"
                if FileManager.default.fileExists(atPath: appPath) {
                    workspace.open(URL(fileURLWithPath: appPath))
                    return
                }
            }
            
            print("未找到应用: \(app.name)")
        }
    }
    
    private func loadApplications() {
        let allApps = getInstalledApplications()
        
        print("=== 开始加载应用 ===")
        print("当前隐藏的应用列表: \(settingsManager.hiddenApps)")
        print("总应用数量: \(allApps.count)")
        
        // 过滤掉用户隐藏的应用
        apps = allApps.filter { app in
            let shouldShow = !settingsManager.hiddenApps.contains { hiddenPath in
                // 获取隐藏应用的名称（去掉 .app 扩展名和路径）
                let hiddenAppName = (hiddenPath as NSString).lastPathComponent
                    .replacingOccurrences(of: ".app", with: "")
                    .trimmingCharacters(in: .whitespacesAndNewlines)
                
                // 获取当前应用的名称
                let currentAppName = app.name.trimmingCharacters(in: .whitespacesAndNewlines)
                
                // 检查是否匹配
                let isHidden = currentAppName.lowercased() == hiddenAppName.lowercased() ||
                              hiddenPath.lowercased().contains(currentAppName.lowercased()) ||
                              app.bundleIdentifier.lowercased().contains(hiddenAppName.lowercased())
                
                if isHidden {
                    print("✗ 隐藏应用: \(currentAppName) 匹配到隐藏路径: \(hiddenPath)")
                }
                
                return isHidden
            }
            
            return shouldShow
        }
        
        print("✓ 显示应用数量: \(apps.count)")
        print("=== 加载完成 ===\n")
    }
    
    private func getInstalledApplications() -> [AppItem] {
        var applications: [AppItem] = []
        let workspace = NSWorkspace.shared
        
        // 获取所有应用目录
        let appDirectories = [
            FileManager.default.urls(for: .applicationDirectory, in: .localDomainMask).first,
            FileManager.default.urls(for: .applicationDirectory, in: .systemDomainMask).first,
            FileManager.default.urls(for: .applicationDirectory, in: .userDomainMask).first
        ].compactMap { $0 }
        
        // 使用字典来去重，以 bundleIdentifier 为键
        var uniqueApps: [String: AppItem] = [:]
        
        for directory in appDirectories {
            do {
                let appURLs = try FileManager.default.contentsOfDirectory(at: directory,
                                                                          includingPropertiesForKeys: [.isDirectoryKey],
                                                                          options: [.skipsHiddenFiles, .skipsSubdirectoryDescendants])
                    .filter { $0.pathExtension.lowercased() == "app" }
                
                for appURL in appURLs {
                    if let bundle = Bundle(url: appURL) {
                        // 获取应用名称
                        let displayName = bundle.object(forInfoDictionaryKey: "CFBundleDisplayName") as? String ??
                                        bundle.object(forInfoDictionaryKey: "CFBundleName") as? String ??
                                        appURL.deletingPathExtension().lastPathComponent
                        
                        // 获取 bundle identifier
                        let bundleIdentifier = bundle.bundleIdentifier ?? "unknown.\(UUID().uuidString)"
                        
                        // 获取应用图标 - 使用 NSWorkspace 的方法
                        let icon = workspace.icon(forFile: appURL.path)
                        
                        let appItem = AppItem(
                            name: displayName,
                            bundleIdentifier: bundleIdentifier,
                            icon: icon
                        )
                        
                        // 使用 bundleIdentifier 去重
                        if uniqueApps[bundleIdentifier] == nil {
                            uniqueApps[bundleIdentifier] = appItem
                        }
                    }
                }
            } catch {
                print("扫描目录 \(directory.path) 时出错: \(error)")
            }
        }
        
        // 将字典值转换为数组并排序
        applications = Array(uniqueApps.values)
            .sorted { $0.name.localizedCompare($1.name) == .orderedAscending }
        
        return applications
    }
}

struct AppIconView: View {
    let app: AppItem
    
    var body: some View {
        VStack(spacing: 8) {
            ZStack {
                // 图标背景
                RoundedRectangle(cornerRadius: 0)
                    .fill(Color.white.opacity(0))
                    .frame(width: 90, height: 90)
                    .shadow(color: Color.black.opacity(0.2), radius: 0, x: 0, y: 2)
                
                // 应用图标
                if let nsImage = app.icon {
                    Image(nsImage: nsImage)
                        .resizable()
                        .scaledToFit()
                        .frame(width: 86, height: 86)
                        .cornerRadius(12)
                } else {
                    // 备用图标
                    Image(systemName: "app.fill")
                        .resizable()
                        .scaledToFit()
                        .frame(width: 50, height: 50)
                        .foregroundColor(.white.opacity(0.7))
                }
            }
            
            // 应用名称
            Text(app.name)
                .font(.system(size: 11, weight: .medium))
                .foregroundColor(.white)
                .multilineTextAlignment(.center)
                .lineLimit(2)
                .frame(width: 90, height: 30)
        }
        .frame(width: 100, height: 130)
    }
}
