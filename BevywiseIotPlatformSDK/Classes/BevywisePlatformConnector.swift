//
//  BevywisePlatformConnector.swift
//  Bevywise Platform Connector
//
//  Created by Prince J on 29/05/18.
//  Copyright © 2018 Bevywise Networks Inc. All rights reserved.
//

import Foundation

public enum DevicePermission: Int {
    case READ, WRITE, READ_WRITE
}

public class BevywisePlatformConnector {
    private init() {}
    public static let shared = BevywisePlatformConnector()
    public var platformConfigutation: PlatformConfiguration?
    
    public func login(delegate: LoginResultDelegate, onFailed: ((String) -> Void)?) {
        if let platformConfiguration = platformConfigutation {
            var dataTask: URLSessionDataTask?
            let urlComponent = URLComponents(string: platformConfiguration.url+"/bwiot/api/v1/auth/login/")
            if (!platformConfiguration.username.isEmpty && !platformConfiguration.password.isEmpty) {
                let postString = "username=\(platformConfiguration.username)&password=\(platformConfiguration.password)&client_id=\(platformConfiguration.clientId)&client_secret=\(platformConfiguration.clientSecret)&grant_type=password"
                
                guard let url = urlComponent?.url else { return }
                
                var urlRequest = URLRequest(url: url)
                NetworkConnection.shared.networkOperation(&dataTask, &urlRequest, postString, onSuccess: { (data) in
                    let status = data["bwapi-status"] as? String ?? ""
                    if status == "success" {
                        let token = data["token"] as? String ?? ""
                        let refreshToken = data["refresh_token"] as? String ?? ""
                        let expiresIn = data["expires_in"] as? Int ?? 0
                        delegate.onLoginSuccess(token: token, refreshToken: refreshToken, expiresIn: expiresIn)
                    } else {
                        let reasonForFailure = data["bwapi-status-reason"] as? String ?? "";
                        onFailed?(reasonForFailure)
                    }
                }, onFailure: { (errorDescription, _) in
                    onFailed?(errorDescription)
                })
            }
        }
    }
    
    public func refreshToken(delegate: TokenRefreshDelegate, token: String, onFailed: ((String) -> Void)?) {
        if let platformConfiguration = platformConfigutation {
            var dataTask: URLSessionDataTask?
            let urlComponent = URLComponents(string: platformConfiguration.url+"/bwiot/api/v1/auth/refresh/")
            if (!platformConfiguration.username.isEmpty && !platformConfiguration.password.isEmpty) {
                let postString = "username=\(platformConfiguration.username)&password=\(platformConfiguration.password)&client_id=\(platformConfiguration.clientId)&client_secret=\(platformConfiguration.clientSecret)&grant_type=refresh_token"
                guard let url = urlComponent?.url else { return }
                
                var urlRequest = URLRequest(url: url)
                NetworkConnection.shared.networkOperation(&dataTask, &urlRequest, postString, onSuccess: { (data) in
                    let status = data["bwapi-status"] as? String ?? ""
                    if status == "success" {
                        let token = data["token"] as? String ?? ""
                        let refreshToken = data["refresh_token"] as? String ?? ""
                        let expiresIn = data["expires_in"] as? Int ?? 0
                        delegate.onTokenRefreshSuccess(token: token, refreshToken: refreshToken, expiresIn: expiresIn)
                    } else {
                        let reasonForFailure = data["bwapi-status-reason"] as? String ?? "";
                        onFailed?(reasonForFailure)
                    }
                }, onFailure: { (errorDescription, _) in
                    onFailed?(errorDescription)
                })
            }
        }
    }
    
    public func setNotificationToken(delegate: PlatformResponseDelegate, pushNotificationToken: String, token: String, onFailed: ((String) -> Void)?) {
        if let platformConfiguration = platformConfigutation {
            var dataTask: URLSessionDataTask?
            let urlComponent = URLComponents(string:platformConfiguration.url+"/bwiot/api/v1/auth/pushfcm/")
            let postString = "notification_token=\(pushNotificationToken)device=ios"
            guard let url = urlComponent?.url else { return }
            
            var urlRequest = URLRequest(url: url)
            NetworkConnection.shared.networkOperation(&dataTask, &urlRequest, postString,token, onSuccess: { (data) in
                let status = data["bwapi-status"] as? String ?? ""
                if status == "success" {
                    delegate.onSuccess()
                } else {
                    let reasonForFailure = data["bwapi-status-reason"] as? String ?? "";
                    onFailed?(reasonForFailure)
                }
            }, onFailure: { (errorDescription, _) in
                onFailed?(errorDescription)
            })
        }
    }
    
