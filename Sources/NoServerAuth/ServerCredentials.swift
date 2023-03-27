//
//  ServerCredentials.swift
//  
//
//  Created by Guerson Perez on 3/16/23.
//

import Foundation
import MongoKitten
import NoMongo
import Vapor

public typealias ServerCredentialsAuthenticatedClosure = (_ request: Request,
                                                          _ credentials: ServerCredentials) async throws -> Void

public final class ServerCredentials: DBCollectionable, Content {
    
    public var _id: ObjectId?
    
    public var privateKey: String?
    
    public var otpKey: String?
    
    public var entityId: ObjectId?
    
    public var entity: String?
    
    public var deviceName: String?
    
    public var appIdentifier: String?
    
    init() { }
    
    public init(_id: ObjectId? = nil,
                privateKey: String? = nil,
                otpKey: String? = nil,
                entityId: ObjectId? = nil,
                entity: String? = nil,
                deviceName: String? = nil,
                appIdentifier: String? = nil) {
        self._id = _id
        self.privateKey = privateKey
        self.otpKey = otpKey
        self.entityId = entityId
        self.entity = entity
        self.deviceName = deviceName
        self.appIdentifier = appIdentifier
    }
    
    public static func findOptional(db: MongoDatabase, entity: String?, entityId: ObjectId?, deviceName: String?, appIdentifier: String?) async throws
    -> ServerCredentials? {
        guard let entityId, let entity, let deviceName, let appIdentifier
        else { throw NoServerAuthError.missingCredentials }
        return try await ServerCredentials.findOneOptional(in: db, query: [
            "entity": entity,
            "entityId": entityId,
            "deviceName": deviceName,
            "appIdentifier": appIdentifier])
    }
}
