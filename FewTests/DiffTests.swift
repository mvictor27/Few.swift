//
//  DiffTests.swift
//  FewTests
//
//  Created by Josh Abernathy on 8/27/14.
//  Copyright (c) 2014 Josh Abernathy. All rights reserved.
//

import Quick
import Nimble
import Few

class DiffTests: QuickSpec {
	override func spec() {
		describe("diffElementLists") {
			let button = Button(title: "Hi") {}
			let view = button.realize()
			let realizedButton = RealizedElement(element: button, children: [], view: view)

			let label = Label(text: "Hey")

			it("should detect simple diffing") {
				let diff = diffElementLists([realizedButton], [button])
				expect(diff.add.count).to(equal(0))
				expect(diff.remove.count).to(equal(0))
				expect(diff.diff.count).to(equal(1))
			}

			it("should detect replacement") {
				let diff = diffElementLists([realizedButton], [label])
				expect(diff.add.count).to(equal(1))
				expect(diff.remove.count).to(equal(1))
				expect(diff.diff.count).to(equal(0))
			}

			it("should detect removal") {
				let diff = diffElementLists([realizedButton], [])
				expect(diff.add.count).to(equal(0))
				expect(diff.remove.count).to(equal(1))
				expect(diff.diff.count).to(equal(0))
			}

			it("should detect addition") {
				let diff = diffElementLists([realizedButton], [button, label])
				expect(diff.add.count).to(equal(1))
				expect(diff.remove.count).to(equal(0))
				expect(diff.diff.count).to(equal(1))
			}

			it("should use keys to match even when position changes") {
				let labelView = label.realize()
				let realizedLabel = RealizedElement(element: label, children: [], view: labelView)

				let newLabel = Label(text: "No.")

				label.key = "key"

				let diff = diffElementLists([realizedButton, realizedLabel], [button, newLabel, label])
				expect(diff.add.count).to(equal(1))
				expect(diff.remove.count).to(equal(0))
				expect(diff.diff.count).to(equal(2))
			}
		}
	}
}