    public func logout(delegate: PlatformResponseDelegate, token: String, onFailed: ((String) -> Void)?) {
        if let platformConfiguration = platformConfigutation {
            var dataTask: URLSessionDataTask?
            let urlComponent = URLComponents(string: platformConfiguration.url+"/bwiot/api/v1/auth/logout/")
            let postString = "client_id=\(platformConfiguration.clientId)&client_secret=\(platformConfiguration.clientSecret)&token=\(token)"
            guard let url = urlComponent?.url else { return }
            
            var urlRequest = URLRequest(url: url)
            NetworkConnection.shared.networkOperation(&dataTask, &urlRequest, postString,token, onSuccess: { (data) in
                let status = data["bwapi-status"] as? String ?? ""
                if status == "success" {
                    delegate.onSuccess()
                } else {
                    let reasonForFailure = data["bwapi-status-reason"] as? String ?? "";
                    onFailed?(reasonForFailure)
                }
            }, onFailure: { (errorDescription, _) in
                onFailed?(errorDescription)
            })
        }
    }
    
    public func signup(delegate: SignupDelegate, username: String, password: String, onFailed: ((String) -> Void)?) {
        if let platformConfiguration = platformConfigutation {
            var dataTask: URLSessionDataTask?
            let urlComponent = URLComponents(string:platformConfiguration.url+"/bwiot/api/v1/auth/signup/")
            if (!platformConfiguration.username.isEmpty && !platformConfiguration.password.isEmpty) {
                let postString = "username=\(username)&password=\(password)&client_id=\(platformConfiguration.clientId)&client_secret=\(platformConfiguration.clientSecret)&grant_type=password"
                guard let url = urlComponent?.url else { return }
                
                var urlRequest = URLRequest(url: url)
                NetworkConnection.shared.networkOperation(&dataTask, &urlRequest, postString, onSuccess: { (data) in
                    let status = data["bwapi-status"] as? String ?? ""
                    if status == "success" {
                        let token = data["token"] as? String ?? ""
                        let refreshToken = data["refresh_token"] as? String ?? ""
                        let expiresIn = data["expires_in"] as? Int ?? 0
                        self.platformConfigutation = PlatformConfiguration(url: platformConfiguration.url, username: username, password: password,clientId: platformConfiguration.clientId, clientSecret: platformConfiguration.clientSecret)
                        delegate.onSignupSuccess(token: token, refreshToken: refreshToken, expiresIn: expiresIn)
                    } else {
                        let reasonForFailure = data["bwapi-status-reason"] as? String ?? "";
                        onFailed?(reasonForFailure)
                    }
                }, onFailure: { (errorDescription, _) in
                    onFailed?(errorDescription)
                })
            }
        }
    }
    
    public func getDeviceAuthKey(delegate: DeviceAuthKeyDelegate, permission: DevicePermission, keyDescription: String, token: String, onFailed: ((String) -> Void)?) {
        if let platformConfiguration = platformConfigutation {
            var dataTask: URLSessionDataTask?
            var keyPermission = "Read"
            switch (permission) {
            case .READ:
                keyPermission = "Read"
                break
            case .WRITE:
                keyPermission = "Write"
                break
            case .READ_WRITE:
                keyPermission = "Read Write"
                break
            }
            let urlComponent = URLComponents(string:platformConfiguration.url+"/bwiot/api/v1/devicesecurity/generatekey/")
            let postString = "permissions=\(keyPermission)&key_desc=\(keyDescription)"
            guard let url = urlComponent?.url else { return }
                
            var urlRequest = URLRequest(url: url)
            NetworkConnection.shared.networkOperation(&dataTask, &urlRequest, postString, token, onSuccess: { (data) in
                let status = data["bwapi-status"] as? String ?? ""
                if status == "success" {
                    let authKeyData = data["data"] as? [String: Any?]
                    delegate.onAuthKeyGenerated(authKeyData: authKeyData)
                } else {
                    let reasonForFailure = data["bwapi-status-reason"] as? String ?? "";
                    onFailed?(reasonForFailure)
                }
            }, onFailure: { (errorDescription, _) in
                onFailed?(errorDescription)
            })
        }
    }
    
