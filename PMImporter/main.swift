//
//  main.swift
//  PMImporter
//
//  Created by Frederick Kuhl on 9/3/20.
//

import Foundation
import PMDataTypes

do {
    let blobData = try Data(contentsOf: URL(fileURLWithPath: "/Users/fkuhl/Desktop/members-pm.json"))
    let blob = try jsonDecoder.decode(ImportedBlob.self, from: blobData)
    NSLog("got \(blob.households.count) households")
} catch {
    if let err = error as? DecodingError {
        NSLog("decode error \(err)")
    } else {
        NSLog("failed data: \(error.localizedDescription)")
    }
}

