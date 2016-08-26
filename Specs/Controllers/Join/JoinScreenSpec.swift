////
///  JoinScreenSpec.swift
//

@testable import Ello
import Quick
import Nimble


class JoinScreenSpec: QuickSpec {
    override func spec() {
        class MockDelegate: JoinDelegate {
            var didValidate = false

            func backAction() {}
            func validate(email email: String, username: String, password: String) {
                didValidate = true
            }
            func onePasswordAction(sender: UIView) {}
            func submit(email email: String, username: String, password: String) {}
            func termsAction() {}
        }

        describe("JoinScreen") {
            var subject: JoinScreen!
            var delegate: MockDelegate!
            beforeEach {
                delegate = MockDelegate()
                subject = JoinScreen()
                subject.delegate = delegate
            }

            describe("snapshots") {
                validateAllSnapshots { return subject }
            }

            describe("snapshot, one password shown") {
                beforeEach {
                    subject.onePasswordAvailable = true
                }
                it("should have a valid snapshot") {
                    expectValidSnapshot(subject, device: .Phone6_Portrait)
                }
            }

            describe("snapshot, keyboard shown") {
                beforeEach {
                    Keyboard.shared.active = true
                    Keyboard.shared.bottomInset = 216
                    subject.keyboardWillChange(Keyboard.shared)
                }
                afterEach {
                    Keyboard.shared.active = false
                    Keyboard.shared.bottomInset = 0
                }
                it("should have a valid snapshot") {
                    expectValidSnapshot(subject, device: .Phone6_Portrait)
                }
            }

            describe("snapshot, email error shown") {
                beforeEach {
                    subject.showEmailError("error")
                }
                it("should have a valid snapshot") {
                    expectValidSnapshot(subject, device: .Phone6_Portrait)
                }
            }

            describe("snapshot, username error shown") {
                beforeEach {
                    subject.showUsernameError("error")
                }
                it("should have a valid snapshot") {
                    expectValidSnapshot(subject, device: .Phone6_Portrait)
                }
            }

            describe("snapshot, username error and message shown") {
                beforeEach {
                    subject.showUsernameError("error")
                    subject.showMessage("message")
                }
                it("should have a valid snapshot") {
                    expectValidSnapshot(subject, device: .Phone6_Portrait)
                }
            }

            describe("snapshot, password error shown") {
                beforeEach {
                    subject.showPasswordError("error")
                }
                it("should have a valid snapshot") {
                    expectValidSnapshot(subject, device: .Phone6_Portrait)
                }
            }

            describe("snapshot, message shown") {
                beforeEach {
                    subject.showMessage("message")
                }
                it("should have a valid snapshot") {
                    expectValidSnapshot(subject, device: .Phone6_Portrait)
                }
            }

            describe("snapshot, email valid") {
                beforeEach {
                    subject.applyValidation(emailValid: true, usernameValid: false, passwordValid: false)
                }
                it("should have a valid snapshot") {
                    expectValidSnapshot(subject, device: .Phone6_Portrait)
                }
            }

            describe("snapshot, username valid") {
                beforeEach {
                    subject.applyValidation(emailValid: false, usernameValid: true, passwordValid: false)
                }
                it("should have a valid snapshot") {
                    expectValidSnapshot(subject, device: .Phone6_Portrait)
                }
            }

            describe("snapshot, password valid") {
                beforeEach {
                    subject.applyValidation(emailValid: false, usernameValid: false, passwordValid: true)
                }
                it("should have a valid snapshot") {
                    expectValidSnapshot(subject, device: .Phone6_Portrait)
                }
            }

            describe("snapshot, all valid") {
                beforeEach {
                    subject.applyValidation(emailValid: true, usernameValid: true, passwordValid: true)
                }
                it("should have a valid snapshot") {
                    expectValidSnapshot(subject, device: .Phone6_Portrait)
                }
            }

            describe("snapshot, username suggestions") {
                beforeEach {
                    subject.showUsernameSuggestions(["aaa", "bbb", "ccc"])
                }
                it("should have a valid snapshot") {
                    expectValidSnapshot(subject, device: .Phone6_Portrait)
                }
            }

            describe("changing text") {
                beforeEach {
                    subject.textField(UITextField(), shouldChangeCharactersInRange: NSRange(location: 0, length: 0), replacementString: "")
                }
                it("should call 'validate' on the delegate") {
                    expect(delegate.didValidate) == true
                }
            }

        }
    }
}
