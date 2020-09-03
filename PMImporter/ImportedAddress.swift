//
//  ImportedAddress.swift
//  PMImporter
//
//  Created by Frederick Kuhl on 9/3/20.
//

import Foundation
import PMDataTypes

public struct ImportedAddress: Codable {
    public var _id: Id
    public var address: String? = ""
    public var address2: String? = nil
    public var city: String? = ""
    public var state: String? = nil
    public var postalCode: String? = ""
    public var country: String? = nil
    public var email: String? = nil
    public var homePhone: String? = nil
}
