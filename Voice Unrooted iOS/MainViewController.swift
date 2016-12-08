//
//  MainViewController.swift
//  Voice Unrooted iOS
//
//  Created by James Bean on 12/5/16.
//  Copyright © 2016 James Bean. All rights reserved.
//

import UIKit
import AudioKit
import Timeline
import ProgressBar

// FIXME: This ViewController does too much!
class MainViewController: UIViewController {
    
    // FIXME: Remove dependency on this if possible
    private let appDelegate = UIApplication.shared.delegate as! AppDelegate
    
    // MARK: - Timing
    
    // Scheduler that fires events off at the right time
    private var timeline = Timeline(rate: 1/20)
    
    // Bar that indicates progression through current event.
    private var progressBar: ProgressBar!
    
    // The events to be executed.
    private let events = EventCollection()
    
    // FIXME: Update this API
    @IBOutlet weak var metronome: ProgressMeterView!
    
    // State to accept or not the Pedal press.
    fileprivate var isAcceptingPedalPress = true
    
    // Whether MIDI pedal is up or down
    fileprivate var pedalPolarity = true
    
    @IBOutlet weak var touchButton: UIButton!
    @IBOutlet weak var storeParametersButton: UIButton!
    @IBOutlet weak var masterSlaveSelect: UISegmentedControl!
    @IBOutlet weak var viewGroupTouch: UIView!
    @IBOutlet weak var viewGroupTouch2: UIView!
    @IBOutlet weak var outputVolumeView: UIView!
    @IBOutlet weak var viewGroupExpert: UIView!
    @IBOutlet weak var viewGroupCounters: UIView!
    @IBOutlet weak var appNameLabel: UILabel!
    @IBOutlet weak var appVersionLabel: UILabel!
    @IBOutlet weak var nextButton: UIButton!
    @IBOutlet weak var previousButton: UIButton!
    @IBOutlet weak var stopButton: UIButton!
    @IBOutlet weak var eventNumberLabel: UILabel!
    @IBOutlet weak var preparedEventNumberLabel: UILabel!
    @IBOutlet weak var outputVolumeSlider: UISlider!
    @IBOutlet weak var outputVolumeSliderLabel: UILabel!
    @IBOutlet weak var dataStoreProgressLabel: UILabel!
    
    public override var canBecomeFirstResponder: Bool {
        return true
    }
    
    public override var keyCommands: [UIKeyCommand]? {
        
        let left = UIKeyCommand(
            input: UIKeyInputLeftArrow,
            modifierFlags: UIKeyModifierFlags(),
            action: #selector(leftPedalPressed)
        )
        
        let right = UIKeyCommand(
            input: UIKeyInputRightArrow,
            modifierFlags: UIKeyModifierFlags(),
            action: #selector(rightPedalPressed)
        )
        
        let up = UIKeyCommand(
            input: UIKeyInputUpArrow,
            modifierFlags: UIKeyModifierFlags(),
            action: #selector(leftPedalPressed)
        )
        
        let down = UIKeyCommand(
            input: UIKeyInputDownArrow,
            modifierFlags: UIKeyModifierFlags(),
            action: #selector(rightPedalPressed)
        )
        
        return [left, right, up, down]
    }
    
    // MARK: - Initializers
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    // MARK: - UIViewController
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // FIXME: wrap up in method
        DefaultValues.readUserDefaults()
        if DefaultValues.Defaults.outputVolume == 0 {
            DefaultValues.Defaults.outputVolume = 0.75
            DefaultValues.writeUserDefaults()
            DefaultValues.readUserDefaults()
        }
        
        configureMIDI()
        configureProgressBar()
        configureAppearance()
        restoreInterfaceElements()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        ensureNavigationBarHidden()
        updateOutputVolumeSlider()
        resetMetronome()
        clearEventLabel()
        clearDataStoreProgressLabel()
        
