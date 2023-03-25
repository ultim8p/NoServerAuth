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

public struct ServerCredentials: DBCollectionable, Content {
    
    public var _id: ObjectId?
    
    public var privateKey: String?
    
    public var otpKey: String?
    
    public var entity: String?
}
