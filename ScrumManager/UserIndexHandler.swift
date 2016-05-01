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
    
    // TODO: how to get information of whose are login
    func handleRequest(request: WebRequest, response: WebResponse) {
        let templateURL = request.documentRoot + "/templates/template.mustache"
        let indexURL = request.documentRoot + "/templates/users/index.mustache"
        var values = [:] as [String: Any]

        let user = User.userWithEmail("wko232@gmail.com")
        values["user"] = user?.asDictionary()
        
        let content = parseMustacheFromURL(indexURL, withValues: values)
        let templateContent = ["content": content] as [String: Any]
        
        response.appendBodyString(parseMustacheFromURL(templateURL, withValues: templateContent))
        response.requestCompletedCallback()
        
        
    }
    
}