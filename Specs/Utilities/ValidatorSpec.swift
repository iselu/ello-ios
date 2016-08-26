////
///  ValidatorSpec.swift
//

import Ello
import Quick
import Nimble


class ValidatorSpec: QuickSpec {
    override func spec() {

        context("email validation") {
            let expectations: [(String, Bool)] = [
                ("name@test.com", true),
                ("n@t.co", true),
                ("n@t.shopping", true),
                ("some.name@domain.co.uk", true),
                ("some+name@domain.somethingreallylong", true),
                ("test.com", false),
                ("name@test", false),
                ("name@.com", false),
                ("name@name.com.", false),
                ("name@name.t", false),
                ("", false),
            ]

            for (test, expected) in expectations {
                it("returns \(expected) for \(test)") {
                    expect(Validator.isValidEmail(test)) == expected
                }
            }
        }

        context("username validation") {
            let expectations: [(String, Bool)] = [
                ("", false),
                ("a", false),
                ("aa", true),
                ("-a", true),
                ("a-", true),
                ("--", true),
                ("user%", false),
            ]

            for (test, expected) in expectations {
                it("returns \(expected) for \(test)") {
                    expect(Validator.isValidUsername(test)) == expected
                }
            }
        }

        context("password validation") {
            let expectations: [(String, Bool)] = [
                ("asdfasdf", true),
                ("12345678", true),
                ("123456789", true),
                ("", false),
                ("1", false),
                ("12", false),
                ("123", false),
                ("1234", false),
                ("12345", false),
                ("123456", false),
                ("1234567", false),
            ]

            for (test, expected) in expectations {
                it("returns \(expected) for \(test)") {
                    expect(Validator.isValidPassword(test)) == expected
                }
            }
        }
    }
}
