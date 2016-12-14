//
//  ViewController.swift
//  AutoMouse
//
//  Created by cat-07 on 2015/12/28.
//  Copyright © 2015年 cat-07. All rights reserved.
//

import Cocoa

enum Command {
    case sleep
    case move
    case leftDown
    case leftUp
    case leftDragged
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
    
    fileprivate var monitorEvents: [AnyObject?] = []

    fileprivate weak var globalMonitorEvent: AnyObject? = nil
    fileprivate weak var globalMonitorMouseMoveEvent: AnyObject? = nil
    fileprivate weak var globalMonitorLeftMouseDownEvent: AnyObject? = nil
    fileprivate weak var globalMonitorLeftMouseUpEvent: AnyObject? = nil
    fileprivate weak var globalMonitorLeftMouseDraggedEvent: AnyObject? = nil
    fileprivate weak var globalMonitorFlagsChangedEvent: AnyObject? = nil
    
    fileprivate var localMonitorEvent: AnyObject? = nil
    fileprivate weak var timer: Timer? = nil
    fileprivate var interval: Date? = nil
    fileprivate var oldFireDate: Date? = nil
    fileprivate var startDate: Date? = nil
    fileprivate var windowHeight: CGFloat? = nil
    
    fileprivate var loopFlg: Bool = false
    
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
    
    override var representedObject: Any? {
        didSet {
            // Update the view, if already loaded.
        }
    }
    
    // MARK: - event action

    // Recボタン
    @IBAction func recBtnAction(_ sender: NSButton) {
        
//        logWindow.showWindow(sender)
//        let mem = Memory()
//        logWindow.debugWindow("usedMem", mem.usedMem())
        
        self.recBtn.isEnabled = false
        self.stopBtn.isEnabled = true
        self.playBtn.isEnabled = false
        
        self.mouseCommands.removeAll()
        
        // イベント登録
        registerEvents()

    }
    
