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
    
    // The events to be executed.
    private let events = EventCollection()

    @IBOutlet weak var startButton: UIButton!
    @IBOutlet weak var dataStoreProgressLabel: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        hideStartButton()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        manageScoreAndAudioFiles()
    }
    
    @IBAction func startButtonPressed(_ sender: Any) {
        print("start button pressed")
    }
    // MARK: - Score and Audio File Management
    
    private func manageScoreAndAudioFiles() {
        
        print("manage score and audio files")
        
        guard !appDelegate.scoreIsPresent else {
            showStartButton()
            return
        }
        
        //disableInterfaceElements()
        updateDataStoreProgressLabel("Retrieving score")
        retrieveScore()
    }
    
    // FIXME: This is not modelled well!
    // FIXME: This can be cleaned up now that `MainViewController` should never be opened
    // without having initialized score and audio
    private func manageAudioFiles() {
        
        guard !appDelegate.allAudioFilesArePresent else {
            updateDataStoreProgressLabel("Audio files are ready")
            self.startButton.isHidden = false
            return
        }
        
        let audioFilesNeedingDownload = audioFilesUnavailableLocally
        if !audioFilesNeedingDownload.isEmpty {
            presentAudioFilesDownloadAlert(names: audioFilesNeedingDownload)
        } else {
            self.startButton.isHidden = false
        }
    }
    
    private func retrieveScore() {
        do {
            clearDataStoreProgressLabel()
            let yamlScore = try DataStore.retrieveScoreFromLocalStore(name: "voice_unrooted")
            appDelegate.scoreIsPresent = true
            try events.populate(with: yamlScore)
            manageAudioFiles()
            
        } catch {
            presentScoreDownloadAlert()
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
            //self.disableInterfaceElements()
            self.downloadAudioFiles(names: names)
        }
        
        present(alert, animated: false)
    }
    
    // FIXME: see: http://stackoverflow.com/questions/32642782/waiting-for-multiple-asynchronous-download-tasks
    // FIXME: see: http://commandshift.co.uk/blog/2014/03/19/using-dispatch-groups-to-wait-for-multiple-web-services/
    private func downloadAudioFiles(names: [String]) {
        do {
            var i = 1
            
            try DataStore.retrieveAudioFilesFromNetwork(audioFileNames: names) {
                
                self.updateDataStoreProgressLabel(amount: i, of: names.count)
                
                //
                if i == names.count {
                    self.updateDataStoreProgressLabelUponCompletion()
                    self.startButton.isHidden = false
                    //self.prepareToPlayFirstAudioFile()
                }
                
                i += 1
            }
            
        } catch {
            DispatchQueue.main.async {
                self.updateDataStoreProgressLabel("Unable to download audio files!")
            }
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
                self.manageAudioFiles()
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
    
    private func updateDataStoreProgressLabel(
        amount audioFilesDownloaded: Int,
        of total: Int
    )
    {
        updateDataStoreProgressLabel(
            "Downloading \(audioFilesDownloaded)/\(total) audio files"
        )
    }
    
    private func updateDataStoreProgressLabelUponCompletion() {
        updateDataStoreProgressLabel("Audio files ready")
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
    
    private func showStartButton() {
        startButton.isHidden = false
    }
    
    private func hideStartButton() {
        startButton.isHidden = true
    }
}
