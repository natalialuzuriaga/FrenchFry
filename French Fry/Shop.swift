//
//  Shop.swift
//  French Fry
//
//  Created by Natalia Luzuriaga on 8/19/17.
//  Copyright © 2017 Natalia Luzuriaga. All rights reserved.
//

import Foundation
import SpriteKit

class Shop: SKScene {
    //UI Connections
    var backButton: MSButtonNode!
    
    override func didMove(to view: SKView) {
        //Setup scene
        
        //Set UI connections
        backButton = self.childNode(withName: "backButton") as! MSButtonNode
        
        backButton.selectedHandler = { [unowned self] in
            self.loadPlayScreen()
        }
    }
    
    func loadPlayScreen() {
        /* 1) Grab reference to our SpriteKit view */
        guard let skView = self.view as SKView! else {
            print("Could not get Skview")
            return
        }
        
        /* 2) Load Game scene */
        guard let scene = SKScene(fileNamed: "PlayScreen") else {
            print("Could not load GameScene with GameScene")
            return
        }
        
        /* 3) Ensure correct aspect mode */
        scene.scaleMode = .aspectFit
        
        /* 4) Start game scene */
        skView.presentScene(scene)
    }
    
}
