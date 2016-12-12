//
//  ViewController.swift
//  AutoMouse
//
//  Created by cat-07 on 2015/12/28.
//  Copyright © 2015年 cat-07. All rights reserved.
//

import Cocoa

enum Command {
    case Sleep
    case Move
    case LeftDown
    case LeftUp
    case LeftDragged
}

struct Action {
    var command: Command
    var value: Any
    
}

// ★ドラッグイベントを追加
// ★monitorEventの変数を配列にまとめる
// ★pragma mark はどうする？
// ★タイトルに座標出力
// ★ファイルをフォルダにまとめる

class ViewController: NSViewController {
    
    @IBOutlet weak var recBtn: NSButton!
    @IBOutlet weak var stopBtn: NSButton!
    @IBOutlet weak var playBtn: NSButton!
    @IBOutlet weak var outputLabel: NSTextField!
    
    private var monitorEvents: [AnyObject?] = []

    private weak var globalMonitorEvent: AnyObject? = nil
    private weak var globalMonitorMouseMoveEvent: AnyObject? = nil
    private weak var globalMonitorLeftMouseDownEvent: AnyObject? = nil
    private weak var globalMonitorLeftMouseUpEvent: AnyObject? = nil
    private weak var globalMonitorLeftMouseDraggedEvent: AnyObject? = nil
    private weak var globalMonitorFlagsChangedEvent: AnyObject? = nil
    
    private var localMonitorEvent: AnyObject? = nil
    private weak var timer: NSTimer? = nil
    private var interval: NSDate? = nil
    private var oldFireDate: NSDate? = nil
    private var startDate: NSDate? = nil
    private var windowHeight: CGFloat? = nil
    
    private var loopFlg: Bool = false
    
    var mouseCommands: Array<Action> = []
    
    var logWindow = LogWindowController(windowNibName: "LogWindowController")
    
