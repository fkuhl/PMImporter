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
    
    func createAddress() -> Address {
        var a = Address()
        a.address = self.address
        a.address2 = self.address2
        a.city = self.city
        a.state = self.state
        a.postalCode = self.postalCode
        a.country = self.country
        a.email = self.email
        a.homePhone = self.homePhone
        return a
    }
}
