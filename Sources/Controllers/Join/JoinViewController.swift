////
///  JoinViewController.swift
//

import OnePasswordExtension

public class JoinViewController: BaseElloViewController, HasAppController {
    var mockScreen: JoinScreenProtocol?
    var screen: JoinScreenProtocol { return mockScreen ?? (self.view as! JoinScreenProtocol) }

    var parentAppController: AppViewController?

    override public func loadView() {
        let screen = JoinScreen()
        screen.delegate = self
        screen.onePasswordAvailable = OnePasswordExtension.sharedExtension().isAppExtensionAvailable()
        self.view = screen
    }

    private func showOnboardingScreen(user: User) {
        parentAppController?.showOnboardingScreen(user)
    }

    private func showLoginScreen(email: String, _ password: String) {
        parentAppController?.showLoginScreen(animated: true)
    }
}

extension JoinViewController: JoinDelegate {
    func backAction() {
        navigationController?.popViewControllerAnimated(true)
    }

    func validate(email email: String, username: String, password: String) {
        let emailValid = Validator.invalidSignUpEmailReason(email) == nil
        let usernameValid = Validator.invalidSignUpUsernameReason(username) == nil
        let passwordValid = Validator.invalidSignUpPasswordReason(password) == nil
        screen.applyValidation(emailValid: emailValid, usernameValid: usernameValid, passwordValid: passwordValid)
    }

    func submit(email email: String, username: String, password: String) {
        Tracker.sharedTracker.tappedJoin()

        screen.hideMessage()
        screen.resignFirstResponder()

        if Validator.hasValidSignUpCredentials(email: email, username: username, password: password) {
            screen.hideEmailError()
            screen.hideUsernameError()
            screen.hidePasswordError()
            screen.disableInputs()

            let joinAborted: () -> Void = {
                self.screen.enableInputs()
            }

            self.emailAvailability(email) { successful in
                if !successful {
                    joinAborted()
                    return
                }

                self.usernameAvailability(username) { successful in
                    if !successful {
                        joinAborted()
                        return
                    }

                    Tracker.sharedTracker.joinValid()

                    UserService().join(email: email, username: username, password: password, success: { user in
                        let authService = CredentialsAuthService()
                        authService.authenticate(email: email,
                            password: password,
                            success: {
                                Tracker.sharedTracker.joinSuccessful()
                                self.showOnboardingScreen(user)
                            },
                            failure: { _, _ in
                                Tracker.sharedTracker.joinFailed()
                                self.showLoginScreen(email, password)
                            })
                        },
                        failure: { error, _ in
                            let errorTitle = error.elloErrorMessage ?? InterfaceString.UnknownError
                            self.screen.showError(errorTitle)
                            joinAborted()
                        })
                }
            }
        }
        else {
            Tracker.sharedTracker.joinInvalid()
            if let msg = Validator.invalidSignUpEmailReason(email) {
                screen.showEmailError(msg)
            }
            else {
                screen.hideEmailError()
            }

            if let msg = Validator.invalidSignUpUsernameReason(username) {
                screen.showUsernameError(msg)
            }
            else {
                screen.hideUsernameError()
            }

            if let msg = Validator.invalidSignUpPasswordReason(password) {
                screen.showPasswordError(msg)
            }
            else {
                screen.hidePasswordError()
            }
        }
    }

    func termsAction() {
        let nav = ElloWebBrowserViewController.navigationControllerWithWebBrowser()
        let browser = nav.rootWebBrowser()
        let url = "\(ElloURI.baseURL)/wtf/post/terms-of-use"
        Tracker.sharedTracker.webViewAppeared(url)
        browser.loadURLString(url)
        browser.tintColor = UIColor.greyA()
        browser.showsURLInNavigationBar = false
        browser.showsPageTitleInNavigationBar = false
        browser.title = InterfaceString.WebBrowser.TermsAndConditions

        presentViewController(nav, animated: true, completion: nil)
    }

    func onePasswordAction(sender: UIView) {
        OnePasswordExtension.sharedExtension().findLoginForURLString(
            ElloURI.baseURL,
            forViewController: self,
            sender: sender) { loginDict, error in
                guard let loginDict = loginDict else { return }

                if let email = loginDict[AppExtensionUsernameKey] as? String {
                    self.screen.email = email
                }

                if let password = loginDict[AppExtensionPasswordKey] as? String {
                    self.screen.password = password
                }
        }
    }
}

// MARK: Text field validation
extension JoinViewController {

    private func emailAvailability(text: String, completion: (Bool) -> Void) {
        AvailabilityService().emailAvailability(text, success: { availability in
            if text != self.screen.email {
                completion(false)
                return
            }

            if !availability.isEmailAvailable {
                self.screen.showEmailError(InterfaceString.Validator.EmailInvalid)
                completion(false)
            }
            else {
                completion(true)
            }
        }, failure: { error, _ in
            let errorTitle = error.elloErrorMessage ?? InterfaceString.UnknownError
            self.screen.showEmailError(errorTitle)
            completion(false)
        })
    }

    private func usernameAvailability(text: String, completion: (Bool) -> Void) {
        AvailabilityService().usernameAvailability(text, success: { availability in
            if text != self.screen.username {
                completion(false)
                return
            }

            if !availability.isUsernameAvailable {
                self.screen.showUsernameError(InterfaceString.Join.UsernameUnavailable)

                if !availability.usernameSuggestions.isEmpty {
                    self.screen.showUsernameSuggestions(availability.usernameSuggestions)
                }
                completion(false)
            }
            else {
                self.screen.hideMessage()
                completion(true)
            }
        }, failure: { error, _ in
            let errorTitle = error.elloErrorMessage ?? InterfaceString.UnknownError
            self.screen.showUsernameError(errorTitle)
            self.screen.hideMessage()
            completion(false)
        })
    }

}
