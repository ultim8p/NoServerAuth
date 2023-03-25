//
//  File.swift
//  
//
//  Created by Guerson Perez on 3/18/23.
//

import Foundation

public enum NoServerAuthError: Error {
    
    case missingCredentials
    
    case noOriginCredentials
    
    case missingBearer
    
    case originCreadentialsCreated
    
    case missingAuthenticatedObject
}
