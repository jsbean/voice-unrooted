//
//  Event.swift
//  SwiftAudioKitTest
//
//  Created by James Bean on 4/23/16.
//  Copyright © 2016 Hans Tutschku. All rights reserved.
//

import Foundation
// TODO: Use YamlSwift as framework, rather than injecting source directly

public struct Event {
    public let index: Int
    public let soundFileName: String
    public let gain: Double
    public let fadeTime: Double
    public let tempo: Double
    public let progressBarTime: Double
}

extension Event: CustomStringConvertible {

    public var description: String {
        var result = "Event \(index): {\n"
        result += "  soundFileName: \(soundFileName)\n"
        result += "  gain: \(gain)\n"
        result += "  fadeTime: \(fadeTime)\n"
        result += "  tempo: \(tempo)\n"
        result += "  progressBarTime: \(progressBarTime)\n"
        result += "}\n"
        return result
    }
}
