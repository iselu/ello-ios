////
///  LoginProtocols.swift
//

protocol LoginDelegate: class {
    func backAction()
    func forgotPasswordAction()
    func onePasswordAction(sender: UIView)
    func submit(username username: String, password: String)
}

protocol LoginScreenProtocol: class {
    var username: String { get set }
    var password: String { get set }
    var onePasswordAvailable: Bool { get set }
    func enableInputs()
    func disableInputs()
    func showError(text: String)
    func hideError()
    func resignFirstResponder() -> Bool
}
