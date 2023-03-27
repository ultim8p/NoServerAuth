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

public final class ClientCredentials: DBCollectionable, Content {
    
    public var _id: ObjectId?
    
    public var publicKey: String?
    
    public var otpKey: String?
        
    init() { }
    
    init(_id: ObjectId? = nil,
         publicKey: String? = nil,
         otpKey: String? = nil) {
        self._id = _id
        self.publicKey = publicKey
        self.otpKey = otpKey
    }
}
