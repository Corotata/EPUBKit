//
//  EPUBManifest.swift
//  EPUBKit
//
//  Created by Witek on 10/06/2017.
//  Copyright © 2017 Witek Bobrowski. All rights reserved.
//

import Foundation

public struct EPUBManifest {
    public var id: String?
    public var items: [String: EPUBManifestItem]
    public var itemList: [EPUBManifestItem]  // 新增数组
}
