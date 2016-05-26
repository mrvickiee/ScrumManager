//
//  LoginHandler.swift
//  SwiftBlog
//
//  Created by Benjamin Johnson on 24/02/2016.
//  Copyright © 2016 Benjamin Johnson. All rights reserved.
//

import Foundation
import PerfectLib


class LogoutHandler: RequestHandler {
    
    func handleRequest(request: WebRequest, response: WebResponse) {
        
        // Logout current user
        let currentSession = response.getSession("user")
        currentSession["user_id"] = nil
        
        response.redirectTo("/")
        response.requestCompletedCallback()
    }
    
}

enum LoginError:Int,  ErrorType, CustomStringConvertible {
    
    case InvalidEmailPassword
    case EmailPasswordAbsent
    
    var description: String {
        switch self {
        case .InvalidEmailPassword:
            return "Invalid Login"
        case .EmailPasswordAbsent:
            return "Email and password must be provided"
        }
    }
    
}

class LoginHandler: RequestHandler {
    
    var authenticatedUser: User?
    
    func handleRequest(request: WebRequest, response: WebResponse) {
        
        
        
        if request.requestMethod() == "GET" {
//            let templateURL = request.documentRoot + "/templates/template.mustache"
            let indexURL = request.documentRoot + "/templates/login.mustache"
            var values = [:] as [String: Any]
            
            if let errorParam = request.param("error"), errorCode = Int(errorParam), error = LoginError(rawValue: errorCode)
            {
                let errorCallout = Callout(type: .Alert, message: error.description)
                values["callout"] = errorCallout.dictionary
            }

           
            response.appendBodyString(parseMustacheFromURL(indexURL, withValues: values))
            response.requestCompletedCallback()
            
        } else {
            print(request.urlVariables)
            
            if let email = request.param("email"), password = request.param("password") {

                // Get User with Email
                guard let user = User.userWithEmail(email) else {
                    
                    response.redirectTo(request.requestURI() + "?error=\(LoginError.InvalidEmailPassword.rawValue)")
                    return response.requestCompletedCallback()
                }
                
                // Encrpyt provided password
                let authKey = User.encodeRawPassword(email, password: password)

                if user.authKey == authKey {
                    // Successful
                    
                    // Setup Session
                    let session = response.getSession("user")
                    session["user_id"] = user._objectID
                    
                    let db = try! DatabaseManager()
                    if let project = db.executeFetchRequest(Project.self).first {
                        session.setProject(project)
                    }
                
                    
                    response.redirectTo("/")
                }
            } else {
                response.redirectTo(request.requestURI() + "?error=\(LoginError.EmailPasswordAbsent.rawValue)")
            }
            
            response.requestCompletedCallback()

        }
        
        
      
    }
    
}