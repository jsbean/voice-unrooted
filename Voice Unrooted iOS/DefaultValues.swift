//
//  DefaultValues.swift
//  SwiftAudioKitTest
//
//  Created by Hans Tutschku on 4/24/16.
//  Copyright © 2016 Hans Tutschku. All rights reserved.
//

import Foundation

public enum DefaultValues {

    private static let defaults = UserDefaults.standard
    
    public enum Defaults {
        public static var expertModeIsEngaged: Bool = false
        public static var autoPlayIsEngaged: Bool = false
        public static var pedalPolarity: Bool = false
        public static var airTurnIsActive: Bool = false
        public static var metronomeIsActive: Bool = false
        public static var tuningValue: Float = 0.0
        public static var outputVolume: Float = 0.75
    }
    
    static func writeUserDefaults() {
        defaults.set(Defaults.expertModeIsEngaged, forKey: "expertModeIsEngaged")
        defaults.set(Defaults.autoPlayIsEngaged, forKey: "autoPlayIsEngaged")
        defaults.set(Defaults.metronomeIsActive, forKey: "metronomeIsActive")
        defaults.set(Defaults.pedalPolarity, forKey: "BlueBoardPolarity")
        defaults.set(Defaults.airTurnIsActive, forKey: "airTurnIsActive")
        defaults.set(Defaults.tuningValue, forKey: "tuningValue")
        defaults.set(Defaults.outputVolume, forKey: "outputVolume")
    }
    
    static func readUserDefaults() {
        Defaults.expertModeIsEngaged = defaults.bool(forKey: "expertModeIsEngaged")
        Defaults.autoPlayIsEngaged = defaults.bool(forKey: "autoPlayIsEngaged")
        Defaults.metronomeIsActive = defaults.bool(forKey: "metronomeIsActive")
        Defaults.pedalPolarity = defaults.bool(forKey: "BlueBoardPolarity")
        Defaults.airTurnIsActive = defaults.bool(forKey: "airTurnIsActive")
        Defaults.tuningValue = defaults.float(forKey: "tuningValue")
        Defaults.outputVolume = defaults.float(forKey: "outputVolume")
    }
}
