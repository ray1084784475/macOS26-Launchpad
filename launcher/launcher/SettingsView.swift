//
//  SettingsView.swift
//  launcher
//
//  Created by 刘波 on 2025/12/6.
//

import SwiftUI
import AppKit
import Combine
import UniformTypeIdentifiers
import Cocoa

struct SettingsView: View {
    @EnvironmentObject var settingsManager: SettingsManager
    @State private var newAppPath = ""
    @State private var showFilePicker = false
    
    func restartApplication() {
        // 保存所有未保存的数据
        UserDefaults.standard.synchronize()
        
        // 清理 SwiftUI 可能存在的缓存
        if let window = NSApp.keyWindow {
            window.close()
        }
        
        // 延迟重启，确保数据保存完成
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            let appURL = Bundle.main.bundleURL
            let config = NSWorkspace.OpenConfiguration()
            config.createsNewApplicationInstance = true

            NSWorkspace.shared.open([appURL], withApplicationAt: appURL, configuration: config, completionHandler: nil)
            NSApplication.shared.terminate(nil)
        }
    }
    
    func stopApplication() {
        UserDefaults.standard.synchronize()
        NSApplication.shared.terminate(nil)
    }
    
    func showAlert() {
        let alert = NSAlert()
        alert.messageText = "提示"
        alert.informativeText = "更改需要重启才能生效"
        alert.alertStyle = .warning
        alert.addButton(withTitle: "立即重启")
        alert.addButton(withTitle: "稍后重启")
        
        let response = alert.runModal()
        if response == .alertFirstButtonReturn {
            restartApplication()
        } else if response == .alertSecondButtonReturn {
            NSApp.keyWindow?.close()
        }
    }
    
    var body: some View {
        VStack(spacing: 0) {
            // 标题栏
            HStack {
                Text("隐藏应用设置")
                    .font(.headline)
                Spacer()
                Button(action: { showFilePicker = true }) {
                    Label("添加应用", systemImage: "plus")
                }
            }
            .padding()
            .background(Color(NSColor.windowBackgroundColor))
            
            Divider()
            
            // 输入区域
            HStack {
                TextField("输入应用路径（如：/Applications/Safari.app）", text: $newAppPath)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                
                Button("添加") {
                    addAppPath()
                }
                .disabled(newAppPath.isEmpty)
                
                Button("选择...") {
                    showFilePicker = true
                }
            }
            .padding()
            
            // 隐藏应用列表
            if settingsManager.hiddenApps.isEmpty {
                Spacer()
                VStack(spacing: 10) {
                    Image(systemName: "app.badge.checkmark")
                        .font(.system(size: 40))
                        .foregroundColor(.gray)
                    Text("暂无隐藏应用")
                        .foregroundColor(.gray)
                    Text("添加应用路径来隐藏它们")
                        .font(.caption)
                        .foregroundColor(.gray)
                }
                Spacer()
            } else {
                ScrollView {
                    VStack(spacing: 0) {
                        ForEach(settingsManager.hiddenApps, id: \.self) { appPath in
                            HStack {
                                Image(systemName: "app")
                                    .foregroundColor(.blue)
                                VStack(alignment: .leading, spacing: 2) {
                                    Text(appPath.components(separatedBy: "/").last ?? "未知应用")
                                        .font(.system(size: 13, weight: .medium))
                                    Text(appPath)
                                        .font(.system(size: 11))
                                        .foregroundColor(.gray)
                                        .lineLimit(1)
                                        .truncationMode(.middle)
                                }
                                Spacer()
                                Button(action: {
                                    settingsManager.removeHiddenApp(path: appPath)
                                }) {
                                    Image(systemName: "trash")
                                        .foregroundColor(.red)
                                }
                                .buttonStyle(PlainButtonStyle())
                            }
                            .padding(.horizontal, 16)
                            .padding(.vertical, 12)
                            .id(appPath)
                            
                            if appPath != settingsManager.hiddenApps.last {
                                Divider()
                                    .padding(.leading, 36)
                            }
                        }
                    }
                    .background(Color(NSColor.controlBackgroundColor))
                    .cornerRadius(8)
                    .overlay(
                        RoundedRectangle(cornerRadius: 8)
                            .stroke(Color.gray.opacity(0.2), lineWidth: 1)
                    )
                    .padding(.horizontal)
                }
            }
            
            Divider()
            
            // 底部说明
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text("提示：")
                        .font(.caption)
                        .foregroundColor(.gray)
                    Text("1. 隐藏的应用将不会出现在启动器主界面中")
                        .font(.caption2)
                        .foregroundColor(.gray)
                    Text("2. 更改需要重启应用才能生效")
                        .font(.caption2)
                        .foregroundColor(.gray)
                }
                Spacer()
                Button("完成") {
                    // 确保数据保存
                    UserDefaults.standard.synchronize()
                    // 通知主界面刷新
                    NotificationCenter.default.post(name: NSNotification.Name("RefreshMainView"), object: nil)
                    NSApp.keyWindow?.close()
                    showAlert()
                }
            }
            .padding()
        }
        .frame(width: 500, height: 400)
        .fileImporter(isPresented: $showFilePicker,
                     allowedContentTypes: [.application],
                     allowsMultipleSelection: false) { result in
            switch result {
            case .success(let urls):
                if let url = urls.first {
                    newAppPath = url.path
                    addAppPath()
                }
            case .failure(let error):
                print("选择文件失败: \(error)")
            }
        }
    }
    
    private func addAppPath() {
        guard !newAppPath.isEmpty else { return }
        
        // 验证路径是否以 .app 结尾
        if newAppPath.hasSuffix(".app") {
            // 检查文件是否存在
            if FileManager.default.fileExists(atPath: newAppPath) {
                settingsManager.addHiddenApp(newAppPath)
                newAppPath = ""
            } else {
                let alert = NSAlert()
                alert.messageText = "路径无效"
                alert.informativeText = "指定的应用路径不存在：\(newAppPath)"
                alert.alertStyle = .warning
                alert.addButton(withTitle: "确定")
                alert.runModal()
            }
        } else {
            let alert = NSAlert()
            alert.messageText = "路径格式错误"
            alert.informativeText = "应用路径必须以 .app 结尾"
            alert.alertStyle = .warning
            alert.addButton(withTitle: "确定")
            alert.runModal()
        }
    }
}
