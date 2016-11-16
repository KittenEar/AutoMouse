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
    
    func debugWindow(items: Any ...) {
        
        let log = NSMutableString.init()

        let dateFormatter = NSDateFormatter()
        dateFormatter.locale = NSLocale(localeIdentifier: "ja_JP")
        dateFormatter.timeStyle = .MediumStyle
        dateFormatter.dateStyle = .MediumStyle
        
        log.appendString(dateFormatter.stringFromDate(NSDate()) + " ")
        
        
        for item in items {
            var out: String = ""
            print(item, separator: "", terminator: "", toStream: &out)
            log.appendString(out)
        }
        
        log.appendString("\n")
        
        self.logTextView.textStorage?.beginEditing()
        self.logTextView.textStorage?.appendAttributedString(NSAttributedString.init(string: log as String))
        self.logTextView.textStorage?.endEditing()
        
    }
    
    
}
