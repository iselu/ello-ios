////
///  JoinProtocols.swift
//

protocol JoinDelegate: class {
    func backAction()
    func validate(email email: String, username: String, password: String)
    func onePasswordAction(sender: UIView)
    func submit(email email: String, username: String, password: String)
    func termsAction()
}

protocol JoinScreenProtocol: class {
    var email: String { get set }
    var username: String { get set }
    var password: String { get set }
    var onePasswordAvailable: Bool { get set }

    func enableInputs()
    func disableInputs()

    func showMessageText(text: String)
    func showUsernameSuggestions(usernames: [String])
    func hideMessage()
    func showUsernameError(text: String)
    func hideUsernameError()
    func showEmailError(text: String)
    func hideEmailError()
    func showPasswordError(text: String)
    func hidePasswordError()
    func showError(text: String)

    func resignFirstResponder() -> Bool
    func applyValidation(emailValid emailValid: Bool, usernameValid: Bool, passwordValid: Bool)
}
