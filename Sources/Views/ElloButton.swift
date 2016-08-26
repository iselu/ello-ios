////
///  ElloButton.swift
//

import UIKit

// black button, gray text, and sets the correct font
public class ElloButton: UIButton {

    override public var enabled: Bool {
        didSet { updateStyle() }
    }

    override public var selected: Bool {
        didSet { updateStyle() }
    }

    func updateStyle() {
        backgroundColor = enabled ? .blackColor() : .grey231F20()
    }

    required override public init(frame: CGRect) {
        super.init(frame: frame)
        sharedSetup()
    }

    required public init?(coder: NSCoder) {
        super.init(coder: coder)
        sharedSetup()
    }

    public override func awakeFromNib() {
        super.awakeFromNib()

        if buttonType != .Custom {
            print("Warning, ElloButton instance '\(currentTitle)' should be configured as 'Custom', not \(buttonType)")
        }

        updateStyle()
    }

    func sharedSetup() {
        titleLabel?.font = UIFont.defaultFont()
        titleLabel?.numberOfLines = 1
        setTitleColor(.whiteColor(), forState: .Normal)
        setTitleColor(.greyA(), forState: .Disabled)
        updateStyle()
    }

    public override func titleRectForContentRect(contentRect: CGRect) -> CGRect {
        var titleRect = super.titleRectForContentRect(contentRect)
        let delta: CGFloat = 4
        titleRect.size.height += 2 * delta
        titleRect.origin.y -= delta
        return titleRect
    }

}

// light gray background, dark gray text
public class LightElloButton: ElloButton {

    override func updateStyle() {
        backgroundColor = enabled ? .greyE5() : .greyF1()
    }

    override func sharedSetup() {
        super.sharedSetup()
        setTitleColor(.grey6(), forState: .Normal)
        setTitleColor(.blackColor(), forState: .Highlighted)
        setTitleColor(.greyC(), forState: .Disabled)
    }

}

// white button, black text
public class WhiteElloButton: ElloButton {

    required public init(frame: CGRect) {
        super.init(frame: frame)
    }

    required public init?(coder: NSCoder) {
        super.init(coder: coder)
    }

    override func updateStyle() {
        if !enabled {
            backgroundColor = .greyA()
        }
        else if selected {
            backgroundColor = .blackColor()
        }
        else {
            backgroundColor = .whiteColor()
        }
    }

    override func sharedSetup() {
        super.sharedSetup()
        titleLabel?.font = UIFont.defaultFont()
        setTitleColor(.blackColor(), forState: .Normal)
        setTitleColor(.grey6(), forState: .Highlighted)
        setTitleColor(.greyC(), forState: .Disabled)
        setTitleColor(.whiteColor(), forState: .Selected)
    }
}

// white button, black text, black outline w/ square corners
public class OutlineElloButton: WhiteElloButton {

    override func sharedSetup() {
        super.sharedSetup()
        backgroundColor = .whiteColor()
        layer.borderWidth = 1
        updateOutline()
    }

    override public var highlighted: Bool {
        didSet {
            updateOutline()
        }
    }

    private func updateOutline() {
        layer.borderColor = highlighted ? UIColor.greyE5().CGColor : UIColor.blackColor().CGColor
    }
}

// clear button, black text.  corners are either "fully" rounded (to match the
// height) or they can be set to any radius
public class RoundedElloButton: ElloButton {
    var borderColor: UIColor? = .blackColor() {
        didSet {
            updateOutline()
        }
    }
    var cornerRadius: CGFloat? {
        didSet {
            setNeedsLayout()
        }
    }

    override public func sharedSetup() {
        super.sharedSetup()
        setTitleColor(.blackColor(), forState: .Normal)
        setTitleColor(.grey6(), forState: .Highlighted)
        setTitleColor(.greyC(), forState: .Disabled)
        layer.borderWidth = 1
        backgroundColor = .clearColor()
        updateOutline()
    }

    override func updateStyle() {
        backgroundColor = enabled ? .clearColor() : .greyF2()
        updateOutline()
    }

    func updateOutline() {
        if let borderColor = borderColor where enabled {
            layer.borderColor = borderColor.CGColor
        }
        else if borderColor != nil && !enabled {
            layer.borderColor = UIColor.greyF2().CGColor
        }
        else {
            layer.borderColor = nil
        }
    }

    override public func layoutSubviews() {
        super.layoutSubviews()

        if let cornerRadius = cornerRadius {
            layer.cornerRadius = cornerRadius
        }
        else {
            layer.cornerRadius = min(frame.height, frame.width) / 2
        }
    }
}

public class RoundedGrayElloButton: RoundedElloButton {
    override public func sharedSetup() {
        super.sharedSetup()
        borderColor = .greyA()
        cornerRadius = 5
        setTitleColor(.greyA(), forState: .Normal)
        setTitleColor(.blackColor(), forState: .Highlighted)
    }
}

// green background, white text.
public class GreenElloButton: ElloButton {
    override func updateStyle() {
        backgroundColor = enabled ? .greenD1() : .grey6()
    }

    override func sharedSetup() {
        super.sharedSetup()
        setTitleColor(.whiteColor(), forState: .Normal)
        setTitleColor(.greyA(), forState: .Highlighted)
        setTitleColor(.whiteColor(), forState: .Disabled)
        layer.cornerRadius = 5
        updateStyle()
    }
}
