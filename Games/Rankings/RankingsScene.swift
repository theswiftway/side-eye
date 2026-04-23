import SpriteKit

class RankingsRevealScene: SKScene {
    private let playerResults: [(playerID: UUID, name: String, rank: Double, color: UIColor)]

    init(
        size: CGSize,
        playerResults: [(playerID: UUID, name: String, rank: Double, color: UIColor)]
    ) {
        self.playerResults = playerResults.sorted { $0.rank < $1.rank }
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
        let topThree = playerResults.prefix(3)
        let spacing: CGFloat = 100
        let startY = size.height / 2 + spacing

        for (index, result) in topThree.enumerated() {
            let yPosition = startY - CGFloat(index) * spacing
            let delay: TimeInterval = Double(index) * 0.3

            DispatchQueue.main.asyncAfter(deadline: .now() + delay) {
                self.animatePlayerResult(result, yPosition: yPosition)
            }
        }
    }

    private func animatePlayerResult(
        _ result: (playerID: UUID, name: String, rank: Double, color: UIColor),
        yPosition: CGFloat
    ) {
        let container = SKNode()
        container.position = CGPoint(x: size.width / 2, y: yPosition)
        container.alpha = 0

        // Circle (avatar)
        let circle = SKShapeNode(circleOfRadius: 20)
        circle.fillColor = result.color
        circle.strokeColor = .clear
        circle.position = CGPoint(x: -60, y: 0)
        container.addChild(circle)

        // Name label
        let nameLabel = SKLabelNode(fontNamed: "AvenirNext-Bold")
        nameLabel.text = result.name
        nameLabel.fontSize = 18
        nameLabel.fontColor = .white
        nameLabel.position = CGPoint(x: 20, y: 5)
        nameLabel.alignment = .left
        container.addChild(nameLabel)

        // Rank label
        let rankLabel = SKLabelNode(fontNamed: "AvenirNext-Regular")
        rankLabel.text = String(format: "Avg: %.1f", result.rank)
        rankLabel.fontSize = 14
        rankLabel.fontColor = UIColor(red: 1.0, green: 0.2, blue: 0.4, alpha: 1.0)
        rankLabel.position = CGPoint(x: 20, y: -10)
        rankLabel.alignment = .left
        container.addChild(rankLabel)

        addChild(container)

        // Fade in + scale
        let fadeIn = SKAction.fadeIn(withDuration: 0.3)
        let scale = SKAction.scale(to: 1.0, duration: 0.3)
        let group = SKAction.group([fadeIn, scale])
        container.run(group)
    }
}
