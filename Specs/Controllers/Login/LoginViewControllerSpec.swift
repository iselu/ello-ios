////
///  LoginViewControllerSpec.swift
//

@testable import Ello
import Quick
import Nimble


class LoginViewControllerSpec: QuickSpec {
    override func spec() {
        describe("LoginViewController") {
            var subject: LoginViewController!
            beforeEach {
                subject = LoginViewController()
                showController(subject)
            }

            describe("submitting successful credentials") {
                it("stores the email and password") {
                    let email = "email@email.com"
                    let password = "password"
                    subject.submit(username: email, password: password)

                    let token = AuthToken()
                    expect(token.username) == email
                    expect(token.password) == password
                }
            }

            describe("-viewDidLoad") {

                it("has a cross dissolve modal transition style") {
                    expect(subject.modalTransitionStyle) == UIModalTransitionStyle.CrossDissolve
                }
            }
        }
    }
}

