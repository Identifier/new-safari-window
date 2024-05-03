//
//  New_Safari_WindowApp.swift
//  New Safari Window
//
//  Created by Daisuke Sakurai on 2024/05/03.
//

import SwiftUI

// App sandboxing has to be disabled to access Safari.
// Apple events have to be enabled to use AppleScript.

// Custom app delegate. Will be called at start up.
class AppDelegate: NSObject, NSApplicationDelegate {
    
    // Will be called when the app is started.
    // Open the Safari window in this function.
    func application(_ application: NSApplication, open urls: [URL]) {
        
        Task.init {
            // Register this app as the default browser.
            try? await NSWorkspace.shared.setDefaultApplication(
                                                 at: Bundle.main.bundleURL,
                                                 toOpenURLsWithScheme: "http")
        }
    
        for url in urls {
            
            // Accept the URL as an input argument
            // Security warning: don't concatenate a URL into this string. It will be prone to code injection attacks.
            let appleScriptString = """
            on run argv
                tell application "Safari"
                    set newWindow to make new document with properties {URL: item 1 of argv}
                    activate
                end tell
            end run
            """
            // `activate` brings all Safari windows to the top.
            
            // This brings the window to the top within all windows of Safari, but will not bring it further afront above other apps.
            // tell application "System Events" to perform action "AXRaise" of newWindow
            
            // This is the only solid way in Swift to use AppleScript with parameters.
            Process.launchedProcess(launchPath: "/usr/bin/osascript", arguments: ["-e", appleScriptString, url.absoluteString])
        }
    }
    
    // Initialization of the app ended. We quit the app.
    func applicationDidFinishLaunching(_ notification: Notification) {
        // Close main app window
        if let window = NSApplication.shared.windows.first {
            window.close()
        }
        
        // Quit the app.
        NSApplication.shared.terminate(self)
    }
}

@main
struct New_Safari_WindowApp: App {
    
    // Set the custom application delegate
    @NSApplicationDelegateAdaptor(AppDelegate.self) var appDelegate
    
    var body: some Scene {
        WindowGroup {
            ContentView()
        }
    }
}
