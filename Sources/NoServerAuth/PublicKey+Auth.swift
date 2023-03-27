//
//  File.swift
//  
//
//  Created by Guerson Perez on 3/18/23.
//

import Foundation

public extension String {
    
    private func apiAuthBearer(auth: AuthCredentials?) throws -> String {
        guard let auth = auth else { return self }
        let encryptedBearer = try self.aesEncrypt(object: auth)
        return encryptedBearer.base64EncodedString()
    }
    
    /// Call this function on a public key to get the fully encrypted Bearer header parameter for a given array of `Credentials`.
    func apiAuthBearer(credentials: [ClientCredentials]? = nil) throws -> String {
        guard let credentials = credentials, !credentials.isEmpty else { return self }
        
        var auth: AuthCredentials?
        var previousKey: String?
        
        for credential in credentials {
            var credAuth = try credential.authCredentials()
            if let prevAuth = auth, let key = previousKey {
                let subCredentials = try key.aesEncrypt(object: prevAuth)
                credAuth.nextAuth = subCredentials
                previousKey = credential.publicKey
                auth = credAuth
            } else {
                previousKey = credential.publicKey
                auth = credAuth
            }
        }
        return try self.apiAuthBearer(auth: auth)
    }
}
