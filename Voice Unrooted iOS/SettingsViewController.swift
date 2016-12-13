//
//  SettingsViewController.swift
//  SwiftAudioKitTest
//
//  Created by Hans Tutschku on 4/24/16.
//  Copyright © 2016 Hans Tutschku. All rights reserved.
//

import UIKit
import Timeline

class SettingsViewController: UIViewController {
    
    fileprivate let appDelegate = UIApplication.shared.delegate as? AppDelegate

    @IBOutlet weak var loudspeakerTestSwitch: UISwitch!
    @IBOutlet weak var expertModeSwitch: UISwitch!
    @IBOutlet weak var autoplaySwitch: UISwitch!
    @IBOutlet weak var tuningSwitch: UISwitch!
    @IBOutlet weak var tuningSliderLabel: UILabel!
    @IBOutlet weak var tuningSlider: UISlider!
    
    @IBOutlet weak var metronomeSwitch: UISwitch!
    @IBOutlet weak var AirTurnSwitch: UISwitch!
    @IBOutlet weak var pedalPolaritySwitch: UISwitch!
    @IBOutlet weak var button438: UIButton!
    @IBOutlet weak var button439: UIButton!
    @IBOutlet weak var button440: UIButton!
    @IBOutlet weak var button441: UIButton!
    @IBOutlet weak var button442: UIButton!
    @IBOutlet weak var button443: UIButton!
    @IBOutlet weak var button444: UIButton!
    
    var timeline: Timeline!
    
    @IBAction func button438pressed(_ sender: AnyObject) {
        tuningSlider.value = 438
        tuningSliderChanged(tuningSlider)
    }
    
    @IBAction func button439pressed(_ sender: AnyObject) {
        tuningSlider.value = 439
        tuningSliderChanged(tuningSlider)
   }
    
    @IBAction func button440pressed(_ sender: AnyObject) {
        tuningSlider.value = 440
        tuningSliderChanged(tuningSlider)
   }
    
    @IBAction func button441pressed(_ sender: AnyObject) {
        tuningSlider.value = 441
        tuningSliderChanged(tuningSlider)
  }
    
    @IBAction func button442pressed(_ sender: AnyObject) {
        tuningSlider.value = 442
        tuningSliderChanged(tuningSlider)
   }
    
    @IBAction func button443pressed(_ sender: AnyObject) {
        tuningSlider.value = 443
        tuningSliderChanged(tuningSlider)
   }
    
    @IBAction func button444pressed(_ sender: AnyObject) {
        tuningSlider.value = 444
        tuningSliderChanged(tuningSlider)
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        configureColors()
        manageDefaultValues()
    }
    
    fileprivate func configureColors() {
        view.backgroundColor = Color.light
    }
    
    fileprivate func manageDefaultValues() {
        DefaultValues.readUserDefaults()
        expertModeSwitch.isOn = DefaultValues.Defaults.expertModeIsEngaged
        autoplaySwitch.isOn = DefaultValues.Defaults.autoPlayIsEngaged
        tuningSlider.value = DefaultValues.Defaults.tuningValue
        metronomeSwitch.isOn = DefaultValues.Defaults.metronomeIsActive
        AirTurnSwitch.isOn = DefaultValues.Defaults.airTurnIsActive
        pedalPolaritySwitch.isOn = DefaultValues.Defaults.pedalPolarity
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        ensureNagivationBarShown()
        tuningSliderChanged(tuningSlider)
    }
    
    fileprivate func ensureNagivationBarShown() {
        self.navigationController?.isNavigationBarHidden = false
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    @IBAction func loudspeakerTestSwitchChanged(_ sender: AnyObject) {
        
        if loudspeakerTestSwitch.isOn {
            timeline = Timeline()
            timeline.addLooping(interval: 10) {
                self.appDelegate?.audioPlayerPool.play(
                    name: "loudspeakertest",
                    baseDir: .resources,
                    looping: true
                )
            }
            timeline.start()
        } else {
            timeline?.stop()
            appDelegate?.audioPlayerPool.stopAll()
        }
    }

    @IBAction func expertModeSwitchChanged(_ sender: AnyObject) {
        DefaultValues.Defaults.expertModeIsEngaged = expertModeSwitch.isOn
        DefaultValues.writeUserDefaults()
    }
    
    @IBAction func autoplaySwitchChanged(_ sender: AnyObject) {
        DefaultValues.Defaults.autoPlayIsEngaged = autoplaySwitch.isOn
        DefaultValues.writeUserDefaults()
    }
    
    @IBAction func tuningSwitchChanged(_ sender: AnyObject) {
        
        if tuningSwitch.isOn {
            appDelegate?.audioPlayerPool.play(
                name: "a440",
                baseDir: .resources,
                looping: true
            )
        } else {
            appDelegate?.audioPlayerPool.stopAll()
        }
    }
    
    @IBAction func tuningSliderChanged(_ sender: UISlider) {
        tuningSliderLabel.text = String(format: "%.2f", tuningSlider.value)
    }
    
    // only write the Default values to NSUserDefaults, when the slider has been released
    @IBAction func tuningSliderChangedEnded(_ sender: AnyObject) {
        DefaultValues.Defaults.tuningValue = tuningSlider.value
        DefaultValues.writeUserDefaults()
    }
    
    @IBAction func tuningButtonPressed(_ sender: AnyObject) {
        
    }
    
    @IBAction func pedalPolaritySwitchChanged(_ sender: AnyObject) {
        DefaultValues.Defaults.pedalPolarity = pedalPolaritySwitch.isOn
        DefaultValues.writeUserDefaults()
    }
    
    @IBAction func AirTurnSwitchChanged(_ sender: AnyObject) {
        DefaultValues.Defaults.airTurnIsActive = AirTurnSwitch.isOn
        DefaultValues.writeUserDefaults()
    }
    
    @IBAction func metronomeSwitchChanged(_ sender: AnyObject) {
        DefaultValues.Defaults.metronomeIsActive = metronomeSwitch.isOn
        DefaultValues.writeUserDefaults()
    }
    
    // FIXME: Not yet implemented!
    @IBAction func updateEventsFromInternetPressed(_ sender: AnyObject) {
        
    }

    func cents(fromFrequency frequency: Double) -> Double {
        return 1200 * log2(frequency / 440)
    }
    
    override var prefersStatusBarHidden : Bool {
        return true
    }
}
