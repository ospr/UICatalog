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
    
    fileprivate var displayLink: CADisplayLink!
    fileprivate let duration: TimeInterval
    
    fileprivate let indeterministicUpdateBlock: ((_ timeDelta: TimeInterval) -> Bool)?
    fileprivate let deterministicUpdateBlock: ((_ progress: Double) -> Void)?
    
    fileprivate var startTimestamp: CFTimeInterval?
    fileprivate var lastFrameTimestamp: CFTimeInterval?
    
    fileprivate init(duration: TimeInterval,
                 deterministicUpdateBlock: ((_ progress: Double) -> Void)?,
                 indeterministicUpdateBlock: ((_ timeDelta: TimeInterval) -> Bool)?) {
        self.duration = duration
        self.deterministicUpdateBlock = deterministicUpdateBlock
        self.indeterministicUpdateBlock = indeterministicUpdateBlock
        
        super.init()
        
        // Must set this after super.init() because self is passed into the object on init
        displayLink = CADisplayLink(target: self, selector: #selector(displayLinkDidUpdate))
    }
    
    static func run(withDuration duration: TimeInterval, update: @escaping (_ progress: Double) -> Void) -> DisplayLinkProgressor {
        let displayLinkProgressor = DisplayLinkProgressor(duration: duration, deterministicUpdateBlock: update, indeterministicUpdateBlock: nil)
        
        displayLinkProgressor.start()
        
        return displayLinkProgressor
    }
    
    static func run(_ update: @escaping (_ timeDelta: Double) -> Bool) -> DisplayLinkProgressor {
        let displayLinkProgressor = DisplayLinkProgressor(duration: 0, deterministicUpdateBlock: nil, indeterministicUpdateBlock: update)
        
        displayLinkProgressor.start()
        
        return displayLinkProgressor
    }
    
    fileprivate func start() {
        displayLink.add(to: RunLoop.main, forMode: RunLoopMode.defaultRunLoopMode)
        startTimestamp = CACurrentMediaTime()
        lastFrameTimestamp = startTimestamp
    }
    
    func stop() {
        displayLink.invalidate()
    }
    
    @objc func displayLinkDidUpdate(_ displayLink: CADisplayLink) {
        if let deterministicUpdateBlock = deterministicUpdateBlock,
           let startTimestamp = self.startTimestamp {
           
            let timeDelta = displayLink.timestamp - startTimestamp
            let progress = min(timeDelta / duration, 1.0)
            
            deterministicUpdateBlock(progress)
            if progress >= 1.0 {
                stop()
            }
        }
        if let indeterministicUpdateBlock = indeterministicUpdateBlock,
           let lastTimestamp = self.lastFrameTimestamp {
            
            let timeDeltaSinceLastFrame = displayLink.timestamp - lastTimestamp
            let shouldContinue = indeterministicUpdateBlock(timeDeltaSinceLastFrame)
            
            if !shouldContinue {
                stop()
            }
            
            self.lastFrameTimestamp = displayLink.timestamp
        }
    }
}
