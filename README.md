# NoServerAuth

## Highly secure, one line server to client request authentication.

To implement NoAuth in Vapor project:

1. Handle authentication from incoming requests:
    '''
    // Create middleware object
    let authCredentialsMiddleware = AuthCredentialsMiddleware(authClosure: handleAuthenticatedEntity)
    
    // Create grouped routes, routesCredentials will be blocked by authentication
        let routesOpen = app.routes
        let routesCredentials = routesOpen.grouped(authCredentialsMiddleware)
    
    // Handle authentication method which calls the method below in a different file.
    func handleAuthenticatedEntity(_ request: Request, _ credentials: ServerCredentials) async throws {
        try await request.saveAuthenticated(in: request.mongoDB, credentials: credentials)
    }
    
    // Find and save in the request each object that the authentication callback succesfully authenticated.
    extension Request {
        func saveAuthenticated(in db: MongoDatabase, credentials: ServerCredentials) async throws {
            guard let entity = credentials.entity,
                let type = AuthCredentialsType(rawValue: entity),
                let id = credentials._id
            else { throw RequestError.objectNotFound("Server credentials") }
            switch type {
            case .user:
                let user: User = try await User.findOne(in: db, id: id)
                authUser = user
            }
        }
    }
    '''
    
2. Create authentication credentials when signin up a User or any object that will require authentication:
    
    '''
    // Define a function to create a new user.
    func createNewUser(db: MongoDatabase) async throws -> (user: User, client: ClientCredentials) {
        // Create User object:
        let user = User(_id: ObjectId())
        
        // Create new credentials object. The entity will be used as an identifier to know which kind of object to query in which collection when the authentication handling is called.
        let credentials = try String.createCredentials(
            tag: Default.appIdentifier,
            id: user._id,
            entity: "user")
    
        // Save user object & server credentials in DB, client credentials should be saved in the server and should be returned to the client as part of the response.
        // The client must permanently save the credentials in order to authenticate every request.
        try await organization.save(in: db)
        try await credentials.server.save(in: db)
        
        return (user, credentials.client)
    }
    '''
    
3. By default every App acting as the server credentials should call ONE time the method `createOriginCredentials()`. This will create a new entity in your `MongoDB` `servercredentials` database where your server key will be stored. You can then read this key either manually or through your application in order to share it with your clients.

    '''
    // Call ONCE! Calling more than one will throw an error.
    try await noServerAuthGenerateOriginCredentials(tag: "com.company.appname")
    '''

4. There is no difference between public & private keys for now. All the keys should only be sent to the client once upon creation and never again. The Framework will internally use these keys to authenticate the requests.


