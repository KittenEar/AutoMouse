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



    func applicationDidFinishLaunching(_ aNotification: Notification) {
        // Insert code here to initialize your application
        
        // Windowを常に前面表示
        NSApp.windows[0].level = Int(CGWindowLevelForKey(.floatingWindow))
        NSApp.windows[0].acceptsMouseMovedEvents = true

    }

    func applicationWillTerminate(_ aNotification: Notification) {
        // Insert code here to tear down your application
    }

    func applicationShouldTerminateAfterLastWindowClosed(_ sender: NSApplication) -> Bool {
        // ウインドウを閉じたときにアプリを終了する
        return true
    }

}

