////
///  StartupScreenSpec.swift
//

@testable import Ello
import Quick
import Nimble


class StartupScreenSpec: QuickSpec {
    override func spec() {
        describe("StartupScreen") {
            describe("snapshots") {
                var subject: StartupScreen!
                beforeEach {
                    subject = StartupScreen()
                    subject.logoImage.stopAnimating()
                }
                validateAllSnapshots { return subject }
            }
        }
    }
}
