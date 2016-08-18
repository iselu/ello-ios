////
///  BlockUserModalScreenSpec.swift
//

@testable import Ello
import Quick
import Nimble


class BlockUserModalScreenSpec: QuickSpec {
    class FakeBlockUserModalController: UIViewController, BlockUserModalDelegate {
        var relationshipPriority: RelationshipPriority?
        var calledFlagTapped = false
        var calledCloseModal = false

        func updateRelationship(newRelationship: RelationshipPriority) {
            relationshipPriority = newRelationship
        }
        func flagTapped() {
            calledFlagTapped = true
        }
        func closeModal() {
            calledCloseModal = true
        }
    }

    override func spec() {
        describe("BlockUserModalScreen") {
            var subject: BlockUserModalScreen!
            var controller: FakeBlockUserModalController!
            var muteButton: UIButton!
            var blockButton: UIButton!
            var flagButton: UIButton!

            func setupScreen(atName atName: String = "@archer", relationshipPriority: RelationshipPriority = .Inactive) {
                let config = BlockUserModalConfig(userId: "666", userAtName: atName, relationshipPriority: relationshipPriority, changeClosure: { _ in })
                controller = FakeBlockUserModalController()
                subject = BlockUserModalScreen(config: config)
                controller.view = subject
                showController(controller)

                muteButton = (subviewThatMatches(subject) { ($0 as? UIButton)?.currentTitle == InterfaceString.Relationship.MuteButton })
                blockButton = (subviewThatMatches(subject) { ($0 as? UIButton)?.currentTitle == InterfaceString.Relationship.BlockButton })
                flagButton = (subviewThatMatches(subject) { ($0 as? UIButton)?.currentTitle == InterfaceString.Relationship.FlagButton })
            }

            beforeEach {
                setupScreen(relationshipPriority: .Inactive)
            }

            describe("snapshots") {
                beforeEach {
                    setupScreen(atName: "@foo", relationshipPriority: .Following)
                }
                validateAllSnapshots({ return subject }, named: "BlockUserModalScreen")
            }

            describe("button targets") {

                describe("@muteButton") {
                    it("not selected") {
                        setupScreen(atName: "@archer", relationshipPriority: .Following)
                        muteButton.sendActionsForControlEvents(UIControlEvents.TouchUpInside)
                        expect(controller.relationshipPriority).to(equal(RelationshipPriority.Mute))
                    }

                    it("selected") {
                        setupScreen(atName: "@archer", relationshipPriority: .Mute)
                        muteButton.sendActionsForControlEvents(UIControlEvents.TouchUpInside)
                        expect(controller.relationshipPriority).to(equal(RelationshipPriority.Inactive))
                    }
                }

                describe("@blockButton") {
                    it("not selected") {
                        setupScreen(atName: "@archer", relationshipPriority: .Following)
                        blockButton.sendActionsForControlEvents(UIControlEvents.TouchUpInside)
                        expect(controller.relationshipPriority).to(equal(RelationshipPriority.Block))
                    }

                    it("selected") {
                        setupScreen(atName: "@archer", relationshipPriority: .Block)
                        blockButton.sendActionsForControlEvents(UIControlEvents.TouchUpInside)
                        expect(controller.relationshipPriority).to(equal(RelationshipPriority.Inactive))
                    }
                }

                describe("@flagButton") {
                    it("triggers") {
                        flagButton.sendActionsForControlEvents(UIControlEvents.TouchUpInside)
                        expect(controller.calledFlagTapped) == true
                    }
                }
            }
        }
    }
}
