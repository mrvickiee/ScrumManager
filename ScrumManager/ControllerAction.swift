//
//  ControllerAction.swift
//  ScrumManager
//
//  Created by Ben Johnson on 18/05/2016.
//  Copyright © 2016 Benjamin Johnson. All rights reserved.
//

import Foundation
import PerfectLib

struct ControllerAction {
    
    let templateURL: String?
    
    let action: ((WebRequest,WebResponse, String) -> ())?
    
    let mustacheDataSource: ((WebRequest,WebResponse, String) -> [String: Any])?
    
    init(action: (WebRequest,WebResponse, String) -> ())
    {
        self.action = action
        
        templateURL = nil
        
        mustacheDataSource = nil
    }
    
    init(templateURL: String, mustacheDataSource: (WebRequest,WebResponse, String)  -> [String: Any]) {
        
        self.templateURL = templateURL
        
        self.mustacheDataSource = mustacheDataSource
        
        self.action = nil
        
    }
}