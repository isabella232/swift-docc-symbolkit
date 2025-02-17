/*
 This source file is part of the Swift.org open source project

 Copyright (c) 2021 Apple Inc. and the Swift project authors
 Licensed under Apache License v2.0 with Runtime Library Exception

 See https://swift.org/LICENSE.txt for license information
 See https://swift.org/CONTRIBUTORS.txt for Swift project authors
*/

import XCTest
import Foundation
@testable import SymbolKit

class SymbolKindTests: XCTestCase {
    
    func testKindParsing() throws {
        var kind: SymbolGraph.Symbol.KindIdentifier

        // Verify basic parsing of old style identifier is working.
        XCTAssert(SymbolGraph.Symbol.KindIdentifier.isKnownIdentifier("swift.func"))
        kind = SymbolGraph.Symbol.KindIdentifier(identifier: "swift.func")
        XCTAssertEqual(kind, .func)
        XCTAssertEqual(kind.identifier, "func")

        // Verify new language-agnostic type is recognized.
        XCTAssert(SymbolGraph.Symbol.KindIdentifier.isKnownIdentifier("func"))
        kind = SymbolGraph.Symbol.KindIdentifier(identifier: "func")
        XCTAssertEqual(kind, .func)
        XCTAssertEqual(kind.identifier, "func")

        // Verify a bare language is not recognized.
        XCTAssertFalse(SymbolGraph.Symbol.KindIdentifier.isKnownIdentifier("swift"))
        kind = SymbolGraph.Symbol.KindIdentifier(identifier: "swift")
        XCTAssertEqual(kind, .unknown)

        // Verify if nothing is recognized, identifier and name is still there.
        XCTAssertFalse(SymbolGraph.Symbol.KindIdentifier.isKnownIdentifier("swift.madeupapi"))
        kind = SymbolGraph.Symbol.KindIdentifier(identifier: "swift.madeupapi")
        XCTAssertEqual(kind, .unknown)
    }

    func testKindDecoding() throws {
        var schemaData: Data
        var kindJson: String
        
        let jsonDecoder = JSONDecoder()

        kindJson = """
            {"identifier": "swift.func", "displayName": "Function"}
        """
        schemaData = kindJson.data(using: .utf8)!
        let kind = try jsonDecoder.decode(SymbolGraph.Symbol.Kind.self, from: schemaData)
        XCTAssertNotNil(kind)
        XCTAssertEqual(kind.identifier, .func)
        XCTAssertEqual(kind.displayName, "Function")
        
        // Verify that the identifier can parse without the "swift." prefix
        kindJson = """
            "func"
        """
        schemaData = kindJson.data(using: .utf8)!
        let identifier = try jsonDecoder.decode(SymbolGraph.Symbol.KindIdentifier.self, from: schemaData)
        XCTAssertNotNil(identifier)
        XCTAssertEqual(identifier, .func)
    }
    
    func testIdentifierRetrieval() throws {
        var theCase: SymbolGraph.Symbol.KindIdentifier
        
        theCase = .class
        XCTAssertEqual(theCase.identifier, "class")
    }

    func testVariousLanguagePrefixes() throws {
        let identifiers = ["func", "swift.func", "objc.func"]
        let jsonDecoder = JSONDecoder()

        for identifier in identifiers {
            let parsed = SymbolGraph.Symbol.KindIdentifier(identifier: identifier)

            XCTAssertEqual(parsed, .func)

            let kindJson = """
                {"identifier": "\(identifier)", "displayName": "Function"}
            """
            let schemaData = kindJson.data(using: .utf8)!
            let kind = try jsonDecoder.decode(SymbolGraph.Symbol.Kind.self, from: schemaData)
            XCTAssertNotNil(kind)
            XCTAssertEqual(kind.identifier, .func)
            XCTAssertEqual(kind.displayName, "Function")
        }
    }
}
