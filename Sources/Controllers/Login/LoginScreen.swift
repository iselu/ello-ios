////
///  LoginScreen.swift
//

import SnapKit


public class LoginScreen: CredentialsScreen {
    struct Size {
        static let fieldsTopMargin: CGFloat = 55
        static let fieldsInnerMargin: CGFloat = 30
        static let buttonHeight: CGFloat = 50
        static let buttonInset: CGFloat = 10
        static let forgotPasswordFontSize: CGFloat = 11
    }

    weak var delegate: LoginDelegate?
    var username: String {
        get { return usernameField.text?.stringByTrimmingCharactersInSet(NSCharacterSet.whitespaceCharacterSet()) ?? "" }
        set { usernameField.text = newValue }
    }
    var password: String {
        get { return passwordField.text ?? "" }
        set { passwordField.text = newValue }
    }
    var onePasswordAvailable = false {
        didSet { passwordField.hasOnePassword = onePasswordAvailable }
    }

    let usernameField = ClearTextField()
    let passwordField = ClearTextField()
    let errorLabel = ElloSizeableLabel()

    let forgotPasswordButton = UIButton()
    let continueButton = RoundedGrayElloButton()
    let continueBackground = UIView()

    override func setText() {
        titleLabel.text = InterfaceString.Startup.Login
        continueButton.setTitle(InterfaceString.Login.Continue, forState: .Normal)
        forgotPasswordButton.setTitle(InterfaceString.Login.ForgotPassword, forState: .Normal)
    }

    override func bindActions() {
        super.bindActions()
        continueButton.addTarget(self, action: #selector(submitAction), forControlEvents: .TouchUpInside)
        forgotPasswordButton.addTarget(self, action: #selector(forgotPasswordAction), forControlEvents: .TouchUpInside)
        passwordField.onePasswordButton.addTarget(self, action: #selector(onePasswordAction(_:)), forControlEvents: .TouchUpInside)
    }

    override func style() {
        super.style()

        ElloTextFieldView.styleAsEmailField(usernameField)
        usernameField.placeholder = InterfaceString.Join.UsernamePlaceholder
        usernameField.delegate = self

        ElloTextFieldView.styleAsPasswordField(passwordField)
        passwordField.placeholder = InterfaceString.Join.PasswordPlaceholder
        passwordField.delegate = self
        passwordField.hasOnePassword = onePasswordAvailable

        continueBackground.backgroundColor = .whiteColor()
        errorLabel.font = UIFont.defaultFont(12)
        errorLabel.textColor = .whiteColor()

        forgotPasswordButton.titleLabel?.font = UIFont.defaultFont(Size.forgotPasswordFontSize)
        forgotPasswordButton.setTitleColor(.greyA(), forState: .Normal)
    }

    override func arrange() {
        super.arrange()

        scrollView.addSubview(usernameField)
        scrollView.addSubview(passwordField)
        scrollView.addSubview(forgotPasswordButton)
        scrollView.addSubview(errorLabel)

        addSubview(continueBackground)
        continueBackground.addSubview(continueButton)

        scrollView.snp_makeConstraints { make in
            make.leading.trailing.equalTo(self)
            make.top.equalTo(blackBar.snp_bottom)
            make.bottom.equalTo(continueBackground.snp_top)
        }

        let scrollViewAnchor = UIView()
        scrollView.addSubview(scrollViewAnchor)
        scrollViewAnchor.snp_makeConstraints { make in
            make.leading.trailing.top.equalTo(scrollView)
            scrollViewWidth = make.width.equalTo(frame.size.width).priorityRequired().constraint
        }

        usernameField.snp_makeConstraints { make in
            make.top.equalTo(titleLabel.snp_bottom).offset(Size.fieldsTopMargin)
            make.leading.trailing.equalTo(scrollView).inset(CredentialsScreen.Size.inset)
        }

        passwordField.snp_makeConstraints { make in
            make.top.equalTo(usernameField.snp_bottom).offset(Size.fieldsInnerMargin)
            make.leading.trailing.equalTo(scrollView).inset(CredentialsScreen.Size.inset)
        }

        forgotPasswordButton.snp_makeConstraints { make in
            make.top.equalTo(passwordField.snp_bottom).offset(Size.fieldsInnerMargin)
            make.trailing.equalTo(scrollView).inset(Size.buttonInset)
        }

        continueButton.snp_makeConstraints { make in
            make.leading.trailing.equalTo(self).inset(Size.buttonInset)
            make.bottom.equalTo(keyboardAnchor.snp_top).offset(-Size.buttonInset)
            make.height.equalTo(Size.buttonHeight)
        }

        continueBackground.snp_makeConstraints { make in
            make.leading.trailing.bottom.equalTo(self)
            make.top.equalTo(continueButton).offset(-Size.buttonInset)
        }

        errorLabel.snp_makeConstraints { make in
            make.top.equalTo(passwordField.snp_bottom).offset(Size.fieldsInnerMargin)
            make.leading.trailing.equalTo(scrollView).inset(Size.inset)
            make.bottom.lessThanOrEqualTo(scrollView).inset(Size.inset)
        }
    }

    override public func resignFirstResponder() -> Bool {
        usernameField.resignFirstResponder()
        passwordField.resignFirstResponder()
        return super.resignFirstResponder()
    }
}

// MARK: Actions
extension LoginScreen {
    override public func backAction() {
        delegate?.backAction()
    }

    public func forgotPasswordAction() {
        delegate?.forgotPasswordAction()
    }

    public func submitAction() {
        delegate?.submit(username: username, password: password)
    }

    public func onePasswordAction(sender: UIView) {
        delegate?.onePasswordAction(sender)
    }
}

// MARK: UITextFieldDelegate
extension LoginScreen: UITextFieldDelegate {
    public func textFieldDidEndEditing(textField: UITextField) {
        textField.setNeedsLayout()
        textField.layoutIfNeeded()
    }

    public func textFieldShouldReturn(textField: UITextField) -> Bool {
        switch textField {
        case usernameField:
            Tracker.sharedTracker.enteredEmail()
            passwordField.becomeFirstResponder()
            return true
        case passwordField:
            Tracker.sharedTracker.enteredPassword()
            delegate?.submit(username: username, password: password)
            return false
        default:
            return true
        }
    }
}

// MARK: LoginScreenProtocol
extension LoginScreen: LoginScreenProtocol {
    func enableInputs() {
        usernameField.enabled = true
        passwordField.enabled = true
        userInteractionEnabled = true
    }

    func disableInputs() {
        usernameField.enabled = false
        passwordField.enabled = false
        userInteractionEnabled = false
    }

    func showError(text: String) {
        errorLabel.setLabelText(text)

        animate {
            self.errorLabel.alpha = 1.0
            self.layoutIfNeeded()
        }
    }

    func hideError() {
        let completion: (Bool) -> Void = { _ in
            self.errorLabel.text = ""
        }

        animate(completion: completion) {
            self.errorLabel.alpha = 0.0
            self.layoutIfNeeded()
        }
    }
}
