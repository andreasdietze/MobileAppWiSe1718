//
//  GameScene.swift
//  MobileApps
//
//  Created by Silas on 05.02.18.
//  Copyright © 2018 Silas. All rights reserved.
//

import SpriteKit
import AVFoundation

class GameScene: SKScene {

    let ship = SKSpriteNode(imageNamed: "ship")
    let backgroundScene1 = SKSpriteNode(imageNamed: "background")
    let backgroundScene2 = SKSpriteNode(imageNamed: "background")
    
    var audioPlayer = AVAudioPlayer()
    var backgroundAudio: URL?
    
    override func didMove(to view: SKView) {

        // Player
        ship.position = CGPoint(x: self.size.width / 2, y: self.size.height / 2 - 200)
        ship.setScale(0.25)
        ship.zPosition = 1
        self.addChild(ship)
        
        // Backgrounds
        self.backgroundColor = SKColor(displayP3Red: 0, green: 104 / 255, blue: 139 / 255, alpha: 1.0)
        
        backgroundScene1.anchorPoint = CGPoint.zero
        backgroundScene1.size = self.size
        backgroundScene1.zPosition = -1
        self.addChild(backgroundScene1)
        
        backgroundScene2.anchorPoint = CGPoint.zero
        backgroundScene2.position.x = 0
        backgroundScene2.position.y = backgroundScene1.size.height - 5
        backgroundScene2.size = self.size
        backgroundScene2.zPosition = -1
        self.addChild(backgroundScene2)
        
        // Audio
        backgroundAudio = Bundle.main.url(forResource: "Steamtech-Mayhem", withExtension: "mp3")
        do {
            audioPlayer = try AVAudioPlayer(contentsOf: backgroundAudio!)
        } catch {
            print("File not found")
        }
        
        // Loop track
        audioPlayer.numberOfLoops = -1
        audioPlayer.prepareToPlay()
        audioPlayer.play()
        
    }
    
    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        
        for touch in touches {
            
            let locationUser = touch.location(in: self)
            ship.position.x = locationUser.x
        }
        
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        for touch in touches {
            let locationUser = touch.location(in: self)
            
            if atPoint(locationUser) == ship {
                addBullet()
            }
        }
    }
    
    override func update(_ currentTime: TimeInterval) {
        backgroundScene1.position.y -= 5
        backgroundScene2.position.y -= 5
        
        if backgroundScene1.position.y < -backgroundScene1.size.height {
            backgroundScene1.position.y = backgroundScene2.position.y + backgroundScene2.size.height
        }
        
        if backgroundScene2.position.y < -backgroundScene2.size.height {
            backgroundScene2.position.y = backgroundScene1.position.y + backgroundScene1.size.height
        }
    }
    
    func addBullet() {
        let bullet = SKSpriteNode(imageNamed: "bullet")
        bullet.position = ship.position
        bullet.zPosition = 0
        self.addChild(bullet)
        
        // Actions - transformation
        let moveTo = SKAction.moveTo(y: self.size.height + bullet.size.height, duration: 3)
        let delete = SKAction.removeFromParent()
        
        bullet.run(SKAction.sequence([moveTo, delete]))
        
        // Actions - sound
        bullet.run(SKAction.playSoundFileNamed("LaserShot", waitForCompletion: true))
    }
}
