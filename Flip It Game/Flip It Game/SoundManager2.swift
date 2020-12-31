//
//  SoundManager2.swift
//  Flip It Game
//
//  Created by Khoi Huu Minh Le on 5/8/20.
//  Copyright © 2020 Khoi Huu Minh Le. All rights reserved.
//

import Foundation
import AVFoundation

class SoundManager2 {
    
    var audioPlayer:AVAudioPlayer?
    
    enum SoundEffect {
        
        case rotateSound
        
    }
    
    func playSound(_ effect:SoundEffect) {
        
        var soundFileName = ""
        
        switch effect {
        case .rotateSound:
            soundFileName = "taptap"
        }
        
        let bundlePath = Bundle.main.path(forResource: soundFileName, ofType: "wav")
        
        guard bundlePath != nil else {
            
            print("could not find sound \(soundFileName) in the system")
            return
            
        }
        let soundURL = URL(fileURLWithPath: bundlePath!)
        
        do {
            audioPlayer = try AVAudioPlayer(contentsOf: soundURL)
            audioPlayer?.play()
            audioPlayer?.numberOfLoops = -1
        }
        catch {
            print("Could create audio object for sound file \(soundFileName)")
        }
    }
}