        // FIXME: wrap up in method
        if events.index > 0 {
            updatePreparedEventLabel(preparedEventNumber: events.current.index)
        } else {
            updatePreparedEventLabel(preparedEventNumber: 1)
        }
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        manageScoreAndAudioFiles()
    }
    
    // MIDI
    private func configureMIDI() {
        let midiIn = AKMIDI()
        midiIn.openInput()
        midiIn.addListener(self)
        pedalPolarity = DefaultValues.Defaults.pedalPolarity
    }
    
    // MARK: - UI Methods
    
    @IBAction func storeParametersPressed(_ sender: AnyObject) {
        // Not yet implemented!
    }
    
    @IBAction func stopButtonPressed(_ sender: AnyObject) {
        stopEverything()
    }
    
    @IBAction func touchButtonPressed(_ sender: AnyObject) {
        activateEvent()
    }
    
    @IBAction func nextButtonPressed(_ sender: AnyObject) {
        prepareNextCue()
        enableTouchButton()
    }
    
    @IBAction func previousButtonPressed(_ sender: AnyObject) {
        preparePreviousCue()
        enableTouchButton()
    }
    
    @IBAction func outputVolumeSliderChanged(_ sender: AnyObject) {
        updateOutputVolumeSliderLabel()
    }
    
    // FIXME: Not yet implemented!
    @IBAction func masterSlaveSelectChanged(_ sender: AnyObject) { }
    
    // FIXME: Not yet implemented!
    @IBAction func showEventsPopover(_ sender: AnyObject) { }
    
    // FIXME: Not yet implemented!
    @IBAction func showSettingsModal(_ sender: AnyObject) { }
    
    // Write the Default values to NSUserDefaults when the slider has been released
    @IBAction func outputVolumeSliderChangedEnded(_ sender: AnyObject) {
        DefaultValues.Defaults.outputVolume = outputVolumeSlider.value
        DefaultValues.writeUserDefaults()
    }
    
    // MARK: - Cue Navigation
    
    public func preparePreviousCue() {
        do {
            try events.preparePrevious()
            prepareCueOnDeck()
        } catch {
            // TODO: Manage case where we can't go back!
        }
    }
    
    public func prepareNextCue() {
        do {
            try events.prepareNext()
            prepareCueOnDeck()
        } catch {
            // TODO: Manage case where we can't go forward!
        }
    }
    
    private func prepareCueOnDeck() {
        prepareAudioForCurrentEvent()
        manageInterfaceElementsForCurrentEvent()
    }
    
    private func manageInterfaceElementsForCurrentEvent() {
        manageInterfaceElements(for: events.current.index)
    }
    
    private func manageInterfaceElements(for preparedEventIndex: Int) {
        updatePreparedEventLabel(preparedEventNumber: preparedEventIndex)
    }
    
    private func clearDataStoreProgressLabel() {
        self.dataStoreProgressLabel.text = ""
    }
    
    private func manageScoreAndAudioFiles() {
        guard !appDelegate.scoreIsPresent else {
            prepareToStartIfScoreIsPresent()
            return
        }
        updateDataStoreProgressLabel("Retrieving score")
        retrieveScore()
    }
    
    private func prepareToStartIfScoreIsPresent() {
        manageAudioFiles()
    }
    
    private func manageAudioFiles() {
        
        guard !appDelegate.allAudioFilesArePresent else {
            updateDataStoreProgressLabel("Audio files are ready")
            prepareToPlayFirstAudioFile()
            enableTouchButton()
            return
        }
        
        let audioFilesNeedingDownload = audioFilesUnavailableLocally
        if !audioFilesNeedingDownload.isEmpty {
            presentAudioFilesDownloadAlert(names: audioFilesNeedingDownload)
        } else {
            enableTouchButton()
            prepareToPlayFirstAudioFile()
        }
    }
    
    // FIXME: Rename to currentAudioFile, perhaps reuse other method
    private func prepareToPlayFirstAudioFile() {
        appDelegate.audioPlayerPool.load(
            name: events.current.soundFileName,
            volume: events.current.gain
        )
    }
    
    private func retrieveScore() {
        do {
            clearDataStoreProgressLabel()
            disableTouchButton()
            let yamlScore = try DataStore.retrieveScoreFromLocalStore(name: "voice_unrooted")
            appDelegate.scoreIsPresent = true
            enableTouchButton()
            try events.populate(with: yamlScore)
            manageAudioFiles()
            
        } catch {
            presentScoreDownloadAlert()
            enableTouchButton()
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
        do {
            var i = 1
            
            try DataStore.retrieveAudioFilesFromNetwork(audioFileNames: names) {
                
                self.updateDataStoreProgressLabel(amount: i, of: names.count)
                
                if i == names.count {
                    self.updateDataStoreProgressLabelUponCompletion()
                    self.prepareToPlayFirstAudioFile()
                }
                
                i += 1
            }
            
        } catch {
            updateDataStoreProgressLabel("Could not download audio files!")
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
            // TODO: Error message on .main thread
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
        disableTouchButton()
        updateDataStoreProgressLabel("Processing score")
    }
    
    private func restoreUIAfterScoreProcessing() {
        clearDataStoreProgressLabel()
        enableTouchButton()
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
    
    // MARK: - Interface Elements
    
    private func fadeInterfaceElements() {
        fadeTouchButton()
    }
    
    private func fadeTouchButton() {
        touchButton.backgroundColor = Color.light
        touchButton.setTitleColor(Color.darkGray, for: UIControlState())
        touchButton.isEnabled = true
    }
    
    private func configureProgressBar() {
        let padX: CGFloat = 20
        progressBar = ProgressBar(
            origin: CGPoint(x: padX, y: 0),
            fullWidth: view.frame.width - 2 * padX,
            height: 68,
            color: UIColor.white.cgColor,
            opacity: 1
        )
        view.layer.addSublayer(progressBar.layer)
    }
    
    private func updateOutputVolumeSlider() {
        outputVolumeSlider.value = DefaultValues.Defaults.outputVolume
        updateOutputVolumeSliderLabel()
    }
    
    private func updateOutputVolumeSliderLabel() {
        appDelegate.audioPlayerPool.volume = Double(outputVolumeSlider.value)
        outputVolumeSliderLabel.text = String(format: "%.2f", outputVolumeSlider.value)
    }
    
    private func resetMetronome() {
        metronome.setProgress(1.0)
        metronome.setProgressColor(Color.white.cgColor)
    }
    
    // TODO: use slightly more explicit naming here (configureVisualAttributes() or sim.)
    private func configureAppearance() {
        view.backgroundColor = Color.light
        viewGroupCounters.backgroundColor = Color.dark
        viewGroupExpert.backgroundColor = Color.dark
        viewGroupTouch.backgroundColor = Color.dark
        viewGroupTouch2.backgroundColor = Color.dark
        outputVolumeView.backgroundColor = Color.dark
        metronome.backgroundColor = Color.dark
        progressBar.color = Color.white.cgColor
        configureAppNameAndVersionLabels()
    }
    
    private func configureAppNameAndVersionLabels() {
        let version = Bundle.main.infoDictionary!["CFBundleVersion"]!
        appVersionLabel.text = "\(version)"
        appNameLabel.text = "Voice Unrooted"
    }
    
    // MARK: - Restore Interface Elements
    
    private func restoreInterfaceElements() {
        restoreNextButton()
        restorePreviousButton()
        restoreTouchButton()
        restoreStopButton()
    }
    
    private func restoreNextButton() {
        nextButton.isEnabled = true
        nextButton.backgroundColor = Color.light
        nextButton.setTitleColor(Color.white, for: UIControlState())
    }
    
    private func restorePreviousButton() {
        previousButton.isEnabled = true;
        previousButton.backgroundColor = Color.light
        previousButton.setTitleColor(Color.white, for: UIControlState())
    }
    
    private func restoreStopButton() {
        stopButton.isEnabled = true;
        stopButton.backgroundColor = Color.red
        stopButton.setTitleColor(Color.white, for: UIControlState())
    }
    
    // MARK: - Timeline
    
    private func regenerateTimeline() {
        timeline.stop()
        timeline = Timeline(rate: 1/120)
    }
    
    private func stopTimers() {
        timeline.stop()
    }
    
    private func manageTimeline(for event: Event) {
        regenerateTimeline()
        
        if DefaultValues.Defaults.metronomeIsActive {
            scheduleMetronomeFlashes(at: event.tempo)
        }
        
        timeline.start()
    }
    
    private func stopEverything() {
        enableTouchButton()
        stopTimers()
        stopProgressBar()
        stopMetronome()
        stopAudio()
        prepareAudioForCurrentEvent()
    }
    
    private func stopAudio() {
        appDelegate.audioPlayerPool.stopAll()
    }
    
    private func stopProgressBar() {
        progressBar.stop()
    }
    
    private func stopMetronome() {
        metronome.setProgress(1)
    }
    
    public func activateEvent() {
        let event = events.current
        manageAudioForNewEvent()
        manageTimeline(for: event)
        manageInterfaceElements(for: event)
        updateEventLabel(eventNumber: events.current.index)
        prepareNextCue()
    }
    
    private func advanceToNextEvent() {
        updateEventLabel(eventNumber: events.current.index)
        updatePreparedEventLabel(preparedEventNumber: events.current.index + 1)
    }
    
    private func manageAudioForNewEvent() {
        playCurrentAudioFile()
        fadeOutPreviousAudioFile()
    }
    
    private func playCurrentAudioFile() {
        appDelegate.audioPlayerPool.play()
    }
    
    private func prepareAudioForCurrentEvent() {
        let event = events.current
        appDelegate.audioPlayerPool.load(name: event.soundFileName, volume: event.gain)
    }
    
    private func fadeOutPreviousAudioFile() {
        let duration = events.previous?.fadeTime ?? 2
        let pool = appDelegate.audioPlayerPool!
        pool.fadeOutPrevious(over: duration)
    }
    
    private func manageInterfaceElements(for event: Event) {
        engageProgressBar(for: event.progressBarTime)
        scheduleEnablingTouchButton(at: event.progressBarTime - 2)
        disableTouchButton()
    }
    
    private func scheduleMetronomeFlashes(at tempo: Double) {
        timeline.addLooping(at: tempo, offset: 0, body: self.showMetronome)
        timeline.addLooping(at: tempo, offset: 0.2, body: self.hideMetronome)
    }
    
    // MARK: - Update Event Interface Elements
    
    private func engageProgressBar(for duration: Double) {
        progressBar.start(for: duration)
    }
    
    private func updateEventLabel(eventNumber: Int) {
        eventNumberLabel.text = String(eventNumber)
    }
    
    private func updatePreparedEventLabel(preparedEventNumber: Int) {
        preparedEventNumberLabel.text = String(preparedEventNumber)
    }
    
    private func clearEventLabel() {
        eventNumberLabel.text = ""
    }
    
    // MARK: - Touch button control
    
    private func disableTouchButton() {
        touchButton.isEnabled = false
        touchButton.backgroundColor = Color.light
        touchButton.setTitleColor(Color.light, for: UIControlState())
    }
    
    private func enableTouchButton() {
        touchButton.isEnabled = true
        isAcceptingPedalPress = true
        restoreTouchButton()
    }
    
    private func scheduleEnablingTouchButton(at duration: Double) {
        timeline.add(at: duration, body: enableTouchButton)
    }
    
    private func restoreTouchButton() {
        touchButton.isEnabled = true
        touchButton.backgroundColor = Color.light
        touchButton.setTitleColor(Color.red, for: UIControlState())
    }
    
    // MARK: - Metronome control
    
    private func showMetronome() {
        metronome.setProgress(0)
    }
    
    private func hideMetronome() {
        metronome.setProgress(1)
    }
    
    // MARK: - Configure UI Elements
    
    private func ensureNavigationBarHidden() {
        self.navigationController?.isNavigationBarHidden = true
    }
    
    private func ensureLandscapeOrientation() {
        let value = UIInterfaceOrientation.landscapeLeft.rawValue
        UIDevice.current.setValue(value, forKey: "orientation")
    }
    
    override var shouldAutorotate: Bool {
        return true
    }
    
    override var prefersStatusBarHidden: Bool {
        return true
    }
}

extension MainViewController {
    
    // MARK: - AirTurn
    
    func leftPedalPressed() {
        print("left pedal pressed")
        preparePreviousCue()
    }
    
    func rightPedalPressed() {
        print("right pedal pressed")
        activateEvent()
    }
}

extension MainViewController: AKMIDIListener {
    
    func midiPedalPressed() {
        DispatchQueue.main.async {
            self.isAcceptingPedalPress = false
            self.activateEvent()
        }
    }
    
    func receivedMIDIController(_ controller: Int, value: Int, channel: MIDIChannel) {
        
        print("midi in")
        
        guard isAcceptingPedalPress && touchButton.isEnabled else { return }
        
        if pedalPolarity {
        
            if value > 64 {
                midiPedalPressed()
            }
            
        } else {
            
            if value <= 64 {
                midiPedalPressed()
            }
        }
    }
}
