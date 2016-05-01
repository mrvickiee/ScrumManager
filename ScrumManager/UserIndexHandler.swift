//
//  UserIndexHandler.swift
//  ScrumManager
//
//  Created by Fagan Ooi on 29/04/2016.
//  Copyright © 2016 Benjamin Johnson. All rights reserved.
//

import Foundation
import PerfectLib

class UserIndexHandler: RequestHandler{

    func handleRequest(request: WebRequest, response: WebResponse) {
        let templateURL = request.documentRoot + "/templates/template.mustache"
        let indexURL = request.documentRoot + "/templates/users/index.mustache"
        var values = [:] as [String: Any]
        let ttt = UserController()
        do{
            let user2 = try ttt.list(request, response: response)
            print(user2);
        }catch{}
            let user = User.userWithEmail("wko232@gmail.com")
            values["user"] = user?.asDictionary()
            print(user)
            print(user?.name)
            print(user?.role)
            print(user?.expertises)
            print(user?.project)
            print(user?.profilePictureURL)
        
        let content = parseMustacheFromURL(indexURL, withValues: values)
        let templateContent = ["content": content] as [String: Any]
        
        response.appendBodyString(parseMustacheFromURL(templateURL, withValues: templateContent))
        response.requestCompletedCallback()
        
        
    }
    
}