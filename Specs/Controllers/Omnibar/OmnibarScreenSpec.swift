////
///  OmnibarScreenSpec.swift
//

@testable import Ello
import Quick
import Nimble


class OmnibarScreenMockDelegate : OmnibarScreenDelegate {
    var didGoBack = false
    var didPresentController = false
    var didDismissController = false
    var didPushController = false
    var submitted = false
    var hasBuyButtonURL = false

    func omnibarCancel() {
        didGoBack = true
    }
    func omnibarPushController(controller: UIViewController) {
        didPushController = true
    }
    func omnibarPresentController(controller : UIViewController) {
        didPresentController = true
    }
    func omnibarDismissController() {
        didDismissController = true
    }
    func omnibarSubmitted(regions: [OmnibarRegion], buyButtonURL: NSURL?) {
        submitted = true
        hasBuyButtonURL = buyButtonURL != nil
    }
}


enum RegionExpectation {
    case Text(String)
    case Image
    case Spacer

    func matches(region: OmnibarRegion) -> Bool {
        switch (self, region) {
        case (.Text, .AttributedText):
            if case let .Text(text) = self {
                return region.text!.string == text
            }
            return false
        case (.Image, .Image): return true
        case (.Image, .ImageData): return true
        case (.Spacer, .Spacer): return true
        default: return false
        }
    }
}


