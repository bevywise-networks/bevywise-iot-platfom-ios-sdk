//
//  LoginResultDelegate.swift
//  Bevywise Platform Connector
//
//  Created by Prince J on 29/05/18.
//  Copyright © 2018 Bevywise Networks Inc. All rights reserved.
//

import Foundation

public protocol LoginResultDelegate {
    func onLoginSuccess(token: String, refreshToken: String, expiresIn: Int)
}

public protocol TokenRefreshDelegate {
    func onTokenRefreshSuccess(token: String, refreshToken: String, expiresIn: Int)
}

public protocol ClientListDelegate {
    func onGetClientListSuccess(clients: [[String: Any?]]?)
}

public protocol CommandsListDelegate {
    func onGetDeviceCmdsListSuccess(clientsCmdList: [String: Any?]?, nextPage: Bool, pageNo: Int)
}

public protocol DashboardDetailsDelegate {
    func onDashboardDetailsSuccess(dashboardData: [String: Any?]?)
}

public protocol DeviceAuthKeyDelegate {
    func onAuthKeyGenerated(authKeyData: [String: Any?]?)
}

public protocol DeviceDetailsDelegate {
    func onDeviceDetailsSuccess(dashboardDetails: [String: Any?])
}

public protocol DeviceListDelegate {
    func onGetDeviceListSuccess(deviceList: [String: Any?]?, nextPage: Bool, pageNo: Int)
}

public protocol TopicsListDelegate {
    func onGetTopicListSuccess(topics: [[String: Any?]]?)
}

public protocol EventListDelegate {
    func onGetDeviceEventListSuccess(eventsList: [String: Any?]?, nextPage: Bool, pageNo: Int)
}

public protocol PlatformResponseDelegate {
    func onSuccess()
}

public protocol SignupDelegate {
    func onSignupSuccess(token: String, refreshToken: String, expiresIn: Int)
}
