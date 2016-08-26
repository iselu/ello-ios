////
///  ClearTextField.swift
//

public class ClearTextField: UITextField {
    public let onePasswordButton = UIButton()
    var line = UIView()
    var hasOnePassword = false {
        didSet { onePasswordButton.hidden = !hasOnePassword }
    }
    var validationState = ValidationState.None {
        didSet {
            rightView = UIImageView(image: validationState.imageRepresentation)
        }
    }

    required override public init(frame: CGRect) {
        super.init(frame: frame)
        sharedSetup()
    }

    required public init?(coder: NSCoder) {
        super.init(coder: coder)
        sharedSetup()
    }

    func sharedSetup() {
        line.backgroundColor = .grey6()
        backgroundColor = .clearColor()
        font = .defaultFont(18)
        textColor = .whiteColor()
        rightViewMode = .Always
        addSubview(line)

        onePasswordButton.hidden = true
        onePasswordButton.setImage(.OnePassword, imageStyle: .White, forState: .Normal)
        onePasswordButton.contentMode = .Center
        addSubview(onePasswordButton)

        onePasswordButton.snp_makeConstraints { make in
            make.centerY.equalTo(self)
            make.trailing.equalTo(self)
            make.size.equalTo(CGSize.minButton)
        }
    }

    override public func drawPlaceholderInRect(rect: CGRect) {
        placeholder?.drawInRect(rect, withAttributes: [
            NSFontAttributeName: UIFont.defaultFont(18),
            NSForegroundColorAttributeName: UIColor.whiteColor(),
        ])
    }

    override public func layoutSubviews() {
        super.layoutSubviews()
        line.frame = CGRect(x: 0, y: frame.height - 1, width: frame.width, height: 1)
    }

    override public func becomeFirstResponder() -> Bool {
        line.backgroundColor = .whiteColor()
        return super.becomeFirstResponder()
    }

    override public func resignFirstResponder() -> Bool {
        line.backgroundColor = .grey6()
        return super.resignFirstResponder()
    }

    override public func textRectForBounds(bounds: CGRect) -> CGRect {
        return rectForBounds(bounds)
    }

    override public func editingRectForBounds(bounds: CGRect) -> CGRect {
        return rectForBounds(bounds)
    }

    override public func clearButtonRectForBounds(bounds: CGRect) -> CGRect {
        var rect = super.clearButtonRectForBounds(bounds)
        rect.origin.x -= 10
        if hasOnePassword {
            rect.origin.x -= 44
        }
        return rect
    }

    override public func rightViewRectForBounds(bounds: CGRect) -> CGRect {
        var rect = super.rightViewRectForBounds(bounds)
        rect.origin.x -= 10
        return rect
    }

    private func rectForBounds(bounds: CGRect) -> CGRect {
        return bounds.shrinkLeft(15).inset(topBottom: 10)
    }

}
