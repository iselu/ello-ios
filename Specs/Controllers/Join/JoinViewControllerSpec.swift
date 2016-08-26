////
///  JoinViewControllerSpec.swift
//

@testable
import Ello
import Quick
import Nimble


class JoinViewControllerSpec: QuickSpec {
    class MockScreen: JoinScreenProtocol {
        var email: String = ""
        var username: String = ""
        var password: String = ""
        var onePasswordAvailable: Bool = false

        var inputsEnabled = true
        var message: String?
        var emailError: String?
        var usernameError: String?
        var passwordError: String?
        var error: String?
        var usernames: [String]?
        var emailValid: Bool?
        var usernameValid: Bool?
        var passwordValid: Bool?
        var resignedFirstResponder = false

        func enableInputs() {
            inputsEnabled = true
        }
        func disableInputs() {
            inputsEnabled = false
        }

        func showMessage(text: String) {
            message = text
        }
        func hideMessage() {
            message = ""
        }

        func showUsernameSuggestions(usernames: [String]) {
            self.usernames = usernames
        }
        func showUsernameError(text: String) {
            usernameError = text
        }
        func hideUsernameError() {
            usernameError = ""
        }

        func showEmailError(text: String) {
            emailError = text
        }
        func hideEmailError() {
            emailError = ""
        }

        func showPasswordError(text: String) {
            passwordError = text
        }
        func hidePasswordError() {
            passwordError = ""
        }

        func showError(text: String) {
            error = text
        }

        func resignFirstResponder() -> Bool {
            resignedFirstResponder = true
            return true
        }

        func applyValidation(emailValid emailValid: Bool, usernameValid: Bool, passwordValid: Bool) {
            self.emailValid = emailValid
            self.usernameValid = usernameValid
            self.passwordValid = passwordValid
        }
    }

    override func spec() {
        describe("JoinViewController") {
            var subject: JoinViewController!
            var mockScreen: MockScreen!

            beforeEach {
                subject = JoinViewController()
                mockScreen = MockScreen()
                subject.mockScreen = mockScreen
                showController(subject)
            }

            describe("validating inputs") {
                context("missing inputs") {
                    beforeEach {
                        subject.validate(email: "", username: "", password: "")
                    }
                    it("should report error to screen") {
                        expect(mockScreen.emailValid) == false
                        expect(mockScreen.usernameValid) == false
                        expect(mockScreen.passwordValid) == false
                    }
                }
                context("invalid inputs") {
                    beforeEach {
                        subject.validate(email: "invalid", username: "a", password: "short")
                    }
                    it("should report error to screen") {
                        expect(mockScreen.emailValid) == false
                        expect(mockScreen.usernameValid) == false
                        expect(mockScreen.passwordValid) == false
                    }
                }

                context("missing email") {
                    beforeEach {
                        subject.validate(email: "", username: "valid", password: "password")
                    }
                    it("should report error to screen") {
                        expect(mockScreen.emailValid) == false
                        expect(mockScreen.usernameValid) == true
                        expect(mockScreen.passwordValid) == true
                    }
                }
                context("invalid email") {
                    beforeEach {
                        subject.validate(email: "invalid", username: "valid", password: "password")
                    }
                    it("should report error to screen") {
                        expect(mockScreen.emailValid) == false
                        expect(mockScreen.usernameValid) == true
                        expect(mockScreen.passwordValid) == true
                    }
                }

                context("missing username") {
                    beforeEach {
                        subject.validate(email: "valid@email.com", username: "", password: "password")
                    }
                    it("should report error to screen") {
                        expect(mockScreen.emailValid) == true
                        expect(mockScreen.usernameValid) == false
                        expect(mockScreen.passwordValid) == true
                    }
                }
                context("invalid username") {
                    beforeEach {
                        subject.validate(email: "valid@email.com", username: "a", password: "password")
                    }
                    it("should report error to screen") {
                        expect(mockScreen.emailValid) == true
                        expect(mockScreen.usernameValid) == false
                        expect(mockScreen.passwordValid) == true
                    }
                }

                context("missing password") {
                    beforeEach {
                        subject.validate(email: "valid@email.com", username: "valid", password: "")
                    }
                    it("should report error to screen") {
                        expect(mockScreen.emailValid) == true
                        expect(mockScreen.usernameValid) == true
                        expect(mockScreen.passwordValid) == false
                    }
                }
                context("invalid password") {
                    beforeEach {
                        subject.validate(email: "valid@email.com", username: "valid", password: "short")
                    }
                    it("should report error to screen") {
                        expect(mockScreen.emailValid) == true
                        expect(mockScreen.usernameValid) == true
                        expect(mockScreen.passwordValid) == false
                    }
                }
            }

            describe("submitting successful credentials") {
                let email = "email@email.com"
                let username = "username"
                let password = "password"
                beforeEach {
                    var token = AuthToken()
                    token.username = ""
                    token.password = ""
                    mockScreen.email = email
                    mockScreen.username = username
                    mockScreen.password = password
                    subject.submit(email: email, username: username, password: password)
                }

                it("stores the email and password") {
                    let token = AuthToken()
                    expect(token.username) == email
                    expect(token.password) == password
                }
            }

            describe("submitting") {
                context("input is valid email") {
                    let email = "email@email.com"
                    let username = "username"
                    let password = "password"
                    beforeEach {
                        mockScreen.email = email
                        mockScreen.username = username
                        mockScreen.password = password
                        subject.submit(email: email, username: username, password: password)
                    }
                    it("should disable inputs") {
                        expect(mockScreen.inputsEnabled) == false
                    }
                    it("should hide errors") {
                        expect(mockScreen.message) == ""
                        expect(mockScreen.emailError) == ""
                        expect(mockScreen.usernameError) == ""
                        expect(mockScreen.passwordError) == ""
                    }
                }

                context("input is invalid") {
                    let email = "not-email"
                    let username = "a"
                    let password = "short"
                    beforeEach {
                        mockScreen.email = email
                        mockScreen.username = username
                        mockScreen.password = password
                        subject.submit(email: email, username: username, password: password)
                    }
                    it("should enable inputs") {
                        expect(mockScreen.inputsEnabled) == true
                    }
                    it("should show errors") {
                        expect(mockScreen.emailError).notTo(beNil())
                        expect(mockScreen.usernameError).notTo(beNil())
                        expect(mockScreen.passwordError).notTo(beNil())
                    }
                }
            }
        }
    }
}
