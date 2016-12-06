//
//  AKAudioPlayer+isDonePlaying.swift
//  SwiftAudioKitTest
//
//  Created by James Bean on 5/10/16.
//  Copyright © 2016 Hans Tutschku. All rights reserved.
//

import AudioKit

extension AKAudioPlayer {
    
    public var isDonePlaying: Bool { return currentTime > duration || isStopped }
    
    public var isAvailable: Bool { return isDonePlaying }
}
