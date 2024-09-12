//
//  AuthCredentialsMiddleware.swift
//  
//
//  Created by Guerson Perez on 3/16/23.
//

import Foundation
import Vapor
import MongoKitten
import NoCrypto

public struct AuthCredentialsMiddleware {
    
    public var authClosure: ServerCredentialsAuthenticatedClosure?
    
    public init(authClosure: ServerCredentialsAuthenticatedClosure? = nil) {
        self.authClosure = authClosure
    }
}

extension AuthCredentialsMiddleware: AsyncMiddleware {
    
    public func respond(to request: Request, chainingTo next: AsyncResponder) async throws -> Response {
        
        try await request.authenticateCredentials(in: request.mongoDB, authClosure: authClosure)
        return try await next.respond(to: request)
    }
}
