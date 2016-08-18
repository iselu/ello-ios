////
///  CategoryListCellSpec.swift
//

@testable import Ello
import Quick
import Nimble
import Nimble_Snapshots


class CategoryListCellSpec: QuickSpec {
    class Delegate: DiscoverCategoryPickerDelegate {
        var categoryTapped = false
        var endpointPath: String?
        var allCategoriesTapped = false

        func discoverCategoryTapped(endpoint: ElloAPI) {
            categoryTapped = true
            endpointPath = endpoint.path
        }

        func discoverAllCategoriesTapped() {
            allCategoriesTapped = true
        }
    }

    override func spec() {
        describe("CategoryListCell") {
            var subject: CategoryListCell!
            var delegate: Delegate!

            beforeEach {
                delegate = Delegate()
                let frame = CGRect(origin: .zero, size: CGSize(width: 320, height: 66))
                subject = CategoryListCell(frame: frame)
                subject.discoverCategoryPickerDelegate = delegate
                showView(subject)
            }

            describe("actions") {
                it("sends action when tapping on a category") {
                    subject.categoriesInfo = [
                        (title: "Featured", endpoint: .CategoryPosts(slug: "featured"), selected: false),
                        (title: "Art", endpoint: .CategoryPosts(slug: "art"), selected: false),
                    ]
                    let categoryButton: UIButton? = subviewThatMatches(subject) { view in
                        (view as? UIButton)?.currentAttributedTitle?.string == "Featured"
                    }
                    categoryButton?.sendActionsForControlEvents(.TouchUpInside)
                    expect(delegate.categoryTapped) == true
                    expect(delegate.endpointPath) == ElloAPI.CategoryPosts(slug: "featured").path
                }

                it("sends action when tapping 'all' button") {
                    subject.categoriesInfo = [
                        (title: "Featured", endpoint: .CategoryPosts(slug: "featured"), selected: false),
                        (title: "Art", endpoint: .CategoryPosts(slug: "art"), selected: false),
                    ]
                    let allButton: UIButton? = subviewThatMatches(subject) { view in (view as? UIButton)?.currentTitle == InterfaceString.SeeAll }
                    allButton?.sendActionsForControlEvents(.TouchUpInside)
                    expect(delegate.allCategoriesTapped) == true
                }
            }

            it("displays categories") {
                subject.categoriesInfo = [
                    (title: "Featured", endpoint: .CategoryPosts(slug: "featured"), selected: false),
                    (title: "Art", endpoint: .CategoryPosts(slug: "art"), selected: false),
                ]
                subject.layoutIfNeeded()
                expect(subject).to(haveValidSnapshot())
            }

            it("hides categories that are off screen") {
                subject.categoriesInfo = [
                    (title: "Featured", endpoint: .CategoryPosts(slug: "featured"), selected: false),
                    (title: "MMMMMMMM", endpoint: .CategoryPosts(slug: "mmmmmmmm"), selected: false),
                    (title: "iiiiiiii", endpoint: .CategoryPosts(slug: "iiiiiiii"), selected: false),
                    (title: "llllllll", endpoint: .CategoryPosts(slug: "llllllll"), selected: false),
                ]
                subject.layoutIfNeeded()
                expect(subject).to(haveValidSnapshot())
            }

            it("highlights the selected category") {
                subject.categoriesInfo = [
                    (title: "Featured", endpoint: .CategoryPosts(slug: "featured"), selected: true),
                    (title: "Art", endpoint: .CategoryPosts(slug: "art"), selected: false),
                ]
                subject.layoutIfNeeded()
                expect(subject).to(haveValidSnapshot())
            }

            it("highlights the selected category, after assigning duplicates") {
                subject.categoriesInfo = [
                    (title: "Featured", endpoint: .CategoryPosts(slug: "featured"), selected: true),
                    (title: "Art", endpoint: .CategoryPosts(slug: "art"), selected: false),
                ]
                subject.categoriesInfo = [
                    (title: "Featured", endpoint: .CategoryPosts(slug: "featured"), selected: false),
                    (title: "Art", endpoint: .CategoryPosts(slug: "art"), selected: true),
                ]
                subject.layoutIfNeeded()
                expect(subject).to(haveValidSnapshot())
            }
        }
    }
}
