////
///  HireScreenSpec.swift
//

@testable import Ello
import Quick
import Nimble


class HireScreenSpec: QuickSpec {
    override func spec() {
        describe("HireScreen") {
            describe("snapshots, keyboard hidden") {
                var subject: HireScreen!
                beforeEach {
                    subject = HireScreen(navigationItem: UINavigationItem())
                }
                validateAllSnapshots({ return subject })
            }
            describe("snapshots, keyboard shown") {
                var subject: HireScreen!
                beforeEach {
                    subject = HireScreen(navigationItem: UINavigationItem())
                    Keyboard.shared.active = true
                    Keyboard.shared.bottomInset = 216
                    subject.toggleKeyboard(visible: true)
                }
                it("should have a valid snapshot") {
                    expectValidSnapshot(subject, device: .Phone6_Portrait)
                }

                describe("submit button enabled") {
                    beforeEach {
                        let textView: UITextView! = subviewThatMatches(subject) { $0 is UITextView }
                        textView.text = "has text"
                        subject.textViewDidChange(textView)
                    }
                    it("should have a valid snapshot") {
                        expectValidSnapshot(subject, device: .Phone6_Portrait)
                    }
                }
            }
            context("text is empty") {
                var subject: HireScreen!
                var submitButton: UIButton?
                beforeEach {
                    subject = HireScreen(navigationItem: UINavigationItem())
                    submitButton = subviewThatMatches(subject) { $0 is UIButton }
                    let textView: UITextView! = subviewThatMatches(subject) { $0 is UITextView }
                    textView.text = ""
                    subject.textViewDidChange(textView)
                }
                it("submitButton is disabled") {
                    expect(submitButton?.enabled) == false
                }
            }
            context("text set") {
                var subject: HireScreen!
                var submitButton: UIButton?
                beforeEach {
                    subject = HireScreen(navigationItem: UINavigationItem())
                    submitButton = subviewThatMatches(subject) { $0 is UIButton }
                    let textView: UITextView! = subviewThatMatches(subject) { $0 is UITextView }
                    textView.text = "hey there!"
                    subject.textViewDidChange(textView)
                }
                it("submitButton is enabled") {
                    expect(submitButton?.enabled) == true
                }
            }
        }
    }
}
