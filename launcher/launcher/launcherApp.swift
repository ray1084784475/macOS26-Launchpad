//
//  launcherApp.swift
//  launcher
//
//  Created by 刘波 on 2025/12/6.
//

import SwiftUI
import AppKit
import Combine  // 添加这行

// 设置管理器，用于存储用户设置
class SettingsManager: ObservableObject {
    @Published var hiddenApps: [String] {
        didSet {
            // 立即同步到 UserDefaults
            UserDefaults.standard.set(hiddenApps, forKey: "hiddenApps")
            UserDefaults.standard.synchronize() // 确保立即写入
            print("保存隐藏应用列表: \(hiddenApps)")
        }
    }
    
    init() {
        let saved = UserDefaults.standard.stringArray(forKey: "hiddenApps") ?? []
        print("加载隐藏应用列表: \(saved)")
        self.hiddenApps = saved
    }
    
    func addHiddenApp(_ path: String) {
        if !hiddenApps.contains(path) {
            hiddenApps.append(path)
        }
    }
    
    func removeHiddenApp(at index: Int) {
        guard index >= 0 && index < hiddenApps.count else {
            print("错误：尝试删除的索引 \(index) 超出范围 [0, \(hiddenApps.count-1)]")
            return
        }
        let removed = hiddenApps.remove(at: index)
        print("删除应用: \(removed), 剩余: \(hiddenApps)")
        
        // 确保更新被观察
        objectWillChange.send()
    }
    
    func removeHiddenApp(path: String) {
        hiddenApps.removeAll { $0 == path }
        print("删除应用路径: \(path), 剩余: \(hiddenApps)")
        objectWillChange.send()
    }
    
    var objectWillChange = ObservableObjectPublisher()
}

class AppDelegate: NSObject, NSApplicationDelegate {
    @Published var showSettingsWindow = false
    var settingsWindow: NSWindow?
    var aboutWindow: NSWindow?

    
    func showSettings() {
        if settingsWindow == nil {
            let settingsView = SettingsView()
                .environmentObject(SettingsManager())  // 修改这行
                .frame(width: 500, height: 400)
            
            settingsWindow = NSWindow(
                contentRect: NSRect(x: 0, y: 0, width: 500, height: 400),
                styleMask: [.titled, .closable, .miniaturizable, .resizable],
                backing: .buffered,
                defer: false
            )
            settingsWindow?.center()
            settingsWindow?.setFrameAutosaveName("Settings")
            settingsWindow?.contentView = NSHostingView(rootView: settingsView)
            settingsWindow?.title = "隐藏应用设置"
            settingsWindow?.isReleasedWhenClosed = false
            settingsWindow?.makeKeyAndOrderFront(nil)
            settingsWindow?.level = .floating
            
            // 窗口关闭时清理
            settingsWindow?.delegate = self
        } else {
            settingsWindow?.makeKeyAndOrderFront(nil)
        }
        
        NSApp.activate(ignoringOtherApps: true)
    }
    
    func showAboutWindow() {
        if aboutWindow == nil {
            let aboutView = AboutView()
                .frame(width: 450, height: 520) // 增大尺寸
            
            aboutWindow = NSWindow(
                contentRect: NSRect(x: 0, y: 0, width: 450, height: 520), // 增大尺寸
                styleMask: [.titled, .closable],
                backing: .buffered,
                defer: false
            )
            aboutWindow?.center()
            aboutWindow?.setFrameAutosaveName("About")
            aboutWindow?.contentView = NSHostingView(rootView: aboutView)
            aboutWindow?.title = "关于启动台"
            aboutWindow?.isReleasedWhenClosed = false
            aboutWindow?.makeKeyAndOrderFront(nil)
            aboutWindow?.level = .floating
            aboutWindow?.isMovableByWindowBackground = true
            
            // 窗口关闭时清理
            aboutWindow?.delegate = self
        } else {
            aboutWindow?.makeKeyAndOrderFront(nil)
        }
        
        NSApp.activate(ignoringOtherApps: true)
    }
}

extension AppDelegate: NSWindowDelegate {
    func windowWillClose(_ notification: Notification) {
        if let window = notification.object as? NSWindow {
            if window == settingsWindow {
                settingsWindow = nil
            } else if window == aboutWindow {
                aboutWindow = nil
            }
        }
    }
}

@main
struct launcherApp: App {
    @NSApplicationDelegateAdaptor(AppDelegate.self) var appDelegate
    @StateObject private var settingsManager = SettingsManager()  // 使用 StateObject
    
    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(settingsManager)  // 传递环境对象
                .onAppear {
                    // 窗口出现时隐藏标题栏并全屏
                    DispatchQueue.main.async {
                        if let window = NSApplication.shared.windows.first {
                            window.styleMask.remove([.titled, .closable, .miniaturizable, .resizable])
                            window.level = .floating
                            window.collectionBehavior = [.fullScreenPrimary]
                            window.setFrame(NSScreen.main?.frame ?? .zero, display: true)
                        }
                    }
                }
        }
        .commands {
            // 移除默认的菜单命令
            CommandGroup(replacing: .newItem) { }
            CommandGroup(replacing: .saveItem) { }
            CommandGroup(replacing: .undoRedo) { }
            CommandGroup(replacing: .pasteboard) { }
            CommandGroup(replacing: .systemServices) { }
            
            // 添加自定义菜单
            CommandGroup(after: .appInfo) {
                Divider()
                Button("关于启动台...") {
                    appDelegate.showAboutWindow()
                }
                .keyboardShortcut("i", modifiers: .command)
                
                Button("设置...") {
                    appDelegate.showSettings()
                }
                .keyboardShortcut(",", modifiers: .command)
                
                Divider()
                Button("退出启动器") {
                    NSApplication.shared.terminate(nil)
                }
                .keyboardShortcut("q", modifiers: .command)
            }
        }
    }
}
