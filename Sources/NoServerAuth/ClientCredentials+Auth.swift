//
//  File.swift
//  
//
//  Created by Guerson Perez on 3/26/23.
//

import Foundation

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
        return AuthCredentials(_id: _id, token: token, entity: entity)
    }
}
