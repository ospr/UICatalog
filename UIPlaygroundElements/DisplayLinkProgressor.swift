//
//  CADisplayLink+Additions.swift
//  UIPlayground
//
//  Created by Kip Nicol on 8/12/16.
//  Copyright © 2016 Kip Nicol. All rights reserved.
//

import Foundation
import QuartzCore

// TODO: consider splitting this up so that one class doesn't handle both indeterminate and determinate progress
//       perhaps have a protocol that gets called to update its own closure
internal class DisplayLinkProgressor: NSObject {
    
    private var displayLink: CADisplayLink!
    private let duration: NSTimeInterval
    
    private let indeterministicUpdateBlock: ((timeDelta: NSTimeInterval) -> Bool)?
    private let deterministicUpdateBlock: ((progress: Double) -> Void)?
    
    private var startTimestamp: CFTimeInterval?
    private var lastFrameTimestamp: CFTimeInterval?
    
    private init(duration: NSTimeInterval,
                 deterministicUpdateBlock: ((progress: Double) -> Void)?,
                 indeterministicUpdateBlock: ((timeDelta: NSTimeInterval) -> Bool)?) {
        self.duration = duration
        self.deterministicUpdateBlock = deterministicUpdateBlock
        self.indeterministicUpdateBlock = indeterministicUpdateBlock
        
        super.init()
        
        // Must set this after super.init() because self is passed into the object on init
        displayLink = CADisplayLink(target: self, selector: #selector(displayLinkDidUpdate))
    }
    
    static func run(withDuration duration: NSTimeInterval, update: (progress: Double) -> Void) -> DisplayLinkProgressor {
        let displayLinkProgressor = DisplayLinkProgressor(duration: duration, deterministicUpdateBlock: update, indeterministicUpdateBlock: nil)
        
        displayLinkProgressor.start()
        
        return displayLinkProgressor
    }
    
    static func run(update: (timeDelta: Double) -> Bool) -> DisplayLinkProgressor {
        let displayLinkProgressor = DisplayLinkProgressor(duration: 0, deterministicUpdateBlock: nil, indeterministicUpdateBlock: update)
        
        displayLinkProgressor.start()
        
        return displayLinkProgressor
    }
    
    private func start() {
        displayLink.addToRunLoop(NSRunLoop.mainRunLoop(), forMode: NSDefaultRunLoopMode)
        startTimestamp = CACurrentMediaTime()
        lastFrameTimestamp = startTimestamp
    }
    
    func stop() {
        displayLink.invalidate()
    }
    
    @objc func displayLinkDidUpdate(displayLink: CADisplayLink) {
        if let deterministicUpdateBlock = deterministicUpdateBlock,
           let startTimestamp = self.startTimestamp {
           
            let timeDelta = displayLink.timestamp - startTimestamp
            let progress = min(timeDelta / duration, 1.0)
            
            deterministicUpdateBlock(progress: progress)
            if progress >= 1.0 {
                stop()
            }
        }
        if let indeterministicUpdateBlock = indeterministicUpdateBlock,
           let lastTimestamp = self.lastFrameTimestamp {
            
            let timeDeltaSinceLastFrame = displayLink.timestamp - lastTimestamp
            let shouldContinue = indeterministicUpdateBlock(timeDelta: timeDeltaSinceLastFrame)
            
            if !shouldContinue {
                stop()
            }
            
            self.lastFrameTimestamp = displayLink.timestamp
        }
    }
}
