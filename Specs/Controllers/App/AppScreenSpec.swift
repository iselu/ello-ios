////
///  AppScreenSpec.swift
//

@testable import Ello
import Quick
import Nimble


class AppScreenSpec: QuickSpec {
    override func spec() {
        describe("AppScreen") {
            describe("snapshots") {
                var subject: AppScreen!
                beforeEach {
                    subject = AppScreen()
                }
                validateAllSnapshots({ return subject })
            }
        }
    }
}