class OmnibarScreenSpec: QuickSpec {
    override func spec() {
        var subject : OmnibarScreen!
        var delegate : OmnibarScreenMockDelegate!

        beforeEach {
            let controller = UIViewController()
            subject = OmnibarScreen(frame: UIScreen.mainScreen().bounds)
            delegate = OmnibarScreenMockDelegate()
            subject.delegate = delegate
            controller.view.addSubview(subject)

            showController(controller)
        }

        describe("OmnibarScreen") {
            it("should use the '.Twitter' keyboard") {
                expect(subject.textView.keyboardType) == UIKeyboardType.Twitter
            }

            describe("tapping the avatar") {
                it("should push the profile VC on to the navigation controller") {
                    subject.currentUser = User.stub(["id": "1"])
                    subject.profileImageTapped()
                    expect(delegate.didPushController) == true
                }
            }

            describe("pressing add image") {
                beforeEach {
                    subject.addImageAction()
                }
                it("should open an image selector") {
                    expect(delegate.didPresentController) == true
                }
            }

            describe("OmnibarScreenProtocol methods") {
                context("var delegate: OmnibarScreenDelegate?") {
                    it("sets the delegate") {
                        subject.delegate = delegate
                        expect(ObjectIdentifier(subject.delegate ?? "")) == ObjectIdentifier(delegate)
                    }
                }
                context("var title: String") {
                    it("sets the navigation title") {
                        subject.title = "title"
                        expect(subject.navigationItem.title) == "title"
                    }
                }
                context("var submitTitle: String") {
                    it("sets the button title") {
                        subject.submitTitle = "post here"
                        expect(subject.tabbarSubmitButton.titleForState(.Normal)) == "post here"
                        expect(subject.keyboardSubmitButton.titleForState(.Normal)) == "post here"
                    }
                }
                context("var isComment: Bool") {
                    context("when false") {
                        beforeEach {
                            subject.isComment = false
                        }
                        it("should show the buyButton") {
                            expect(subject.buyButton.hidden) == false
                        }
                    }
                    context("when true") {
                        beforeEach {
                            subject.isComment = true
                        }
                        it("should hide the buyButton") {
                            expect(subject.buyButton.hidden) == true
                        }
                    }
                }
                context("var avatarURL: NSURL?") {
                    it("should set the button image (to nil)") {
                        let image = UIImage()
                        subject.avatarButton.setImage(image, forState: .Normal)
                        subject.avatarURL = NSURL(string: "http://www.example1.com")!
                        subject.avatarURL = nil  // value needs to *change* for this to work
                        expect(subject.avatarButton.imageForState(.Normal)).to(beNil())
                    }
                }
                context("var avatarImage: UIImage?") {
                    it("should set the button image") {
                        let image = UIImage()
                        subject.avatarImage = image
                        expect(subject.avatarButton.imageForState(.Normal)) == image
                    }
                }
                context("var currentUser: User?") {
                    it("should set the user") {
                        subject.currentUser = User.stub(["id": "12345"])
                        expect(subject.currentUser?.id) == "12345"
                    }
                }
                context("var canGoBack: Bool") {
                    context("when true") {
                        it("should show the navigationBar") {
                            subject.canGoBack = true
                            subject.layoutIfNeeded()
                            expect(subject.navigationBar.frame.height) > 0
                        }
                        it("should position the avatarButton and toolbarButtonViews") {
                            subject.canGoBack = false
                            subject.layoutIfNeeded()
                            let toolbarY = subject.toolbarButtonViews[0].frame.minY
                            let avatarY = subject.avatarButton.frame.minY

                            subject.canGoBack = true
                            subject.layoutIfNeeded()
                            expect(subject.avatarButton.frame.minY) > avatarY
                            for button in subject.toolbarButtonViews {
                                expect(button.frame.minY) > toolbarY
                            }
                        }
                    }
                    context("when false") {
                        it("should hide the navigationBar") {
                            subject.canGoBack = false
                            subject.layoutIfNeeded()
                            expect(subject.navigationBar.frame.height) <= 0
                        }
                        it("should position the avatarButton and toolbarButtonViews") {
                            subject.canGoBack = true
                            subject.layoutIfNeeded()
                            let toolbarY = subject.toolbarButtonViews[0].frame.minY
                            let avatarY = subject.avatarButton.frame.minY

                            subject.canGoBack = false
                            subject.layoutIfNeeded()
                            expect(subject.avatarButton.frame.minY) < avatarY
                            for button in subject.toolbarButtonViews {
                                expect(button.frame.minY) < toolbarY
                            }
                        }
                    }
                }
                context("var isEditing: Bool") {
                    context("when false") {
                        it("causes 'x' button to delete") {
                            subject.isEditing = false
                            subject.regions = [.Text("foo")]
                            expect(subject.canPost()) == true
                            subject.cancelEditingAction()
                            expect(delegate.didPresentController) == true
                            expect(delegate.didGoBack) == false
                        }
                    }
                    context("when true") {
                        it("causes 'x' button to cancel (when true)") {
                            subject.isEditing = true
                            subject.regions = [.Text("foo")]
                            expect(subject.canPost()) == true
                            subject.cancelEditingAction()
                            expect(delegate.didPresentController) == false
                            expect(delegate.didGoBack) == true
                        }
                    }
                }
                context("func reportError(title: String, error: NSError)") {
                    context("when passing an NSError") {
                        it("should reportError") {
                            subject.reportError("foo", error: NSError(domain: ElloErrorDomain, code: 0, userInfo: [NSLocalizedFailureReasonErrorKey: "failure"]))
                            expect(delegate.didPresentController) == true
                        }
                    }
                }
                context("func reportError(title: String, errorMessage: String)") {
                    context("when passing a String") {
                        it("should reportError") {
                            subject.reportError("foo", errorMessage: "bar")
                            expect(delegate.didPresentController) == true
                        }
                    }
                }
                context("func startEditing()") {
                    context("if the only region is text") {
                        it("should set the currentTextPath.row to 0") {
                            subject.currentTextPath = nil
                            subject.regions = [.Text("")]
                            subject.startEditing()
                            expect(subject.currentTextPath?.row) == 0
                        }
                    }
                    context("if the first region is an image") {
                        it("should set the currentTextPath.row to 2") {
                            subject.currentTextPath = nil
                            subject.regions = [.Image(UIImage()), .Text("")]
                            subject.startEditing()
                            expect(subject.currentTextPath?.row) == 2  // image, spacer, text
                        }
                    }
                    context("if the only region is text and image") {
                        it("should not set the currentTextPath") {
                            subject.currentTextPath = nil
                            subject.regions = [.Text(""), .Image(UIImage())]
                            subject.startEditing()
                            expect(subject.currentTextPath?.row) == 0  // text, spacer, image, spacer, text
                        }
                    }
                }
                context("func startEditingLast()") {
                    context("if the only region is text") {
                        it("should set the currentTextPath.row to 0") {
                            subject.currentTextPath = nil
                            subject.regions = [.Text("")]
                            subject.startEditingLast()
                            expect(subject.currentTextPath?.row) == 0
                        }
                    }
                    context("if the first region is an image") {
                        it("should set the currentTextPath.row to 2") {
                            subject.currentTextPath = nil
                            subject.regions = [.Image(UIImage()), .Text("")]
                            subject.startEditingLast()
                            expect(subject.currentTextPath?.row) == 2  // image, spacer, text
                        }
                    }
                    context("if the only region is text and image") {
                        it("should not set the currentTextPath") {
                            subject.currentTextPath = nil
                            subject.regions = [.Text(""), .Image(UIImage())]
                            subject.startEditingLast()
                            expect(subject.currentTextPath?.row) == 4  // text, image, spacer, text
                        }
                    }
                }
                context("func startEditingAtPath()") {
                    it("should set the currentTextPath") {
                        subject.currentTextPath = nil
                        subject.regions = [.Image(UIImage()), .Text("")]
                        subject.startEditingAtPath(NSIndexPath(forRow: 2, inSection: 0))
                        expect(subject.currentTextPath?.row) == 2
                    }
                    it("should not set the currentTextPath") {
                        subject.currentTextPath = nil
                        subject.regions = [.Image(UIImage()), .Text("")]
                        subject.startEditingAtPath(NSIndexPath(forRow: 1, inSection: 0))
                        expect(subject.currentTextPath).to(beNil())
                    }
                }
                context("func stopEditing()") {
                    it("should set the currentTextPath to nil") {
                        subject.regions = [.Text("")]
                        subject.startEditing()
                        expect(subject.currentTextPath?.row).notTo(beNil())
                        subject.stopEditing()
                        expect(subject.currentTextPath?.row).to(beNil())
                    }
                    it("should remove empty regions") {
                        subject.regions = [.Text(""), .Image(UIImage()), .Text("")]
                        subject.startEditing()
                        subject.stopEditing()
                        expect(subject.regions.count) == 2
                        expect(RegionExpectation.Image.matches(subject.regions[0])) == true
                        expect(RegionExpectation.Text("").matches(subject.regions[1])) == true
                    }
                }
                context("func updateButtons()") {
                    context("if posts are empty") {
                        beforeEach {
                            subject.regions = [OmnibarRegion]()
                            expect(subject.canPost()) == false
                            subject.updateButtons()
                        }
                        it("should disable posting") {
                            expect(subject.keyboardSubmitButton.enabled) == false
                            expect(subject.tabbarSubmitButton.enabled) == false
                        }
                        it("should disable buyButton") {
                            expect(subject.buyButton.enabled) == false
                        }
                    }
                    context("if posts have text") {
                        beforeEach {
                            subject.regions = [.Text("test")]
                            subject.updateButtons()
                        }
                        it("should enable posting") {
                            expect(subject.keyboardSubmitButton.enabled) == true
                            expect(subject.tabbarSubmitButton.enabled) == true
                        }
                        it("should disable buyButton") {
                            expect(subject.buyButton.enabled) == false
                        }
                    }
                    context("if posts have text and images") {
                        beforeEach {
                            subject.regions = [.Text("test"), .Image(UIImage())]
                            subject.updateButtons()
                        }
                        it("should enable posting") {
                            expect(subject.keyboardSubmitButton.enabled) == true
                            expect(subject.tabbarSubmitButton.enabled) == true
                        }
                        it("should enable buyButton") {
                            expect(subject.buyButton.enabled) == true
                        }
                    }
                    context("if reordering and posts have text") {
                        beforeEach {
                            subject.regions = [.Text("test")]
                            subject.reorderingTable(true)
                            subject.updateButtons()
                        }
                        it("should disable posting") {
                            expect(subject.keyboardSubmitButton.enabled) == false
                            expect(subject.tabbarSubmitButton.enabled) == false
                        }
                        it("should enable cancelling") {
                            expect(subject.cancelButton.enabled) == true
                        }
                        it("should disable buyButton button") {
                            expect(subject.buyButton.enabled) == false
                        }
                    }
                    context("if reordering and posts have text and images") {
                        beforeEach {
                            subject.regions = [.Text("test"), .Image(UIImage())]
                            subject.reorderingTable(true)
                            subject.updateButtons()
                        }
                        it("should disable posting") {
                            expect(subject.keyboardSubmitButton.enabled) == false
                            expect(subject.tabbarSubmitButton.enabled) == false
                        }
                        it("should enable cancelling") {
                            expect(subject.cancelButton.enabled) == true
                        }
                        it("should disable buyButton button") {
                            expect(subject.buyButton.enabled) == false
                        }
                    }
                    context("if not reordering") {
                        beforeEach {
                            subject.regions = [.Text("test")]
                            subject.reorderingTable(false)
                            subject.updateButtons()
                        }
                        it("should enable cancelling") {
                            expect(subject.cancelButton.enabled) == true
                        }
                    }
                }
                describe("var regions: [OmnibarRegion]") {
                    context("setting to empty array") {
                        it("should set it to one text region") {
                            subject.regions = [OmnibarRegion]()
                            expect(subject.regions.count) == 1
                            expect(subject.regions[0].isText) == true
                            expect(subject.regions[0].empty) == true
                        }
                        it("should disable buyButton") {
                            expect(subject.buyButton.enabled) == false
                        }
                    }
                    context("setting to one text region array") {
                        beforeEach {
                            subject.regions = [.Text("testing")]
                        }
                        it("should set it to one text region") {
                            expect(subject.regions.count) == 1
                            expect(subject.regions[0].isText) == true
                            expect(subject.regions[0].empty) == false
                        }
                        it("should disable buyButton") {
                            expect(subject.buyButton.enabled) == false
                        }
                    }
                    context("setting to one image region") {
                        beforeEach {
                            subject.regions = [.Image(UIImage())]
                        }
                        it("generates a text region") {
                            expect(subject.regions.count) == 2
                            expect(subject.regions[0].isImage) == true
                            expect(subject.regions[1].isText) == true
                            expect(subject.regions[1].text?.string) == ""
                        }
                        it("should enable buyButton") {
                            expect(subject.buyButton.enabled) == true
                        }
                    }
                }
            }

            describe("generating editableRegions") {
                let expectationRules: [(String, [OmnibarRegion], [RegionExpectation])] = [
                    ("zero", [OmnibarRegion](), [.Text("")]),
                    ("empty", [.Text("")], [.Text("")]),
                    ("text", [.Text("some")], [.Text("some")]),
                    ("image", [.Image(UIImage())], [.Image, .Spacer, .Text("")]),
                    ("image,text", [.Image(UIImage()), .Text("some")], [.Image, .Spacer, .Text("some")]),
                    ("text,image", [.Text("some"), .Image(UIImage())], [.Text("some"), .Spacer, .Image, .Spacer, .Text("")]),
                    ("text,image,text", [.Text("some"), .Image(UIImage()), .Text("more")], [.Text("some"), .Spacer, .Image, .Spacer, .Text("more")]),
                    ("text,image,image", [.Text("some"), .Image(UIImage()), .Image(UIImage())], [.Text("some"), .Spacer, .Image, .Spacer, .Image, .Spacer, .Text("")]),
                    ("text,image,image,text", [.Text("some"), .Image(UIImage()), .Image(UIImage()), .Text("")], [.Text("some"), .Spacer, .Image, .Spacer, .Image, .Spacer, .Text("")]),
                    ("image,text,image", [.Image(UIImage()), .Text("some"), .Image(UIImage())], [.Image, .Spacer, .Text("some"), .Spacer, .Image, .Spacer, .Text("")]),
                    ("text,image,image,image,text,image,image",
                        [.Text("some"), .Image(UIImage()), .Image(UIImage()), .Image(UIImage()), .Text("text"), .Image(UIImage()), .Image(UIImage())],
                        [.Text("some"), .Spacer, .Image, .Spacer, .Image, .Spacer, .Image, .Spacer, .Text("text"), .Spacer, .Image, .Spacer, .Image, .Spacer, .Text("")]
                    ),
                ]
                for (name, regions, expectations) in expectationRules {
                    it("should correctly generate for \(name) conditions") {
                        subject.regions = regions

                        let editableRegions = subject.editableRegions
                        expect(editableRegions.count) == expectations.count
                        for (index, expectation) in expectations.enumerate() {
                            let (_, region) = editableRegions[index]
                            expect(expectation.matches(region)) == true
                        }
                    }
                }
            }

            describe("generating reorderableRegions") {
                let expectationRules: [(String, [OmnibarRegion], [RegionExpectation])] = [
                    ("empty", [.Text("")],[RegionExpectation]()),
                    ("text", [.Text("some")],[.Text("some")]),
                    ("text with newlines", [.Text("some\ntext")],[.Text("some\ntext")]),
                    ("image,empty", [.Image(UIImage()), .Text("")],[.Image]),
                    ("image,text", [.Image(UIImage()), .Text("some")],[.Image,.Text("some")]),
                    ("text,image,empty", [.Text("some"), .Image(UIImage()),.Text("")],[.Text("some"),.Image]),
                    ("text,image,text", [.Text("some"), .Image(UIImage()),.Text("text")],[.Text("some"),.Image,.Text("text")]),
                    ("text with newlines,image,text", [.Text("some\n\ntext"), .Image(UIImage()), .Text("more")],[.Text("some\n\ntext"),.Image,.Text("more")]),
                    ("text,image,image,empty", [.Text("some"), .Image(UIImage()), .Image(UIImage()), .Text("")],[.Text("some"),.Image,.Image]),
                    ("text,image,image,text", [.Text("some"), .Image(UIImage()), .Image(UIImage()), .Text("more")],[.Text("some"),.Image,.Image,.Text("more")]),
                    ("text,image,image,text w newlines", [.Text("some"), .Image(UIImage()), .Image(UIImage()), .Text("more\nlines")],[.Text("some"),.Image,.Image,.Text("more\nlines")]),
                    ("image,text,image,empty", [.Image(UIImage()), .Text("some"), .Image(UIImage()), .Text("")],[.Image,.Text("some"),.Image]),
                    ("image,text,image,text", [.Image(UIImage()), .Text("some"), .Image(UIImage()), .Text("text")],[.Image,.Text("some"),.Image,.Text("text")]),
                    ("text,image,image,image,text,image,text",
                        [.Text("some"), .Image(UIImage()), .Image(UIImage()), .Image(UIImage()), .Text("text"), .Image(UIImage()), .Image(UIImage()),.Text("some")],
                        [.Text("some"), .Image, .Image, .Image, .Text("text"), .Image, .Image, .Text("some")]
                    ),
                ]
                for (name, regions, expectations) in expectationRules {
                    it("should correctly generate for \(name) conditions") {
                        subject.regions = regions

                        subject.reorderingTable(true)
                        let editableRegions = subject.reorderableRegions
                        expect(editableRegions.count) == expectations.count
                        for (index, expectation) in expectations.enumerate() {
                            let (_, region) = editableRegions[index]
                            expect(expectation.matches(region)) == true
                        }
                    }
                }
            }

            describe("generating editableRegions") {
                let expectationRules: [(String, [OmnibarRegion], [RegionExpectation])] = [
                    ("empty", [OmnibarRegion](),[.Text("")]),
                    ("text", [.Text("some")],[.Text("some")]),
                    ("text,text", [.Text("some\ntext")],[.Text("some\ntext")]),
                    ("image,empty", [.Image(UIImage())],[.Image, .Spacer, .Text("")]),
                    ("image,text", [.Image(UIImage()),.Text("some")],[.Image, .Spacer, .Text("some")]),
                    ("text,image,empty", [.Text("some"),.Image(UIImage())],[.Text("some"), .Spacer, .Image, .Spacer,.Text("")]),
                    ("text with newlines,image,text", [.Text("some\n\ntext"),.Image(UIImage()),.Text("more")],[.Text("some\n\ntext"), .Spacer, .Image, .Spacer, .Text("more")]),
                    ("text,image,image,empty", [.Text("some"),.Image(UIImage()),.Image(UIImage())],[.Text("some"), .Spacer, .Image, .Spacer, .Image, .Spacer, .Text("")]),
                    ("text,image,image,text", [.Text("some"),.Image(UIImage()),.Image(UIImage()),.Text("more\nlines")],[.Text("some"), .Spacer, .Image, .Spacer, .Image, .Spacer, .Text("more\nlines")]),
                    ("image,text,image,empty", [.Image(UIImage()),.Text("some"),.Image(UIImage())],[.Image, .Spacer, .Text("some"), .Spacer, .Image, .Spacer, .Text("")]),
                    ("text,image,image,image,text,image,text",
                        [.Text("some"), .Image(UIImage()), .Image(UIImage()), .Image(UIImage()), .Text("text"), .Image(UIImage()), .Image(UIImage()), .Text("some")],
                        [.Text("some"), .Spacer, .Image, .Spacer, .Image, .Spacer, .Image, .Spacer, .Text("text"), .Spacer, .Image, .Spacer, .Image, .Spacer, .Text("some")]
                    ),
                ]
                for (name, regions, expectations) in expectationRules {
                    it("should correctly generate for \(name) conditions") {
                        subject.reorderableRegions = regions.map { (nil, $0) }

                        subject.reorderingTable(false)
                        let editableRegions = subject.editableRegions
                        expect(editableRegions.count) == expectations.count
                        for (index, expectation) in expectations.enumerate() {
                            let (_, region) = editableRegions[index]
                            expect(expectation.matches(region)) == true
                        }
                    }
                }
            }

            describe("deletable regions") {
                let expectations: [(String, OmnibarRegion, Bool)] = [
                    ("empty", .Text(""), false),
                    ("text", .Text("text"), true),
                    ("spacer", .Spacer, false),
                    ("image", .Image(UIImage()), true),
                ]
                for (name, region, expected) in expectations {
                    it("\(name) should \(expected ? "be" : "not be") editable") {
                        expect(region.editable) == expected
                    }
                }
            }

            describe("deleting regions") {
                let expectationRules: [(String, [OmnibarRegion], NSIndexPath, [RegionExpectation])] = [
                    ("text", [.Text("some")], NSIndexPath(forRow: 0, inSection: 0),                               [.Text("")]),
                    ("image", [.Image(UIImage())], NSIndexPath(forRow: 0, inSection: 0),                 [.Text("")]),
                    ("image,text(0)", [.Image(UIImage()), .Text("some")], NSIndexPath(forRow: 0, inSection: 0),  [.Text("some")]),
                    ("image,text(1)", [.Image(UIImage()), .Text("some")], NSIndexPath(forRow: 2, inSection: 0),  [.Image, .Spacer, .Text("")]),
                    ("text,image(0)", [.Text("some"), .Image(UIImage())], NSIndexPath(forRow: 0, inSection: 0),  [.Image, .Spacer, .Text("")]),
                    ("text,image(1)", [.Text("some"), .Image(UIImage())], NSIndexPath(forRow: 2, inSection: 0),  [.Text("some")]),
                    ("text,image,text(0)", [.Text("some"), .Image(UIImage()), .Text("more")],NSIndexPath(forRow: 0, inSection: 0), [.Image, .Spacer, .Text("more")]),
                    ("text,image,text(1a)", [.Text("some"), .Image(UIImage()), .Text("more")],NSIndexPath(forRow: 2, inSection: 0), [.Text("some\n\nmore")]),
                    ("text,image,text(1b)", [.Text("some\n"), .Image(UIImage()), .Text("more")],NSIndexPath(forRow: 2, inSection: 0), [.Text("some\n\nmore")]),
                    ("text,image,text(1c)", [.Text("some\n\n"), .Image(UIImage()), .Text("more")],NSIndexPath(forRow: 2, inSection: 0), [.Text("some\n\nmore")]),
                    ("text,image,text(1d)", [.Text("some\n\n\n"), .Image(UIImage()), .Text("more")],NSIndexPath(forRow: 2, inSection: 0), [.Text("some\n\n\nmore")]),
                    ("text,image,text(2)", [.Text("some"), .Image(UIImage()), .Text("more")], NSIndexPath(forRow: 4, inSection: 0), [.Text("some"), .Spacer, .Image, .Spacer, .Text("")]),
                    ("text,image,image(0)", [.Text("some"), .Image(UIImage()), .Image(UIImage())], NSIndexPath(forRow: 0, inSection: 0), [.Image, .Spacer, .Image, .Spacer, .Text("")]),
                    ("text,image,image(1)", [.Text("some"), .Image(UIImage()), .Image(UIImage())], NSIndexPath(forRow: 2, inSection: 0), [.Text("some"), .Spacer, .Image, .Spacer, .Text("")]),
                    ("text,image,image(2)", [.Text("some"), .Image(UIImage()), .Image(UIImage())], NSIndexPath(forRow: 4, inSection: 0), [.Text("some"), .Spacer, .Image, .Spacer, .Text("")]),
                    ("text,image,image,text(0)", [.Text("some"), .Image(UIImage()), .Image(UIImage()), .Text("text")], NSIndexPath(forRow: 0, inSection: 0), [.Image, .Spacer, .Image, .Spacer, .Text("text")]),
                    ("text,image,image,text(1)", [.Text("some"), .Image(UIImage()), .Image(UIImage()), .Text("text")], NSIndexPath(forRow: 2, inSection: 0), [.Text("some"), .Spacer, .Image, .Spacer, .Text("text")]),
                    ("text,image,image,text(2)", [.Text("some"), .Image(UIImage()), .Image(UIImage()), .Text("text")], NSIndexPath(forRow: 4, inSection: 0), [.Text("some"), .Spacer, .Image, .Spacer, .Text("text")]),
                    ("text,image,image,text(3)", [.Text("some"), .Image(UIImage()), .Image(UIImage()), .Text("text")], NSIndexPath(forRow: 6, inSection: 0), [.Text("some"), .Spacer, .Image, .Spacer, .Image, .Spacer, .Text("")]),
                    ("image,text,image(0)", [.Image(UIImage()), .Text("some"), .Image(UIImage())], NSIndexPath(forRow: 0, inSection: 0), [.Text("some"), .Spacer, .Image, .Spacer, .Text("")]),
                    ("image,text,image(1)", [.Image(UIImage()), .Text("some"), .Image(UIImage())], NSIndexPath(forRow: 2, inSection: 0), [.Image, .Spacer, .Image, .Spacer, .Text("")]),
                    ("image,text,image(2)", [.Image(UIImage()), .Text("some"), .Image(UIImage())], NSIndexPath(forRow: 4, inSection: 0), [.Image, .Spacer, .Text("some")]),
                    ("text,image,image,image,text,image,image(0)",
                        [.Text("some"), .Image(UIImage()), .Image(UIImage()), .Image(UIImage()), .Text("text"), .Image(UIImage()), .Image(UIImage())],
                        NSIndexPath(forRow: 0, inSection: 0),
                        [.Image, .Spacer, .Image, .Spacer, .Image, .Spacer, .Text("text"), .Spacer, .Image, .Spacer, .Image, .Spacer, .Text("")]
                    ),
                    ("text,image,image,image,text,image,image(1)",
                        [.Text("some"), .Image(UIImage()), .Image(UIImage()), .Image(UIImage()), .Text("text"), .Image(UIImage()), .Image(UIImage())],
                        NSIndexPath(forRow: 2, inSection: 0),
                        [.Text("some"), .Spacer, .Image, .Spacer, .Image, .Spacer, .Text("text"), .Spacer, .Image, .Spacer, .Image, .Spacer, .Text("")]
                    ),
                    ("text,image,image,image,text,image,image(2)",
                        [.Text("some"), .Image(UIImage()), .Image(UIImage()), .Image(UIImage()), .Text("text"), .Image(UIImage()), .Image(UIImage())],
                        NSIndexPath(forRow: 4, inSection: 0),
                        [.Text("some"), .Spacer, .Image, .Spacer, .Image, .Spacer, .Text("text"), .Spacer, .Image, .Spacer, .Image, .Spacer, .Text("")]
                    ),
                    ("text,image,image,image,text,image,image(3)",
                        [.Text("some"), .Image(UIImage()), .Image(UIImage()), .Image(UIImage()), .Text("text"), .Image(UIImage()), .Image(UIImage())],
                        NSIndexPath(forRow: 6, inSection: 0),
                        [.Text("some"), .Spacer, .Image, .Spacer, .Image, .Spacer, .Text("text"), .Spacer, .Image, .Spacer, .Image, .Spacer, .Text("")]
                    ),
                    ("text,image,image,image,text,image,image(4)",
                        [.Text("some"), .Image(UIImage()), .Image(UIImage()), .Image(UIImage()), .Text("text"), .Image(UIImage()), .Image(UIImage())],
                        NSIndexPath(forRow: 8, inSection: 0),
                        [.Text("some"), .Spacer, .Image, .Spacer, .Image, .Spacer, .Image, .Spacer, .Image, .Spacer, .Image, .Spacer, .Text("")]
                    ),
                    ("text,image,image,image,text,image,image(5)",
                        [.Text("some"), .Image(UIImage()), .Image(UIImage()), .Image(UIImage()), .Text("text"), .Image(UIImage()), .Image(UIImage())],
                        NSIndexPath(forRow: 10, inSection: 0),
                        [.Text("some"), .Spacer, .Image, .Spacer, .Image, .Spacer, .Image, .Spacer, .Text("text"), .Spacer, .Image, .Spacer, .Text("")]
                    ),
                    ("text,image,image,image,text,image,image(6)",
                        [.Text("some"), .Image(UIImage()), .Image(UIImage()), .Image(UIImage()), .Text("text"), .Image(UIImage()), .Image(UIImage())],
                        NSIndexPath(forRow: 12, inSection: 0),
                        [.Text("some"), .Spacer, .Image, .Spacer, .Image, .Spacer, .Image, .Spacer, .Text("text"), .Spacer, .Image, .Spacer, .Text("")]
                    ),
                ]
                for (name, regions, path, expectations) in expectationRules {
                    it("should correctly delete for \(name) at row \(path.row)") {
                        subject.regions = regions

                        if subject.tableView(UITableView(), canEditRowAtIndexPath: path) {
                            subject.deleteEditableAtIndexPath(path)
                            let editableRegions = subject.editableRegions
                            expect(editableRegions.count) == expectations.count
                            for (index, expectation) in expectations.enumerate() {
                                let (_, region) = editableRegions[index]
                                expect(expectation.matches(region)) == true
                            }
                        }
                        else {
                            fail("cannot edit at index path \(path)")
                        }
                    }
                }
            }

            describe("reordering regions") {
                let expectationRules: [(String, [OmnibarRegion], (NSIndexPath, NSIndexPath), [RegionExpectation])] = [
                    ("image,text(0)",
                        [.Image(UIImage()), .Text("some")],
                        (NSIndexPath(forRow: 0, inSection: 0), NSIndexPath(forRow: 1, inSection: 0)),
                        [.Text("some"),.Spacer,.Image,.Spacer,.Text("")]
                    ),
                    ("image,text(1)",
                        [.Image(UIImage()), .Text("some")],
                        (NSIndexPath(forRow: 1, inSection: 0), NSIndexPath(forRow: 0, inSection: 0)),
                        [.Text("some"),.Spacer,.Image,.Spacer,.Text("")]
                    ),

                    ("text,image,text(0)",
                        [.Text("some"),.Spacer,.Image(UIImage()),.Text("text")],
                        (NSIndexPath(forRow: 0, inSection: 0), NSIndexPath(forRow: 1, inSection: 0)),
                        [.Image,.Spacer,.Text("some\n\ntext")]
                    ),
                    ("text,image,text(1)",
                        [.Text("some"),.Spacer,.Image(UIImage()),.Text("text")],
                        (NSIndexPath(forRow: 0, inSection: 0), NSIndexPath(forRow: 2, inSection: 0)),
                        [.Image,.Spacer,.Text("text\n\nsome")]
                    ),
                    ("text,image,text(2)",
                        [.Text("some"),.Spacer,.Image(UIImage()),.Text("text")],
                        (NSIndexPath(forRow: 1, inSection: 0), NSIndexPath(forRow: 0, inSection: 0)),
                        [.Image,.Spacer,.Text("some\n\ntext")]
                    ),
                    ("text,image,text(3)",
                        [.Text("some"),.Spacer,.Image(UIImage()),.Text("text")],
                        (NSIndexPath(forRow: 1, inSection: 0), NSIndexPath(forRow: 2, inSection: 0)),
                        [.Text("some\n\ntext"),.Spacer,.Image,.Spacer,.Text("")]
                    ),
                    ("text,image,text(4)",
                        [.Text("some"),.Image(UIImage()),.Text("text")],
                        (NSIndexPath(forRow: 2, inSection: 0), NSIndexPath(forRow: 0, inSection: 0)),
                        [.Text("text\n\nsome"),.Spacer,.Image,.Spacer,.Text("")]
                    ),
                    ("text,image,text(5)",
                        [.Text("some"),.Image(UIImage()),.Text("text")],
                        (NSIndexPath(forRow: 2, inSection: 0), NSIndexPath(forRow: 1, inSection: 0)),
                        [.Text("some\n\ntext"),.Spacer,.Image,.Spacer,.Text("")]
                    ),

                    ("text with two trailing newlines,image,text",
                        [.Text("some\n\n"),.Image(UIImage()), .Text("more")],
                        (NSIndexPath(forRow: 0, inSection: 0), NSIndexPath(forRow: 1, inSection: 0)),
                        [.Image,.Spacer,.Text("some\n\nmore")]
                    ),
                    ("text with many trailing newlines,image,text",
                        [.Text("some\n\n\n\n"),.Image(UIImage()), .Text("more")],
                        (NSIndexPath(forRow: 0, inSection: 0), NSIndexPath(forRow: 1, inSection: 0)),
                        [.Image,.Spacer,.Text("some\n\n\n\nmore")]
                    ),
                    ("text with one trailing newline,image,text",
                        [.Text("some\n"),.Image(UIImage()), .Text("more")],
                        (NSIndexPath(forRow: 0, inSection: 0), NSIndexPath(forRow: 1, inSection: 0)),
                        [.Image,.Spacer,.Text("some\n\nmore")]
                    ),

                    ("text with newlines,image,text(0)",
                        [.Text("some\n\ntext"),.Image(UIImage()), .Text("more")],
                        (NSIndexPath(forRow: 0, inSection: 0), NSIndexPath(forRow: 1, inSection: 0)),
                        [.Image,.Spacer,.Text("some\n\ntext\n\nmore")]
                    ),
                    ("text with newlines,image,text(1)",
                        [.Text("some\n\ntext"),.Image(UIImage()), .Text("more")],
                        (NSIndexPath(forRow: 0, inSection: 0), NSIndexPath(forRow: 2, inSection: 0)),
                        [.Image,.Spacer,.Text("more\n\nsome\n\ntext")]
                    ),

                    ("text,image,image,empty(0)",
                        [.Text("some"),.Spacer,.Image(UIImage()),.Image(UIImage()), .Text("")],
                        (NSIndexPath(forRow: 0, inSection: 0), NSIndexPath(forRow: 1, inSection: 0)),
                        [.Image,.Spacer,.Text("some"),.Spacer,.Image,.Spacer,.Text("")]
                    ),
                    ("text,image,image,empty(1)",
                        [.Text("some"),.Spacer,.Image(UIImage()),.Image(UIImage()), .Text("")],
                        (NSIndexPath(forRow: 1, inSection: 0), NSIndexPath(forRow: 0, inSection: 0)),
                        [.Image,.Spacer,.Text("some"),.Spacer,.Image,.Spacer,.Text("")]
                    ),
                    ("text,image,image,empty(2)",
                        [.Text("some"),.Spacer,.Image(UIImage()),.Image(UIImage()), .Text("")],
                        (NSIndexPath(forRow: 2, inSection: 0), NSIndexPath(forRow: 0, inSection: 0)),
                        [.Image,.Spacer,.Text("some"),.Spacer,.Image,.Spacer,.Text("")]
                    ),
                    ("text,image,image,empty(3)",
                        [.Text("some"),.Spacer,.Image(UIImage()),.Image(UIImage()), .Text("")],
                        (NSIndexPath(forRow: 0, inSection: 0), NSIndexPath(forRow: 2, inSection: 0)),
                        [.Image,.Spacer,.Image,.Spacer,.Text("some")]
                    ),

                    ("text,image,image,text(0)",
                        [.Text("some"),.Spacer,.Image(UIImage()),.Image(UIImage()), .Text("more")],
                        (NSIndexPath(forRow: 0, inSection: 0), NSIndexPath(forRow: 1, inSection: 0)),
                        [.Image,.Spacer,.Text("some"),.Spacer,.Image,.Spacer,.Text("more")]
                    ),
                    ("text,image,image,text(1)",
                        [.Text("some"),.Spacer,.Image(UIImage()),.Image(UIImage()), .Text("more")],
                        (NSIndexPath(forRow: 0, inSection: 0), NSIndexPath(forRow: 2, inSection: 0)),
                        [.Image,.Spacer,.Image,.Spacer,.Text("some\n\nmore")]
                    ),
                    ("text,image,image,text(2)",
                        [.Text("some"),.Spacer,.Image(UIImage()),.Image(UIImage()), .Text("more")],
                        (NSIndexPath(forRow: 0, inSection: 0), NSIndexPath(forRow: 3, inSection: 0)),
                        [.Image,.Spacer,.Image,.Spacer,.Text("more\n\nsome")]
                    ),
                    ("text,image,image,text(3)",
                        [.Text("some"),.Spacer,.Image(UIImage()),.Image(UIImage()), .Text("more")],
                        (NSIndexPath(forRow: 1, inSection: 0), NSIndexPath(forRow: 0, inSection: 0)),
                        [.Image,.Spacer,.Text("some"),.Spacer,.Image,.Spacer,.Text("more")]
                    ),
                    ("text,image,image,text(4)",
                        [.Text("some"),.Spacer,.Image(UIImage()),.Image(UIImage()), .Text("more")],
                        (NSIndexPath(forRow: 1, inSection: 0), NSIndexPath(forRow: 2, inSection: 0)),
                        [.Text("some"),.Spacer,.Image,.Spacer,.Image,.Spacer,.Text("more")]
                    ),
                    ("text,image,image,text(5)",
                        [.Text("some"),.Spacer,.Image(UIImage()),.Image(UIImage()), .Text("more")],
                        (NSIndexPath(forRow: 1, inSection: 0), NSIndexPath(forRow: 3, inSection: 0)),
                        [.Text("some"),.Spacer,.Image,.Spacer,.Text("more"),.Spacer,.Image,.Spacer,.Text("")]
                    ),

                    ("text,image,image,text w newlines(0)",
                        [.Text("some"),.Spacer,.Image(UIImage()),.Image(UIImage()), .Text("more\nlines")],
                        (NSIndexPath(forRow: 0, inSection: 0), NSIndexPath(forRow: 2, inSection: 0)),
                        [.Image,.Spacer,.Image,.Spacer,.Text("some\n\nmore\nlines")]
                    ),
                    ("text,image,image,text w newlines(1)",
                        [.Text("some"),.Spacer,.Image(UIImage()),.Image(UIImage()), .Text("more\nlines")],
                        (NSIndexPath(forRow: 0, inSection: 0), NSIndexPath(forRow: 3, inSection: 0)),
                        [.Image,.Spacer,.Image,.Spacer,.Text("more\nlines\n\nsome")]
                    ),
                    ("text,image,image,text w newlines(2)",
                        [.Text("some"),.Spacer,.Image(UIImage()),.Image(UIImage()), .Text("more\nlines")],
                        (NSIndexPath(forRow: 2, inSection: 0), NSIndexPath(forRow: 0, inSection: 0)),
                        [.Image,.Spacer,.Text("some"),.Spacer,.Image,.Spacer,.Text("more\nlines")]
                    ),
                    ("text,image,image,text w newlines(3)",
                        [.Text("some"),.Spacer,.Image(UIImage()),.Image(UIImage()), .Text("more\nlines")],
                        (NSIndexPath(forRow: 3, inSection: 0), NSIndexPath(forRow: 0, inSection: 0)),
                        [.Text("more\nlines\n\nsome"),.Spacer,.Image,.Spacer,.Image,.Spacer,.Text("")]
                    ),
                ]
                for (name, regions, reorder, expectations) in expectationRules {
                    describe("for \(name) conditions (from \(reorder.0.row) to \(reorder.1.row))") {
                        beforeEach {
                            let (src, dest) = reorder
                            subject.regions = regions
                            subject.reorderingTable(true)
                            subject.tableView(UITableView(), moveRowAtIndexPath: src, toIndexPath: dest)
                            subject.reorderingTable(false)
                        }
                        it("should correctly reorder") {
                            let editableRegions = subject.editableRegions
                            expect(editableRegions.count) == expectations.count
                            for (index, expectation) in expectations.enumerate() {
                                let (_, region) = editableRegions[index]
                                expect(expectation.matches(region)) == true
                            }
                        }
                    }
                }
            }

            describe("deleting regions while reordering") {
                let expectationRules: [(String, [OmnibarRegion], NSIndexPath, [RegionExpectation])] = [
                    ("text", [.Text("some")], NSIndexPath(forRow: 0, inSection: 0),                               [.Text("")]),
                    ("image", [.Image(UIImage())], NSIndexPath(forRow: 0, inSection: 0),                 [.Text("")]),
                    ("image,text(0)", [.Image(UIImage()), .Text("some")], NSIndexPath(forRow: 0, inSection: 0),  [.Text("some")]),
                    ("image,text(1)", [.Image(UIImage()), .Text("some")], NSIndexPath(forRow: 1, inSection: 0),  [.Image,.Spacer,.Text("")]),
                    ("text,image(0)", [.Text("some"), .Image(UIImage())], NSIndexPath(forRow: 0, inSection: 0),  [.Image,.Spacer,.Text("")]),
                    ("text,image(1)", [.Text("some"), .Image(UIImage())], NSIndexPath(forRow: 1, inSection: 0),  [.Text("some")]),
                    ("text,image,image(0)", [.Text("some"), .Image(UIImage()), .Image(UIImage())], NSIndexPath(forRow: 0, inSection: 0), [.Image,.Spacer,.Image,.Spacer,.Text("")]),
                    ("text,image,image(1)", [.Text("some"), .Image(UIImage()), .Image(UIImage())], NSIndexPath(forRow: 1, inSection: 0), [.Text("some"),.Spacer,.Image,.Spacer,.Text("")]),
                    ("text,image,image(2)", [.Text("some"), .Image(UIImage()), .Image(UIImage())], NSIndexPath(forRow: 2, inSection: 0), [.Text("some"),.Spacer,.Image,.Spacer,.Text("")]),
                ]
                for (name, regions, path, expectations) in expectationRules {
                    describe("for \(name) at row \(path.row)") {
                        let expectedBuyButton = expectations.reduce(false) { return $0 || $1.matches(.Image(UIImage())) }
                        beforeEach {
                            subject.regions = regions
                            subject.reorderingTable(true)
                            subject.deleteReorderableAtIndexPath(path)
                            subject.reorderingTable(false)
                        }
                        it("should correctly delete") {
                            let editableRegions = subject.editableRegions
                            expect(editableRegions.count) == expectations.count
                            for (index, expectation) in expectations.enumerate() {
                                let (_, region) = editableRegions[index]
                                expect(expectation.matches(region)) == true
                            }
                        }

                        it("should set buyButton.enabled to \(expectedBuyButton)") {
                            expect(subject.buyButton.enabled) == expectedBuyButton
                        }
                    }
                }
                it("should end reordering if no more regions") {
                    subject.regions = [.Text("some")]
                    subject.reorderingTable(true)
                    expect(subject.reordering) == true
                    subject.deleteReorderableAtIndexPath(NSIndexPath(forRow: 0, inSection: 0))
                    expect(subject.reordering) == false
                    expect(subject.regions.count) == 1
                    expect(RegionExpectation.Text("").matches(subject.regions[0])) == true
                }
            }

            describe("adding images") {
                let expectationRules: [(String, [OmnibarRegion], [RegionExpectation])] = [
                    ("text", [.Text("some")], [.Text("some"),.Spacer,.Image,.Spacer,.Text("")]),
                    ("image", [.Image(UIImage())], [.Image,.Spacer,.Image,.Spacer,.Text("")]),
                    ("image,text", [.Image(UIImage()), .Text("some")], [.Image,.Spacer,.Text("some"),.Spacer,.Image,.Spacer,.Text("")]),
                    ("text,image", [.Text("some"), .Image(UIImage())], [.Text("some"),.Spacer,.Image,.Spacer,.Image,.Spacer,.Text("")]),
                ]
                for (name, regions, expectations) in expectationRules {
                    describe("for \(name)") {
                        beforeEach {
                            subject.regions = regions
                            subject.addImage(UIImage())
                        }
                        it("should correctly add an image") {
                            let editableRegions = subject.editableRegions
                            expect(editableRegions.count) == expectations.count
                            for (index, expectation) in expectations.enumerate() {
                                let (_, region) = editableRegions[index]
                                expect(expectation.matches(region)) == true
                            }
                        }
                        it("should enable buyButton") {
                            expect(subject.buyButton.enabled) == true
                        }
                    }
                }
            }
        }
    }
}
