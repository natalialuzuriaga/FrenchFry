//
//  Bomb.swift
//  French Fry
//
//  Created by Natalia Luzuriaga on 8/23/17.
//  Copyright © 2017 Natalia Luzuriaga. All rights reserved.
//

import SpriteKit

class Bomb: SKSpriteNode {
    
    init() {
        //Make a texture from an image, a color, and size
        let texture = SKTexture(imageNamed: "pepper")
        let color = UIColor.clear
        let size = texture.size()
        
        
        //Call the dsignated initializer
        super.init(texture: texture, color: color, size: size)
        zPosition = 4
        
        //Set physics properties
        physicsBody = SKPhysicsBody(circleOfRadius: size.width / 2)
        physicsBody?.categoryBitMask = 16
        physicsBody?.contactTestBitMask = 4
        
        physicsBody?.affectedByGravity = false
    }
    
    required init?(coder aDecoder: NSCoder){
        fatalError("init(coder:) has not been implemented")
    }
}

