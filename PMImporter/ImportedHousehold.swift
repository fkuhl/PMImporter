//
//  ImportedHousehold.swift
//  PMImporter
//
//  Created by Frederick Kuhl on 9/3/20.
//

import Foundation
import PMDataTypes

public struct ImportedHousehold: Codable {
    public var _id: ID = ""
    public var head: ID? = nil //sketchy! who doesn't have a head?
    public var spouse: ID? = nil
    public var others: [ID] = []
    public var address: ID? = nil
}
