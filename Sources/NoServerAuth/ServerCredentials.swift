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

public protocol CredentialIdentifiable: DBCollectionable {
    
    var entityId: ObjectId? { get set }
    
    var entity: String? { get set }
    
    var deviceName: String? { get set }
    
    var appIdentifier: String? { get set }
}

public protocol Credentialable: Content, Codable {
    
    var _id: ObjectId? { get set }
    
    static var entityName: String { get set }
    
    // Specify the current server app identifier.
    // This will be returned to the client for them to identify the key for our app.
    static var clientAppIdentifier: String { get set }
}

public final class ServerCredentials: Content, CredentialIdentifiable {
    
    public var _id: ObjectId?
    
    public var privateKey: String?
    
    public var otpKey: String?
    
    public var entityId: ObjectId?
    
    public var entity: String?
    
    public var deviceName: String?
    
    public var appIdentifier: String?
    
    public init() { }
    
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
}

public extension Credentialable {
    
    // If there were existing server credentials for this object, delete them.
    // We will always create new credentials, save server and return client.
    func recreateCredentials(db: MongoDatabase, deviceName: String?, serverAppIdentifier: String?)
    async throws -> ClientCredentials {
        guard let _id, let deviceName, let serverAppIdentifier
        else { throw NoServerAuthError.missingCreationValues }
        if let existingCredentials = try await ServerCredentials.findOptional(
            db: db,
            entity: Self.entityName,
            entityId: _id,
            deviceName: deviceName,
            appIdentifier: serverAppIdentifier) {
//            print("DELETED EXISITNG CREDS: \(existingCredentials.appIdentifier) \(existingCredentials.deviceName)")
            try await existingCredentials.delete(in: db)
        }
        let credentials = try String.noAuthCreateCredentials(
            entityId: _id,
            entity: Self.entityName,
            deviceName: deviceName,
            serverAppIdentifier: serverAppIdentifier,
            clientAppIdentifier: Self.clientAppIdentifier)
        try await credentials.server.save(in: db)
//        print("CREATED CREDENTIALS: \(credentials.client.appIdentifier) \(credentials.client.deviceName)")
        return credentials.client
    }
}

// Mostly user for saving credentials from other servers locally.
public extension CredentialIdentifiable {
    
    static func findOptional(db: MongoDatabase,
                             entity: String?,
                             entityId: ObjectId?,
                             deviceName: String?,
                             appIdentifier: String?)
    async throws -> Self? {
        guard let entityId, let entity, let deviceName, let appIdentifier
        else { return nil }
        return try await Self.findOneOptional(in: db, query: [
            "entity": entity,
            "entityId": entityId,
            "deviceName": deviceName,
            "appIdentifier": appIdentifier])
    }
    
    // Finds existing credentials with the same identifiable properties and replaces it.
    func replaceOrSave(db: MongoDatabase) async throws {
        if let existing = try await Self.findOptional(
            db: db,
            entity: entity,
            entityId: entityId,
            deviceName: deviceName,
            appIdentifier: appIdentifier) {
            print("DELETING NEW CREDENTIALS: \(entity) \(appIdentifier) \(deviceName)")
            try await existing.delete(in: db)
        }
        print("SAVIG NEW CREDENTIALS: \(entity) \(appIdentifier) \(deviceName)")
        try await self.save(in: db)
    }
}
