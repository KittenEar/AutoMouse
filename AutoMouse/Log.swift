//
//  Log.swift
//  AutoMouse
//
//  Created by cat-07 on 2015/12/29.
//  Copyright © 2015年 cat-07. All rights reserved.
//

import Foundation

class Log {
    
    class func debug(_ items: Any ...) {
        
        let dateFormatter = DateFormatter()
        dateFormatter.locale = Locale(identifier: "ja_JP")
        dateFormatter.timeStyle = .medium
        dateFormatter.dateStyle = .medium

        print(dateFormatter.string(from: Date()), "", terminator: "")

        for item in items {
            print(item, "", terminator: "")
        }
        
        print("")
    }
    
}
