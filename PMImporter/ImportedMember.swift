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
    public var _id: ID
    public var familyName: String = ""
    public var givenName: String = ""
    public var middleName: String? = nil
    public var previousFamilyName: String? = nil
    public var nameSuffix: String? = nil
    public var title: String? = nil
    public var nickName: String? = nil
    public var sex: Sex = .MALE
    public var dateOfBirth: Date? = nil
    public var placeOfBirth: String? = nil
    public var status: MemberStatus = .COMMUNING
    public var resident: Bool = true
    public var exDirectory: Bool = false
    public var household: ID? = nil //DEAD members haven't been given mansion yet
    public var tempAddress: ID? = nil
    public var transactions: [Transaction] = []
    public var maritalStatus: MaritalStatus = .SINGLE
    public var spouse: String? = nil
    public var dateOfMarriage: Date? = nil
    public var divorce: String? = nil
    public var father: ID? = nil
    public var mother: ID? = nil
    public var eMail: String? = nil
    public var workEmail: String? = nil
    public var mobilePhone: String? = nil
    public var workPhone: String? = nil
    //public var education: String? = nil
    //public var employer: String? = nil
    public var baptism: String? = nil
    public var services: [Service] = []
    public var dateLastChanged: Date? = nil
    
    
    public func isEmpty() -> Bool {
        return nugatory(familyName) && nugatory(givenName)
    }
    
    /** A function, not computed property, because a computed property interferes with encoding and decoding. */
    public func fullName() -> String {
        if self.isEmpty() { return "[no value]" }
        let previousContribution = nugatory(previousFamilyName) ? "" : " (\(previousFamilyName!))"
        let nickContribution = nugatory(nickName) ? "" : " \"\(nickName!)\""
        let middleContribution = nugatory(middleName) ? "" : " \(middleName!)"
        let suffixContrib = nugatory(nameSuffix) ? "" : " \(nameSuffix!)"
        return "\(familyName), \(givenName)\(middleContribution)\(suffixContrib)\(previousContribution)\(nickContribution)"
    }
    
    func createMember(mansionId: ID) -> Member {
        var m = Member()
        m.id = self._id
        m.familyName = self.familyName
        m.givenName = self.givenName
        m.middleName = self.middleName
        m.previousFamilyName = self.previousFamilyName
        m.nameSuffix = self.nameSuffix
        m.title = self.title
        m.nickname = self.nickName
        m.sex = self.sex
        m.dateOfBirth = self.dateOfBirth
        m.placeOfBirth = self.placeOfBirth
        m.status = self.status
        m.resident = self.resident
        m.exDirectory = self.exDirectory
        m.household = self.household ?? mansionId
        m.tempAddress = nil //we don't transfer these
        m.transactions = self.transactions
        m.maritalStatus = self.maritalStatus
        m.spouse = self.spouse
        m.dateOfMarriage = self.dateOfMarriage
        m.divorce = self.divorce
        m.father = self.father
        m.mother = self.mother
        m.eMail = self.eMail
        m.workEmail = self.workEmail
        m.mobilePhone = self.mobilePhone
        m.workPhone = self.workPhone
        m.baptism = self.baptism
        m.services = self.services
        m.dateLastChanged = self.dateLastChanged
        return m
    }
}
