//
//  EPUBDocumentTests.swift
//  
//
//  Created by Witek Bobrowski on 13/06/2021.
//

import XCTest
@testable import EPUBKit

final class EPUBDocumentTests: XCTestCase {

    private lazy var library: FileLibrary = EPUBLibrary()

    func testEPUBDocumentSimpleInitialiserWithAliceInWonderland() {
        let url = library.path(for: .alicesAdventuresinWonderland)
        guard let document = EPUBDocument(url: url) else {
            XCTFail("Document should be parsed correctly.")
            return
        }
        XCTAssertNil(document.title)
        XCTAssertNil(document.author)
        XCTAssertNil(document.publisher)
        XCTAssertNil(document.cover)
    }

    func testEPUBDocumentSimpleInitialiserWithGeographyOfBliss() {
        let url = library.path(for: .theGeographyofBliss)
        guard let document = EPUBDocument(url: url) else {
            XCTFail("Document should be parsed correctly.")
            return
        }
        XCTAssertEqual(document.title, "The Geography of Bliss: One Grump's Search for the Happiest Places in the World")
        XCTAssertEqual(document.author, "Eric Weiner")
        XCTAssertEqual(document.publisher, "Twelve")
        XCTAssertNotNil(document.cover)
    }

    func testEPUBDocumentSimpleInitialiserWithMethamorphosis() {
        let url = library.path(for: .theMetamorphosis)
        guard let document = EPUBDocument(url: url) else {
            XCTFail("Document should be parsed correctly.")
            return
        }
        XCTAssertEqual(document.title, "Metamorphosis")
        XCTAssertEqual(document.author, "Franz Kafka")
        XCTAssertEqual(document.publisher, "PressBooks.com")
        XCTAssertNotNil(document.cover)
    }

    func testEPUBDocumentSimpleInitialiserWithPhilosophy() {
        let url = library.path(for: .theProblemsofPhilosophy)
        guard let document = EPUBDocument(url: url) else {
            XCTFail("Document should be parsed correctly.")
            return
        }
        XCTAssertEqual(document.title, "The Problems of Philosophy")
        XCTAssertEqual(document.author, "Bertrand Russell")
        XCTAssertEqual(document.publisher, "PresssBooks.com")
        XCTAssertNotNil(document.cover)
    }

    /// 无旧版封面标识时，应识别 EPUB 3 属性列表中的封面图片。
    func testCoverFallsBackToEPUB3CoverImageProperty() {
        let url = library.path(for: .alicesAdventuresinWonderland)
        guard let parsed = EPUBDocument(url: url) else {
            XCTFail("Document should be parsed correctly.")
            return
        }

        var metadata = parsed.metadata
        metadata.coverId = nil
        var manifest = parsed.manifest
        let coverItem = EPUBManifestItem(
            id: "epub3-cover",
            path: "Images/cover.jpg",
            mediaType: .unknown,
            property: "nav cover-image"
        )
        manifest.items[coverItem.id] = coverItem
        manifest.itemList.append(coverItem)
        let document = EPUBDocument(
            directory: parsed.directory,
            contentDirectory: parsed.contentDirectory,
            metadata: metadata,
            manifest: manifest,
            spine: parsed.spine,
            tableOfContents: parsed.tableOfContents
        )

        XCTAssertEqual(document.cover, parsed.contentDirectory.appendingPathComponent(coverItem.path))
    }
}
