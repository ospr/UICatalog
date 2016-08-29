//
//  CADisplayLink+Additions.swift
//  UICatalog
//
//  Created by Kip Nicol on 8/12/16.
//  Copyright © 2016 Kip Nicol. All rights reserved.
//

import Foundation

// TODO: consider splitting this up so that one class doesn't handle both indeterminate and determinate progress
//       perhaps have a protocol that gets called to update its own closure
internal class DisplayLinkProgressor: NSObject {
    
    private var displayLink: CADisplayLink!
    private let duration: NSTimeInterval
    
    private let indeterministicUpdateBlock: ((timeDelta: NSTimeInterval) -> Bool)?
    private let deterministicUpdateBlock: ((progress: Double) -> Void)?
    
    private var startTimestamp: CFTimeInterval?
    
    
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
    
    static func run(withDuration duration: NSTimeInterval, update: (progress: Double) -> Void) {
        let displayLinkProgressor = DisplayLinkProgressor(duration: duration, deterministicUpdateBlock: update, indeterministicUpdateBlock: nil)
        
        displayLinkProgressor.start()
    }
    
    static func run(update: (timeDelta: Double) -> Bool) {
        let displayLinkProgressor = DisplayLinkProgressor(duration: 0, deterministicUpdateBlock: nil, indeterministicUpdateBlock: update)
        
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
        
        let timeDelta = displayLink.timestamp - startTimestamp
        
        if let deterministicUpdateBlock = deterministicUpdateBlock {
            let progress = min(timeDelta / duration, 1.0)
            
            deterministicUpdateBlock(progress: progress)
            if progress >= 1.0 {
                stop()
            }
        }
        if let indeterministicUpdateBlock = indeterministicUpdateBlock {
            let shouldContinue = indeterministicUpdateBlock(timeDelta: timeDelta)
            
            if !shouldContinue {
                stop()
            }
        }
    }
}
