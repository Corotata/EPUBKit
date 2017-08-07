//
//  EPUBDataSource.swift
//  EPUBKit
//
//  Created by Witek on 07/08/2017.
//  Copyright © 2017 Witek Bobrowski. All rights reserved.
//

import Foundation

protocol EPUBDataSource: class {
    func build(from epubDocument: EPUBDocument)
}