    public func getDeviceList(delegate: DeviceListDelegate, pageNo: Int, token: String, onFailed: ((String) -> Void)?) {
        if let platformConfiguration = platformConfigutation {
            var dataTask: URLSessionDataTask?
            let urlComponent = URLComponents(string:platformConfiguration.url+"/bwiot/api/v1/devices/")
            let postString = "page_no=\(pageNo)"
            guard let url = urlComponent?.url else { return }
            
            var urlRequest = URLRequest(url: url)
            NetworkConnection.shared.networkOperation(&dataTask, &urlRequest, postString,token, onSuccess: { (data) in
                let status = data["bwapi-status"] as? String ?? ""
                if status == "success" {
                    let deviceListData = data["data"] as? [String: Any?]
                    let nextPage = data["next_page"] as? Bool ?? false
                    let pageNo = data["page_no"] as? Int ?? 0
                    delegate.onGetDeviceListSuccess(deviceList: deviceListData, nextPage: nextPage, pageNo: pageNo)
                } else {
                    let reasonForFailure = data["bwapi-status-reason"] as? String ?? "";
                    onFailed?(reasonForFailure)
                }
            }, onFailure: { (errorDescription, _) in
                onFailed?(errorDescription)
            })
        }
    }
    
    public func editDeviceName(delegate: PlatformResponseDelegate, deviceId: String, deviceName: String, token: String, onFailed: ((String) -> Void)?) {
        if let platformConfiguration = platformConfigutation {
            var dataTask: URLSessionDataTask?
            let urlComponent = URLComponents(string:platformConfiguration.url+"/bwiot/api/v1/devices/edit_device_name/")
            let postString = "device_id=\(deviceId)&new_device_name=\(deviceName)"
            guard let url = urlComponent?.url else { return }
            
            var urlRequest = URLRequest(url: url)
            NetworkConnection.shared.networkOperation(&dataTask, &urlRequest, postString,token, onSuccess: { (data) in
                let status = data["bwapi-status"] as? String ?? ""
                if status == "success" {
                    delegate.onSuccess()
                } else {
                    let reasonForFailure = data["bwapi-status-reason"] as? String ?? "";
                    onFailed?(reasonForFailure)
                }
            }, onFailure: { (errorDescription, _) in
                onFailed?(errorDescription)
            })
        }
    }
    
    public func getDeviceEvents(delegate: EventListDelegate, deviceId: String, pageNo: Int, token: String, onFailed: ((String) -> Void)?) {
        if let platformConfiguration = platformConfigutation {
            var dataTask: URLSessionDataTask?
            let urlComponent = URLComponents(string:platformConfiguration.url+"/bwiot/api/v1/devices/get_device_recv_detail/")
            let postString = "page_no=\(pageNo)&device_id=\(deviceId)"
            guard let url = urlComponent?.url else { return }
            
            var urlRequest = URLRequest(url: url)
            NetworkConnection.shared.networkOperation(&dataTask, &urlRequest, postString,token, onSuccess: { (data) in
                let status = data["bwapi-status"] as? String ?? ""
                if status == "success" {
                    let deviceEventsData = data["recv_data"] as? [String: Any?]
                    let nextPage = (data["page_nav_data"] as? [String: Any?])?["next_page"] as? Bool ?? false
                    let pageNo = (data["page_nav_data"] as? [String: Any?])?["page_no"] as? Int ?? 0
                    delegate.onGetDeviceEventListSuccess(eventsList: deviceEventsData, nextPage: nextPage, pageNo: pageNo)
                } else {
                    let reasonForFailure = data["bwapi-status-reason"] as? String ?? "";
                    onFailed?(reasonForFailure)
                }
            }, onFailure: { (errorDescription, _) in
                onFailed?(errorDescription)
            })
        }
    }
    
