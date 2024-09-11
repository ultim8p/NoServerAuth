import NoCrypto
import MongoKitten
import NoMongo

public enum NoServerAuthConstant {
    static let originEntity = "origin"
}

public struct NoServerAuth {
    public private(set) var text = "Hello, World!"

    public init() {
    }
    
    public static func createIndexes(in db: MongoDatabase) async throws {
        try await ServerCredentials.createIndexes(in: db)
        try await ClientCredentials.createIndexes(in: db)
    }
}

public extension String {
    
    @discardableResult
    static func noAuthGenerateOriginCredentials(in db: MongoDatabase) async throws
    -> ClientCredentials {
        let currentCredential = try await ServerCredentials.findOneOptional(
            in: db,
            query: ["entity": NoServerAuthConstant.originEntity]
        )
        guard currentCredential == nil else { throw NoServerAuthError.originCreadentialsCreated }
        
        let credentials = try String.noAuthCreateCredentials(
            entityId: ObjectId(),
            entity: NoServerAuthConstant.originEntity,
            deviceName: "",
            serverAppIdentifier: "",
            clientAppIdentifier: "")
        
        let server = credentials.server
        
        try await server.save(in: db)
        
        return credentials.client
    }
}

public enum AuthCredentialsDefault {
    
    static let otpInterval: Int = 30
    
    static let otpRangeValidation: Int = 1
    
    static let otpKeySize: OTPKeySize = .key40
}

public extension String {
    
    static func noAuthCreateCredentials(
        entityId: ObjectId,
        entity: String,
        deviceName: String,
        serverAppIdentifier: String,
        clientAppIdentifier: String
    ) throws -> (server: ServerCredentials, client: ClientCredentials) {
        let aesKey = try String.aesGenerateEncryptionKey()
        let otpKey = try String.generateOTPKey(size: AuthCredentialsDefault.otpKeySize)
        let id = ObjectId()
        let serverCredentials = ServerCredentials(
            _id: id,
            privateKey: aesKey,
            otpKey: otpKey,
            entityId: entityId,
            entity: entity,
            deviceName: deviceName,
            appIdentifier: serverAppIdentifier)
        
        let clientCredentials = ClientCredentials(
            _id: id,
            publicKey: aesKey,
            otpKey: otpKey,
            entityId: entityId,
            entity: entity,
            deviceName: deviceName,
            appIdentifier: clientAppIdentifier)
        
        return (serverCredentials, clientCredentials)
    }
}
