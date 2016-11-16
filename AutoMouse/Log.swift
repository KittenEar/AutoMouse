//
//  Log.swift
//  AutoMouse
//
//  Created by cat-07 on 2015/12/29.
//  Copyright © 2015年 cat-07. All rights reserved.
//

import Foundation

class Log {
    
    class func debug(items: Any ...) {
        
        let dateFormatter = NSDateFormatter()
        dateFormatter.locale = NSLocale(localeIdentifier: "ja_JP")
        dateFormatter.timeStyle = .MediumStyle
        dateFormatter.dateStyle = .MediumStyle

        print(dateFormatter.stringFromDate(NSDate()), "", terminator: "")

        for item in items {
            print(item, "", terminator: "")
        }
        
        print("")
    }
    
}