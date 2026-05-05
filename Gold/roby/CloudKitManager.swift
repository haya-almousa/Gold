//
//  CloudKitManager.swift
//  Gold
//
//  Created by Raghad Alamoudi on 18/11/1447 AH.
//

import Foundation
import CloudKit

final class CloudKitManager {
    
    static let shared = CloudKitManager()
    let container = CKContainer(identifier: "iCloud.HayaAlmousa.Gold")
    private let publicDB: CKDatabase
    private let privateDB: CKDatabase

    private init() {
        publicDB  = container.publicCloudDatabase
        privateDB = container.privateCloudDatabase
    }
}
