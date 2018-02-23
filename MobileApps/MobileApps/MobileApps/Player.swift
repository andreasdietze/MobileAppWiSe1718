//
//  Player.swift
//  MobileApps
//
//  Created by Bambi on 23.02.18.
//  Copyright © 2018 Silas. All rights reserved.
//

import Foundation
import SpriteKit

class Player {
    
    // Player texture
    let playerTexture = "ship"
    
    // Player object --> With ! u know the var now has no state but will have one before its first call.
    // The problem is that there is no access to any specific funcs/vars before init and return
    //var player: SKSpriteNode!
    var playerNode: SKSpriteNode = SKSpriteNode()  // Works -> empty node
    
    // Start parameters for the player
    func initPlayer(gameInstance: GameScene){
        
        // Set state of the player
        playerNode = SKSpriteNode(imageNamed: playerTexture)
        
        // Set player start position
        playerNode.position = CGPoint(x: gameInstance.size.width / 2, y: gameInstance.size.height / 2 - 200)
        
        // Set player scale
        playerNode.setScale(0.25)
        
        // Set z-index
        playerNode.zPosition = 1
        
        // Add to scene
        gameInstance.addChild(playerNode)
        
    }
    
    func addBullet(gameInstance: GameScene, audioManagerInstance: AudioManager, textureName: String) {
        
        // Initiate shot node
        let bullet = SKSpriteNode(imageNamed: textureName)
        
        // Set position relative to player
        bullet.position = playerNode.position
        
        // Set z-index
        bullet.zPosition = 0
        
        // Add to scene
        gameInstance.addChild(bullet)
        
        // Set target position for the shot (when reached, the shot will be deleted)
        // Target position: client height + texture height
        let targetPositionY: CGFloat = gameInstance.size.height + bullet.size.height
        
        // Action - transformation
        let moveTo = SKAction.moveTo(
            y: targetPositionY,     // Target position
            duration: 3             // Transformation duration in seconds --> speed derivation
        )
        
        // Action - remove shot if its position is greater than the target position
        let delete = SKAction.removeFromParent()
        
        // Execute action sequence (I totally freak out Oo - what a nice Framework)
        bullet.run(SKAction.sequence([moveTo, delete]))
        
        // Action - sound
        audioManagerInstance.playPlayerShotSoundSKAction(bullet: bullet) // works very good (frequency)
        //audioManager.playPlayerShotSound() // works - low frequency
        
    }
}
