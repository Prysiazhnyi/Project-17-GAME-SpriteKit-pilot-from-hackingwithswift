//
//  GameScene.swift
//  Project-17-GAME-SpriteKit-pilot
//
//  Created by Serhii Prysiazhnyi on 14.11.2024.
//

import SpriteKit
import GameplayKit
import AVFoundation

class GameScene: SKScene, SKPhysicsContactDelegate {
    
    var starfield: SKEmitterNode!
    var player: SKSpriteNode!
    var scoreLabel: SKLabelNode!
    
    let possibleEnemies = ["ball", "hammer", "tv"]
    var isGameOver = false
    var gameTimer: Timer?
    var startPlayerPosition = CGPoint(x: 100, y: 384)
    var startTouchPosition: CGPoint = .zero
    var enemyCount = 0
    var spawnInterval = 1.0 // Начальное значение интервала (1 секунда)
    var audioPlayer: AVAudioPlayer?
    
    var score = 0 {
        didSet {
            scoreLabel.text = "Score: \(score)"
        }
        
    }
    
    override func didMove(to view: SKView) {
        restartMusic()
        
        //        // Создаем SKAction для проигрывания музыки
        //        let backgroundMusic = SKAction.playSoundFileNamed("Cosmos.mp3", waitForCompletion: false)
        //        // Зацикливаем проигрывание музыки
        //        let repeatAction = SKAction.repeatForever(backgroundMusic)
        //        // Запускаем зацикленную музыку на фоне
        //        run(repeatAction)
        
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
        
        gameTimer = Timer.scheduledTimer(timeInterval: spawnInterval, target: self, selector: #selector(createEnemy), userInfo: nil, repeats: true)
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
        
        // Устанавливаем уникальное имя для врага
        sprite.name = "enemy"
        
        enemyCount += 1
        
        // Каждые 20 врагов уменьшаем интервал появления
        if enemyCount % 20 == 0 {
            if spawnInterval > 0.3 {
                spawnInterval -= 0.1
            }
            gameTimer?.invalidate() // Останавливаем текущий таймер
            
            print("20 врагов - -0.1 сек  \(spawnInterval)")
            
            // Создаём новый таймер с обновлённым интервалом
            gameTimer = Timer.scheduledTimer(timeInterval: spawnInterval, target: self, selector: #selector(createEnemy), userInfo: nil, repeats: true)
        }
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
    }
    
    func didBegin(_ contact: SKPhysicsContact) {
        let explosion = SKEmitterNode(fileNamed: "explosion")!
        explosion.position = player.position
        addChild(explosion)
        
        player.removeFromParent()
        
        isGameOver = true
        gameTimer?.invalidate()  // Останавливаем таймер для создания врагов
        gameTimer = nil  // Сбрасываем таймер
        gameRestart()
    }
    
    func gameRestart() {
        // Остановка фоновой музыки
        audioPlayer?.stop()
        
        // Удаление всех врагов по имени "enemy"
        for node in children {
            if let sprite = node as? SKSpriteNode, sprite.name == "enemy" {
                sprite.removeFromParent()
            }
        }
        
        let gameOver = SKSpriteNode(imageNamed: "gameOver")
              gameOver.name = "gameOver"
              gameOver.position = CGPoint(x: 512, y: 484)
              gameOver.zPosition = 1
              addChild(gameOver)
              run(SKAction.playSoundFileNamed("Игра окончена!.m4a", waitForCompletion: false))
        
        // Отображение уведомления об окончании игры и перезапуске
        let ac = UIAlertController(
            title: "Your score: \(score)",
            message: "Press OK to start the game again",
            preferredStyle: .alert
        )
        
        // Действие по нажатию "OK" для сброса и перезапуска игры
        ac.addAction(UIAlertAction(title: "OK", style: .default) { [weak self] _ in
            guard let self = self else { return }
            
            // Сброс всех игровых значений
            self.score = 0
            self.enemyCount = 0
            self.spawnInterval = 1.0
            self.isGameOver = false
            
            // Удаление спрайта gameOver, если он существует
            self.children
                .filter { $0.name == "gameOver" }
                .forEach { $0.removeFromParent() }
            
            // Восстановление игрока
            self.player = SKSpriteNode(imageNamed: "player")
            self.player.position = self.startPlayerPosition
            self.player.physicsBody = SKPhysicsBody(texture: self.player.texture!, size: self.player.size)
            self.player.physicsBody?.contactTestBitMask = 1
            self.addChild(self.player)
            
            // Настройка физики мира
            self.physicsWorld.gravity = CGVector(dx: 0, dy: 0)
            self.physicsWorld.contactDelegate = self
            
            // Запуск таймера для создания врагов с начальным интервалом
            self.gameTimer = Timer.scheduledTimer(
                timeInterval: self.spawnInterval,
                target: self,
                selector: #selector(self.createEnemy),
                userInfo: nil,
                repeats: true
            )
            
            // Перезапуск музыки
            self.restartMusic()
        })
        
        // Показ уведомления
        if let viewController = view?.window?.rootViewController {
            viewController.present(ac, animated: true)
        }
        
        print("Игра окончена")
    }
    
    
    func restartMusic() {
        
        guard let musicURL = Bundle.main.url(forResource: "Cosmos", withExtension: "mp3") else { return }
        
        do {
            audioPlayer = try AVAudioPlayer(contentsOf: musicURL)
            audioPlayer?.numberOfLoops = -1 // Бесконечное воспроизведение
            audioPlayer?.play()
        } catch {
            print("Не удалось запустить музыку: \(error)")
        }
        
        audioPlayer?.currentTime = 0  // Сбрасываем время воспроизведения на начало
        audioPlayer?.play()  // Начинаем воспроизведение заново
    }
}
