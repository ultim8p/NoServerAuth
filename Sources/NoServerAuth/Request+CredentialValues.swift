//
//  Request+CredentialValues.swift
//  
//
//  Created by Guerson Perez on 3/16/23.
//

import Vapor
import MongoKitten

public extension Request {
    
    var bearerData: Data {
        get throws {
            guard let bearer = headers.bearerAuthorization?.token,
                    let bearerData = bearer.base64Data
            else { throw NoServerAuthError.missingBearer }
            
            return bearerData
        }
    }
}


extension String {
    
    var base64Data: Data? {
        Data(base64Encoded: self)
    }
}

