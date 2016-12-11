//
//  WelcomeViewController.swift
//  Voice Unrooted iOS
//
//  Created by James Bean on 12/11/16.
//  Copyright © 2016 James Bean. All rights reserved.
//

import UIKit

class WelcomeViewController: UIViewController {
    
    // FIXME: Remove dependency on this if possible
    private let appDelegate = UIApplication.shared.delegate as! AppDelegate
    
    // The events to be populated.
    private let events = EventCollection()

    @IBOutlet weak var dataStoreProgressLabel: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        retrieveResources()
    }
    
    @IBAction func startButtonPressed(_ sender: Any) {
        proceedToPerformanceViewController()
    }
    
    private func proceedToPerformanceViewController() {
        
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        
        let controller = storyboard.instantiateViewController(
            withIdentifier: "NavigationController"
        )
        
        present(controller, animated: false, completion: nil)
    }
    
    // MARK: - Score and Audio File Management
    
    private func retrieveResources() {
        retrieveScore()
        retrieveAudioFiles()
        proceedToPerformanceViewController()
    }
    
    private func retrieveScore() {
        
        updateDataStoreProgressLabel("Retrieving score...")
        
        do {
            let yamlScore = try DataStore.retrieveScoreFromLocalStore(name: "voice_unrooted")
            try events.populate(with: yamlScore)
            
        } catch {
            presentScoreDownloadAlert()
        }
    }
    
    private func retrieveAudioFiles() {
        
        // If all audio files are prepared, continue!
        if audioFilesUnavailableLocally.isEmpty {
            updateDataStoreProgressLabel("Audio files are ready")
            proceedToPerformanceViewController()
        } else {
            presentAudioFilesDownloadAlert(names: audioFilesUnavailableLocally)
        }
    }
    
    private func presentAudioFilesDownloadAlert(names: [String]) {
        
        if names.isEmpty { return }
        
        let alert = UIAlertController.downloadPermissionAlert(
            title: "There are audio files that still need to be downloaded",
            message: "Download remaining audio files?",
            sourceView: self.view
        )
        {
            self.downloadAudioFiles(names: names)
        }
        
        present(alert, animated: false)
    }
    
    private func downloadAudioFiles(names: [String]) {
        
        // Dispatch group to which each async task belongs
        let group = DispatchGroup()
        
        // Amount of audio files downloaded thus far
        var amountDownloaded = 1
        
        // Iterate over all names needing to be downloaded
        for name in names {
            
            // Enter the dispatch group
            group.enter()
            
            // Retrieve a single audio file
            DataStore.retrieveAudioFileFromNetwork(name: name) {
                
                // Let the world know!
                self.updateDataStoreProgressLabel(amount: amountDownloaded, of: names.count)
                
                // Increment counter
                amountDownloaded += 1
                
                // Leave the dispatch group
                group.leave()
            }
        }
        
        // After all audio files have been downloaded, proceed to performance interface
        group.notify(queue: .main) {
            self.updateDataStoreProgressLabelUponCompletion()
            self.proceedToPerformanceViewController()
        }
    }
    
    private func presentScoreDownloadAlert() {
        
        // Create an alert that prompts the user to download the score
        let alert = UIAlertController.downloadPermissionAlert(
            title: "The score cannot be found on the device",
            message: "Download the score?",
            sourceView: self.view,
            performingUponPermission: downloadScore
        )
        
        present(alert, animated: false)
    }
    
    private func downloadScore() {
        
        updateUIBeforeScoreRetrieval()
        
        do {
            try DataStore.retrieveScoreFromNetwork(pieceName: "voice_unrooted") {
                
                // Upon successful retrieval of score from network, do:
                self.processScoreFromLocalStore()
                self.restoreUIAfterScoreProcessing()
                self.retrieveAudioFiles()
            }
        } catch {
            
            DispatchQueue.main.async {
                self.updateDataStoreProgressLabel("Unable to download score")
            }
        }
    }
    
    private func processScoreFromLocalStore() {
        
        do {
            updateUIBeforeScoreProcessing()
            let yamlScore = try DataStore.retrieveScoreFromLocalStore(name: "voice_unrooted")
            try events.populate(with: yamlScore)
        } catch {
            // TODO: Error message
        }
    }
    
    private func updateUIBeforeScoreRetrieval() {
        updateDataStoreProgressLabel("Retrieving score from network")
    }
    
    private func updateUIBeforeScoreProcessing() {
        updateDataStoreProgressLabel("Processing score")
    }
    
    private func restoreUIAfterScoreProcessing() {
        clearDataStoreProgressLabel()
    }
    
    private func updateDataStoreProgressLabel(amount: Int, of total: Int) {
        updateDataStoreProgressLabel("Downloading \(amount)/\(total) audio files")
    }
    
    private func updateDataStoreProgressLabelUponCompletion() {
        updateDataStoreProgressLabel("Ready!")
    }
    
    private var audioFilesUnavailableLocally: [String] {
        let names = events.map { $0.soundFileName }
        return DataStore.audioFilesUnavailableLocally(from: names)
    }
    
    private func updateDataStoreProgressLabel(_ text: String) {
        dataStoreProgressLabel.text = text
    }
    
    private func clearDataStoreProgressLabel() {
        dataStoreProgressLabel.text = ""
    }
}