    public func getReceivedCommandsForDevice(delegate: CommandsListDelegate, deviceId: String, pageNo: Int, token: String, onFailed: ((String) -> Void)?) {
        if let platformConfiguration = platformConfigutation {
            var dataTask: URLSessionDataTask?
            let urlComponent = URLComponents(string:platformConfiguration.url+"/bwiot/api/v1/devices/get_device_sent_detail/")
            let postString = "page_no=\(pageNo)&device_id=\(deviceId)"
            guard let url = urlComponent?.url else { return }
            
            var urlRequest = URLRequest(url: url)
            NetworkConnection.shared.networkOperation(&dataTask, &urlRequest, postString,token, onSuccess: { (data) in
                let status = data["bwapi-status"] as? String ?? ""
                if status == "success" {
                    let deviceCommandsData = data["recv_data"] as? [String: Any?]
                    let nextPage = (data["page_nav_data"] as? [String: Any?])?["next_page"] as? Bool ?? false
                    let pageNo = (data["page_nav_data"] as? [String: Any?])?["page_no"] as? Int ?? 0
                    delegate.onGetDeviceCmdsListSuccess(clientsCmdList: deviceCommandsData, nextPage: nextPage, pageNo: pageNo)
                } else {
                    let reasonForFailure = data["bwapi-status-reason"] as? String ?? "";
                    onFailed?(reasonForFailure)
                }
            }, onFailure: { (errorDescription, _) in
                onFailed?(errorDescription)
            })
        }
    }
    
    public func getClientListForTopic(delegate: ClientListDelegate, token: String, onFailed: ((String) -> Void)?) {
        if let platformConfiguration = platformConfigutation {
            var dataTask: URLSessionDataTask?
            let urlComponent = URLComponents(string:platformConfiguration.url+"/bwiot/api/v1/ic/get_clients_related_to_the_topic/")
            guard let url = urlComponent?.url else { return }
            
            var urlRequest = URLRequest(url: url)
            NetworkConnection.shared.networkOperation(&dataTask, &urlRequest,token: token, onSuccess: { (data) in
                let status = data["bwapi-status"] as? String ?? ""
                if status == "success" {
                    let deviceClientsData = data["clients"] as? [[String: Any?]]
                    delegate.onGetClientListSuccess(clients: deviceClientsData)
                } else {
                    let reasonForFailure = data["bwapi-status-reason"] as? String ?? "";
                    onFailed?(reasonForFailure)
                }
            }, onFailure: { (errorDescription, _) in
                onFailed?(errorDescription)
            })
        }
    }
    
    public func getActiveTopicSubscriptionofDevice(delegate: TopicsListDelegate, deviceId: String, token: String, onFailed: ((String) -> Void)?) {
        if let platformConfiguration = platformConfigutation {
            var dataTask: URLSessionDataTask?
            let urlComponent = URLComponents(string:platformConfiguration.url+"/bwiot/api/v1/ic/get_active_topics_for_this_device/")
            let postString = "device_id=\(deviceId)"
            guard let url = urlComponent?.url else { return }
            
            var urlRequest = URLRequest(url: url)
            NetworkConnection.shared.networkOperation(&dataTask, &urlRequest, postString,token, onSuccess: { (data) in
                let status = data["bwapi-status"] as? String ?? ""
                if status == "success" {
                    let activeSubscriptionData = data["topics"] as? [[String: Any?]]
                    delegate.onGetTopicListSuccess(topics: activeSubscriptionData)
                } else {
                    let reasonForFailure = data["bwapi-status-reason"] as? String ?? "";
                    onFailed?(reasonForFailure)
                }
            }, onFailure: { (errorDescription, _) in
                onFailed?(errorDescription)
            })
        }
    }
    
    public func getActiveSubscriptionListner(delegate: TopicsListDelegate, token: String, onFailed: ((String) -> Void)?) {
        if let platformConfiguration = platformConfigutation {
            var dataTask: URLSessionDataTask?
            let urlComponent = URLComponents(string:platformConfiguration.url+"/bwiot/api/v1/ic/get_active_topics/")
            guard let url = urlComponent?.url else { return }
            
            var urlRequest = URLRequest(url: url)
            NetworkConnection.shared.networkOperation(&dataTask, &urlRequest,token: token, onSuccess: { (data) in
                let status = data["bwapi-status"] as? String ?? ""
                if status == "success" {
                    let activeSubscriptionData = data["active_topics"] as? [[String: Any?]]
                    delegate.onGetTopicListSuccess(topics: activeSubscriptionData)
                } else {
                    let reasonForFailure = data["bwapi-status-reason"] as? String ?? "";
                    onFailed?(reasonForFailure)
                }
            }, onFailure: { (errorDescription, _) in
                onFailed?(errorDescription)
            })
        }
    }
    
