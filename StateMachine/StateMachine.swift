//
//  StateMachine.swift
//  StateMachine
//
//  Created by Curt Clifton on 11/7/15.
//  Copyright © 2015 curtclifton.net. All rights reserved.
//

import Foundation

protocol StateMachineState {
    typealias EventType
    
    mutating func resetToInitialStateWithStateMachine(stateMachine: StateMachine<Self>)
    
    mutating func transitionWithEvent(event: EventType) -> TransitionOutcome<Self>

    mutating func takePreTransitionActionForEvent(event: EventType, withStateMachine stateMachine: StateMachine<Self>)
    mutating func takeEnterStateActionWithStateMachine(stateMachine: StateMachine<Self>)
    mutating func takeExitStateActionWithStateMachine(stateMachine: StateMachine<Self>)
    mutating func takePostTransitionActionForEvent(event: EventType, withStateMachine stateMachine: StateMachine<Self>)
}

// Default action methods are no-ops
extension StateMachineState {
    mutating func takePreTransitionActionForEvent(event: EventType, withStateMachine stateMachine: StateMachine<Self>) {
        // override if there’s work to be done
    }
    
    mutating func takeEnterStateActionWithStateMachine(stateMachine: StateMachine<Self>)  {
        // override if there’s work to be done
    }
    
    mutating func takeExitStateActionWithStateMachine(stateMachine: StateMachine<Self>)  {
        // override if there’s work to be done
    }
    
    mutating func takePostTransitionActionForEvent(event: EventType, withStateMachine stateMachine: StateMachine<Self>)  {
        // override if there’s work to be done
    }
}

enum TransitionOutcome<State: StateMachineState> {
    case NewState(previousState: State)
    case SameState
}

class StateMachine<State: StateMachineState> {
    var state: State
    
    init(state: State) {
        self.state = state
        self.state.resetToInitialStateWithStateMachine(self)
    }

    func processEvent(event: State.EventType) {
        state.takePreTransitionActionForEvent(event, withStateMachine: self)
        let outcome = state.transitionWithEvent(event)
        switch outcome {
        case .NewState(var previousState):
            previousState.takeExitStateActionWithStateMachine(self)
            state.takeEnterStateActionWithStateMachine(self)
        case .SameState:
            break
        }
        state.takePostTransitionActionForEvent(event, withStateMachine: self)
    }
}
