//
//  Event+YAML.swift
//  SwiftAudioKitTest
//
//  Created by James Bean on 11/19/16.
//  Copyright © 2016 Hans Tutschku. All rights reserved.
//

import Foundation

extension Event {
    
    /// Construct an `Event` value with a `Yaml` source.
    public init?(index: Int, attributes: Yaml) {
        
        guard let attributesDict = attributes.dictionary else { return nil }
        
        guard let soundFileName = attributesDict["sound_file_name"]?.string else {
            return nil
        }
        
        guard let tempo = attributesDict["tempo"]?.double else {
            return nil
        }
        
        guard let progressBarTime = attributesDict["progress_bar_time"]?.double else {
            return nil
        }
        
        guard let fadeTime = attributesDict["fade_time"]?.double else {
            return nil
        }
        
        guard let gain = attributesDict["gain"]?.double else {
            return nil
        }
        
        self.index = index
        self.soundFileName = soundFileName
        self.tempo = tempo
        self.progressBarTime = progressBarTime
        self.fadeTime = fadeTime
        self.gain = gain
    }
}
