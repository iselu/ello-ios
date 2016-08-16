////
///  AvatarButtonSpec.swift
//

@testable import Ello
import Quick
import Nimble


class AvatarButtonSpec: QuickSpec {
    override func spec() {
        describe("AvatarButton") {
            context("When size is 30x30") {
                it("should have correct starIcon sizes") {
                    let subject = AvatarButton()
                    subject.frame.size = CGSize(width: 30, height: 30)
                    subject.layoutIfNeeded()
                    expect(subject.starIcon.frame.size) == CGSize(width: 7.5, height: 7.5)
                }
            }
            context("When size is 60x60") {
                it("should have correct starIcon sizes") {
                    let subject = AvatarButton()
                    subject.frame.size = CGSize(width: 60, height: 60)
                    subject.layoutIfNeeded()
                    expect(subject.starIcon.frame.size) == CGSize(width: 15, height: 15)
                }
            }
            context("assigning user") {
                var subject: AvatarButton!
                var user: User!
                let url = NSURL(string: "http://www.example.com/image")!

                beforeEach {
                    subject = AvatarButton()
                    user = User.empty()
                }

                it("should assign the asset url") {
                    let asset = Asset(url: url)
                    user.avatar = asset
                    subject.setUser(user)
                }

                it("should assign the asset large url") {
                    let asset = Asset(id: NSUUID().UUIDString)
                    let attachment = Attachment(url: url)
                    asset.large = attachment
                    user.avatar = asset
                    subject.setUser(user)
                }

                it("should assign the asset optimized url") {
                    let asset = Asset(id: NSUUID().UUIDString)
                    let attachment = Attachment(url: url)
                    asset.optimized = attachment
                    user.avatar = asset
                    subject.setUser(user)
                }

            }
        }
    }
}
