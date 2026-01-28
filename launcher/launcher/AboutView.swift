//
//  AboutView.swift
//  launcher
//
//  Created by 刘波 on 2025/12/6.
//

import SwiftUI
import AppKit

struct AboutView: View {
    @Environment(\.colorScheme) var colorScheme
    @State private var appIcon: NSImage? = nil
    
    var body: some View {
        VStack(spacing: 0) {
            // 顶部区域 - 简化背景
            ZStack {
                
                
                
                VStack(spacing: 20) {
                    // 软件图标 - 从应用资源加载
                    if let icon = appIcon {
                        Image(nsImage: icon)
                            .resizable()
                            .scaledToFit()
                            .frame(width: 100, height: 100)
                            .shadow(color: .black.opacity(0.1), radius: 5, x: 0, y: 2)
                    } else {
                        // 备用图标
                        Image(systemName: "square.grid.2x2.fill")
                            .resizable()
                            .scaledToFit()
                            .frame(width: 100, height: 100)
                            .foregroundColor(.blue)
                            .shadow(color: .black.opacity(0.1), radius: 5, x: 0, y: 2)
                    }
                    
                    // 应用名称
                    Text("启动台")
                        .font(.system(size: 32, weight: .bold))
                        .foregroundColor(.primary)
                }
                .padding(.vertical, 40)
            }
            .frame(height: 180)
            

            
            // 信息区域
            VStack(spacing: 20) {
                Spacer().frame(height: 20)
                
                // 版本信息
                HStack {
                    Text("版本")
                        .font(.system(size: 14))
                        .foregroundColor(.secondary)
                        .frame(width: 60, alignment: .trailing)
                    Text("1.0")
                        .font(.system(size: 14, weight: .medium))
                        .foregroundColor(.primary)
                        .frame(maxWidth: .infinity, alignment: .leading)
                }
                .frame(width: 280)
                
                // 作者信息
                HStack {
                    Text("作者")
                        .font(.system(size: 14))
                        .foregroundColor(.secondary)
                        .frame(width: 60, alignment: .trailing)
                    Text("Ray")
                        .font(.system(size: 14, weight: .medium))
                        .foregroundColor(.primary)
                        .frame(maxWidth: .infinity, alignment: .leading)
                }
                .frame(width: 280)
                
                Spacer().frame(height: 10)
                // 描述文本
                VStack(spacing: 8) {
                    Text("macOS 26 移除了原生的「启动台」应用，")
                        .multilineTextAlignment(.center)
                        .font(.system(size: 13))
                        .foregroundColor(.secondary)
                    Text("此应用是其替代品，提供简洁高效的应用启动体验。")
                        .multilineTextAlignment(.center)
                        .font(.system(size: 13))
                        .foregroundColor(.secondary)
                }
                .fixedSize(horizontal: false, vertical: true)
                .frame(width: 320)
                .padding(.horizontal, 20)

                // GitHub 链接
                Button(action: {
                    if let url = URL(string: "https://github.com/ray1084784475/macOS26-Launchpad") {
                        NSWorkspace.shared.open(url)
                        NSApplication.shared.terminate(nil)
                    }
                }) {
                    HStack(spacing: 6) {
                        Image(systemName: "link")
                            .font(.system(size: 12))
                        Text("GitHub 项目主页")
                            .font(.system(size: 13, weight: .medium))
                    }
                    .foregroundColor(.blue)
                }
                .buttonStyle(PlainButtonStyle())
                .padding(.top, 8)

                Spacer()
                
                // 完成按钮
                Button(action: {
                    NSApp.keyWindow?.close()
                }) {
                    Text("完成")
                        .font(.system(size: 14, weight: .medium))
                        .frame(width: 140)
                        .padding(.vertical, 10)
                        .background(
                            RoundedRectangle(cornerRadius: 8)
                                .fill(Color.blue)
                        )
                        .foregroundColor(.white)
                        .contentShape(Rectangle())
                }
                .buttonStyle(PlainButtonStyle())
                .keyboardShortcut(.defaultAction)
                .buttonStyle(PlainButtonStyle())
                
                Spacer().frame(height: 30)
            }
            .padding(.horizontal, 24)
        }
        .frame(width: 450, height: 520) // 增大窗口尺寸
        .background(
            colorScheme == .dark ?
            Color(NSColor.windowBackgroundColor) :
            Color(NSColor.controlBackgroundColor)
        )
        .onAppear {
            loadAppIcon()
        }
    }
    
    private func loadAppIcon() {
        // 方法1: 尝试从应用资源加载图标
        if let icon = NSImage(named: "AppIcon") {
            appIcon = icon
        } else {
            // 方法2: 尝试从应用包加载
            let appBundle = Bundle.main
            if let iconPath = appBundle.pathForImageResource("AppIcon"),
               let icon = NSImage(contentsOfFile: iconPath) {
                appIcon = icon
            } else {
                // 方法3: 尝试加载应用自己的图标
                let appPath = Bundle.main.bundlePath
                let workspace = NSWorkspace.shared
                appIcon = workspace.icon(forFile: appPath)
            }
        }
    }
    
    private func getAppVersion() -> String {
        if let version = Bundle.main.object(forInfoDictionaryKey: "CFBundleShortVersionString") as? String,
           let build = Bundle.main.object(forInfoDictionaryKey: "CFBundleVersion") as? String {
            return "\(version) (\(build))"
        }
        return "1.0"
    }
}



#Preview {
    AboutView()
}
