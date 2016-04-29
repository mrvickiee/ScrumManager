//
//  TestHandler.swift
//  ScrumManager
//
//  Created by Ben Johnson on 20/04/2016.
//  Copyright © 2016 Benjamin Johnson. All rights reserved.
//

import Foundation
import PerfectLib

class TestHandler: RequestHandler {
    
    func handleRequest(request: WebRequest, response: WebResponse) {
        let templateURL = request.documentRoot + "/templates/template.mustache"
        let indexURL = request.documentRoot + "/templates/users/index.mustache"
        let values = [:] as [String: Any]
        let content = parseMustacheFromURL(indexURL, withValues: values)
        let templateContent = ["content": content] as [String: Any]
        
        response.appendBodyString(parseMustacheFromURL(templateURL, withValues: templateContent))
        response.requestCompletedCallback()
        
    }
    
}

class EditHandler: RequestHandler {
    
    func handleRequest(request: WebRequest, response: WebResponse) {
        let templateURL = request.documentRoot + "/templates/template.mustache"
        let indexURL = request.documentRoot + "/templates/users/edit.mustache"
        let values = [:] as [String: Any]
        let content = parseMustacheFromURL(indexURL, withValues: values)
        let templateContent = ["content": content] as [String: Any]
        
        response.appendBodyString(parseMustacheFromURL(templateURL, withValues: templateContent))
        response.requestCompletedCallback()
        
    }
    
}


class ShowHandler: RequestHandler {
    
    func handleRequest(request: WebRequest, response: WebResponse) {
        let templateURL = request.documentRoot + "/templates/template.mustache"
        let indexURL = request.documentRoot + "/templates/users/show.mustache"
        let values = [:] as [String: Any]
        let content = parseMustacheFromURL(indexURL, withValues: values)
        let templateContent = ["content": content] as [String: Any]
        
        response.appendBodyString(parseMustacheFromURL(templateURL, withValues: templateContent))
        response.requestCompletedCallback()
        
    }
    
}

class NewHandler: RequestHandler {
    
    func handleRequest(request: WebRequest, response: WebResponse) {
        let templateURL = request.documentRoot + "/templates/template.mustache"
        let indexURL = request.documentRoot + "/templates/users/new.mustache"
        let values = [:] as [String: Any]
        let content = parseMustacheFromURL(indexURL, withValues: values)
        let templateContent = ["content": content] as [String: Any]
        
        response.appendBodyString(parseMustacheFromURL(templateURL, withValues: templateContent))
        response.requestCompletedCallback()
        
    }
    
}