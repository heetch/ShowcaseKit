//
//  ShowcaseKitTests.swift
//  Heetch
//
//  Created by Jérôme Alves on 09/09/2019.
//  Copyright © 2019 Heetch. All rights reserved.
//

import Foundation
import XCTest
import ShowcaseKit

private final class TestCaseShowcase: Showcase {

    final class ViewController: UIViewController {

    }

    func makeViewController() -> UIViewController {
        return ViewController()
    }

}

class ShowcaseKitTests: XCTestCase {
    func testShowcaseVisibleAtRuntime() {
        guard let sut = ShowcaseDescription.allCases.first(where: { $0.classType == TestCaseShowcase.self }) else {
            return XCTFail("TestCaseShowcase not found")
        }
        XCTAssertEqual(sut.className, "TestCaseShowcase")
        XCTAssertEqual(sut.title, "Test Case")
        XCTAssertEqual(sut.path, .root)
        XCTAssertEqual(sut.presentationMode, .automatic)
    }
    
    static var allTests = [
        ("testShowcaseVisibleAtRuntime", testShowcaseVisibleAtRuntime),
    ]
}
