//
//  AuthController.swift
//  ScrumManager
//
//  Created by Ben Johnson on 15/04/2016.
//  Copyright © 2016 Benjamin Johnson. All rights reserved.
//

import Foundation
import PerfectLib

protocol AuthController: RESTController {
    
    func currentUser(request: WebRequest, response: WebResponse) -> User?
    
    func getUserInformation(request: WebRequest, response: WebResponse) -> [String: Any]
    
    var anoymousUserCanView: Bool { get }

}

extension AuthController {
    
    var anoymousUserCanView: Bool {
        return false
    }
    
    func currentUser(request: WebRequest, response: WebResponse) -> User? {
        
        // Obtain Session
        let currentSession = response.getSession("user")
        print(currentSession["user_id"])
        
        guard let currentUserID = currentSession["user_id"] as? String, let user = User(email: currentUserID) else {
            return  nil
        }
        
        return user
    }
    
    func getUserInformation(request: WebRequest, response: WebResponse) -> [String: Any] {
        print("Getting user informmation")

        if let user = currentUser(request, response: response) {
            print("Got user informmation")

            return ["user":["name": user.name] as [String: Any]]
        } else {
            return [:]
        }
    }
    
    func handleRequest(request: WebRequest, response: WebResponse) {
        
        print("Using AUTH Controller")

        print(request.requestURI())
        
        let requestMethod = RequestMethod(rawValue: request.requestMethod())!
        
        var values = getUserInformation(request, response: response)
        
        
        if let identifier = request.urlVariables["id"] {
            
            switch(requestMethod) {
            case .POST, .PATCH, .PUT:
                fatalError()
                //update(identifier, request: request, response: response)
                
            case .DELETE:
                fatalError()
                //delete(identifier, request: request, response: response)
                
            case .GET:
                
                switch(identifier) {
                case "new":
                    
                    
                    let templateURL = request.documentRoot + "/templates/\(modelPluralName)/new.mustache"
                    
                    // Call Show
                    values.update(try! create(request, response: response))
                    response.appendBodyString(loadPageWithTemplate(request, url: templateURL, withValues: values))
                    response.requestCompletedCallback()
                    
                default:
                    
                    if let action = request.urlVariables["action"]{
                        print("Found action \(action)")
                        
                        // Call Show
                        let templateURL = request.documentRoot + "/templates/\(modelPluralName)/edit.mustache"
                        values.update( try! edit(identifier, request: request, response: response))
                    //    var values = try! edit(identifier, request: request, response: response)
                        values["url"] = "/\(modelName)s/\(identifier)"
                        
                        response.appendBodyString(loadPageWithTemplate(request, url: templateURL, withValues: values))
                        response.requestCompletedCallback()
                        
                        
                    } else {
                        
                        let templateURL = request.documentRoot + "/templates/\(modelPluralName)/show.mustache"
                        //let values = try! show(identifier, request: request, response: response)
                        values.update(try! show(identifier, request: request, response: response))
                        response.appendBodyString(loadPageWithTemplate(request, url: templateURL, withValues: values))
                        response.requestCompletedCallback()
                    }
                }
                
                
                
            }
            
        } else {
            
            if requestMethod == .POST {
                
                new(request, response: response)
                
            } else {
                print("Listing models")
                // Show all posts
                let templateURL: String
                if request.format == "json" {
                    templateURL = request.documentRoot + "//\(modelPluralName)/index.json.mustache"
                } else {
                    templateURL = request.documentRoot + "/templates/\(modelPluralName)/index.mustache"
                }
                
               // var values = try! list(request, response: response)
                values.update(try! list(request, response: response))
                print("getting user information")
                print("DICT: \(getUserInformation(request, response: response))")
                values.update(getUserInformation(request, response: response))

                response.appendBodyString(loadPageWithTemplate(request, url: templateURL, withValues: values))
                response.requestCompletedCallback()
                
            }
        }
    }
    
    
    
    
    
    
    
    
    
    
    
    
    
}