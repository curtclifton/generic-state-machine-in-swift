//
//  ViewController.swift
//  StateMachine
//
//  Created by Curt Clifton on 11/7/15.
//  Copyright © 2015 curtclifton.net. All rights reserved.
//

import UIKit

class ViewController: UIViewController, StenciltownViewController {
    
    @IBOutlet weak var statusLabel: UILabel!
    @IBOutlet weak var downloadButton: UIButton!
    @IBOutlet weak var progressView: UIProgressView!
    
    var viewModel: StenciltownViewModel? {
        didSet {
            updateView()
        }
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        updateView()
        viewModel?.beginFetch()
    }
    
    func updateView() {
        guard viewIfLoaded != nil else {
            return
        }
        guard let viewModel = self.viewModel else {
            return
        }
        
        if statusLabel.text != viewModel.stateDescription {
            statusLabel.text = viewModel.stateDescription
        }
        downloadButton.hidden = viewModel.downloadButtonHidden
        downloadButton.enabled = viewModel.downloadButtonEnabled
        progressView.hidden = viewModel.progressBarHidden
        progressView.progress = viewModel.progressBarProgress
    }
    
    @IBAction func download(sender: AnyObject) {
        viewModel?.download()
    }
}

