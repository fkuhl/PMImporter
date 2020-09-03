//
//  ImportedMember.swift
//  PMImporter
//
//  Created by Frederick Kuhl on 9/3/20.
//

import Foundation
import PMDataTypes

/**
 As imported from PM. Cf. _id and tempAddress
 */
public struct ImportedMember: Codable {
    public var _id: Id
    public var familyName: String = ""
    public var givenName: String = ""
    public var middleName: String? = nil
    public var previousFamilyName: String? = nil
    public var nameSuffix: String? = nil
    public var title: String? = nil
    public var nickname: String? = nil
    public var sex: Sex = .MALE
    public var dateOfBirth: Date? = nil
    public var placeOfBirth: String? = nil
    public var status: MemberStatus = .COMMUNING
    public var resident: Bool = true
    public var exDirectory: Bool = false
    public var household: Id? = nil //DEAD members haven't been given mansion yet
    public var tempAddress: Id? = nil
    public var transactions: [Transaction] = []
    public var maritalStatus: MaritalStatus = .SINGLE
    public var spouse: String? = nil
    public var dateOfMarriage: Date? = nil
    public var divorce: String? = nil
    public var father: Id? = nil
    public var mother: Id? = nil
    public var eMail: String? = nil
    public var workEmail: String? = nil
    public var mobilePhone: String? = nil
    public var workPhone: String? = nil
    //public var education: String? = nil
    //public var employer: String? = nil
    public var baptism: String? = nil
    public var services: [Service] = []
    public var dateLastChanged: Date? = nil
}
