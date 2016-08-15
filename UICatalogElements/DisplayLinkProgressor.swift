//
//  CADisplayLink+Additions.swift
//  UICatalog
//
//  Created by Kip Nicol on 8/12/16.
//  Copyright © 2016 Kip Nicol. All rights reserved.
//

import Foundation

internal class DisplayLinkProgressor: NSObject {
    
    private var displayLink: CADisplayLink!
    private let duration: NSTimeInterval
    private let updateBlock: (progress: Double) -> Void
    
    private var startTimestamp: CFTimeInterval?
    
    
    private init(duration: NSTimeInterval, updateBlock: (progress: Double) -> Void) {
        self.duration = duration
        self.updateBlock = updateBlock
        
        super.init()
        
        // Must set this after super.init() because self is passed into the object on init
        displayLink = CADisplayLink(target: self, selector: #selector(displayLinkDidUpdate))
    }
    
    static func run(withDuration duration: NSTimeInterval, update: (progress: Double) -> Void) {
        let displayLinkProgressor = DisplayLinkProgressor(duration: duration, updateBlock: update)
        
        displayLinkProgressor.start()
    }
    
    private func start() {
        displayLink.addToRunLoop(NSRunLoop.mainRunLoop(), forMode: NSDefaultRunLoopMode)
        startTimestamp = CACurrentMediaTime()
    }
    
    private func stop() {
        displayLink.invalidate()
    }
    
    @objc func displayLinkDidUpdate(displayLink: CADisplayLink) {
        guard let startTimestamp = self.startTimestamp else {
            return
        }
        
        let timestampDelta = displayLink.timestamp - startTimestamp
        let progress = min(timestampDelta / duration, 1.0)
        
        updateBlock(progress: progress)
        
        if progress >= 1.0 {
            stop()
        }
    }
}
