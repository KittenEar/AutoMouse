//
//  AppDelegate.swift
//  AutoMouse
//
//  Created by cat-07 on 2016/09/02.
//  Copyright © 2016年 cat-07. All rights reserved.
//

import Cocoa

@NSApplicationMain
class AppDelegate: NSObject, NSApplicationDelegate {



    func applicationDidFinishLaunching(aNotification: NSNotification) {
        // Insert code here to initialize your application
        
        // Windowを常に前面表示
        NSApp.windows[0].level = Int(CGWindowLevelForKey(.FloatingWindowLevelKey))
        NSApp.windows[0].acceptsMouseMovedEvents = true

    }

    func applicationWillTerminate(aNotification: NSNotification) {
        // Insert code here to tear down your application
    }

    func applicationShouldTerminateAfterLastWindowClosed(sender: NSApplication) -> Bool {
        // ウインドウを閉じたときにアプリを終了する
        return true
    }

}

