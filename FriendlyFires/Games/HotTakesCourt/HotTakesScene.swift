import SpriteKit

class HotTakesRevealScene: SKScene {
    private let results: [Take]

    init(size: CGSize, results: [Take]) {
        self.results = results.prefix(3).map { $0 }
        super.init(size: size)
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func didMove(to view: SKView?) {
        backgroundColor = UIColor(red: 0.05, green: 0.05, blue: 0.08, alpha: 1.0)
        animateReveal()
    }

    private func animateReveal() {
        let spacing: CGFloat = 120
        let startY = size.height / 2 + spacing

        for (index, take) in results.enumerated() {
            let yPosition = startY - CGFloat(index) * spacing
            let delay: TimeInterval = Double(index) * 0.4

            DispatchQueue.main.asyncAfter(deadline: .now() + delay) {
                self.animateTakeReveal(take, yPosition: yPosition)
            }
        }
    }

    private func animateTakeReveal(_ take: Take, yPosition: CGFloat) {
        let container = SKNode()
        container.position = CGPoint(x: size.width / 2, y: yPosition)
        container.alpha = 0

        // Gavel icon
        let gavel = SKLabelNode(fontNamed: "AvenirNext-Bold")
        gavel.text = "⚖️"
        gavel.fontSize = 32
        gavel.position = CGPoint(x: -80, y: 0)
        container.addChild(gavel)

        // Vote count: Hot 🔥
        let hotLabel = SKLabelNode(fontNamed: "AvenirNext-Bold")
        hotLabel.text = "🔥 \(take.hotVotes)"
        hotLabel.fontSize = 18
        hotLabel.fontColor = UIColor(red: 1.0, green: 0.2, blue: 0.4, alpha: 1.0)
        hotLabel.position = CGPoint(x: 20, y: 15)
        hotLabel.horizontalAlignmentMode = .left
        container.addChild(hotLabel)

        // Vote count: Cold ❄️
        let coldLabel = SKLabelNode(fontNamed: "AvenirNext-Bold")
        coldLabel.text = "❄️ \(take.coldVotes)"
        coldLabel.fontSize = 18
        coldLabel.fontColor = UIColor(red: 0.3, green: 0.8, blue: 1.0, alpha: 1.0)
        coldLabel.position = CGPoint(x: 20, y: -10)
        coldLabel.horizontalAlignmentMode = .left
        container.addChild(coldLabel)

        addChild(container)

        // Animate: fade in + scale + gavel bounce
        let fadeIn = SKAction.fadeIn(withDuration: 0.3)
        let scale = SKAction.scale(to: 1.0, duration: 0.3)
        let group = SKAction.group([fadeIn, scale])
        container.run(group)

        // Gavel bounce
        let bounceUp = SKAction.moveBy(x: 0, y: 10, duration: 0.2)
        let bounceDown = SKAction.moveBy(x: 0, y: -10, duration: 0.2)
        let bounce = SKAction.sequence([bounceUp, bounceDown])
        gavel.run(bounce)
    }
}
