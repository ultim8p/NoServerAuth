//
//  AuthCredentials.swift
//  
//
//  Created by Guerson Perez on 3/16/23.
//

import Foundation
import MongoKitten

public struct AuthCredentials: Codable {
    
    var _id: ObjectId?
    
    var token: Data?
    
    var nextAuth: Data?
}
