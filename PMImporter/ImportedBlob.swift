//
//  ImportedBlob.swift
//  PMImporter
//
//  Created by Frederick Kuhl on 9/3/20.
//

import Foundation

struct ImportedBlob: Decodable {
    var addresses: [ImportedAddress]
    var members: [ImportedMember]
    var households: [ImportedHousehold]
}
