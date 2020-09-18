//
//  main.swift
//  PMImporter
//
//  Created by Frederick Kuhl on 9/3/20.
//

import Foundation
import PMDataTypes
import CryptoKit
import CommonCrypto

var blob = readBlob()
NSLog("\(blob.households.count) households, \(blob.members.count) members, \(blob.addresses.count) addresses")
let importedAddressesByIndex = index(addresses: blob.addresses)
var mansionInTheSky = makeMansionInTheSky()
removeTempAddressesFrom(members: &blob.members)
let importedMembersByIndex = index(members: &blob.members, adding: mansionInTheSky)
NSLog("indexed \(importedMembersByIndex.count) imported members")
validateHouseholds(in: &blob, against: importedMembersByIndex)
NSLog("after validation, have \(blob.households.count) households")
let addressesByIndex = create(from: importedAddressesByIndex)
NSLog("indexed \(addressesByIndex.count) PM Addresses")
let membersByIndex = create(from: importedMembersByIndex, mansionId: mansionInTheSky.id)
NSLog("indexed \(membersByIndex.count) PM Members")
populate(mansionInTheSky: &mansionInTheSky, from: membersByIndex)
NSLog("mansionInTheSky now has \(mansionInTheSky.others.count) others")
let households = create(from: blob.households, members: membersByIndex, addresses: addressesByIndex, mansionInTheSky: mansionInTheSky)
NSLog("created \(households.count) PM Households")
#warning("password from arguments!")
let key = createKey(password: "1234")
let byteCount = write(households: households, withKey: key)
NSLog("wrote \(byteCount) bytes")


/**
 Write households!
 */
func write(households: [Household], withKey: SymmetricKey) -> Int {
    do {
        let unencrypted = try jsonEncoder.encode(households)
        let encrypted = try! ChaChaPoly.seal(unencrypted, using: key).combined
        let byteCount = encrypted.count
        try encrypted.write(to: URL(fileURLWithPath: "/Users/fkuhl/Desktop/test.pmrolls"))
        return byteCount
    } catch {
        if let err = error as? EncodingError {
            NSLog("encode error \(err)")
        } else {
            NSLog("failed data: \(error.localizedDescription)")
        }
        exit(1)
    }
}

func createKey(password: String) -> SymmetricKey {
    let keyData = pbkdf2(hash: CCPBKDFAlgorithm(kCCPBKDF2),
                         password: password,
                         salt: Data(), //saltless
                         keyByteCount: 32, //256 bits
                         rounds: 8)
    return SymmetricKey(data: keyData!)
}

/**
 mansionInTheSky should have all DEAD members as 'others'.
 */
func populate(mansionInTheSky: inout Household, from members: [Id:Member]) {
    for member in members.values {
        if member.household == mansionInTheSky.id {
            mansionInTheSky.others.append(member)
        }
    }
}

/**
 Create PM Households.
 - Precondition: Households with nil heads have been removed.
 */
func create(from importedHouseholds: [ImportedHousehold],
            members: [Id:Member],
            addresses: [Id:Address],
            mansionInTheSky: Household) -> [Household] {
    var households = [mansionInTheSky]
    for imported in importedHouseholds {
        var household = Household()
        household.id = imported._id
        if let head = members[imported.head ?? ""] { //see precond
            household.head = head
        }
        household.spouse = nil
        if let spouseIndex = imported.spouse, let spouse = members[spouseIndex] {
            household.spouse = spouse
        }
        var others = [Member]()
        for otherIndex in imported.others {
            if let other = members[otherIndex] {
                others.append(other)
            } else {
                NSLog("household '\(household.head.fullName())' had unk other index \(otherIndex)")
            }
        }
        household.others = others
        if let addressIndex = imported.address, let address = addresses[addressIndex] {
            household.address = address
        }
        households.append(household)
    }
    return households
}


/**
 Create PM Members.
 - Postcondition: Any Member lacking an address is supplied with the Mansion In the Sky.
 */
func create(from imported: [Id:ImportedMember], mansionId: Id) -> [Id:Member] {
    var members = [Id:Member]()
    for (index, mem) in imported {
        members[index] = mem.createMember(mansionId: mansionId)
    }
    return members
}


/**
 Create PM Addresses.
 */
