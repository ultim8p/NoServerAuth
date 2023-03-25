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
}

public extension String {
    
    @discardableResult
    static func noAuthGenerateOriginCredentials(in db: MongoDatabase, tag: String) async throws
    -> ClientCredentials {
        let currentCredential = try await ServerCredentials.findOneOptional(
            in: db,
            query: ["entity": NoServerAuthConstant.originEntity]
        )
        guard currentCredential == nil else { throw NoServerAuthError.originCreadentialsCreated }
        
        let id = ObjectId()
        let credentials = try String.noAuthCreateCredentials(
            tag: tag,
            id: id,
            entity: NoServerAuthConstant.originEntity)
        
        let server = ServerCredentials(
            _id: id,
            privateKey: credentials.server.privateKey,
            entity: NoServerAuthConstant.originEntity
        )
        let client = ClientCredentials(
            _id: id,
            publicKey: credentials.client.publicKey,
            entity: NoServerAuthConstant.originEntity)
        
        try await server.save(in: db)
        
        return client
    }
}

public enum AuthCredentialsDefault {
    static let otpInterval: Int = 30
    static let otpRangeValidation: Int = 1
    static let otpKeySize: OTPKeySize = .key40
}

public extension String {
    
    static func noAuthCreateCredentials(
        tag: String,
        id: ObjectId?,
        entity: String
    ) throws -> (server: ServerCredentials, client: ClientCredentials) {
        let aesKey = try String.aesGenerateEncryptionKey()
        let otpKey = try String.generateOTPKey(size: AuthCredentialsDefault.otpKeySize)
        let serverCredentials = ServerCredentials(
            _id: id,
            privateKey: aesKey,
            otpKey: otpKey,
            entity: entity)
        let clientCredentials = ClientCredentials(
            _id: id,
            publicKey: aesKey,
            otpKey: otpKey,
            entity: entity)
        return (serverCredentials, clientCredentials)
    }
}