    public func getDashboardDetails(delegate: DashboardDetailsDelegate, token: String, onFailed: ((String) -> Void)?) {
        if let platformConfiguration = platformConfigutation {
            var dataTask: URLSessionDataTask?
            let urlComponent = URLComponents(string:platformConfiguration.url+"/bwiot/api/v1/dashboard/")
            guard let url = urlComponent?.url else { return }
            
            var urlRequest = URLRequest(url: url)
            NetworkConnection.shared.networkOperation(&dataTask, &urlRequest,token: token, onSuccess: { (data) in
                let status = data["bwapi-status"] as? String ?? ""
                if status == "success" {
                    let dashboardData = data["data"] as? [String: Any?]
                    delegate.onDashboardDetailsSuccess(dashboardData: dashboardData)
                } else {
                    let reasonForFailure = data["bwapi-status-reason"] as? String ?? "";
                    onFailed?(reasonForFailure)
                }
            }, onFailure: { (errorDescription, _) in
                onFailed?(errorDescription)
            })
        }
    }
    
    public func getDeviceDetails(delegate: DeviceDetailsDelegate, deviceId: String, token: String, onFailed: ((String) -> Void)?) {
        if let platformConfiguration = platformConfigutation {
            var dataTask: URLSessionDataTask?
            let urlComponent = URLComponents(string:platformConfiguration.url+"/bwiot/api/v1/devices/get_device_detail/")
            let postString = "device_id=\(deviceId)"
            guard let url = urlComponent?.url else { return }
            
            var urlRequest = URLRequest(url: url)
            NetworkConnection.shared.networkOperation(&dataTask, &urlRequest, postString,token, onSuccess: { (data) in
                let status = data["bwapi-status"] as? String ?? ""
                if status == "success" {
                    delegate.onDeviceDetailsSuccess(dashboardDetails: data)
                } else {
                    let reasonForFailure = data["bwapi-status-reason"] as? String ?? "";
                    onFailed?(reasonForFailure)
                }
            }, onFailure: { (errorDescription, _) in
                onFailed?(errorDescription)
            })
        }
    }
    
    public func sendCommandsToTopic(delegate: PlatformResponseDelegate, topic: String, commandToSend: String, token: String, onFailed: ((String) -> Void)?) {
        if let platformConfiguration = platformConfigutation {
            var dataTask: URLSessionDataTask?
            let urlComponent = URLComponents(string:platformConfiguration.url+"/bwiot/api/v1/ic/send_command_to_topic/")
            let postString = "topic=\(topic)&command=\(commandToSend)"
            guard let url = urlComponent?.url else { return }
            
            var urlRequest = URLRequest(url: url)
            NetworkConnection.shared.networkOperation(&dataTask, &urlRequest, postString,token, onSuccess: { (data) in
                let status = data["bwapi-status"] as? String ?? ""
                if status == "success" {
                    delegate.onSuccess()
                } else {
                    let reasonForFailure = data["bwapi-status-reason"] as? String ?? "";
                    onFailed?(reasonForFailure)
                }
            }, onFailure: { (errorDescription, _) in
                onFailed?(errorDescription)
            })
        }
    }
    
    public func sendCommandsToDevice(delegate: PlatformResponseDelegate, deviceId: String, commandToSend: String, token: String, topic: String, onFailed: ((String) -> Void)?) {
        if let platformConfiguration = platformConfigutation {
            var dataTask: URLSessionDataTask?
            let urlComponent = URLComponents(string:platformConfiguration.url+"/bwiot/api/v1/ic/send_command_to_device/")
            let postString = "topic=\(topic)&command=\(commandToSend)"
            guard let url = urlComponent?.url else { return }
            
            var urlRequest = URLRequest(url: url)
            NetworkConnection.shared.networkOperation(&dataTask, &urlRequest, postString,token, onSuccess: { (data) in
                let status = data["bwapi-status"] as? String ?? ""
                if status == NSLocalizedString("ApiSuccess", comment: "success") {
                    delegate.onSuccess()
                } else {
                    let reasonForFailure = data["bwapi-status-reason"] as? String ?? "";
                    onFailed?(reasonForFailure)
                }
            }, onFailure: { (errorDescription, _) in
                onFailed?(errorDescription)
            })
        }
    }
    
}