    // MARK: - lifecycle method
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
    }
    
    override func viewWillAppear() {

        // window の高さを保持
        windowHeight = self.view.window?.screen?.frame.height
    }
    
    override func viewWillDisappear() {
        
        // イベント解除
        releaseEvents()
        
    }
    
    override var representedObject: AnyObject? {
        didSet {
            // Update the view, if already loaded.
        }
    }
    
    // MARK: - event action

    // Recボタン
    @IBAction func recBtnAction(sender: NSButton) {
        
//        logWindow.showWindow(sender)
//        let mem = Memory()
//        logWindow.debugWindow("usedMem", mem.usedMem())
        
        self.recBtn.enabled = false
        self.stopBtn.enabled = true
        self.playBtn.enabled = false
        
        self.mouseCommands.removeAll()
        
        // イベント登録
        registerEvents()

    }
    
    // Stopボタン
    @IBAction func stopBtnAction(sender: NSButton) {
        
        self.recBtn.enabled = true
        self.stopBtn.enabled = false
        self.playBtn.enabled = true
        
        self.interval = nil
        
        // イベント解除
        releaseEvents()
        
//        if let _ = self.globalMonitorMouseMoveEvent {
//            NSEvent.removeMonitor(self.globalMonitorMouseMoveEvent!)
//            self.globalMonitorMouseMoveEvent = nil
//        }
//        
//        if let _ = self.globalMonitorLeftMouseDownEvent {
//            NSEvent.removeMonitor(self.globalMonitorLeftMouseDownEvent!)
//            self.globalMonitorLeftMouseDownEvent = nil
//        }
//        
//        if let _ = self.globalMonitorLeftMouseUpEvent {
//            NSEvent.removeMonitor(self.globalMonitorLeftMouseUpEvent!)
//            self.globalMonitorLeftMouseUpEvent = nil
//        }
//        
//        if let _ = self.globalMonitorLeftMouseDraggedEvent {
//            NSEvent.removeMonitor(self.globalMonitorLeftMouseDraggedEvent!)
//            self.globalMonitorLeftMouseDraggedEvent = nil
//        }
        
    }
    
    // Play
    @IBAction func playBtnAction(sender: NSButton) {
        
        self.recBtn.enabled = false
        self.stopBtn.enabled = true
        self.playBtn.enabled = false
        
        NSOperationQueue().addOperationWithBlock { () -> Void in
            
            for event in self.mouseCommands {
                
                switch event.command {
                case .Sleep:
                    Log.debug("Sleep")
                    
                    let v: Double = event.value as! Double
                    NSThread.sleepForTimeInterval(v)
                    
                case .Move:
                    Log.debug("Move")
                    
                    let v: NSPoint = event.value as! NSPoint
                    let mouseMove = CGEventCreateMouseEvent(nil, .MouseMoved, v, .Center)
                    CGEventPost(.CGHIDEventTap, mouseMove)
                    
                case .LeftDown:
                    Log.debug("LeftDown")
                    
                    let v: NSPoint = event.value as! NSPoint
                    let leftMouseDown = CGEventCreateMouseEvent(nil, .LeftMouseDown, v, .Center)
                    CGEventPost(.CGHIDEventTap, leftMouseDown)
                    
                case .LeftUp:
                    Log.debug("LeftUp")
                    
                    let v: NSPoint = event.value as! NSPoint
                    let leftMouseUp = CGEventCreateMouseEvent(nil, .LeftMouseUp, v, .Center)
                    CGEventPost(.CGHIDEventTap, leftMouseUp)
                    
                case .LeftDragged:
                    Log.debug("LeftDragged")
                    
                    let v: NSPoint = event.value as! NSPoint
                    let leftMouseDragged = CGEventCreateMouseEvent(nil, .LeftMouseDragged, v, .Center)
                    CGEventPost(.CGHIDEventTap, leftMouseDragged)
                    
                }
            }
            
            self.recBtn.enabled = true
            self.stopBtn.enabled = false
            self.playBtn.enabled = true

        }
        
        
        //        let mouseDown: CGEvent = CGEventCreateMouseEvent(nil, CGEventType.LeftMouseDown, location, CGMouseButton.Left)!
        //        CGEventPost(CGEventTapLocation.CGHIDEventTap, mouseDown)
        
        //        let mouseUp: CGEvent = CGEventCreateMouseEvent(nil, CGEventType.LeftMouseUp, location, CGMouseButton.Left)!
        //        CGEventPost(CGEventTapLocation.CGHIDEventTap, mouseUp)
        
        
    }
    
    // 連打ボタン
    @IBAction func rendaBtnAction(sender: NSButton) {
        
        //        let queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0)
        //        dispatch_async(queue) {
        //        }
        
        NSThread.sleepForTimeInterval(3.0)
        
        self.oldFireDate = NSDate()
        
        self.timer = NSTimer.scheduledTimerWithTimeInterval(0.001, target: self, selector: Selector("click:"), userInfo: nil, repeats: true)
        //        self.timer = NSTimer.init(timeInterval: 0.1, target: self, selector: Selector("click:"), userInfo: nil, repeats: true)
        
        // test
        //        NSRunLoop.mainRunLoop().addTimer(self.timer!, forMode: NSRunLoopCommonModes)
        
        self.globalMonitorEvent = NSEvent.addGlobalMonitorForEventsMatchingMask(NSEventMask.KeyDownMask, handler: { (event: NSEvent) -> Void in
            Log.debug("G event.keyCode", event.keyCode)
            
            if event.keyCode == 53 {
                Log.debug("esc!!")
                
                // timer stop
                self.timer?.invalidate()
                self.timer = nil;
            }
            
            if let _ = self.globalMonitorEvent {
                NSEvent.removeMonitor(self.globalMonitorEvent!)
                self.globalMonitorEvent = nil
            }
            
        })
        
    }
    
    @IBAction func renda2Button(sender: NSButton) {
        
        sender.enabled = false
        //        self.loopFlg = true
        
        self.globalMonitorEvent = NSEvent.addGlobalMonitorForEventsMatchingMask(NSEventMask.KeyDownMask, handler: { (event: NSEvent) -> Void in
            Log.debug("G event.keyCode", event.keyCode)
            
            if event.keyCode == 53 {
                Log.debug("esc!!")
                
                sender.enabled = true
                
                // timer stop
                self.timer?.invalidate()
                self.timer = nil;
                
                //                self.loopFlg = false
                
                if let _ = self.globalMonitorEvent {
                    NSEvent.removeMonitor(self.globalMonitorEvent!)
                    self.globalMonitorEvent = nil
                }
            }
        })
        
        NSThread.sleepForTimeInterval(3.0)
        
        self.timer = NSTimer.scheduledTimerWithTimeInterval(0.1, target: self, selector: Selector("click:"), userInfo: nil, repeats: true)
        
        //        NSOperationQueue().addOperationWithBlock({ () -> Void in
        //
        //            // ★★そもそもループさせてはいけない
        //            while (self.loopFlg) {
        //                autoreleasepool {
        //                    NSThread.sleepForTimeInterval(0.1)
        //                    Log.debug("renda")
        //
        //                    let event = CGEventCreate(nil)
        //                    let location = CGEventGetLocation(event)
        //
        //                    // UIの更新を行わないとタイマーが正常に動作しないことに注意
        //                    self.outputLabel.stringValue = "test" //NSStringFromPoint(location)
        //
        //                    let mouseDown = CGEventCreateMouseEvent(nil, .LeftMouseDown, location, .Left)
        //                    CGEventPost(.CGHIDEventTap, mouseDown)
        //
        //                    let mouseUp = CGEventCreateMouseEvent(nil, .LeftMouseUp, location, .Left)
        //                    CGEventPost(.CGHIDEventTap, mouseUp)
        //                }
        //            }
        //
        //            Log.debug("while end")
        //        })
        
    }

    @IBAction func logButtonAction(sender: NSButton) {
        
        self.mouseCommands.removeAll()
        
        self.globalMonitorMouseMoveEvent = NSEvent.addGlobalMonitorForEventsMatchingMask(.MouseMovedMask, handler: { (event: NSEvent) -> Void in
            Log.debug("G mouse move", event.locationInWindow)
            
            let point = NSPoint.init(x: event.locationInWindow.x, y: 800 - event.locationInWindow.y)
            let sleep = NSDate.init().timeIntervalSinceDate(self.startDate!)
            
            self.mouseCommands.append(Action.init(command: .Sleep, value: sleep))
            self.mouseCommands.append(Action.init(command: .Move, value: point))
            
            self.startDate = NSDate.init()
        })
        
        self.globalMonitorLeftMouseDownEvent = NSEvent.addGlobalMonitorForEventsMatchingMask(.LeftMouseDownMask, handler: { (event: NSEvent) -> Void in
            Log.debug("G left D", event.locationInWindow)
            
            let point = NSPoint.init(x: event.locationInWindow.x, y: 800 - event.locationInWindow.y)
            let sleep = NSDate.init().timeIntervalSinceDate(self.startDate!)
            
            self.mouseCommands.append(Action.init(command: .Sleep, value: sleep))
            self.mouseCommands.append(Action.init(command: .LeftDown, value: point))
            
            self.startDate = NSDate.init()
        })
        
        self.globalMonitorLeftMouseUpEvent = NSEvent.addGlobalMonitorForEventsMatchingMask(.LeftMouseUpMask, handler: { (event: NSEvent) -> Void in
            Log.debug("G left U", event.locationInWindow)
            
            let point = NSPoint.init(x: event.locationInWindow.x, y: 800 - event.locationInWindow.y)
            let sleep = NSDate.init().timeIntervalSinceDate(self.startDate!)
            
            self.mouseCommands.append(Action.init(command: .Sleep, value: sleep))
            self.mouseCommands.append(Action.init(command: .LeftUp, value: point))
            
            self.startDate = NSDate.init()
        })
        
        self.globalMonitorLeftMouseDraggedEvent = NSEvent.addGlobalMonitorForEventsMatchingMask(.LeftMouseDraggedMask, handler: { (event: NSEvent) -> Void in
            
            Log.debug("G left Dragged", event.locationInWindow)
            
            let point = NSPoint.init(x: event.locationInWindow.x, y: 800 - event.locationInWindow.y)
            let sleep = NSDate.init().timeIntervalSinceDate(self.startDate!)
            
            self.mouseCommands.append(Action.init(command: .Sleep, value: sleep))
            self.mouseCommands.append(Action.init(command: .LeftDragged, value: point))
            
            self.startDate = NSDate.init()
        })
        
        self.globalMonitorFlagsChangedEvent = NSEvent.addGlobalMonitorForEventsMatchingMask(.OtherMouseDraggedMask, handler: { (event: NSEvent) -> Void in
            Log.debug("G FlagsChanged", event.locationInWindow)
            
            let point = NSPoint.init(x: event.locationInWindow.x, y: 800 - event.locationInWindow.y)
            let sleep = NSDate.init().timeIntervalSinceDate(self.startDate!)
            
            self.mouseCommands.append(Action.init(command: .Sleep, value: sleep))
            self.mouseCommands.append(Action.init(command: .LeftDragged, value: point))
            
            self.startDate = NSDate.init()
        })
        
        self.startDate = NSDate.init()
        
    }
    
    // MARK: - Selector method

    func click(timer: NSTimer) {
        
        let date = NSDate.init()
        
        // 10秒毎
        if false /*date.timeIntervalSinceDate(self.oldFireDate!) > 10 */ {
            
            self.oldFireDate = date
            Log.debug(self.oldFireDate)
            
            NSOperationQueue().addOperationWithBlock({ () -> Void in
                
                // 全画面スクリーンショット
                let image = CGDisplayCreateImage(CGMainDisplayID())
                let bmap = NSBitmapImageRep.init(CGImage: image!)
                
                let data = bmap.representationUsingType(NSBitmapImageFileType.NSBMPFileType, properties: [:])
                //        let data = bmap.representationUsingType(NSBitmapImageFileType.NSPNGFileType, properties: [:])
                data!.writeToFile("ss.bmp", atomically: true)
                
                let images = ["cookie00.png", "cookie01.png", "cookie02.png", "cookie03.png",
                    "cookie04.png", "cookie05.png", "cookie06.png", "cookie07.png"]
                
                let point = OpenCV.matching("ss.bmp", searchImages: images)
                
                
                //                for image in images {
                //                    var maxVal: CGFloat = 0.0
                //                    let pp = OpenCV.matching("ss.bmp", searchImage: image, maxVal: &maxVal)
                //                    Log.debug("pp ", pp)
                //                    Log.debug("maxval ", maxVal)
                //
                //                }
                
                
                
                
                if CGPointEqualToPoint(point, CGPointZero) != true {
                    Log.debug("match")
                    
                    let event: CGEvent = CGEventCreate(nil)!
                    let nowlocation: CGPoint = CGEventGetLocation(event)
                    
                    let mouseDown: CGEvent = CGEventCreateMouseEvent(nil, CGEventType.LeftMouseDown, point, CGMouseButton.Left)!
                    CGEventPost(CGEventTapLocation.CGHIDEventTap, mouseDown)
                    
                    let mouseUp: CGEvent = CGEventCreateMouseEvent(nil, CGEventType.LeftMouseUp, point, CGMouseButton.Left)!
                    CGEventPost(CGEventTapLocation.CGHIDEventTap, mouseUp)
                    
                    let mouseMove: CGEvent = CGEventCreateMouseEvent(nil, CGEventType.MouseMoved, nowlocation, CGMouseButton.Left)!
                    CGEventPost(CGEventTapLocation.CGHIDEventTap, mouseMove)
                    
                }
                
            })
            
            
        }
        
        let event: CGEvent = CGEventCreate(nil)!
        let location: CGPoint = CGEventGetLocation(event)
        
        //        Log.debug(location)
        
        // UIの更新を行わないとタイマーが正常に動作しないことに注意
        self.outputLabel.stringValue = NSStringFromPoint(location)
        
        let mouseDown: CGEvent = CGEventCreateMouseEvent(nil, CGEventType.LeftMouseDown, location, CGMouseButton.Left)!
        CGEventPost(CGEventTapLocation.CGHIDEventTap, mouseDown)
        
        let mouseUp: CGEvent = CGEventCreateMouseEvent(nil, CGEventType.LeftMouseUp, location, CGMouseButton.Left)!
        CGEventPost(CGEventTapLocation.CGHIDEventTap, mouseUp)
    }
    
    override func prepareForSegue(segue: NSStoryboardSegue, sender: AnyObject?) {
        
        Log.debug(segue.destinationController)
        
    }
    
    // MARK: - private method
    
    // イベント登録
    private func registerEvents() {
        
        var anyObj: AnyObject? = nil
        
        // グローバルイベント マウスMoved
        anyObj = NSEvent.addGlobalMonitorForEventsMatchingMask(NSEventMask.MouseMovedMask, handler: { (event: NSEvent) -> Void in
            Log.debug("G MMoved Pos", event.locationInWindow)
            
            let point = NSPoint.init(x: event.locationInWindow.x, y: self.windowHeight! - event.locationInWindow.y)
            
            self.mouseCommands.append(Action.init(command: .Move, value: point))
            
            if let time = self.interval {
                let sleepTime = NSDate.init().timeIntervalSinceDate(time)
                self.mouseCommands.append(Action.init(command: .Sleep, value: sleepTime))
            }
            
            self.interval = NSDate.init()
        })
        
        self.monitorEvents.append(anyObj!)

        // グローバルイベント マウス左Down test
        anyObj = NSEvent.addGlobalMonitorForEventsMatchingMask(NSEventMask.LeftMouseDownMask, handler: { (event: NSEvent) -> Void in
            Log.debug("G LMDown Pos", event.locationInWindow)
            
            let point = NSPoint.init(x: event.locationInWindow.x, y: self.windowHeight! - event.locationInWindow.y)
            
            self.mouseCommands.append(Action.init(command: .LeftDown, value: point))
            
            if let time = self.interval {
                let sleepTime = NSDate.init().timeIntervalSinceDate(time)
                self.mouseCommands.append(Action.init(command: .Sleep, value: sleepTime))
            }
            
            self.interval = NSDate.init()
        })
        
        self.monitorEvents.append(anyObj!)

        // グローバルイベント マウス左Up test
        anyObj = NSEvent.addGlobalMonitorForEventsMatchingMask(NSEventMask.LeftMouseUpMask, handler: { (event: NSEvent) -> Void in
            Log.debug("G LMUp Pos", event.locationInWindow)
            
            let point = NSPoint.init(x: event.locationInWindow.x, y: self.windowHeight! - event.locationInWindow.y)
            
            self.mouseCommands.append(Action.init(command: .LeftUp, value: point))
            
            if let time = self.interval {
                let sleepTime = NSDate.init().timeIntervalSinceDate(time)
                self.mouseCommands.append(Action.init(command: .Sleep, value: sleepTime))
            }
            
            self.interval = NSDate.init()
        })
        
        self.monitorEvents.append(anyObj!)

        // グローバルイベント マウス左Dragged test
        anyObj = NSEvent.addGlobalMonitorForEventsMatchingMask(NSEventMask.LeftMouseDraggedMask, handler: { (event: NSEvent) -> Void in
            Log.debug("G LMDragged Pos", event.locationInWindow)
            
            let point = NSPoint.init(x: event.locationInWindow.x, y: self.windowHeight! - event.locationInWindow.y)
            
            self.mouseCommands.append(Action.init(command: .LeftDragged, value: point))
            
            if let time = self.interval {
                let sleepTime = NSDate.init().timeIntervalSinceDate(time)
                self.mouseCommands.append(Action.init(command: .Sleep, value: sleepTime))
            }
            
            self.interval = NSDate.init()
        })
        
        self.monitorEvents.append(anyObj!)

        // ローカルイベント マウスMoved
        anyObj = NSEvent.addLocalMonitorForEventsMatchingMask(NSEventMask.MouseMovedMask, handler: { (event: NSEvent) -> NSEvent? in
            Log.debug("L MMoved Pos", event.locationInWindow)
            
            var point = CGPointZero
            
            if event.window == nil {
                // マウスがアプリ外に出た場合、nil になるときがある
                // そのとき event.locationInWindow は全画面の位置になる
                
                point = NSPoint.init(x: event.locationInWindow.x, y: self.windowHeight! - event.locationInWindow.y)
                Log.debug("L point", point)
                
            }
            else {
                // window が取得できる場合は、全画面からの相対位置を求める
                
                let appFrame = event.window?.frame
                let areaX = (appFrame?.origin.x)! + event.locationInWindow.x
                let areaY = (appFrame?.origin.y)! + event.locationInWindow.y
                let allAreaPoint = NSPoint.init(x: areaX, y: areaY)
                
                point = NSPoint.init(x: allAreaPoint.x, y: self.windowHeight! - allAreaPoint.y)
                Log.debug("L point", point)
                
            }
            
            self.mouseCommands.append(Action.init(command: .Move, value: point))
            
            if let time = self.interval {
                let sleepTime = NSDate.init().timeIntervalSinceDate(time)
                self.mouseCommands.append(Action.init(command: .Sleep, value: sleepTime))
            }
            
            self.interval = NSDate.init()
            
            return event
        })
        
        self.monitorEvents.append(anyObj!)

        // ローカルイベント マウスDown test
        anyObj = NSEvent.addLocalMonitorForEventsMatchingMask(NSEventMask.LeftMouseDownMask, handler: { (event: NSEvent) -> NSEvent? in
            Log.debug("L LMDown Pos", event.locationInWindow)
            
            var point = CGPointZero
            
            if event.window == nil {
                // マウスがアプリ外に出た場合、nil になるときがある
                // そのとき event.locationInWindow は全画面の位置になる
                
                point = NSPoint.init(x: event.locationInWindow.x, y: self.windowHeight! - event.locationInWindow.y)
                Log.debug("L point", point)
                
            }
            else {
                // window が取得できる場合は、全画面からの相対位置を求める
                
                let appFrame = event.window?.frame
                let areaX = (appFrame?.origin.x)! + event.locationInWindow.x
                let areaY = (appFrame?.origin.y)! + event.locationInWindow.y
                let allAreaPoint = NSPoint.init(x: areaX, y: areaY)
                
                point = NSPoint.init(x: allAreaPoint.x, y: self.windowHeight! - allAreaPoint.y)
                Log.debug("L point", point)
                
            }
            
            self.mouseCommands.append(Action.init(command: .LeftDown, value: point))
            
            if let time = self.interval {
                let sleepTime = NSDate.init().timeIntervalSinceDate(time)
                self.mouseCommands.append(Action.init(command: .Sleep, value: sleepTime))
            }
            
            self.interval = NSDate.init()
            
            return event
        })
        
        self.monitorEvents.append(anyObj!)

        // ローカルイベント マウスUp test
        anyObj = NSEvent.addLocalMonitorForEventsMatchingMask(NSEventMask.LeftMouseUpMask, handler: { (event: NSEvent) -> NSEvent? in
            Log.debug("L LMUp Pos", event.locationInWindow)
            
            var point = CGPointZero
            
            if event.window == nil {
                // マウスがアプリ外に出た場合、nil になるときがある
                // そのとき event.locationInWindow は全画面の位置になる
                
                point = NSPoint.init(x: event.locationInWindow.x, y: self.windowHeight! - event.locationInWindow.y)
                Log.debug("L point", point)
                
            }
            else {
                // window が取得できる場合は、全画面からの相対位置を求める
                
                let appFrame = event.window?.frame
                let areaX = (appFrame?.origin.x)! + event.locationInWindow.x
                let areaY = (appFrame?.origin.y)! + event.locationInWindow.y
                let allAreaPoint = NSPoint.init(x: areaX, y: areaY)
                
                point = NSPoint.init(x: allAreaPoint.x, y: self.windowHeight! - allAreaPoint.y)
                Log.debug("L point", point)
                
            }
            
            self.mouseCommands.append(Action.init(command: .LeftUp, value: point))
            
            if let time = self.interval {
                let sleepTime = NSDate.init().timeIntervalSinceDate(time)
                self.mouseCommands.append(Action.init(command: .Sleep, value: sleepTime))
            }
            
            self.interval = NSDate.init()
            
            return event
        })
        
        self.monitorEvents.append(anyObj!)

        // ローカルイベント マウスDragged test
        anyObj = NSEvent.addLocalMonitorForEventsMatchingMask(NSEventMask.LeftMouseDraggedMask, handler: { (event: NSEvent) -> NSEvent? in
            Log.debug("L LMDragged Pos", event.locationInWindow)
            
            var point = CGPointZero
            
            if event.window == nil {
                // マウスがアプリ外に出た場合、nil になるときがある
                // そのとき event.locationInWindow は全画面の位置になる
                
                point = NSPoint.init(x: event.locationInWindow.x, y: self.windowHeight! - event.locationInWindow.y)
                Log.debug("L point", point)
                
            }
            else {
                // window が取得できる場合は、全画面からの相対位置を求める
                
                let appFrame = event.window?.frame
                let areaX = (appFrame?.origin.x)! + event.locationInWindow.x
                let areaY = (appFrame?.origin.y)! + event.locationInWindow.y
                let allAreaPoint = NSPoint.init(x: areaX, y: areaY)
                
                point = NSPoint.init(x: allAreaPoint.x, y: self.windowHeight! - allAreaPoint.y)
                Log.debug("L point", point)
                
            }
            
            self.mouseCommands.append(Action.init(command: .LeftDragged, value: point))
            
            if let time = self.interval {
                let sleepTime = NSDate.init().timeIntervalSinceDate(time)
                self.mouseCommands.append(Action.init(command: .Sleep, value: sleepTime))
            }
            
            self.interval = NSDate.init()
            
            return event
        })
        
        self.monitorEvents.append(anyObj!)

    }

    // イベント解除
    private func releaseEvents() {
        
//        for var i = 0; i < self.monitorEvents.count; i++ {
//            NSEvent.removeMonitor(self.monitorEvents[i]!)
//        }
        
        for monitorEvent in self.monitorEvents {
            NSEvent.removeMonitor(monitorEvent!)
        }

        self.monitorEvents.removeAll()
        
//        if let _ = self.globalMonitorEvent {
//            NSEvent.removeMonitor(self.globalMonitorEvent!)
//            self.globalMonitorEvent = nil
//        }
//        
//        if let _ = self.localMonitorEvent {
//            NSEvent.removeMonitor(self.localMonitorEvent!)
//            self.localMonitorEvent = nil
//        }
        
    }
    
}

