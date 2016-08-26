////
///  ProfileViewControllerSpec.swift
//

@testable import Ello
import Moya
import Quick
import Nimble


class ProfileViewControllerSpec: QuickSpec {
    override func spec() {
        beforeEach {
            ElloLinkedStore.sharedInstance.writeConnection.readWriteWithBlock { transaction in
                transaction.removeObjectForKey("42", inCollection: "users")
            }
        }

        describe("ProfileViewController") {
            let currentUser: User = stub([:])

            describe("initialization from storyboard") {
                var subject: ProfileViewController!
                beforeEach {
                    subject = ProfileViewController(userParam: "42")
                    subject.currentUser = currentUser
                }

                it("can be instantiated") {
                    expect(subject).notTo(beNil())
                }

                describe("IBOutlets") {
                    beforeEach {
                        showController(subject)
                    }

                    it("has navigationBar") {
                        expect(subject.navigationBar).toNot(beNil())
                    }
                    it("has whiteSolidView") {
                        expect(subject.whiteSolidView).toNot(beNil())
                    }
                    it("has navigationBarTopConstraint") {
                        expect(subject.navigationBarTopConstraint).toNot(beNil())
                    }
                    it("has coverImage") {
                        expect(subject.coverImage).toNot(beNil())
                    }
                    it("has coverImageHeight") {
                        expect(subject.coverImageHeight).toNot(beNil())
                    }
                }

            }

            describe("contentInset") {
                var subject: ProfileViewController!
                beforeEach {
                    subject = ProfileViewController(userParam: "42")
                    subject.currentUser = currentUser
                    UIApplication.sharedApplication().setStatusBarHidden(true, withAnimation: .None)
                    showController(subject)
                }

                it("does not update the top inset") {
                    expect(subject.streamViewController.contentInset.top) == 0
                }
            }

            context("when displaying the currentUser") {
                var currentUser: User!
                var subject: ProfileViewController!

                beforeEach {
                    currentUser = User.stub(["id": "42"])
                    subject = ProfileViewController(user: currentUser)
                    subject.currentUser = currentUser
                    showController(subject)
                }

                it("does not have a 'more following options' Button") {
                    let rightButtons = subject.elloNavigationItem.rightBarButtonItems
                    expect(rightButtons?.count ?? 0) == 0
                }
                context("user is hireable") {
                    beforeEach {
                        currentUser = User.stub(["id": "42", "isHireable": true])
                        subject = ProfileViewController(user: currentUser)
                        subject.currentUser = currentUser
                        showController(subject)
                    }
                    it("has hidden mentionButton") {
                        expect(subject.mentionButton.hidden) == true
                    }
                    it("has hidden hireButton") {
                        expect(subject.hireButton.hidden) == true
                    }
                }
                context("user is NOT hireable") {
                    beforeEach {
                        currentUser = User.stub(["id": "42", "isHireable": false])
                        subject = ProfileViewController(user: currentUser)
                        subject.currentUser = currentUser
                        showController(subject)
                    }
                    it("has hidden mentionButton") {
                        expect(subject.mentionButton.hidden) == true
                    }
                    it("has hidden hireButton") {
                        expect(subject.hireButton.hidden) == true
                    }
                }
            }

            context("when NOT displaying the currentUser") {
                var currentUser: User!
                var subject: ProfileViewController!

                beforeEach {
                    currentUser = User.stub(["id": "not42"])
                    subject = ProfileViewController(userParam: "42")
                    subject.currentUser = currentUser
                    showController(subject)
                }

                it("has 'share' and 'more following options' buttons") {
                    expect(subject.elloNavigationItem.rightBarButtonItems?.count) == 2
                }

                context("user is hireable") {
                    beforeEach {
                        ElloProvider.sharedProvider = ElloProvider.RecordedStubbingProvider([
                            RecordedResponse(endpoint: .UserStream(userParam: "hireable"), response: .NetworkResponse(200, stubbedData("user_details_hireable"))),
                        ])

                        currentUser = User.stub(["id": "not42"])
                        subject = ProfileViewController(userParam: "hireable")
                        subject.currentUser = currentUser
                        showController(subject)
                    }
                    it("user is hireable") {
                        expect(subject.user?.isHireable) == true
                    }
                    it("has hidden mentionButton") {
                        expect(subject.mentionButton.hidden) == true
                    }
                    it("has visible hireButton") {
                        expect(subject.hireButton.hidden) == false
                    }
                }

                context("user is NOT hireable") {
                    beforeEach {
                        ElloProvider.sharedProvider = ElloProvider.RecordedStubbingProvider([
                            RecordedResponse(endpoint: .UserStream(userParam: "not-hireable"), response: .NetworkResponse(200, stubbedData("user_details_not_hireable"))),
                        ])

                        currentUser = User.stub(["id": "not42"])
                        subject = ProfileViewController(userParam: "not-hireable")
                        subject.currentUser = currentUser
                        showController(subject)
                    }
                    it("user is not hireable") {
                        expect(subject.user?.isHireable) == false
                    }
                    it("has visible mentionButton") {
                        expect(subject.mentionButton.hidden) == false
                    }
                    it("has hidden hireButton") {
                        expect(subject.hireButton.hidden) == true
                    }
                }
            }

            context("when displaying a private user") {
                var currentUser: User!
                var subject: ProfileViewController!

                beforeEach {
                    ElloProvider.sharedProvider = ElloProvider.RecordedStubbingProvider([
                        RecordedResponse(endpoint: .UserStream(userParam: "50"), response: .NetworkResponse(200,
                            stubbedData("profile__no_sharing")
                        )),
                    ])

                    currentUser = User.stub(["id": "not50"])
                    subject = ProfileViewController(userParam: "50")
                    subject.currentUser = currentUser
                    showController(subject)
                }

                it("only has a 'more following options' button") {
                    expect(subject.elloNavigationItem.rightBarButtonItems?.count) == 1
                }
            }

            describe("tapping more button") {
                var user: User!
                var subject: ProfileViewController!

                beforeEach {
                    user = User.stub(["id": "42"])
                    subject = ProfileViewController(userParam: user.id)
                    subject.currentUser = currentUser
                    showController(subject)
                }

                it("launches the block modal") {
                    subject.moreButtonTapped()
                    let presentedVC = subject.presentedViewController
                    expect(presentedVC).notTo(beNil())
                    expect(presentedVC).to(beAKindOf(BlockUserModalViewController))
                }
            }


            context("with successful request") {
                var user: User!
                var subject: ProfileViewController!

                beforeEach {
                    subject = ProfileViewController(userParam: "42")
                    subject.currentUser = currentUser
                    showController(subject)
                    user = subject.user!
                }

                describe("@moreButton") {
                    it("not selected block") {
                        user.relationshipPriority = .Inactive
                        subject.moreButtonTapped()
                        let presentedVC = subject.presentedViewController as! BlockUserModalViewController
                        presentedVC.updateRelationship(.Block)
                        expect(user.relationshipPriority) == RelationshipPriority.Block
                    }

                    it("not selected mute") {
                        user.relationshipPriority = .Inactive
                        subject.moreButtonTapped()
                        let presentedVC = subject.presentedViewController as! BlockUserModalViewController
                        presentedVC.updateRelationship(.Mute)
                        expect(user.relationshipPriority) == RelationshipPriority.Mute
                    }

                    it("selected block") {
                        user.relationshipPriority = .Block
                        subject.moreButtonTapped()
                        let presentedVC = subject.presentedViewController as! BlockUserModalViewController
                        presentedVC.updateRelationship(.Inactive)
                        expect(user.relationshipPriority) == RelationshipPriority.Inactive
                    }

                    it("selected mute") {
                        user.relationshipPriority = .Mute
                        subject.moreButtonTapped()
                        let presentedVC = subject.presentedViewController as! BlockUserModalViewController
                        presentedVC.updateRelationship(.Inactive)
                        expect(user.relationshipPriority) == RelationshipPriority.Inactive
                    }

                }
            }

            context("with failed request") {
                var user: User!
                var subject: ProfileViewController!

                beforeEach {
                    subject = ProfileViewController(userParam: "42")
                    subject.currentUser = currentUser
                    showController(subject)
                    user = subject.user!
                    ElloProvider.sharedProvider = ElloProvider.ErrorStubbingProvider()
                }

                describe("@moreButton") {
                    it("not selected block") {
                        user.relationshipPriority = .Inactive
                        subject.moreButtonTapped()
                        let presentedVC = subject.presentedViewController as! BlockUserModalViewController
                        presentedVC.updateRelationship(.Block)
                        expect(user.relationshipPriority).to(equal(RelationshipPriority.Inactive))
                    }

                    it("not selected mute") {
                        user.relationshipPriority = .Inactive
                        subject.moreButtonTapped()
                        let presentedVC = subject.presentedViewController as! BlockUserModalViewController
                        presentedVC.updateRelationship(.Mute)
                        expect(user.relationshipPriority).to(equal(RelationshipPriority.Inactive))
                    }

                    it("selected block") {
                        user.relationshipPriority = .Block
                        subject.moreButtonTapped()
                        let presentedVC = subject.presentedViewController as! BlockUserModalViewController
                        presentedVC.updateRelationship(.Inactive)
                        expect(user.relationshipPriority).to(equal(RelationshipPriority.Block))
                    }

                    it("selected mute") {
                        user.relationshipPriority = .Mute
                        subject.moreButtonTapped()
                        let presentedVC = subject.presentedViewController as! BlockUserModalViewController
                        presentedVC.updateRelationship(.Inactive)
                        expect(user.relationshipPriority).to(equal(RelationshipPriority.Mute))
                    }
                }
            }

            xcontext("snapshots") {
                var subject: ProfileViewController!
                beforeEach {
                    subject = ProfileViewController(userParam: "42")
                    subject.currentUser = currentUser
                }
                validateAllSnapshots { return subject }
            }

            xcontext("snapshots - currentUser") {
                let user: User = stub([:])
                var subject: ProfileViewController!
                beforeEach {
                    subject = ProfileViewController(user: user)
                    showController(subject)
                    subject.currentUser = user
                    subject.updateUser(user)
                }
                validateAllSnapshots { return subject }
            }
        }
    }
}
