//
//  UserNewHandler.swift
//  ScrumManager
//
//  Created by Fagan Ooi on 29/04/2016.
//  Copyright © 2016 Benjamin Johnson. All rights reserved.
//

import Foundation
import PerfectLib

class UserNewHandler: RequestHandler {
    
    // TODO: Show alert/get login user
   
    func handleRequest(request: WebRequest, response: WebResponse) {
        let user = User.userWithEmail("wko232@gmail.com")
        if request.requestMethod() == "GET"{
        
            let templateURL = request.documentRoot + "/templates/template.mustache"
            let indexURL = request.documentRoot + "/templates/users/new.mustache"
            var values = [:] as [String: Any]
            
            values["user"] = user?.asDictionary()

            let content = parseMustacheFromURL(indexURL, withValues: values)
            let templateContent = ["content": content] as [String: Any]
            
            response.appendBodyString(parseMustacheFromURL(templateURL, withValues: templateContent))
            response.requestCompletedCallback()
        }else{
            if let name = request.param("name"),
                email = request.param("email"),
                role = request.param("role"),
                password = request.param("password1"),
                confirmPassword = request.param("password2"),
                roleUser = request.param("role"){
            //                var profilePic = ""
            //                if request.fileUploads.count > 0{
            //                    let filePic = request.fileUploads
            //                    profilePic = filePic[0].tmpFileName
            //
            //                }else{
            //                    profilePic = (user?.profilePictureURL)!
            //                }
            
                if name != "" || email != "" || role != "" || password != confirmPassword || roleUser != ""{
            
                }else{
//                    UserController.new(request: request, response: response)
                }
            }
        
        }
    }

    
}