//
//  GameScene.swift
//  Project23
//
//  Created by Mehmet Can Şimşek on 9.08.2022.
//

import SpriteKit
import AVFoundation

class GameScene: SKScene {

    var gameScore: SKLabelNode!
    var score = 0 {
        didSet {
            gameScore.text = "Score: \(score)"
        }
    }
    var livesImages = [SKSpriteNode]()
    var lives = 3
    
    var acticeSliceBG: SKShapeNode!
    var acticeSliceFG: SKShapeNode!
    
    var activeSlicePoints = [CGPoint]()
    
    var isSwooshSoundActive = false
    var bombSoundEffect: AVAudioPlayer?
    
    var activeEnemies = [SKSpriteNode]()
    
    override func didMove(to view: SKView) {
        let background = SKSpriteNode(imageNamed: "sliceBackground")
        background.position = CGPoint(x: 512, y: 384)
        background.blendMode = .replace
        background.zPosition = -1
        addChild(background)
        
        physicsWorld.gravity = CGVector(dx: 0, dy: -6)
        physicsWorld.speed = 0.85
        
        createScore()
        createLives()
        createSlices()
        
    }
    
    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard let touch = touches.first else { return }
        let location = touch.location(in: self)
        activeSlicePoints.append(location)
        redrawActiveSlice()
        
        if !isSwooshSoundActive {
            playSwooshSound()
        }
    }
    
    func playSwooshSound() {
        isSwooshSoundActive = true
        
        let rondomNumber = Int.random(in: 1...3)
        let soundName = "swoosh\(rondomNumber).caf"
        
        let swooshSound = SKAction.playSoundFileNamed(soundName, waitForCompletion: true)
        
        run(swooshSound) { [weak self] in
            self?.isSwooshSoundActive = false
        }
    }
    
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        acticeSliceBG.run(SKAction.fadeOut(withDuration: 0.25))
        acticeSliceFG.run(SKAction.fadeOut(withDuration: 0.25))
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard let touch = touches.first else { return }
        
        activeSlicePoints.removeAll(keepingCapacity: true)
        
        let location = touch.location(in: self)
        activeSlicePoints.append(location)
        
        redrawActiveSlice()
        
        acticeSliceBG.removeAllActions()
        acticeSliceFG.removeAllActions()
        
        acticeSliceBG.alpha = 1
        acticeSliceFG.alpha = 1
        
    }
    
    
    func redrawActiveSlice() {
        if activeSlicePoints.count < 2 {
            acticeSliceBG.path = nil
            acticeSliceFG.path = nil
        }
        if activeSlicePoints.count > 12 {
            activeSlicePoints.removeFirst(activeSlicePoints.count - 12)
        }
        
        let path = UIBezierPath()
        path.move(to: activeSlicePoints[0])
        
        for i in 1 ..< activeSlicePoints.count {
            path.addLine(to: activeSlicePoints[i])
        }
        
        acticeSliceBG.path = path.cgPath
        acticeSliceFG.path = path.cgPath
        
    }
    
    func createScore() {
        gameScore = SKLabelNode(fontNamed: "Chalkduster")
        gameScore.horizontalAlignmentMode = .left
        gameScore.fontSize = 48
        addChild(gameScore)
        
        gameScore.position = CGPoint(x: 8, y: 8)
        score = 0
    }
    
    func createLives() {
        for i in 0 ..< 3 {
            let spriteNode = SKSpriteNode(imageNamed: "sliceLife")
            spriteNode.position = CGPoint(x: CGFloat(834 + (i * 70)), y: 720)
            addChild(spriteNode)
            
            livesImages.append(spriteNode)
        }
    }
    
    func createSlices() {
        acticeSliceBG = SKShapeNode()
        acticeSliceBG.zPosition = 2
        
        acticeSliceFG = SKShapeNode()
        acticeSliceFG.zPosition = 3
        
        acticeSliceBG.strokeColor = UIColor(red: 1, green: 0.9, blue: 0, alpha: 1)
        acticeSliceBG.lineWidth = 9
        
        acticeSliceFG.strokeColor = UIColor.white
        acticeSliceFG.lineWidth = 5
        
        addChild(acticeSliceBG)
        addChild(acticeSliceFG)
    }
    
    func createEnemy(forceBomb: ForceBomb = .random) {
        let enemy: SKSpriteNode
        
        var enemyType = Int.random(in: 0...6)
        
        if forceBomb == .never {
            enemyType = 1
        } else if forceBomb == .always {
            enemyType = 0
        }
        
        if enemyType == 0 {
            //bomb code goes here
            enemy = SKSpriteNode()
            enemy.zPosition = 1
            enemy.name = "bombContainer"
            
            let bombImage = SKSpriteNode(imageNamed: "sliceBomb")
            bombImage.name = "bomb"
            enemy.addChild(bombImage)
            
            if bombSoundEffect != nil {
                bombSoundEffect?.stop()
                bombSoundEffect = nil
            }
            if let path = Bundle.main.url(forResource: "sliceBombFuse", withExtension: "caf") {
                if let sound = try? AVAudioPlayer(contentsOf: path) {
                    bombSoundEffect = sound
                    sound.play()
                }
            }
            
            if let emitter = SKEmitterNode(fileNamed: "sliceFuse") {
                emitter.position = CGPoint(x: 76, y: 64)
                enemy.addChild(emitter)
            }
        }else {
            enemy = SKSpriteNode(imageNamed: "penguin")
            run(SKAction.playSoundFileNamed("launch.caf", waitForCompletion: false))
            enemy.name = "enemy"
        }
        
        // position code goes here
        
        let randomPosition = CGPoint(x: Int.random(in: 64...960), y: -128)
        enemy.position = randomPosition
        
        let randomAngularVelocity = CGFloat.random(in: -3...3)
        let randomXvelocity: Int
        
        if randomPosition.x < 256 {
            randomXvelocity = Int.random(in: 8...15)
        }else if randomPosition.x < 512 {
            randomXvelocity = Int.random(in: 3...5)
        }else if randomPosition.x < 768 {
            randomXvelocity = -Int.random(in: 3...5)
        }else {
            randomXvelocity = -Int.random(in: 8...15)
        }
        
        let randomYVelocity = Int.random(in: 24...32)
        
        enemy.physicsBody = SKPhysicsBody(circleOfRadius: 64)
        enemy.physicsBody?.velocity = CGVector(dx: randomXvelocity * 40, dy: randomYVelocity * 40)
        enemy.physicsBody?.angularVelocity = randomAngularVelocity
        enemy.physicsBody?.collisionBitMask = 0
        
        addChild(enemy)
        activeEnemies.append(enemy)
    }
    
    enum ForceBomb {
        case never, always, random
    }
   
    override func update(_ currentTime: TimeInterval) {
        var bombCount = 0
        
        for node in activeEnemies {
            if node.name == "bombContainer" {
                bombCount += 1
                break
            }
        }
        if bombCount == 0 {
            bombSoundEffect?.stop()
            bombSoundEffect = nil
        }
    }
}
