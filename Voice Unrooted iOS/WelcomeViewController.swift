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

    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        manageScoreAndAudioFiles()
    }
    
    // MARK: - Score and Audio File Management
    
    // TODO: Move to `WelcomeViewController`.
    private func manageScoreAndAudioFiles() {
        
        print("manage score and audio files")
        
        guard !appDelegate.scoreIsPresent else {
            prepareToStartIfScoreIsPresent()
            return
        }
        
        //disableInterfaceElements()
        updateDataStoreProgressLabel("Retrieving score")
        retrieveScore()
    }
    
    // TODO: Move to `WelcomeViewController`.
    private func prepareToStartIfScoreIsPresent() {
        manageAudioFiles()
    }
    
    // TODO: Move to `WelcomeViewController`.
    // FIXME: This is not modelled well!
    private func manageAudioFiles() {
        
        guard !appDelegate.allAudioFilesArePresent else {
            updateDataStoreProgressLabel("Audio files are ready")
            //prepareToPlayFirstAudioFile()
            return
        }
        
        let audioFilesNeedingDownload = audioFilesUnavailableLocally
        if !audioFilesNeedingDownload.isEmpty {
            presentAudioFilesDownloadAlert(names: audioFilesNeedingDownload)
        } else {
            //prepareToPlayFirstAudioFile()
        }
    }
    
    /*
    // FIXME: Rename to currentAudioFile, perhaps reuse other method
    private func prepareToPlayFirstAudioFile() {
        
        DispatchQueue.main.async {
            self.restoreInterfaceElements()
        }
        
        appDelegate.audioPlayerPool.load(
            name: events.current.soundFileName,
            volume: events.current.gain
        )
    }
    */
    
    // TODO: Move to `WelcomeViewController`.
    private func retrieveScore() {
        do {
            //clearDataStoreProgressLabel()
            let yamlScore = try DataStore.retrieveScoreFromLocalStore(name: "voice_unrooted")
            appDelegate.scoreIsPresent = true
            try events.populate(with: yamlScore)
            manageAudioFiles()
            
        } catch {
            presentScoreDownloadAlert()
        }
    }
    
    // TODO: Move to `WelcomeViewController`.
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
    
    // TODO: Move to `WelcomeViewController`.
    private func downloadAudioFiles(names: [String]) {
        do {
            var i = 1
            
            try DataStore.retrieveAudioFilesFromNetwork(audioFileNames: names) {
                
                self.updateDataStoreProgressLabel(amount: i, of: names.count)
                
                if i == names.count {
                    self.updateDataStoreProgressLabelUponCompletion()
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
    
    // TODO: Move to `WelcomeViewController`.
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
    
    // TODO: Move to `WelcomeViewController`.
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
    
    // TODO: Move to `WelcomeViewController`.
    private func processScoreFromLocalStore() {
        
        do {
            updateUIBeforeScoreProcessing()
            let yamlScore = try DataStore.retrieveScoreFromLocalStore(name: "voice_unrooted")
            try events.populate(with: yamlScore)
        } catch {
            // TODO: Error message
        }
    }
    
    // TODO: Move to `WelcomeViewController`.
    private func updateUIBeforeScoreRetrieval() {
        updateDataStoreProgressLabel("Retrieving score from network")
    }
    
    // TODO: Move to `WelcomeViewController`.
    private func updateUIBeforeScoreProcessing() {
        updateDataStoreProgressLabel("Processing score")
    }
    
    // TODO: Move to `WelcomeViewController`.
    private func restoreUIAfterScoreProcessing() {
        //clearDataStoreProgressLabel()
    }
    
    // TODO: Move to `WelcomeViewController`.
    private func updateDataStoreProgressLabel(
        amount audioFilesDownloaded: Int,
        of total: Int
        )
    {
        updateDataStoreProgressLabel(
            "Downloading \(audioFilesDownloaded)/\(total) audio files"
        )
    }
    
    // TODO: Move to `WelcomeViewController`.
    private func updateDataStoreProgressLabelUponCompletion() {
        updateDataStoreProgressLabel("Audio files ready")
    }
    
    // TODO: Move to `WelcomeViewController`.
    private var audioFilesUnavailableLocally: [String] {
        let names = events.map { $0.soundFileName }
        return DataStore.audioFilesUnavailableLocally(from: names)
    }
    
    // TODO: Move to `WelcomeViewController`.
    private func updateDataStoreProgressLabel(_ text: String) {
        //dataStoreProgressLabel.text = text
    }
}

