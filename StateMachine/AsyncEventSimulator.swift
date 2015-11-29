//
//  AsyncEventSimulator.swift
//  StateMachine
//
//  Created by Curt Clifton on 11/9/15.
//  Copyright © 2015 curtclifton.net. All rights reserved.
//

import Foundation

private func makeBackgroundQueue() -> NSOperationQueue {
    let opQueue = NSOperationQueue()
    opQueue.qualityOfService = .Background
    opQueue.maxConcurrentOperationCount = 2
    return opQueue
}
private let backgroundQueue = makeBackgroundQueue()

func afterDelayOfTimeInterval(delay: NSTimeInterval, performBlockOnMainQueue block: () -> ()) {
    backgroundQueue.addOperationWithBlock {
        NSThread.sleepForTimeInterval(delay)
        NSOperationQueue.mainQueue().addOperationWithBlock {
            block()
        }
    }
}

private let asyncSimulationProgressGranularity = Float(1.0 / 50.0)
func simulateAsyncOperationLastingSeconds<State: StateMachineState>(seconds: Int, forStateMachine stateMachine: StateMachine<State>, completionEventGenerator completionEvent: () -> State.EventType, progressEventGenerator progressEvent: (Float) -> State.EventType) {
    let durationInSeconds = Double(seconds)
    let progressInterval = durationInSeconds * Double(asyncSimulationProgressGranularity)
    let startTime = NSDate()
    
    func rescheduleProgress() {
        afterDelayOfTimeInterval(progressInterval) {
            let currentTime = NSDate()
            let elapsedTimeInterval = currentTime.timeIntervalSinceDate(startTime)
            let progress = Float(elapsedTimeInterval / durationInSeconds)
            stateMachine.processEvent(progressEvent(progress))
            // schedule another update unless it would put us past 100%
            if progress + asyncSimulationProgressGranularity < 1.0 {
                rescheduleProgress()
            }
        }
    }
    
    rescheduleProgress()
    afterDelayOfTimeInterval(durationInSeconds)  {
        stateMachine.processEvent(completionEvent())
    }
}
