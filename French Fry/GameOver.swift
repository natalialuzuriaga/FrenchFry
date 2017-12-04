import Foundation
import SpriteKit

class GameOver: SKScene {
    //UI Connections
    var playButton: MSButtonNode!
    var homeButton: MSButtonNode!
    var finalScoreLabel: SKLabelNode!
    var highScoreLabel: SKLabelNode!
    var saltTotalLabel: SKLabelNode!
    
    override func didMove(to view: SKView) {
        //Setup scene
        
        finalScoreLabel = childNode(withName: "finalScoreLabel") as! SKLabelNode
        highScoreLabel = childNode(withName: "highScoreLabel") as! SKLabelNode
        saltTotalLabel = childNode(withName: "saltTotalLabel") as! SKLabelNode
        
        finalScoreLabel.text = "\(GlobalData.currentScore)"
        highScoreLabel.text = "\(UserDefaults().integer(forKey: "HIGHSCORE"))"
        saltTotalLabel.text = "\(UserDefaults().integer(forKey: "COINS"))"
        
        //Set UI connections
        playButton = self.childNode(withName: "playButton") as! MSButtonNode
        homeButton = self.childNode(withName: "homeButton") as! MSButtonNode
        
        
        playButton.selectedHandler = { [unowned self] in
            self.loadGame()
        }
        
        homeButton.selectedHandler = { [unowned self] in
            self.loadPlayScreen()
        }
    }
    
    func loadGame() {
        //rest global variables
        GlobalData.currentScore = 1
        GlobalData.currentSaltTotal = 0
        GlobalData.bonus = 0
        
        GlobalData.spawnOne = 1.0
        GlobalData.spawnThree = 2.8
        GlobalData.spawnFourTable = 2.7
        GlobalData.spawnFourGrain = 4.05
        GlobalData.spawnFiveBottle = 2
        GlobalData.spawnFiveDrop = 1
        GlobalData.spawnSixStool = 1.5
        GlobalData.spawnSixGrain = 2.56
        
        GlobalData.scrollSpeed = 100
        /* 1) Grab reference to our SpriteKit view */
        guard let skView = self.view as SKView! else {
            print("Could not get Skview")
            return
        }
        
        /* 2) Load Game scene */
        guard let scene = GameScene(fileNamed: "GameScene") else {
            print("Could not load GameScene with Game Scene")
            return
        }
        
        let transition = SKTransition.crossFade(withDuration: 1.0)
        
        /* 3) Ensure correct aspect mode */
        scene.scaleMode = .aspectFit
        
        
        /* 4) Start game scene */
        skView.presentScene(scene, transition: transition)
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
