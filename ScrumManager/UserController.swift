//
//  AuthorController.swift
//  SwiftBlog
//
//  Created by Benjamin Johnson on 9/02/2016.
//  Copyright © 2016 Benjamin Johnson. All rights reserved.
//


import PerfectLib

class UserController: AuthController {
    
    let modelName = "user"
    
    let modelPluralName: String = "users"
    
    
    func list(request: WebRequest, response: WebResponse) throws -> MustacheEvaluationContext.MapType {
        // Get User
        let user = currentUser(request, response: response)!
        
        var values :MustacheEvaluationContext.MapType = ["userProfile": user.dictionary]
        var expertises = [[String:Any]]()
        for expertise in user.expertises{
            expertises.append(["expertise":expertise])
        }
        values["expertisesList"] = expertises
        return values
    }
    
    func getUserList() -> ArraySlice<User> {
        let db = try! DatabaseManager()
        let user = db.executeFetchRequest(User).suffixFrom(0)

        return user
    }
    
    func show(identifier: String, request: WebRequest, response: WebResponse) throws -> MustacheEvaluationContext.MapType {
        // Query User Story
        let tempUserList = getUserList()
        var userList = [[String:Any]]()
        
        for user in tempUserList{
            userList.append(["name":user.name, "email": user.email, "profilePicUrl": user.profilePictureURL])
        }
        var values: MustacheEvaluationContext.MapType = [:]
        values["userList"] = userList

        return values
        
    }
    
    
    func update(identifier: Int, request: WebRequest, response: WebResponse) {
        print("erer")
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
    
    // When load edit page
    func edit(identifier: String, request: WebRequest, response: WebResponse) throws -> MustacheEvaluationContext.MapType {
        
        
        guard let user = currentUser(request, response: response) else {
            return MustacheEvaluationContext.MapType()
        }
        
        let values = ["user": user.dictionary] as  MustacheEvaluationContext.MapType
        return values
        
    }
    
    // After Create Button is clicked
    func new(request: WebRequest, response: WebResponse) {
        if let error = request.param("error") {
            print(error)
        }
        
        // Handle new post request
        if let email = request.param("email"),
            name = request.param("name"),
            password = request.param("password"),
            password2 = request.param("password2"),
            role = request.param("role")
        {
            // Valid Article
            guard password == password2 else {
                response.setStatus(500, message: "The passwords did not match.")
                return
            }
            
            // Default pic
            let pictureURL: String = "/resources/default.jpg"
            
            do {
                
                _ = try User.create(name, email: email, password: password, pictureURL: pictureURL, role: role)
                
            } catch {
                print(error)
                response.setStatus(500, message: "The user was not able to be created.")
                
                response.redirectTo(request.requestURI() + "?error=bad")
                response.requestCompletedCallback()
                return
            }
            
            // FIXME: redirectPath
            response.redirectTo("/")
        }
        
        response.requestCompletedCallback()
    }
    
    // When create page is load
    func create(request: WebRequest, response: WebResponse) throws ->  MustacheEvaluationContext.MapType
    {
        return MustacheEvaluationContext.MapType()
    }
    
    func delete(identifier: Int, request: WebRequest, response: WebResponse) {
//        let databseManager = try! DatabaseManager()
//        if let userStory = databseManager.getObject(UserStory.self, primaryKeyValue: identifier) {
//            try! databseManager.deleteObject(userStory)
//            
//        }
//        response.requestCompletedCallback()
        print("ee")
    }
    
    
}