func create(from imported: [Id:ImportedAddress]) -> [Id:Address] {
    var addresses = [Id:Address]()
    for (index, addr) in imported {
        addresses[index] = addr.createAddress()
    }
    return addresses
}


/**
 Check integrity of head reference.
 - Postcondition: Households with nil or unknown head are removed.
 */
func validateHouseholds(in blob: inout ImportedBlob, against memberIndex: [Id:ImportedMember]) {
    let culledHouseholds = blob.households.filter { household in
        if let head = household.head {
            if memberIndex[head] == nil {
                NSLog("household \(household._id) has unk head \(head)")
                return false
            } else { return true }
        } else {
            NSLog("household \(household._id) has nil head")
            return false
        }
    }
    blob.households = culledHouseholds
}


/**
 Create collection of Member instances indexed by member's imported index.
 - Precondition: Addresses have been indexed, i.e., indexAddresses has been executed.
 - Postcondition: Household index is still the imported index, not the Mongo, but nil household replaced by mansionInTheSky..
 - Returns index of members by imported index.
 */
func index(members: inout [ImportedMember], adding mansion: Household) -> [Id:ImportedMember] {
    var index = [Id:ImportedMember]()
    for member in members {
        var m = member
        if m.household == nil {
            m.household = mansion.id
        }
        index[m._id] = m
    }
    return index
}

/**
 Remove temporary addresses.
 This sidesteps the need to embed them at this stage.
 */
func removeTempAddressesFrom(members: inout [ImportedMember]) {
    for (index, member) in members.enumerated() {
        var m = member
        m.tempAddress = nil
        members[index] = m
    }
}

/**
 DEAD members must still belong to a household, to be included in the denormalized data.
     As DEAD members are imported they are added to mansionInTheSky.
     And of course each household must have a head.
 */
func makeMansionInTheSky() -> Household {
    let mansionInTheSkyTempId = UUID().uuidString
    var goodShepherd = Member()
    goodShepherd.familyName = "Shepherd"
    goodShepherd.givenName = "Good"
    goodShepherd.placeOfBirth = "Bethlehem"
    goodShepherd.status = MemberStatus.PASTOR  // not counted against communicants
    goodShepherd.resident = false  // not counted against residents
    goodShepherd.exDirectory = true  // not included in directory
    goodShepherd.household = mansionInTheSkyTempId
    
    var mansionInTheSky = Household()
    mansionInTheSky.head = goodShepherd
    mansionInTheSky.id = mansionInTheSkyTempId
    return mansionInTheSky
}

/**
 Address instances by imported index.
 */
func index(addresses: [ImportedAddress]) -> [Id: ImportedAddress] {
    var index = [Id: ImportedAddress]()
    addresses.forEach { index[$0._id] = $0 }
    return index
}


func readBlob() -> ImportedBlob {
    do {
        let blobData = try Data(contentsOf: URL(fileURLWithPath: "/Users/fkuhl/Desktop/members-pm.json"))
        let blob = try jsonDecoder.decode(ImportedBlob.self, from: blobData)
        return blob
    } catch {
        if let err = error as? DecodingError {
            NSLog("decode error \(err)")
        } else {
            NSLog("failed data: \(error.localizedDescription)")
        }
        exit(1)
    }
}


//https://www.andyibanez.com/posts/cryptokit-not-enough/
func pbkdf2(hash: CCPBKDFAlgorithm,
            password: String,
            salt: Data,
            keyByteCount: Int,
            rounds: Int) -> Data? {
    guard let passwordData = password.data(using: .utf8) else { return nil }

    var derivedKeyData = Data(repeating: 0, count: keyByteCount)
    let derivedCount = derivedKeyData.count

  let derivationStatus: OSStatus = derivedKeyData.withUnsafeMutableBytes { derivedKeyBytes in
      let derivedKeyRawBytes = derivedKeyBytes.bindMemory(to: UInt8.self).baseAddress
        return salt.withUnsafeBytes { saltBytes in
          let rawBytes = saltBytes.bindMemory(to: UInt8.self).baseAddress
          return CCKeyDerivationPBKDF(
                CCPBKDFAlgorithm(kCCPBKDF2),
                password,
                passwordData.count,
                rawBytes,
                salt.count,
                hash,
                UInt32(rounds),
                derivedKeyRawBytes,
                derivedCount)
        }
    }
    return derivationStatus == kCCSuccess ? derivedKeyData : nil
}
