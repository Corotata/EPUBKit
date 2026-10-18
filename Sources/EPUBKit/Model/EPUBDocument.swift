//
//  EPUBDocument.swift
//  EPUBKit
//
//  Created by Witek on 09/06/2017.
//  Copyright © 2017 Witek Bobrowski. All rights reserved.
//

import Foundation

public struct EPUBDocument {

    public let directory: URL
    public let contentDirectory: URL
    public let metadata: EPUBMetadata
    public let manifest: EPUBManifest
    public let spine: EPUBSpine
    public let tableOfContents: EPUBTableOfContents

    init(
        directory: URL,
        contentDirectory: URL,
        metadata: EPUBMetadata,
        manifest: EPUBManifest,
        spine: EPUBSpine,
        tableOfContents: EPUBTableOfContents
    ) {
        self.directory = directory
        self.contentDirectory = contentDirectory
        self.metadata = metadata
        self.manifest = manifest
        self.spine = spine
        self.tableOfContents = tableOfContents
    }

    public init?(url: URL) {
        guard let document = try? EPUBParser().parse(documentAt: url) else {
            return nil
        }
        self = document
    }

}

extension EPUBDocument {
    public var title: String? { metadata.title }
    public var author: String? { metadata.creator?.name }
    public var publisher: String? { metadata.publisher }
    /// 封面资源 URL；优先使用旧版元数据标识，随后识别 EPUB 3 的 cover-image 属性。
    public var cover: URL? {
        if let coverId = metadata.coverId,
           let path = manifest.items[coverId]?.path {
            return contentDirectory.appendingPathComponent(path)
        }

        // EPUB 3 的 properties 是空白分隔的属性列表。
        guard let item = manifest.itemList.first(where: {
            $0.property?.split(whereSeparator: \.isWhitespace).contains("cover-image") == true
        }) else {
            return nil
        }
        return contentDirectory.appendingPathComponent(item.path)
    }
}
