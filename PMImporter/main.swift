//
//  main.swift
//  PMImporter
//
//  Created by Frederick Kuhl on 9/3/20.
//

import Foundation
import PMDataTypes

var blob = readBlob()
NSLog("\(blob.households.count) households, \(blob.members.count) members, \(blob.addresses.count) addresses")
let addressesByImportedIndex = index(addresses: blob.addresses)
let mansionInTheSky = makeMansionInTheSky()
removeTempAddressesFrom(members: &blob.members)
let membersByImportedIndex = index(members: &blob.members, adding: mansionInTheSky)
validateHouseholds(in: &blob, against: membersByImportedIndex, and: addressesByImportedIndex)

/**
 Check integrity of member and address references.
 - Postcondition: Households with nil head are removed, or unknown indexes, are removed.
 */
func validateHouseholds(in blob: inout ImportedBlob, against memberIndex: [Id:ImportedMember], and addressIndex: [Id:ImportedAddress]) {
    let culledHouseholds = blob.households.filter{ isValid(household: $0, against: membersByImportedIndex, and: addressesByImportedIndex) }
    blob.households = culledHouseholds
}

func isValid(household: ImportedHousehold, against memberIndex: [Id:ImportedMember], and addressIndex: [Id:ImportedAddress]) -> Bool {
    var isValid = true
    if let head = household.head {
        if memberIndex[head] == nil {
            isValid = false
            NSLog("household \(household._id) has unk head \(head)")
        }
    } else {
        isValid = false
        NSLog("household \(household._id) has nil head")
    }
    if let spouse = household.spouse {
        if memberIndex[spouse] == nil {
            isValid = false
            NSLog("household \(household._id) has unk spouse \(spouse)")
        }
    }
//    household.others.forEach { other in
//        if memberIndex[other] == nil {
//            isValid = false
//            NSLog("household \(household._id) has unk other \(other)")
//        }
//    }
    if let address = household.address {
        if addressIndex[address] == nil {
            isValid = false
            NSLog("household \(household._id) has unk addr \(address)")
        }
    }
    return isValid
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
//        for household in blob.households {
//            if (household.head == nil) {
//                NSLog("nil household, id \(household._id)")
//            }
//        }
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

