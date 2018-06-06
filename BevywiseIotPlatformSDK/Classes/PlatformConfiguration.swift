//
//  PlatformConfiguration.swift
//  Bevywise Platform Connector
//
//  Created by Prince J on 29/05/18.
//  Copyright © 2018 Bevywise Networks Inc. All rights reserved.
//

import Foundation

public class PlatformConfiguration {
    let url: String
    let username: String
    let password: String
    let clientId: String
    let clientSecret: String
    
    public init(url: String, username: String, password: String, clientId: String, clientSecret: String) {
        self.url = url
        self.username = username
        self.password = password
        self.clientId = clientId
        self.clientSecret = clientSecret
    }
    
    public convenience init(url: String, clientId: String, clientSecret: String) {
        self.init(url: url, username: "", password: "", clientId: clientId, clientSecret: clientSecret)
    }
}
