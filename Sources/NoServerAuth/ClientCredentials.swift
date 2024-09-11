//
//  ClientCredentials.swift
//  
//
//  Created by Guerson Perez on 3/16/23.
//

import Foundation
import MongoKitten
import Vapor
import NoMongo
import NoCrypto

public final class ClientCredentials: DBCollectionable, Content, CredentialIdentifiable {
    
    public var _id: ObjectId?
    
    public var publicKey: String?
    
    public var otpKey: String?
    
    public var entityId: ObjectId?
    
    public var entity: String?
    
    public var deviceName: String?
    
    public var appIdentifier: String?
        
    public init() { }
    
    public init(_id: ObjectId? = nil,
         publicKey: String? = nil,
         otpKey: String? = nil,
         entityId: ObjectId? = nil,
         entity: String? = nil,
         deviceName: String? = nil,
         appIdentifier: String? = nil) {
        self._id = _id
        self.publicKey = publicKey
        self.otpKey = otpKey
        self.entityId = entityId
        self.entity = entity
        self.deviceName = deviceName
        self.appIdentifier = appIdentifier
    }
    
    static func createIndexes(in db: MongoDatabase) async throws {
        let collection = ClientCredentials.collection(in: db)
        try await collection.createIndex(named: "entity,entityId,deviceName,appIdentifier", keys: [
            "entity": 1,
            "entityId": 1,
            "deviceName": 1,
            "appIdentifier": 1
        ])
    }
}
