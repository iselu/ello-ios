////
///  StartupGradientLayer.swift
//

public class StartupGradientLayer: CAGradientLayer {
    override init(layer: AnyObject) {
        super.init(layer: layer)
    }

    override init() {
        super.init()

        locations = [0, 1]
        colors = [
            UIColor(hex: 0x673f00).CGColor,
            UIColor(hex: 0x67191f).CGColor,
        ]
        startPoint = CGPoint(x: 1, y: 1)
        endPoint = CGPoint(x: 0, y: 0)
        addGradientAnimation()
    }

    public required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func addGradientAnimation() {
        let animation = CAKeyframeAnimation()
        animation.keyPath = "colors"
        animation.values = [
            [UIColor(hex: 0x673f00).CGColor, UIColor(hex: 0x67191f).CGColor],
            [UIColor(hex: 0x67191f).CGColor, UIColor(hex: 0x67325c).CGColor],
            [UIColor(hex: 0x67325c).CGColor, UIColor(hex: 0x2b3967).CGColor],
            [UIColor(hex: 0x2b3967).CGColor, UIColor(hex: 0x2a624d).CGColor],
            [UIColor(hex: 0x2a624d).CGColor, UIColor(hex: 0x673f00).CGColor],
            [UIColor(hex: 0x2b3967).CGColor, UIColor(hex: 0x2a624d).CGColor],
            [UIColor(hex: 0x67325c).CGColor, UIColor(hex: 0x2b3967).CGColor],
            [UIColor(hex: 0x67191f).CGColor, UIColor(hex: 0x67325c).CGColor],
            [UIColor(hex: 0x673f00).CGColor, UIColor(hex: 0x67191f).CGColor],
        ]
        animation.keyTimes = [
            0, 0.125, 0.25, 0.375, 0.5, 0.625, 0.75, 0.875, 1,
        ]
        animation.duration = 30
        animation.repeatCount = Float.infinity
        addAnimation(animation, forKey: "comments")
    }

}
