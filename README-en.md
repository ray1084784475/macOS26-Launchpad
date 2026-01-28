
# Launchpad for macOS26

**[简体中文](README.md)** | **English**

<div align="center">
	<img width="100" height="100" src="./assets/logo.png" />
	<h2>Launchpad</h2>
	<img src="https://img.shields.io/badge/Swift-5.0-orange.svg">
  	<img src="https://img.shields.io/badge/Platform-macOS-blue.svg">
  	<img src="https://img.shields.io/badge/License-MIT-lightgrey.svg">
</div>

## Table of Contents

- [Introduction](#introduction)
- [Key Features](#key-features)
- [System Requirements](#system-requirements)
- [Installation](#installation)
- [Usage](#usage)
- [Configuration](#configuration)
- [Contributing](#contributing)
- [License](#license)
- [Contact Us](#contact-us)

## Introduction

The macOS 26 Launchpad is an application launcher designed specifically for the macOS system, aiming to provide a cleaner and more efficient app launching experience. Since macOS 26 removed the native Launchpad functionality, this project serves as a replacement to help users quickly access and manage their installed applications.

This app is developed using the modern SwiftUI framework, featuring beautiful visual effects and a smooth user interaction experience.

## Key Features

### 🚀 **Quick Launch**
- Launch any installed application with one click
- Supports keyboard shortcuts for operation
- Automatically quits after launching an app, keeping the system tidy

### 🔍 **Smart Search**
- Real-time application search for quick location
- Supports fuzzy matching to improve lookup efficiency
- Clean search interface that doesn't obstruct your view

### 🎨 **Beautiful Interface**
- Modern frosted glass visual effects
- Adaptive layout supporting different screen sizes
- Clear display of application icons for visual comfort

### ⚙️ **Flexible Configuration**
- Customizable hidden application list
- Supports batch adding and removal of hidden applications

### 🛡️ **Privacy Protection**
- All configuration data stored locally
- No network permissions required, operates completely offline
- Does not collect any user data

## System Requirements

- **Operating System**: macOS 26 Beta or higher
- **Device**: Mac computer (supports both Apple Silicon and Intel chips)
- **Memory**: 8GB or more recommended
- **Storage Space**: 50MB of free space
- **Development Environment**: Xcode 15.0+, Swift 5.9+


## Installation

### Method 1: Compile from Source (Recommended for Developers)

1. **Clone the project locally**:
```bash
git clone https://github.com/ray1084784475/macOS26-Launchpad.git
cd macOS26-Launchpad
```

2. **Open the project**:
```bash
open Launchpad.xcodeproj
```

3. **Compile and run**:
   - Select the target device (your Mac)
   - Press `⌘ + R` to compile and run

### Method 2: Direct Download of Installer Package

1. Go to the [Releases page](https://github.com/ray1084784475/macOS26-Launchpad/releases)
2. Download the latest version of the `.dmg` file (or the `.app` file for direct launch or copying to the "Applications" folder)
3. Double-click to open the disk image
4. Drag the application to the "Applications" folder
5. Launch the app from "Applications" (or add it to the Dock for quick access)

## Usage

### Basic Operations

1. **Launch the App**:
   - Double-click the app icon to launch Launchpad, or click its icon in the Dock
   - The app will automatically display in fullscreen mode
 
<img width="640" height="480" src="./assets/open.gif" />

2. **Search for Apps**:
   - Enter the app name in the top search box
   - Matching results will be displayed in real-time

3. **Launch an Application**:
   - Click an app icon to launch the corresponding application
   - Launchpad will automatically quit after launching an app
 
 <img width="640" height="480" src="./assets/openapp.gif" />

4. **Quit Launchpad**:
   - Click the **top area** (blank area near the search box)
   - Or use the shortcut `⌘ + Q`

### Keyboard Shortcuts

| Shortcut | Description |
|----------|-------------|
| `⌘ + ,` | Open Settings window |
| `⌘ + I` | Open About window |
| `⌘ + Q` | Quit the application |

### Hidden Apps Management

1. **Open Settings**:
   - Use the shortcut `⌘ + ,`
   - Or select "Settings" from the application menu

2. **Add a Hidden App**:
   - Click the "Add Application" button
   - Select an application file (.app format)
   - Or directly enter the application path

3. **Remove a Hidden App**:
   - In the hidden applications list
   - Click the trash can icon next to the app

4. **Apply Changes**:
   - Click "Done" to save settings
   - Restart the application for changes to take effect

<img width="640" height="480" src="./assets/hide.gif" />


## Contributing

We welcome and appreciate contributions from all developers to this project!

Developers can contact via email `ray_eay@foxmail.com` or `1084784475@qq.com`.

## License

This project is licensed under the MIT License - see the [LICENSE](./LICENSE) file for details.

## Contact Us

If you encounter any issues while using the app or have suggestions for improvement, please feel free to contact us through the following channels:

### Feedback Channels

1. **GitHub Issues**:
   - Go to the [Issues page](https://github.com/ray1084784475/macOS26-Launchpad/issues)
   - Check existing issues or create a new one
   - Describe the problem phenomena and reproduction steps in detail

2. **Feature Suggestions**:
   - Describe your usage scenario and desired features
   - Provide relevant references or examples

3.  **Other Methods**:
      - Contact via email `ray_eay@foxmail.com` or `1084784475@qq.com`.

### Issue Report Template

To better understand and resolve issues, please submit problems using the following template:

```
## Problem Description
[Clearly describe the encountered problem]

## Reproduction Steps
1. [Step 1]
2. [Step 2]
3. [The problem occurs]

## Expected Behavior
[The expected correct behavior]

## Actual Behavior
[The actual erroneous behavior that occurred]

## Environment Information
- Device Model: [e.g., MacBook Pro 2025]
- Chip Type: [e.g., Apple M4]
- App Version: [e.g., 1.0.0]

## Screenshots or Logs
[If available, please provide relevant screenshots or error logs]
```

<div align="center">

<h2>Make Application Launching Simpler and More Efficient</h2>

<b>If this project helps you, please give it a ⭐️<b>


</div>
