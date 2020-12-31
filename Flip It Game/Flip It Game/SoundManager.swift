//
//  SoundManager.swift
//  Flip It Game
//
//  Created by Khoi Huu Minh Le on 5/6/20.
//  Copyright © 2020 Khoi Huu Minh Le. All rights reserved.
//

import Foundation
import AVFoundation

class SoundManager {
    
    var audioPlayer:AVAudioPlayer?
    
    enum SoundEffect {
        
        case waveSound
        case waveSound2
        case waveSound3
        case waveSound4
        
    }
    
    func playSound() {
        
        let bundlePath1 = Bundle.main.path(forResource: "8BitSurf", ofType: "mp3")
        let bundlePath2 = Bundle.main.path(forResource: "FeelGood", ofType: "mp3")
        let bundlePath3 = Bundle.main.path(forResource: "ShakeItUp", ofType: "mp3")
        let bundlePath4 = Bundle.main.path(forResource: "BadApple", ofType: "mp3")
        
        let bundlePathArray = [bundlePath1,bundlePath2,bundlePath3,bundlePath4]
        let bundlePath = bundlePathArray.randomElement()!
        
        let soundURL = URL(fileURLWithPath: bundlePath!)
        
        guard bundlePath != nil else {
            
            print("could not find sound in the system")
            return
            
        }
        
        do {
            audioPlayer = try AVAudioPlayer(contentsOf: soundURL)
            audioPlayer?.play()
            audioPlayer?.numberOfLoops = -1
        }
        catch {
            print("Could create audio object for sound file")
        }
    }
}

