////
///  HireScreen.swift
//

import SnapKit


public class HireScreen: ElloScreen {
    struct Size {
        static let keyboardButtonHeight: CGFloat = 44
        static let textViewTopMargin: CGFloat = 40
        static let textViewSideMargins: CGFloat = 15
        static let placeholderTopMargin: CGFloat = 8
        static let successLabelLeading: CGFloat = 55
        static let successImageLeading: CGFloat = 20
    }

    var recipient: String = "" {
        didSet {
            successLabel.text = "Email sent to \(recipient)"
        }
    }
    weak var delegate: HireDelegate?

    private let successView = UIView()
    private let successLabel = UILabel()
    private let successImage = UIImageView()
    private let textView = UITextView()
    private let placeholder = UILabel()
    private let keyboardSubmitButton = UIButton()
    private var keyboardBottomConstraint: Constraint!

    override func arrange() {
        super.arrange()

        addSubview(textView)
        addSubview(placeholder)
        addSubview(keyboardSubmitButton)

        textView.snp_makeConstraints { make in
            make.leading.trailing.equalTo(self).inset(Size.textViewSideMargins)
            make.top.equalTo(navigationBar.snp_bottom).offset(Size.textViewTopMargin)
            make.bottom.equalTo(keyboardSubmitButton.snp_top)
        }

        placeholder.snp_makeConstraints { make in
            make.top.equalTo(textView).offset(Size.placeholderTopMargin)
            make.leading.equalTo(textView)
        }

        keyboardSubmitButton.snp_makeConstraints { make in
            make.leading.trailing.equalTo(self)
            make.height.equalTo(Size.keyboardButtonHeight)
            make.bottom.lessThanOrEqualTo(self).offset(-ElloTabBar.Size.height).priorityRequired()
            keyboardBottomConstraint = make.bottom.equalTo(self).priorityHigh().constraint
        }

        let window = UIApplication.sharedApplication().keyWindow!
        window.addSubview(successView)
        successView.addSubview(successLabel)
        successView.addSubview(successImage)

        successView.snp_makeConstraints { make in
            make.edges.equalTo(window)
        }
        successLabel.snp_makeConstraints { make in
            make.leading.equalTo(successView).offset(Size.successLabelLeading)
            make.centerY.equalTo(successView)
        }
        successImage.snp_makeConstraints { make in
            make.leading.equalTo(successView).offset(Size.successImageLeading)
            make.centerY.equalTo(successView)
        }
    }

    override func style() {
        super.style()

        textView.delegate = self
        textView.backgroundColor = .clearColor()
        textView.tintColor = .blackColor()
        textView.textColor = .blackColor()
        textView.font = UIFont.editorFont()
        textView.textContainer.lineFragmentPadding = 0
        textView.showsHorizontalScrollIndicator = false
        textView.keyboardAppearance = .Dark

        placeholder.text = InterfaceString.Omnibar.SayEllo
        placeholder.textColor = .greyC()
        placeholder.font = UIFont.editorFont()

        keyboardSubmitButton.enabled = false
        keyboardSubmitButton.backgroundColor = .blackColor()
        keyboardSubmitButton.setTitleColor(.whiteColor(), forState: .Normal)
        keyboardSubmitButton.setTitleColor(.grey6(), forState: .Disabled)
        keyboardSubmitButton.titleLabel?.font = UIFont.defaultFont()
        keyboardSubmitButton.contentEdgeInsets.left = -5
        keyboardSubmitButton.imageEdgeInsets.right = 5

        successView.backgroundColor = .whiteColor()
        successView.alpha = 0
        successLabel.textColor = .blackColor()
        successLabel.font = UIFont.defaultFont(18)
        successImage.image = InterfaceImage.ValidationOK.normalImage
    }

    override func setText() {
        super.setText()

        keyboardSubmitButton.setImages(.Pencil, white: true)
        keyboardSubmitButton.setTitle(InterfaceString.Hire.Send, forState: .Normal)
    }

    override func bindActions() {
        super.bindActions()
        keyboardSubmitButton.addTarget(self, action: #selector(submitAction), forControlEvents: .TouchUpInside)
    }

    public func toggleKeyboard(visible visible: Bool) {
        self.layoutIfNeeded()

        let bottomInset = Keyboard.shared.keyboardBottomInset(inView: self)
        keyboardBottomConstraint.updateOffset(-bottomInset)
        animate(duration: Keyboard.shared.duration, options: Keyboard.shared.options) {
            self.keyboardSubmitButton.frame.origin.y = self.frame.size.height - bottomInset - Size.keyboardButtonHeight
        }
    }

    public func submitAction() {
        guard let text = textView.text else { return }

        textView.resignFirstResponder()
        self.delegate?.submit(body: text)
        self.showSuccess()

    }

    public func showSuccess() {
        animate {
            self.successView.alpha = 1
        }
    }

    public func hideSuccess() {
        animate {
            self.successView.alpha = 0
        }
    }

}

extension HireScreen: UITextViewDelegate {
    public func textViewDidChange(textView: UITextView) {
        let hasText = textView.text?.isEmpty != true
        placeholder.hidden = hasText
        keyboardSubmitButton.enabled = hasText
    }
}

extension HireViewController: HireScreenProtocol {
}
