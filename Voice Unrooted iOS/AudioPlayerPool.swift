//
//  AudioPlayerPool.swift
//  SwiftAudioKitTest
//
//  Created by Hans Tutschku on 4/22/16.
//  Copyright © 2016 Hans Tutschku. All rights reserved.
//

import ArithmeticTools
import AudioKit

/// Polyphonic audio player.
final class AudioPlayerPool: AKMixer {
    
    // MARK: - Type methods
    
    // Returns an array of `AKAudioPlayer` objects with the given `amount`.
    private static func makeAudioPlayers(amount: Int) -> [AKSampler] {
        return (0..<amount).map { _ in
            makeConfiguredAudioPlayer(name: "a440", baseDir: .resources)!
        }
    }
    
    // Create `AKAudioPlayer` with the given file name, if possible.
    private static func makeConfiguredAudioPlayer(
        name: String,
        volume: Double = 1.0,
        loops: Bool = false,
        baseDir: AKAudioFile.BaseDirectory = .documents
    ) -> AKSampler?
    {
        let sampler = AKSampler()
        sampler.volume = volume
        return sampler
    }
    
    // Audio players
    fileprivate let audioPlayers: [AKSampler]

    // Index of current playing `AKSampler`.
    private var index: Int = 0

    // Next available audio player, if present.
    private var currentPlayer: AKSampler {
        return audioPlayers[index % audioPlayers.count]
    }

    // MARK: - Initializers
    
    /**
     Create an AudioPlayerPool.
     
     - parameter amountAudioPlayers: Amount of audio files that can be played at once
     */
    public init(voices: Int = 3) {
        self.audioPlayers = AudioPlayerPool.makeAudioPlayers(amount: voices)
        super.init()
        connectAudioPlayers()
    }
 
    // MARK: - Instance Methods
    
    /// Load a file with the given name, location, and playing attributes.
    public func load(
        name: String,
        baseDir: AKAudioFile.BaseDirectory = .documents,
        volume: Double = 1.0,
        looping: Bool = false
    )
    {
        do {
            let newFile = try AKAudioFile(readFileName: "\(name).caf", baseDir: baseDir)
            try currentPlayer.loadAudioFile(newFile)
            currentPlayer.volume = volume
        } catch {
            print(error)
        }
    }
    
    /// Play the next sampler on deck.
    public func play() {
        currentPlayer.play()
        index += 1
    }
    
    /// Load and play file with name, location, and playing attributes.
    public func play(
        name: String,
        baseDir: AKAudioFile.BaseDirectory = .documents,
        volume: Double = 1.0,
        looping: Bool = false
    )
    {
        load(name: name, baseDir: baseDir, volume: volume, looping: looping)
        play()
    }
    
    /// Stop all players.
    public func stopAll() {
        audioPlayers.forEach { $0.stop() }
    }
    
    /// Fade out the previous audio player.
    ///
    /// - TODO: Fade out all audio players other than current.
    public func fadeOutPrevious(over duration: Double) {
        let previousIndex = Int.mod(index - 2, audioPlayers.count)
        let previousPlayer = audioPlayers[previousIndex]
        Fader(audioPlayer: previousPlayer).fadeOut(over: duration)
    }

    private func connectAudioPlayers() {
        audioPlayers.forEach(connect)
    }
}

extension AudioPlayerPool: Collection {
    
    // MARK: - Collection
    
    /// - returns: The index after the given `i`.
    public func index(after i: Int) -> Int {
        return audioPlayers.index(after: i)
    }
    
    /// - returns: The start index of the internal array of audio players.
    public var startIndex: Int {
        return audioPlayers.startIndex
    }
    
    /// - returns: The end index of the internal array of audio players.
    public var endIndex: Int {
        return audioPlayers.endIndex
    }
    
    /// - returns: The player at the given `index`.
    public subscript(index: Int) -> AKSampler {
        return audioPlayers[index]
    }
}
