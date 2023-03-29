//
//  File.swift
//  
//
//  Created by Guerson Perez on 3/18/23.
//

import Foundation

public extension String {
    
    func apiAuthBearer(
        credentials: [ClientCredentials]?
    ) throws -> String? {
        guard let credentials = credentials, !credentials.isEmpty else { return self }
        
        var sumAuth: Data? = nil
        
        for i in 0..<credentials.count {
            let credential = credentials[i]
            
            let hasNext = i+1 < credentials.count
            guard let key = hasNext ? credentials[i+1].publicKey : self
            else { continue }
            
            let authData = try encryptAuth(
                publicKey: key,
                credentials: credential,
                nextAuth: sumAuth)
            sumAuth = authData
        }
        
        guard let sumAuth = sumAuth else { return nil }
        return sumAuth.base64EncodedString()
    }
    
    func encryptAuth(publicKey: String,
                     credentials: ClientCredentials,
                     nextAuth: Data?) throws -> Data {
        
        // 1 Build Auth from Credentials
        var auth = try credentials.authCredentials()
        auth.nextAuth = nextAuth
        
        // 2 Encrypt Auth
        let encryptedAuth = try publicKey.aesEncrypt(object: auth)
        return encryptedAuth
    }
}
