////
///  LoginViewController.swift
//

import Alamofire
import OnePasswordExtension

public class LoginViewController: BaseElloViewController, HasAppController {
    var mockScreen: LoginScreenProtocol?
    var screen: LoginScreenProtocol { return mockScreen ?? (self.view as! LoginScreenProtocol) }

    var parentAppController: AppViewController?

    override public func loadView() {
        let screen = LoginScreen()
        screen.delegate = self
        screen.onePasswordAvailable = OnePasswordExtension.sharedExtension().isAppExtensionAvailable()
        self.view = screen
    }

    private func loadCurrentUser() {
        parentAppController?.loadCurrentUser() { error in
            self.screen.enableInputs()
            let errorTitle = error.elloErrorMessage ?? InterfaceString.Login.LoadUserError
            self.screen.showError(errorTitle)
        }
    }

}

extension LoginViewController: LoginDelegate {
    func backAction() {
        navigationController?.popViewControllerAnimated(true)
    }

    func forgotPasswordAction() {
        Tracker.sharedTracker.tappedForgotPassword()

        let browser = ElloWebBrowserViewController()
        let nav = ElloWebBrowserViewController.navigationControllerWithBrowser(browser)
        let url = "\(ElloURI.baseURL)/forgot-my-password"
        Tracker.sharedTracker.webViewAppeared(url)
        browser.loadURLString(url)
        browser.tintColor = UIColor.greyA()

        browser.showsURLInNavigationBar = false
        browser.showsPageTitleInNavigationBar = false
        browser.title = InterfaceString.Login.ForgotPassword
        browser.toolbarHidden = true

        presentViewController(nav, animated: true, completion: nil)
    }

    func onePasswordAction(sender: UIView) {
        OnePasswordExtension.sharedExtension().findLoginForURLString(
            ElloURI.baseURL,
            forViewController: self,
            sender: sender) { loginDict, error in
                guard let loginDict = loginDict else { return }

                if let username = loginDict[AppExtensionUsernameKey] as? String {
                    self.screen.username = username
                }

                if let password = loginDict[AppExtensionPasswordKey] as? String {
                    self.screen.password = password
                }

                if !self.screen.username.isEmpty && !self.screen.password.isEmpty {
                    self.submit(username: self.screen.username, password: self.screen.password)
                }
            }
}

    func submit(username username: String, password: String) {
        Tracker.sharedTracker.tappedLogin()

        screen.resignFirstResponder()

        if Validator.hasValidLoginCredentials(username: username, password: password) {
            Tracker.sharedTracker.loginValid()
            screen.hideError()
            screen.disableInputs()

            CredentialsAuthService().authenticate(email: username,
                password: password,
                success: {
                    Tracker.sharedTracker.loginSuccessful()
                    self.loadCurrentUser()
                },
                failure: { (error, statusCode) in
                    Tracker.sharedTracker.loginFailed()
                    self.screen.enableInputs()
                    let errorTitle = error.elloErrorMessage ?? InterfaceString.UnknownError
                    self.screen.showError(errorTitle)
                }
            )
        }
        else {
            Tracker.sharedTracker.loginInvalid()
            if let errorTitle = Validator.invalidLoginCredentialsReason(username: username, password: password) {
                screen.showError(errorTitle)
            }
        }
    }
}
