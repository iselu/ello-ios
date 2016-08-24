////
///  StartupViewController.swift
//

public class StartupViewController: UIViewController {
    var screen: StartupScreen { return self.view as! StartupScreen }
    var parentAppController: AppViewController?

    override public func loadView() {
        let screen = StartupScreen()
        screen.delegate = self
        self.view = screen
    }

}

extension StartupViewController: StartupDelegate {
    func signUpAction() {
        parentAppController?.showJoinScreen()
    }

    func loginAction() {
        parentAppController?.showLoginScreen()
    }
}
