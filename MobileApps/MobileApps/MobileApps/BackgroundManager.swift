//
//  BackgroundManager.swift
//  MobileApps
//
//  Created by Bambi on 23.02.18.
//  Copyright © 2018 Silas. All rights reserved.
//

import Foundation
import SpriteKit

class BackgroundManager {
    
    // Game objects
    let backgroundScene1 = SKSpriteNode(imageNamed: "background")
    let backgroundScene2 = SKSpriteNode(imageNamed: "background")
    
    // Global game instance -> alternative for passing self (like this)
    //let gameInstance = GameScene.sharedInstance
    
    // Passing self
    func initBackground(gameInstance: GameScene){
        // func initBackground(){

        gameInstance.backgroundColor = SKColor(displayP3Red: 0, green: 104 / 255, blue: 139 / 255, alpha: 1.0)
        
        backgroundScene1.anchorPoint = CGPoint.zero
        backgroundScene1.size = gameInstance.size
        backgroundScene1.zPosition = -1
        gameInstance.addChild(backgroundScene1)
        
        backgroundScene2.anchorPoint = CGPoint.zero
        backgroundScene2.position.x = 0
        backgroundScene2.position.y = backgroundScene1.size.height - 5
        backgroundScene2.size = gameInstance.size
        backgroundScene2.zPosition = -1
        gameInstance.addChild(backgroundScene2)
        
    }
    
    // Update background
    func updateBackground(){
        
        backgroundScene1.position.y -= 5
        backgroundScene2.position.y -= 5
        
        if backgroundScene1.position.y < -backgroundScene1.size.height {
            backgroundScene1.position.y = backgroundScene2.position.y + backgroundScene2.size.height
        }
        
        if backgroundScene2.position.y < -backgroundScene2.size.height {
            backgroundScene2.position.y = backgroundScene1.position.y + backgroundScene1.size.height
        }
        
    }
}
