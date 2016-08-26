////
///  StartupViewController.swift
//

public class StartupViewController: UIViewController {
    var mockScreen: StartupScreenProtocol?
    var screen: StartupScreenProtocol { return mockScreen ?? (self.view as! StartupScreenProtocol) }
    var parentAppController: AppViewController?

    override public func loadView() {
        let screen = StartupScreen()
        screen.delegate = self
        self.view = screen
    }

}

extension StartupViewController: StartupDelegate {
    func signUpAction() {
        parentAppController?.showJoinScreen(animated: true)
    }

    func loginAction() {
        parentAppController?.showLoginScreen(animated: true)
    }
}
