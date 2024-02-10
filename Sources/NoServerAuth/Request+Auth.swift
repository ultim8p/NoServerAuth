//
//  Request+Authentication.swift
//  
//
//  Created by Guerson Perez on 3/16/23.
//

import Foundation
import Vapor
import MongoKitten
import NoMongo

public extension Request {
    
    func authenticateCredentials(in db: MongoDatabase, authClosure: ServerCredentialsAuthenticatedClosure?) async throws {
        let bearer = try bearerData
        let privateKey = try await db.appPrivateKey
        try await authenticateCredentials(in: db,
                                          privateKey: privateKey,
                                          auth: bearer,
                                          authClosure: authClosure)
    }
    
    func authenticateCredentials(in db: MongoDatabase,
                                 privateKey: String?,
                                 auth: Data?,
                                 authClosure: ServerCredentialsAuthenticatedClosure?) async throws {
        guard let privateKey = privateKey,
              let credentials = auth
        else { throw NoServerAuthError.missingCredentials }
        
        // 1 Decrypt Auth using privateKey
        let auth: AuthCredentials = try privateKey.aesDecrypt(data: credentials)
        
        // 2 Find Credentials by Auth._id
        guard let authId = auth._id else { throw NoServerAuthError.missingCredentials }
        let creds: ServerCredentials = try await ServerCredentials.findOne(in: db, id: authId)
        
        // 3 Verify otp token by generating with local Credentials and matching to Auth object.
        try creds.verify(auth: auth)
        
        // 4 Call closure to
        try await authClosure?(self, creds)
        
        // 5 Check if there is embedded Auth
        guard let nextAuth = auth.nextAuth else { return }
        
        // 6 Verify the next credentials by decripting with the current Credentials
        try await authenticateCredentials(in: db,
                                          privateKey: creds.privateKey,
                                          auth: nextAuth,
                                          authClosure: authClosure)
    }
}
