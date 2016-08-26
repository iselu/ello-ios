////
///  AvatarImageSelectionViewControllerSpec.swift
//

@testable
import Ello
import Quick
import Nimble
import Nimble_Snapshots


class AvatarImageSelectionViewControllerSpec: QuickSpec {
    override func spec() {
        describe("AvatarImageSelectionViewController") {
            var subject: AvatarImageSelectionViewController!
            beforeEach {
                subject = AvatarImageSelectionViewController()
            }
            validateAllSnapshots(named: "AvatarImageSelectionViewController") { return subject }
        }
    }
}
