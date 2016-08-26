////
///  LoginScreenSpec.swift
//

@testable import Ello
import Quick
import Nimble


class LoginScreenSpec: QuickSpec {
    override func spec() {
        describe("LoginScreen") {
            var subject: LoginScreen!
            beforeEach {
                subject = LoginScreen()
            }

            describe("snapshots") {
                validateAllSnapshots({ return subject }, record: true)
            }

            describe("text fields") {
                context("usernameField") {

                    it("is properly configured") {
                        expect(subject.usernameField.keyboardType) == UIKeyboardType.EmailAddress
                        expect(subject.usernameField.returnKeyType) == UIReturnKeyType.Next
                    }

                    it("has screen as delegate") {
                        expect(subject.usernameField.delegate) === subject
                    }

                }

                context("passwordField") {

                    it("is properly configured") {
                        expect(subject.passwordField.keyboardType) == UIKeyboardType.Default
                        expect(subject.passwordField.returnKeyType) == UIReturnKeyType.Go
                        expect(subject.passwordField.secureTextEntry) == true
                    }

                    it("has controller as delegate") {
                        expect(subject.passwordField.delegate) === subject
                    }
                }
            }


            describe("continueButton") {

                context("input is valid email") {

                    it("disables input") {
                        subject.username = "name@example.com"
                        subject.password = "12345678"

                        subject.enterTapped(subject.enterButton)
                        expect(subject.usernameField.enabled) == false
                        expect(subject.passwordField.enabled) == false
                        expect(subject.view.userInteractionEnabled) == false
                    }

                }

                context("input is valid username") {

                    it("disables input") {
                        subject.username = "name"
                        subject.password = "12345678"

                        subject.enterTapped(subject.enterButton)
                        expect(subject.usernameField.enabled) == false
                        expect(subject.passwordField.enabled) == false
                        expect(subject.view.userInteractionEnabled) == false
                    }

                }

                context("input is invalid") {

                    it("does not disable input") {
                        subject.username = "invalid email"
                        subject.password = "abc"

                        subject.enterTapped(subject.enterButton)
                        expect(subject.usernameField.enabled) == true
                        expect(subject.passwordField.enabled) == true
                        expect(subject.view.userInteractionEnabled) == true
                    }
                }
            }

            describe("keyboard") {

                describe("UIKeyboardWillShowNotification") {

                    context("keyboard is docked") {

                        it("adjusts scrollview") {
                            Keyboard.shared.bottomInset = screenHeight - 303.0
                            postNotification(Keyboard.Notifications.KeyboardWillShow, value: Keyboard.shared)

                            expect(subject.scrollView.contentInset.bottom) > 50
                        }
                    }

                    context("keyboard is not docked") {
                        xit("does NOT adjust scrollview") {
                            // this is not easily faked with Keyboard unfortunately
                            Keyboard.shared.bottomInset = screenHeight - 100.0
                            postNotification(Keyboard.Notifications.KeyboardWillShow, value: Keyboard.shared)

                            expect(subject.scrollView.contentInset.bottom) == 0
                        }
                    }
                }

                describe("UIKeyboardWillHideNotification") {

                    it("adjusts scrollview") {
                        Keyboard.shared.bottomInset = 0.0
                        postNotification(Keyboard.Notifications.KeyboardWillHide, value: Keyboard.shared)

                        expect(subject.scrollView.contentInset.bottom) == 0.0
                    }
                }
            }

        }
    }
}
