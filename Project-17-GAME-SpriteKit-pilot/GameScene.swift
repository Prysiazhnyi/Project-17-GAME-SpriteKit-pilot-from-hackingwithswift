//
//  GameScene.swift
//  Project-17-GAME-SpriteKit-pilot
//
//  Created by Serhii Prysiazhnyi on 14.11.2024.
//

import SpriteKit
import GameplayKit

class GameScene: SKScene, SKPhysicsContactDelegate {
    
    var starfield: SKEmitterNode!
    var player: SKSpriteNode!
    var scoreLabel: SKLabelNode!
    
    let possibleEnemies = ["ball", "hammer", "tv"]
    var isGameOver = false
    var gameTimer: Timer?
    var startPlayerPosition = CGPoint(x: 100, y: 384)
    var startTouchPosition: CGPoint = .zero
    
    var score = 0 {
        didSet {
            scoreLabel.text = "Score: \(score)"
        }
        
    }
    
    override func didMove(to view: SKView) {
        
        backgroundColor = .black

        starfield = SKEmitterNode(fileNamed: "starfield")!
        starfield.position = CGPoint(x: 1024, y: 384)
        starfield.advanceSimulationTime(10)
        addChild(starfield)
        starfield.zPosition = -1

        player = SKSpriteNode(imageNamed: "player")
        player.position = startPlayerPosition
        player.physicsBody = SKPhysicsBody(texture: player.texture!, size: player.size)
        player.physicsBody?.contactTestBitMask = 1
        addChild(player)

        scoreLabel = SKLabelNode(fontNamed: "Chalkduster")
        scoreLabel.position = CGPoint(x: 16, y: 16)
        scoreLabel.horizontalAlignmentMode = .left
        addChild(scoreLabel)

        score = 0

        physicsWorld.gravity = CGVector(dx: 0, dy: 0)
        physicsWorld.contactDelegate = self
        
        gameTimer = Timer.scheduledTimer(timeInterval: 0.35, target: self, selector: #selector(createEnemy), userInfo: nil, repeats: true)
    }
    
    @objc func createEnemy() {
        guard let enemy = possibleEnemies.randomElement() else { return }

        let sprite = SKSpriteNode(imageNamed: enemy)
        sprite.position = CGPoint(x: 1200, y: Int.random(in: 50...736))
        addChild(sprite)

        sprite.physicsBody = SKPhysicsBody(texture: sprite.texture!, size: sprite.size)
        sprite.physicsBody?.categoryBitMask = 1
        sprite.physicsBody?.velocity = CGVector(dx: -500, dy: 0)
        sprite.physicsBody?.angularVelocity = 5
        sprite.physicsBody?.linearDamping = 0
        sprite.physicsBody?.angularDamping = 0
    }
    
    override func update(_ currentTime: TimeInterval) {
        for node in children {
            if node.position.x < -300 {
                node.removeFromParent()
            }
        }

        if !isGameOver {
            score += 1
        }
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
            guard let touch = touches.first else { return }
            
            // Запоминаем начальную точку касания
            startTouchPosition = touch.location(in: self)
            
            // Запоминаем начальную позицию игрока
            startPlayerPosition = player.position
        }
    
    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
            guard let touch = touches.first else { return }
            
            // Текущее положение касания
            let currentTouchPosition = touch.location(in: self)
            
            // Рассчитываем смещение
            let deltaX = currentTouchPosition.x - startTouchPosition.x
            let deltaY = currentTouchPosition.y - startTouchPosition.y
            
            // Перемещаем игрока на смещение от его начальной позиции
            player.position = CGPoint(x: startPlayerPosition.x + deltaX, y: startPlayerPosition.y + deltaY)
            
            // Ограничиваем движение игрока по оси Y
            if player.position.y < 100 {
                player.position.y = 100
            } else if player.position.y > 668 {
                player.position.y = 668
            }
            
            // Ограничиваем движение по оси X
            if player.position.x < 25 {
                player.position.x = 25
            } else if player.position.x > 974 {
                player.position.x = 974
            }
        }
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
           // Сохраняем текущую позицию как начальную для следующего перемещения
           if let touch = touches.first {
               startTouchPosition = touch.location(in: self)
               startPlayerPosition = player.position
           }
           
           print("touchesEnded: player.position = \(player.position), startTouchPosition = \(startTouchPosition), startPlayerPosition = \(startPlayerPosition)")
       }
    
    func didBegin(_ contact: SKPhysicsContact) {
        let explosion = SKEmitterNode(fileNamed: "explosion")!
        explosion.position = player.position
        addChild(explosion)

        player.removeFromParent()

        isGameOver = true
    }
}
