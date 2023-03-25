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

public struct ClientCredentials: DBCollectionable, Content {
    
    public var _id: ObjectId?
    
    public var publicKey: String?
    
    public var otpKey: String?
    
    public var entity: String?
}

public extension ClientCredentials {
    
    var authenticatedToken: Data {
        get throws {
            guard let otpKey = otpKey,
                  let publicKey = publicKey else { throw NoServerAuthError.missingCredentials }
            let code = try otpKey.getOTPToken(interval: AuthCredentialsDefault.otpInterval)
            let token = AuthToken(token: code)
            return try publicKey.aesEncrypt(object: token)
        }
    }
    
    func authCredentials() throws -> AuthCredentials {
        let token = try authenticatedToken
        return AuthCredentials(_id: _id, token: token)
    }
}
