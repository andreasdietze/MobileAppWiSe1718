//
//  Enemy.swift
//  MobileApps
//
//  Created by Bambi on 23.02.18.
//  Copyright © 2018 Silas. All rights reserved.
//

import Foundation
import SpriteKit

class Enemy {
    
    // Enemy texture
    let enemyTexture = "bluedestroyer"
    
    // Enemy object
    var enemyNode: SKSpriteNode = SKSpriteNode()
    
    // Start parameters for the player
    func addEnemy(gameInstance: GameScene){
        
        // Set state of the enemy
        enemyNode = SKSpriteNode(imageNamed: enemyTexture)
        
        // Set enemy start position
        enemyNode.position = CGPoint(x: 200, y: 600)//CGPoint(x: gameInstance.size.width / 2, y: gameInstance.size.height + enemyNode.size.height)
        
        // Set enemy scale
        enemyNode.setScale(0.25)
        
        // Set enemy rotation (rotate 270 deg)
        enemyNode.zRotation = CGFloat((CGFloat.pi / 180) * 270)
        
        // Set z-index
        enemyNode.zPosition = 1
        
        // Add to scene
        gameInstance.addChild(enemyNode)
        
        // Action - transformation
        let moveDown = SKAction.moveTo(y: -enemyNode.size.height, duration: 10)
        let delete = SKAction.removeFromParent()
        enemyNode.run(SKAction.sequence([moveDown, delete]))
    }
}
