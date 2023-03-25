//
//  File.swift
//  
//
//  Created by Guerson Perez on 3/18/23.
//

import Foundation
import MongoKitten
import NoMongo

public extension MongoDatabase {
    
    var appPrivateKey: String {
        get async throws {
            guard let key = try await appCredentials.privateKey
            else { throw NoServerAuthError.noOriginCredentials }
            return key
        }
    }
    
    var appCredentials: ServerCredentials {
        get async throws {
            let credentials: ServerCredentials = try await ServerCredentials.findOne(
                in: self,
                query: ["entity": NoServerAuthConstant.originEntity])
            return credentials
        }
    }
}
