//
//  EPUBParser.swift
//  EPUBKit
//
//  Created by Witek on 09/06/2017.
//  Copyright © 2017 Witek Bobrowski. All rights reserved.
//

import Foundation
import AEXML

public final class EPUBParser: EPUBParserProtocol {

    public typealias XMLElement = AEXMLElement

    private let archiveService: EPUBArchiveService
    private let spineParser: EPUBSpineParser
    private let metadataParser: EPUBMetadataParser
    private let manifestParser: EPUBManifestParser
    private let tableOfContentsParser: EPUBTableOfContentsParser

    public weak var delegate: EPUBParserDelegate?

    public init() {
        archiveService = EPUBArchiveServiceImplementation()
        metadataParser = EPUBMetadataParserImplementation()
        manifestParser = EPUBManifestParserImplementation()
        spineParser = EPUBSpineParserImplementation()
        tableOfContentsParser = EPUBTableOfContentsParserImplementation()
    }

    public func parse(documentAt path: URL) throws -> EPUBDocument {
        var directory: URL
        var contentDirectory: URL
        var metadata: EPUBMetadata
        var manifest: EPUBManifest
        var spine: EPUBSpine
        var tableOfContents: EPUBTableOfContents
        delegate?.parser(self, didBeginParsingDocumentAt: path)
        do {
            var isDirectory: ObjCBool = false
            FileManager.default.fileExists(atPath: path.path, isDirectory: &isDirectory)
            
            directory = isDirectory.boolValue ? path : try unzip(archiveAt: path)
            delegate?.parser(self, didUnzipArchiveTo: directory)

            let contentService = try EPUBContentServiceImplementation(directory)
            contentDirectory = contentService.contentDirectory
            delegate?.parser(self, didLocateContentAt: contentDirectory)

            spine = getSpine(from: contentService.spine)
            delegate?.parser(self, didFinishParsing: spine)

            metadata = getMetadata(from: contentService.metadata)
            delegate?.parser(self, didFinishParsing: metadata)

            manifest = getManifest(from: contentService.manifest)
            delegate?.parser(self, didFinishParsing: manifest)
            /// 修改以支持部分无内容
            let toc = spine.toc ?? "toc.ncx"
            
            /// 最终决定的目录名
            var resultName: String?
            
            
            var fileNames: [String] = []
            /// 罗列可能的名称
            fileNames.append(toc)
            fileNames.append("_nav.xhtml")
            fileNames.append("_toc.xhtml")
            
            for name in fileNames {
                /// 确定文件存在
                if let fileName = manifest.items[name]?.path,
                   fileExist(fileName: fileName, contentService: contentService) {
                    resultName = fileName
                    break
                }
            }
            
            if resultName == nil,let toc = manifest.items.filter({$0.key == "toc" || $0.value.id == "toc"}).first?.value  {
                resultName = toc.path
            }
            
            guard let fileName = resultName else {
                throw EPUBParserError.tableOfContentsMissing
            }
            
            let tableOfContentsElement = try contentService.tableOfContents(fileName)

            tableOfContents = getTableOfContents(from: tableOfContentsElement)
            delegate?.parser(self, didFinishParsing: tableOfContents)
        } catch let error {
            delegate?.parser(self, didFailParsingDocumentAt: path, with: error)
            throw error
        }
        delegate?.parser(self, didFinishParsingDocumentAt: path)
        return EPUBDocument(directory: directory, contentDirectory: contentDirectory,
                            metadata: metadata, manifest: manifest,
                            spine: spine, tableOfContents: tableOfContents)
    }

    /// 检查文件是否存在
    func fileExist(fileName: String?,contentService: EPUBContentServiceImplementation) -> Bool {
        
        guard let fileName = fileName else {
            return false
        }
        let url =  contentService.contentDirectory.appendingPathComponent(fileName)
        
        return FileManager.default.fileExists(atPath: url.path)
    }
    
}

extension EPUBParser: EPUBParsable {

    public func unzip(archiveAt path: URL) throws -> URL {
        try archiveService.unarchive(archive: path)
    }

    public func getSpine(from xmlElement: XMLElement) -> EPUBSpine {
        spineParser.parse(xmlElement)
    }

    public func getMetadata(from xmlElement: XMLElement) -> EPUBMetadata {
        metadataParser.parse(xmlElement)
    }

    public func getManifest(from xmlElement: XMLElement) -> EPUBManifest {
        manifestParser.parse(xmlElement)
    }

    public func getTableOfContents(from xmlElement: XMLElement) -> EPUBTableOfContents {
        tableOfContentsParser.parse(xmlElement)
    }

}