    // Stopボタン
    @IBAction func stopBtnAction(_ sender: NSButton) {
        
        self.recBtn.isEnabled = true
        self.stopBtn.isEnabled = false
        self.playBtn.isEnabled = true
        
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
    @IBAction func playBtnAction(_ sender: NSButton) {
        
        self.recBtn.isEnabled = false
        self.stopBtn.isEnabled = true
        self.playBtn.isEnabled = false
        
        OperationQueue().addOperation { () -> Void in
            
            for event in self.mouseCommands {
                
                switch event.command {
                case .sleep:
                    Log.debug("Sleep")
                    
                    let v: Double = event.value as! Double
                    Thread.sleep(forTimeInterval: v)
                    
                case .move:
                    Log.debug("Move")
                    
                    let v: NSPoint = event.value as! NSPoint
                    let mouseMove = CGEvent(mouseEventSource: nil, mouseType: .mouseMoved, mouseCursorPosition: v, mouseButton: .center)
                    mouseMove?.post(tap: .cghidEventTap)
                    
                case .leftDown:
                    Log.debug("LeftDown")
                    
                    let v: NSPoint = event.value as! NSPoint
                    let leftMouseDown = CGEvent(mouseEventSource: nil, mouseType: .leftMouseDown, mouseCursorPosition: v, mouseButton: .center)
                    leftMouseDown?.post(tap: .cghidEventTap)
                    
                case .leftUp:
                    Log.debug("LeftUp")
                    
                    let v: NSPoint = event.value as! NSPoint
                    let leftMouseUp = CGEvent(mouseEventSource: nil, mouseType: .leftMouseUp, mouseCursorPosition: v, mouseButton: .center)
                    leftMouseUp?.post(tap: .cghidEventTap)
                    
                case .leftDragged:
                    Log.debug("LeftDragged")
                    
                    let v: NSPoint = event.value as! NSPoint
                    let leftMouseDragged = CGEvent(mouseEventSource: nil, mouseType: .leftMouseDragged, mouseCursorPosition: v, mouseButton: .center)
                    leftMouseDragged?.post(tap: .cghidEventTap)
                    
                }
            }
            
            self.recBtn.isEnabled = true
            self.stopBtn.isEnabled = false
            self.playBtn.isEnabled = true

        }
        
        
        //        let mouseDown: CGEvent = CGEventCreateMouseEvent(nil, CGEventType.LeftMouseDown, location, CGMouseButton.Left)!
        //        CGEventPost(CGEventTapLocation.CGHIDEventTap, mouseDown)
        
        //        let mouseUp: CGEvent = CGEventCreateMouseEvent(nil, CGEventType.LeftMouseUp, location, CGMouseButton.Left)!
        //        CGEventPost(CGEventTapLocation.CGHIDEventTap, mouseUp)
        
        
    }
    
    // 連打ボタン
    @IBAction func rendaBtnAction(_ sender: NSButton) {
        
        //        let queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0)
        //        dispatch_async(queue) {
        //        }
        
        Thread.sleep(forTimeInterval: 3.0)
        
        self.oldFireDate = Date()
        
        self.timer = Timer.scheduledTimer(timeInterval: 0.001, target: self, selector: #selector(ViewController.click(_:)), userInfo: nil, repeats: true)
        //        self.timer = NSTimer.init(timeInterval: 0.1, target: self, selector: Selector("click:"), userInfo: nil, repeats: true)
        
        // test
        //        NSRunLoop.mainRunLoop().addTimer(self.timer!, forMode: NSRunLoopCommonModes)
        
        self.globalMonitorEvent = NSEvent.addGlobalMonitorForEvents(matching: NSEventMask.keyDown, handler: { (event: NSEvent) -> Void in
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
            
        }) as AnyObject?
        
    }
    
    @IBAction func renda2Button(_ sender: NSButton) {
        
        sender.isEnabled = false
        //        self.loopFlg = true
        
        self.globalMonitorEvent = NSEvent.addGlobalMonitorForEvents(matching: NSEventMask.keyDown, handler: { (event: NSEvent) -> Void in
            Log.debug("G event.keyCode", event.keyCode)
            
            if event.keyCode == 53 {
                Log.debug("esc!!")
                
                sender.isEnabled = true
                
                // timer stop
                self.timer?.invalidate()
                self.timer = nil;
                
                //                self.loopFlg = false
                
                if let _ = self.globalMonitorEvent {
                    NSEvent.removeMonitor(self.globalMonitorEvent!)
                    self.globalMonitorEvent = nil
                }
            }
        }) as AnyObject?
        
        Thread.sleep(forTimeInterval: 3.0)
        
        self.timer = Timer.scheduledTimer(timeInterval: 0.1, target: self, selector: #selector(ViewController.click(_:)), userInfo: nil, repeats: true)
        
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

    @IBAction func logButtonAction(_ sender: NSButton) {
        
        self.mouseCommands.removeAll()
        
        self.globalMonitorMouseMoveEvent = NSEvent.addGlobalMonitorForEvents(matching: .mouseMoved, handler: { (event: NSEvent) -> Void in
            Log.debug("G mouse move", event.locationInWindow)
            
            let point = NSPoint.init(x: event.locationInWindow.x, y: 800 - event.locationInWindow.y)
            let sleep = Date.init().timeIntervalSince(self.startDate!)
            
            self.mouseCommands.append(Action.init(command: .sleep, value: sleep))
            self.mouseCommands.append(Action.init(command: .move, value: point))
            
            self.startDate = Date.init()
        }) as AnyObject?
        
        self.globalMonitorLeftMouseDownEvent = NSEvent.addGlobalMonitorForEvents(matching: .leftMouseDown, handler: { (event: NSEvent) -> Void in
            Log.debug("G left D", event.locationInWindow)
            
            let point = NSPoint.init(x: event.locationInWindow.x, y: 800 - event.locationInWindow.y)
            let sleep = Date.init().timeIntervalSince(self.startDate!)
            
            self.mouseCommands.append(Action.init(command: .sleep, value: sleep))
            self.mouseCommands.append(Action.init(command: .leftDown, value: point))
            
            self.startDate = Date.init()
        }) as AnyObject?
        
        self.globalMonitorLeftMouseUpEvent = NSEvent.addGlobalMonitorForEvents(matching: .leftMouseUp, handler: { (event: NSEvent) -> Void in
            Log.debug("G left U", event.locationInWindow)
            
            let point = NSPoint.init(x: event.locationInWindow.x, y: 800 - event.locationInWindow.y)
            let sleep = Date.init().timeIntervalSince(self.startDate!)
            
            self.mouseCommands.append(Action.init(command: .sleep, value: sleep))
            self.mouseCommands.append(Action.init(command: .leftUp, value: point))
            
            self.startDate = Date.init()
        }) as AnyObject?
        
        self.globalMonitorLeftMouseDraggedEvent = NSEvent.addGlobalMonitorForEvents(matching: .leftMouseDragged, handler: { (event: NSEvent) -> Void in
            
            Log.debug("G left Dragged", event.locationInWindow)
            
            let point = NSPoint.init(x: event.locationInWindow.x, y: 800 - event.locationInWindow.y)
            let sleep = Date.init().timeIntervalSince(self.startDate!)
            
            self.mouseCommands.append(Action.init(command: .sleep, value: sleep))
            self.mouseCommands.append(Action.init(command: .leftDragged, value: point))
            
            self.startDate = Date.init()
        }) as AnyObject?
        
        self.globalMonitorFlagsChangedEvent = NSEvent.addGlobalMonitorForEvents(matching: .otherMouseDragged, handler: { (event: NSEvent) -> Void in
            Log.debug("G FlagsChanged", event.locationInWindow)
            
            let point = NSPoint.init(x: event.locationInWindow.x, y: 800 - event.locationInWindow.y)
            let sleep = Date.init().timeIntervalSince(self.startDate!)
            
            self.mouseCommands.append(Action.init(command: .sleep, value: sleep))
            self.mouseCommands.append(Action.init(command: .leftDragged, value: point))
            
            self.startDate = Date.init()
        }) as AnyObject?
        
        self.startDate = Date.init()
        
    }
    
    // MARK: - Selector method

    func click(_ timer: Timer) {
        
        let date = Date.init()
        
        // 10秒毎
        if false /*date.timeIntervalSinceDate(self.oldFireDate!) > 10 */ {
            
            self.oldFireDate = date
            
            OperationQueue().addOperation({ () -> Void in
                
                // 全画面スクリーンショット
                let image = CGDisplayCreateImage(CGMainDisplayID())
                let bmap = NSBitmapImageRep.init(cgImage: image!)
                
                let data = bmap.representation(using: NSBitmapImageFileType.BMP, properties: [:])
                //        let data = bmap.representationUsingType(NSBitmapImageFileType.NSPNGFileType, properties: [:])
                try? data!.write(to: URL(fileURLWithPath: "ss.bmp"), options: [.atomic])
                
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
                
                
                
                
                if point.equalTo(CGPoint.zero) != true {
                    Log.debug("match")
                    
                    let event: CGEvent = CGEvent(source: nil)!
                    let nowlocation: CGPoint = event.location
                    
                    let mouseDown: CGEvent = CGEvent(mouseEventSource: nil, mouseType: CGEventType.leftMouseDown, mouseCursorPosition: point, mouseButton: CGMouseButton.left)!
                    mouseDown.post(tap: CGEventTapLocation.cghidEventTap)
                    
                    let mouseUp: CGEvent = CGEvent(mouseEventSource: nil, mouseType: CGEventType.leftMouseUp, mouseCursorPosition: point, mouseButton: CGMouseButton.left)!
                    mouseUp.post(tap: CGEventTapLocation.cghidEventTap)
                    
                    let mouseMove: CGEvent = CGEvent(mouseEventSource: nil, mouseType: CGEventType.mouseMoved, mouseCursorPosition: nowlocation, mouseButton: CGMouseButton.left)!
                    mouseMove.post(tap: CGEventTapLocation.cghidEventTap)
                    
                }
                
            })
            
            
        }
        
        let event: CGEvent = CGEvent(source: nil)!
        let location: CGPoint = event.location
        
        //        Log.debug(location)
        
        // UIの更新を行わないとタイマーが正常に動作しないことに注意
        self.outputLabel.stringValue = NSStringFromPoint(location)
        
        let mouseDown: CGEvent = CGEvent(mouseEventSource: nil, mouseType: CGEventType.leftMouseDown, mouseCursorPosition: location, mouseButton: CGMouseButton.left)!
        mouseDown.post(tap: CGEventTapLocation.cghidEventTap)
        
        let mouseUp: CGEvent = CGEvent(mouseEventSource: nil, mouseType: CGEventType.leftMouseUp, mouseCursorPosition: location, mouseButton: CGMouseButton.left)!
        mouseUp.post(tap: CGEventTapLocation.cghidEventTap)
    }
    
    override func prepare(for segue: NSStoryboardSegue, sender: Any?) {
        
        Log.debug(segue.destinationController)
        
    }
    
    // MARK: - private method
    
    // イベント登録
    fileprivate func registerEvents() {
        
        var anyObj: AnyObject? = nil
        
        // グローバルイベント マウスMoved
        anyObj = NSEvent.addGlobalMonitorForEvents(matching: NSEventMask.mouseMoved, handler: { (event: NSEvent) -> Void in
            Log.debug("G MMoved Pos", event.locationInWindow)
            
            let point = NSPoint.init(x: event.locationInWindow.x, y: self.windowHeight! - event.locationInWindow.y)
            
            self.mouseCommands.append(Action.init(command: .move, value: point))
            
            if let time = self.interval {
                let sleepTime = Date.init().timeIntervalSince(time)
                self.mouseCommands.append(Action.init(command: .sleep, value: sleepTime))
            }
            
            self.interval = Date.init()
        }) as AnyObject?
        
        self.monitorEvents.append(anyObj!)

        // グローバルイベント マウス左Down test
        anyObj = NSEvent.addGlobalMonitorForEvents(matching: NSEventMask.leftMouseDown, handler: { (event: NSEvent) -> Void in
            Log.debug("G LMDown Pos", event.locationInWindow)
            
            let point = NSPoint.init(x: event.locationInWindow.x, y: self.windowHeight! - event.locationInWindow.y)
            
            self.mouseCommands.append(Action.init(command: .leftDown, value: point))
            
            if let time = self.interval {
                let sleepTime = Date.init().timeIntervalSince(time)
                self.mouseCommands.append(Action.init(command: .sleep, value: sleepTime))
            }
            
            self.interval = Date.init()
        }) as AnyObject?
        
        self.monitorEvents.append(anyObj!)

        // グローバルイベント マウス左Up test
        anyObj = NSEvent.addGlobalMonitorForEvents(matching: NSEventMask.leftMouseUp, handler: { (event: NSEvent) -> Void in
            Log.debug("G LMUp Pos", event.locationInWindow)
            
            let point = NSPoint.init(x: event.locationInWindow.x, y: self.windowHeight! - event.locationInWindow.y)
            
            self.mouseCommands.append(Action.init(command: .leftUp, value: point))
            
            if let time = self.interval {
                let sleepTime = Date.init().timeIntervalSince(time)
                self.mouseCommands.append(Action.init(command: .sleep, value: sleepTime))
            }
            
            self.interval = Date.init()
        }) as AnyObject?
        
        self.monitorEvents.append(anyObj!)

        // グローバルイベント マウス左Dragged test
        anyObj = NSEvent.addGlobalMonitorForEvents(matching: NSEventMask.leftMouseDragged, handler: { (event: NSEvent) -> Void in
            Log.debug("G LMDragged Pos", event.locationInWindow)
            
            let point = NSPoint.init(x: event.locationInWindow.x, y: self.windowHeight! - event.locationInWindow.y)
            
            self.mouseCommands.append(Action.init(command: .leftDragged, value: point))
            
            if let time = self.interval {
                let sleepTime = Date.init().timeIntervalSince(time)
                self.mouseCommands.append(Action.init(command: .sleep, value: sleepTime))
            }
            
            self.interval = Date.init()
        }) as AnyObject?
        
        self.monitorEvents.append(anyObj!)

        // ローカルイベント マウスMoved
        anyObj = NSEvent.addLocalMonitorForEvents(matching: NSEventMask.mouseMoved, handler: { (event: NSEvent) -> NSEvent? in
            Log.debug("L MMoved Pos", event.locationInWindow)
            
            var point = CGPoint.zero
            
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
            
            self.mouseCommands.append(Action.init(command: .move, value: point))
            
            if let time = self.interval {
                let sleepTime = Date.init().timeIntervalSince(time)
                self.mouseCommands.append(Action.init(command: .sleep, value: sleepTime))
            }
            
            self.interval = Date.init()
            
            return event
        }) as AnyObject?
        
        self.monitorEvents.append(anyObj!)

        // ローカルイベント マウスDown test
        anyObj = NSEvent.addLocalMonitorForEvents(matching: NSEventMask.leftMouseDown, handler: { (event: NSEvent) -> NSEvent? in
            Log.debug("L LMDown Pos", event.locationInWindow)
            
            var point = CGPoint.zero
            
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
            
            self.mouseCommands.append(Action.init(command: .leftDown, value: point))
            
            if let time = self.interval {
                let sleepTime = Date.init().timeIntervalSince(time)
                self.mouseCommands.append(Action.init(command: .sleep, value: sleepTime))
            }
            
            self.interval = Date.init()
            
            return event
        }) as AnyObject?
        
        self.monitorEvents.append(anyObj!)

        // ローカルイベント マウスUp test
        anyObj = NSEvent.addLocalMonitorForEvents(matching: NSEventMask.leftMouseUp, handler: { (event: NSEvent) -> NSEvent? in
            Log.debug("L LMUp Pos", event.locationInWindow)
            
            var point = CGPoint.zero
            
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
            
            self.mouseCommands.append(Action.init(command: .leftUp, value: point))
            
            if let time = self.interval {
                let sleepTime = Date.init().timeIntervalSince(time)
                self.mouseCommands.append(Action.init(command: .sleep, value: sleepTime))
            }
            
            self.interval = Date.init()
            
            return event
        }) as AnyObject?
        
        self.monitorEvents.append(anyObj!)

        // ローカルイベント マウスDragged test
        anyObj = NSEvent.addLocalMonitorForEvents(matching: NSEventMask.leftMouseDragged, handler: { (event: NSEvent) -> NSEvent? in
            Log.debug("L LMDragged Pos", event.locationInWindow)
            
            var point = CGPoint.zero
            
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
            
            self.mouseCommands.append(Action.init(command: .leftDragged, value: point))
            
            if let time = self.interval {
                let sleepTime = Date.init().timeIntervalSince(time)
                self.mouseCommands.append(Action.init(command: .sleep, value: sleepTime))
            }
            
            self.interval = Date.init()
            
            return event
        }) as AnyObject?
        
        self.monitorEvents.append(anyObj!)

    }

    // イベント解除
    fileprivate func releaseEvents() {
        
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

