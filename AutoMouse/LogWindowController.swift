//
//  LogWindowController.swift
//  AutoMouse
//
//  Created by cat-07 on 2016/01/13.
//  Copyright © 2016年 cat-07. All rights reserved.
//

import Cocoa

class LogWindowController: NSWindowController {

    @IBOutlet var logTextView: NSTextView!

    override func windowDidLoad() {
        super.windowDidLoad()

    }
    
    func debugWindow(_ items: Any ...) {
        
        let log = NSMutableString.init()

        let dateFormatter = DateFormatter()
        dateFormatter.locale = Locale(identifier: "ja_JP")
        dateFormatter.timeStyle = .medium
        dateFormatter.dateStyle = .medium
        
        log.append(dateFormatter.string(from: Date()) + " ")
        
        
        for item in items {
            var out: String = ""
            print(item, separator: "", terminator: "", to: &out)
            log.append(out)
        }
        
        log.append("\n")
        
        self.logTextView.textStorage?.beginEditing()
        self.logTextView.textStorage?.append(NSAttributedString.init(string: log as String))
        self.logTextView.textStorage?.endEditing()
        
    }
    
    
}
