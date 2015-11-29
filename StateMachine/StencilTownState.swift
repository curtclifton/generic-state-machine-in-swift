//
//  StenciltownState.swift
//  StateMachine
//
//  Created by Curt Clifton on 11/9/15.
//  Copyright © 2015 curtclifton.net. All rights reserved.
//

import Foundation

protocol StenciltownViewController {
    var viewModel: StenciltownViewModel? { get set }
}

struct StenciltownState: StateMachineState {
    enum State {
        case Initial
        case Fetching(progress: Float)
        case Fetched
        case Downloading(progress: Float)
        case Downloaded
    }
    
    enum Event {
        case BeginFetch
        case FetchProgress(progress: Float)
        case FetchCompleted
        case BeginDownload
        case DownloadProgress(progress: Float)
        case DownloadCompleted
        case Reset
    }
    
    private var viewController: StenciltownViewController
    private var state: State
    
    init(viewController: StenciltownViewController) {
        self.viewController = viewController
        self.state = State.Initial
    }
    
    private func viewModelWithStateMachine(stateMachine: StateMachine<StenciltownState>) -> StenciltownViewModel {
        switch state {
        case .Initial:
            return StenciltownViewModel(description: "", fetchOperation: { stateMachine.processEvent(.BeginFetch) } )
        case .Fetching(let progress):
            return StenciltownViewModel(description: "Fetching Description…", progressBarHidden: false, progressBarProgress: progress)
        case .Fetched:
            return StenciltownViewModel(description: "It’s a bunny", downloadButtonHidden: false, downloadPressOperation: { stateMachine.processEvent(.BeginDownload) })
        case .Downloading(let progress):
            return StenciltownViewModel(description: "Downloading…", progressBarHidden: false, progressBarProgress: progress)
        case .Downloaded:
            return StenciltownViewModel(description: "Isn’t it cute?")
        }
    }
    
    mutating func resetToInitialStateWithStateMachine(stateMachine: StateMachine<StenciltownState>) {
        self.state = State.Initial
        viewController.viewModel = viewModelWithStateMachine(stateMachine)
    }
    
    mutating func transitionWithEvent(event: Event) -> TransitionOutcome<StenciltownState> {
        let previousState = self
        switch (state, event) {
        case (.Initial, .BeginFetch):
            state = .Fetching(progress: 0.0)
        case (.Fetching, .FetchProgress(let progress)):
            state = .Fetching(progress: progress)
            return .SameState
        case (.Fetching, .FetchCompleted):
            state = .Fetched
        case (.Fetched, .BeginDownload):
            state = .Downloading(progress: 0.0)
        case (.Downloading, .DownloadProgress(let progress)):
            state = .Downloading(progress: progress)
            return .SameState
        case (.Downloading, .DownloadCompleted):
            state = .Downloaded
        case (_, .Reset):
            state = .Initial
        default:
            // could conceivably transition to error state if we got an unexpected event, but for now just ignore it
            return .SameState
        }
        return .NewState(previousState: previousState)
    }
    
    func takePreTransitionActionForEvent(event: Event, withStateMachine stateMachine: StateMachine<StenciltownState>) {
        switch event {
        case .BeginFetch:
            // For simulation, we schedule a progress update and a fetch completed. In reality we would start the async fetch and need to poke the state machine with actual progress.
            simulateAsyncOperationLastingSeconds(5, forStateMachine: stateMachine, completionEventGenerator: { .FetchCompleted }, progressEventGenerator: { .FetchProgress(progress: $0) })
        case .BeginDownload:
            // For simulation, we schedule a progress update and a download completed. In reality we would start the async fetch and need to poke the state machine with actual progress.
            simulateAsyncOperationLastingSeconds(10, forStateMachine: stateMachine, completionEventGenerator: { .DownloadCompleted }, progressEventGenerator: { .DownloadProgress(progress: $0) })
        case .Reset: // CCC, 11/7/2015. currently no way to trigger in the UI
            // CCC, 11/7/2015. purge the background queue?
            break
        default:
            // Let state transitions handle
            break
        }
    }
    
    mutating func takePostTransitionActionForEvent(event: Event, withStateMachine stateMachine: StateMachine<StenciltownState>) {
        viewController.viewModel = viewModelWithStateMachine(stateMachine)
    }
}

struct StenciltownViewModel {
    let stateDescription: String
    let downloadButtonHidden: Bool
    let progressBarHidden: Bool
    let progressBarProgress: Float
    private let fetchOperation: (() -> Void)?
    private let downloadPressOperation: (() -> Void)?
    var downloadButtonEnabled: Bool {
        return downloadPressOperation != nil
    }
    
    init(description: String, downloadButtonHidden: Bool = true, progressBarHidden: Bool = true, progressBarProgress: Float = 0.0, fetchOperation: (() -> Void)? = nil, downloadPressOperation: (() -> Void)? = nil) {
        self.stateDescription = description
        self.downloadButtonHidden = downloadButtonHidden
        self.progressBarHidden = progressBarHidden
        self.progressBarProgress = progressBarProgress
        self.fetchOperation = fetchOperation
        self.downloadPressOperation = downloadPressOperation
    }
    
    func download() {
        downloadPressOperation?()
    }
    
    func beginFetch() {
        fetchOperation?()
    }
}
