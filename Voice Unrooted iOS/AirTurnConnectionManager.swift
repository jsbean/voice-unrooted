//
//  AirTurnConnectionManager.swift
//  Voice Unrooted iOS
//
//  Created by James Bean on 2/15/17.
//  Copyright © 2017 James Bean. All rights reserved.
//

import AirTurnInterface






public protocol AirTurnDelegate {
    
    func event(_ notification: Notification)
}

public class AirTurnConnectionManager {
    
    public let delegate: AirTurnDelegate
    
    public init(delegate: AirTurnDelegate) {
        self.delegate = delegate
    }
    
    /*
    func connect() {
        
        if UserDefaults.standard.bool(forKey: InitialModeDefaultKey) {
            AirTurnCentral.shared().enabled = true
            NotificationCenter.default.removeObserver(self)
        } else if AirTurnKeyboardManager.automaticKeyboardManagementAvailable() {
            if AirTurnKeyboardManager.automaticKeyboardManagementAvailable() {
                self.keyboardManagerReady()
            } else {
                NotificationCenter.default.addObserver(self,
                   selector: #selector(keyboardManagerReady),
                   name: Notification.Name.AirTurn.airTurnKeyboardManagerReadyNotification,
                   object: nil
                )
            }
        } else {
            AirTurnViewManager.shared().enabled = true
            NotificationCenter.default.removeObserver(self)
        }
        
        print("is connected: \(AirTurnManager.shared().isConnected)")
        
        // To be notified of button events, add an object as an observer of the button event to NSNotificationCenter.
        NotificationCenter.default.addObserver(self, selector: #selector(delegate.event(_:)), name: NSNotification.Name.AirTurnPedalPress, object: nil)
        
        //self.connectedLED.isHighlighted = AirTurnManager.shared().isConnected
        NotificationCenter.default.addObserver(self, selector: #selector(ViewController.connectionStateChanged(_:)), name: NSNotification.Name.AirTurnConnectionStateChanged, object: nil)

    }
    
    @objc func keyboardManagerReady() {
        AirTurnViewManager.shared().enabled = true
        AirTurnKeyboardManager.shared()?.automaticKeyboardManagementEnabled = self.keyboardManagementShouldEnable()
    }
    
    // make computed property
    func keyboardManagementShouldEnable() -> Bool {
        
        // audit keys
        return (
            AirTurnKeyboardManager.automaticKeyboardManagementAvailable() &&
                UserDefaults.standard.object(forKey: AutomaticKeyboardManagementUserDefaultKey) == nil ||
                UserDefaults.standard.bool(forKey: AutomaticKeyboardManagementUserDefaultKey)
        )
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
     */
}
