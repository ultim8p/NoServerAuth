//
//  ServerCredentials+Verification.swift
//  
//
//  Created by Guerson Perez on 3/16/23.
//

import Foundation
import MongoKitten
import Vapor
import NoCrypto

public extension ServerCredentials {
    
    func tokenObject(from auth: AuthCredentials) throws -> AuthToken {
        guard let privateKey = privateKey,
              let tokenData = auth.token
        else { throw NoServerAuthError.missingCredentials }
        return try privateKey.aesDecrypt(data: tokenData)
    }
    
    func verify(token: AuthToken) throws {
        guard let otpKey = otpKey,
              let tokenValue = token.token
        else { throw NoServerAuthError.missingCredentials }
        
        try otpKey.validateOTP(token: tokenValue,
                               interval: AuthCredentialsDefault.otpInterval,
                               range: AuthCredentialsDefault.otpRangeValidation)
    }
    
    func verify(auth: AuthCredentials) throws {
        let token = try tokenObject(from: auth)
        try verify(token: token)
    }
}
