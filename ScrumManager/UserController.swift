//
//  AuthorController.swift
//  SwiftBlog
//
//  Created by Benjamin Johnson on 9/02/2016.
//  Copyright © 2016 Benjamin Johnson. All rights reserved.
//


import PerfectLib

class UserController: AuthController {
    
//    let modelName = "user"
//    
//    let modelPluralName: String = "user"
//    
//    
//    func list(request: WebRequest, response: WebResponse) throws -> MustacheEvaluationContext.MapType {
//        var values = MustacheEvaluationContext.MapType()
//        values["users"] = try! DatabaseManager().executeFetchRequest(User).map({ (user) -> [String: Any] in
//            return user.asDictionary()
//        })
//        
//        return values
//    }
//    
//    func getUserWithIdentifier(identifier: Int) -> User? {
//        
//        let user = try! DatabaseManager().getObject(User.self, primaryKeyValue: identifier);
//        return user
//    }
//    
//    func show(identifier: String, request: WebRequest, response: WebResponse) throws -> MustacheEvaluationContext.MapType {
//        
////        // Query Article
////        let user: User?
////        
////        if let id = Int(identifier)  {
////            user = getUserWithIdentifier(id)
////        } else {
////            fatalError()
////            //author = Author(username: identifier)
////        }
////        
////        // Query Article
////        // Get Articles
////        guard let requestedAuthor = user else {
////            return MustacheEvaluationContext.MapType()
////        }
////        
////        
////        let values: [String:Any] = ["user": requestedAuthor.keyValues()]
////        
//        // Query User Story
//        let id = Int(identifier)!
//        let user2: User? = getUserWithIdentifier(id)
//        
//        guard let user = user2 else {
//            return MustacheEvaluationContext.MapType()
//        }
//        
//        var values: MustacheEvaluationContext.MapType = [:]
//        values["user"] = user.asDictionary()
//        
//        return values
//        
//    }
//    
//    func update(identifier: Int, request: WebRequest, response: WebResponse) {
//        /*
//        // Handle new post request
//        if let title = request.param("title"), body = request.param("body"), existingArticle = getUserWithIdentifier(identifier) {
//            
//            // Update post properties
//            existingArticle.title = title
//            existingArticle.body = body
//            
//            // Save Article
//            do {
//                DatabaseManager().database.getCollection(Article).save(try existingArticle.document())
//                response.redirectTo("/\(modelName)s/\(identifier)")
//            } catch {
//                print(error)
//            }
//        }
//        */
//        
//        if let name = request.param("name"),
//            email = request.param("email"),
//            expertises = request.param("expertises"),
//            password = request.param("password"),
//            theUser = getUserWithIdentifier(identifier){
//            var profilePic = ""
//            // Update the pic if the user gt upload a new version of file
//            if request.fileUploads.count > 0 {
//                // Get Profile Picture
//                if let uploadedFile = request.fileUploads.first {
//                    
//                    let fileName = uploadedFile.fileName
//                    print("Profile Pic uploaded: \(fileName)")
//                    
//                    // Save profile picture to disk
//                    if let file = uploadedFile.file {
//                        // Copy file
//                        do {
//                            let saveLocation = request.documentRoot + "/resources/pictures/" + uploadedFile.fileName
//                            profilePic = uploadedFile.fileName
//                            print(saveLocation)
//                            
//                            try file.copyTo(saveLocation, overWrite: true)
//                        } catch {
//                            print(error)
//                        }
//                    }
//                    
//                }
//            }
//            // Update
//            let updateValues: [String: Any] =
//                [ "name" : name,
//                  "email" : email,
//                  "expertises" : expertises,
//                  "authKey" : User.encodeRawPassword(email, password: password),
//                  "profilePicURL" : profilePic
//                ]
//            // Save User
//            try! DatabaseManager().updateObject(theUser, updateValues: updateValues)
//
//            response.redirectTo("/")
//            
//        }
//        response.requestCompletedCallback()
//    }
//    
//    func getModelWithIdentifier(identifier: String) -> User? {
//
//        if let id = Int(identifier)  {
//            return getUserWithIdentifier(id)
//        } else {
//            return nil
//        }
//    }
//    
//    func edit(identifier: String, request: WebRequest, response: WebResponse) throws -> MustacheEvaluationContext.MapType {
//        
//        guard let post = getModelWithIdentifier(identifier) else {
//            return MustacheEvaluationContext.MapType()
//        }
//        
//        let values: [String:Any] = ["user": post.keyValues()]
//        
//        return values
//    }
//    
//    
//    func new(request: WebRequest, response: WebResponse) {
//        
//        if let error = request.param("error") {
//            print(error)
//        }
//        
//        // Handle new post request
//        if let email = request.param("email"),
//            name = request.param("name"),
//            password = request.param("password1"),
//            password2 = request.param("password2"),
//            role = request.param("role")
//        {
//            
//            // Valid Article
//            guard password == password2 else {
//                response.setStatus(500, message: "The passwords did not match.")
//                return
//            }
//            var pictureURL: String = ""
//            // Get Profile Picture
//            if let uploadedFile = request.fileUploads.first {
//                
//                let fileName = uploadedFile.fileName
//                print("Profile Pic uploaded: \(fileName)")
//                
//                // Save profile picture to disk
//                if let file = uploadedFile.file {
//                    // Copy file 
//                    do {
//                        let saveLocation = request.documentRoot + "/resources/pictures/" + uploadedFile.fileName
//                        pictureURL = uploadedFile.fileName
//                        print(saveLocation)
//                        
//                        try file.copyTo(saveLocation, overWrite: true)
//                    } catch {
//                        print(error)
//                    }
//                }
//                
//            }
//            
//            do {
//                
//                let user = try User.create(name, email: email, password: password, pictureURL: pictureURL, role: role)
//                // Create Session
//                let session = response.getSession("user")
//                session["user_id"] = user._objectID
//                
//            } catch {
//                print(error)
//                response.setStatus(500, message: "The user was not able to be created.")
//
//                response.redirectTo(request.requestURI() + "?error=bad")
//                response.requestCompletedCallback()
//                return
//            }
//          
//            
//            response.redirectTo("/")
//        }
//        
//        response.requestCompletedCallback()
//    }
//    
//    func delete(identifier: Int, request: WebRequest, response: WebResponse) {
//        /*
//        if let postBSON = try! DatabaseManager().database.getCollection(Article).find(identifier) {
//            
//            do {
//                
//                let post = Article(bson: postBSON)
//                let query: [String: JSONValue] = ["_id": post.identifierDictionary!]
//                let jsonEncode = try JSONEncoder().encode(query)
//                
//                try! DatabaseManager().database.getCollection(Article).remove(try! BSON(json: jsonEncode))
//                
//            } catch {
//                print(error)
//            }
//            
//            
//        }
//        response.requestCompletedCallback()
// */
//    }
    
