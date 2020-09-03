//
//  ImportedHousehold.swift
//  PMImporter
//
//  Created by Frederick Kuhl on 9/3/20.
//

import Foundation
import PMDataTypes

public struct ImportedHousehold: Codable {
    public var _id: Id = ""
    public var head: Id? = nil //sketchy! who doesn't have a head?
    public var spouse: Id? = nil
    public var others: [Id] = []
    public var address: Id? = nil
}
