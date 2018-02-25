//
//  AudioManager.swift
//  MobileApps
//
//  Created by Bambi on 23.02.18.
//  Copyright © 2018 Silas. All rights reserved.
//

import Foundation
import AVFoundation
import SpriteKit

class AudioManager {
    // Init stuff and declare vars
    var backgroundAudioPlayer = AVAudioPlayer()
    var playerShotAudioPlayer = AVAudioPlayer()
    
    // Background track
    var backgroundAudio: URL?
    let backgroundAudioSource = "Steamtech-Mayhem"
    let backgroundAudioSourceExtension = "mp3"
    
    // Player laser shot sound
    var playerLaserShotAudio: URL?
    let playerLaserShotAudioSource = "LaserShot"
    let playerLaserShotAudioSourceExtension = "wav"
    
    // ExplosionOne
    let explosionOneAudioSource = "explosion"
    let explosionOneAudioSourceExtension = "wav"
    
    // Load and init the audio source data
    func initAudioFiles (){
        // Set resource identifier and file extension
        backgroundAudio = Bundle.main.url(forResource: backgroundAudioSource, withExtension: backgroundAudioSourceExtension)
        playerLaserShotAudio = Bundle.main.url(forResource: playerLaserShotAudioSource, withExtension: playerLaserShotAudioSourceExtension)
        
        // Load background track
        do {
            backgroundAudioPlayer = try AVAudioPlayer(contentsOf: backgroundAudio!)
        } catch {
            print("File not found: " + backgroundAudioSource + "." + backgroundAudioSourceExtension)
        }
        
        // Load player laser shot sound
        do {
            playerShotAudioPlayer = try AVAudioPlayer(contentsOf: playerLaserShotAudio!)
        } catch {
            print("File not found: " + playerLaserShotAudioSource + "." + playerLaserShotAudioSourceExtension)
        }
        
    }
    
    func playBackgroundMusic(){
        // Loop track
        backgroundAudioPlayer.numberOfLoops = -1
        backgroundAudioPlayer.prepareToPlay()
        backgroundAudioPlayer.play()
    }
    
    func playPlayerShotSound(){
        // No loop
        playerShotAudioPlayer.numberOfLoops = 0
        playerShotAudioPlayer.prepareToPlay()
        playerShotAudioPlayer.play()
    }
    
    func playPlayerShotSoundSKAction(bullet: SKSpriteNode){
        // Allows high frequency due to a seperate AVAudioPlayer-Instance for each shot
        bullet.run(SKAction.playSoundFileNamed(playerLaserShotAudioSource, waitForCompletion: true))
    }
    
    func playExplosionOneSKAction(gameInstance: GameScene){
        gameInstance.run(SKAction.playSoundFileNamed(explosionOneAudioSource, waitForCompletion: true))
    }
    


}