    let modelName = "user"
    
    let modelPluralName: String = "users"
    
    
    func list(request: WebRequest, response: WebResponse) throws -> MustacheEvaluationContext.MapType {
        
        
        // Get Articles
                
        let user = currentUser(request, response: response)!
        
        
        let values :MustacheEvaluationContext.MapType = ["userProfile": user.dictionary]
        return values
    }
    
    func getUserWithIdentifier(identifier: Int) -> User? {
        let db = try! DatabaseManager()
        guard let user = db.executeFetchRequest(User.self, predicate: ["identifier": identifier]).first else {
            return nil
        }
        
        return user
    }
    
    func show(identifier: String, request: WebRequest, response: WebResponse) throws -> MustacheEvaluationContext.MapType {
        // Query User Story
        let id = Int(identifier)!
        let tempUser: User? = getUserWithIdentifier(id)
        
        guard let user = tempUser else {
            return MustacheEvaluationContext.MapType()
        }
        
        var values: MustacheEvaluationContext.MapType = [:]
        values["user"] = user.dictionary

        return values
        
    }
    
    
    func update(identifier: Int, request: WebRequest, response: WebResponse) {
        
        /*
         // Handle new post request
         if let title = request.param("title"), body = request.param("body"), existingArticle = getArticleWithIdentifier(identifier), currentAuthor = currentUser(request, response: response) where currentAuthor.email == existingArticle.author.email {
         
         // Update post properties
         existingArticle.title = title
         existingArticle.body = body
         
         // Save Article
         do {
         try! DatabaseManager().database.getCollection(UserStory).save(try existingArticle.document())
         response.redirectTo("/\(modelName)s/\(identifier)")
         } catch {
         print(error)
         }
         }
//         */
//        let user = UserStory(title: "test", story: "")
//        response.redirectTo("\(userStory.pathURL)")
//        response.requestCompletedCallback()
    }
    
    
    func edit(identifier: String, request: WebRequest, response: WebResponse) throws -> MustacheEvaluationContext.MapType {
        
        
        guard let user = getUserWithIdentifier(Int(identifier)!) else {
            return MustacheEvaluationContext.MapType()
        }
        
        let values = ["user": user.dictionary] as  MustacheEvaluationContext.MapType
        return values
        
    }
    
    func new(request: WebRequest, response: WebResponse) {
        
        // Handle new post request
//        if let title = request.param("title"), body = request.param("body") {
//            
//            // Valid Article
//            let newUserStory = UserStory(title: title, story: body)
//            
//            // Save Article
//            do {
//                let databaseManager = try! DatabaseManager()
//                
//                newUserStory._objectID = databaseManager.generateUniqueIdentifier()
//                // Set Identifier
//                let userStoryCount = databaseManager.countForFetchRequest(UserStory)
//                guard userStoryCount > -1 else {
//                    throw CreateUserError.DatabaseError
//                }
//                
//                newUserStory.identifier = userStoryCount
//                try databaseManager.insertObject(newUserStory)
//                response.redirectTo("/")
//            } catch {
//                
//            }
//        }
//        
//        response.requestCompletedCallback()
    }
    
    func create(request: WebRequest, response: WebResponse) throws ->  MustacheEvaluationContext.MapType
    {
        /*
         let beforeValues = beforeAction(request, response: response)
         
         guard var values = beforeValues else {
         return MustacheEvaluationContext.MapType()
         }
         return values
         */
        return MustacheEvaluationContext.MapType()
        
    }
    
    func delete(identifier: Int, request: WebRequest, response: WebResponse) {
//        let databseManager = try! DatabaseManager()
//        if let userStory = databseManager.getObject(UserStory.self, primaryKeyValue: identifier) {
//            try! databseManager.deleteObject(userStory)
//            
//        }
//        response.requestCompletedCallback()
    }
    
    
}