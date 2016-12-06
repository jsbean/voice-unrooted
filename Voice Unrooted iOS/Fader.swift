//
//  Fader.swift
//  SwiftAudioKitTest
//
//  Created by Hans Tutschku on 4/25/16.
//  Copyright © 2016 Hans Tutschku. All rights reserved.
//

import Foundation
import AudioKit

/**
 Adjusts the volume of an `AKAudioPlayer`.
 */
final class Fader {
    
    public typealias Seconds = Double
    
    private weak var audioPlayer: AKSampler?
    private var timeGrain: Seconds
    private var completionHandler: (() -> ())?
    
    private var timer: Timer!
    private var interpolationIsInProgress: Bool = false
    
    public init(
        audioPlayer: AKSampler,
        timeGrain: Seconds = 1/20,
        completion: (() -> ())? = nil
    )
    {
        self.audioPlayer = audioPlayer
        self.timeGrain = timeGrain
        self.completionHandler = completion
    }
    
    public func fadeOut(over duration: Seconds = 1.0) {
        fade(to: 0, over: duration)
    }
    
    // TODO: Consider adding to master `Timeline`.
    public func fade(to destinationVolume: Double, over duration: Seconds) {
        guard let audioPlayer = audioPlayer else { return }
        let startVolume = audioPlayer.volume
        let deltaVolume = destinationVolume - startVolume
        let numberOfSteps = duration / timeGrain
        let volumeGrain = deltaVolume / numberOfSteps
        engageTimer(withVolumeGrain: volumeGrain)
    }
    
    public func engageTimer(withVolumeGrain volumeGrain: Double) {
        timer = Timer.scheduledTimer(timeInterval: 1/20,
            target: self,
            selector: #selector(adjustVolume),
            userInfo: volumeGrain,
            repeats: true
        )
        interpolationIsInProgress = true
    }
    
    @objc public func adjustVolume(_ sender: Timer) {
        
        guard
            let audioPlayer = audioPlayer,
            let amount = sender.userInfo as? Double
        else {
            return
        }
        
        abortInterpolationIfNecessary()
        audioPlayer.volume += amount
    }
    
    private func abortInterpolationIfNecessary() {
        guard
            let audioPlayer = audioPlayer,
            audioPlayer.volume <= 0,
            interpolationIsInProgress
        else {
            return
        }

        timer.invalidate()
        completionHandler?()
        interpolationIsInProgress = false
    }
}
