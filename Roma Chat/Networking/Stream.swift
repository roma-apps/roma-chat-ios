//
//  Stream.swift
//  Roma Chat
//
//  Created by Monica Brinkman on 2019-05-22.
//  Copyright © 2019 Barrett Breshears. All rights reserved.
//

import UIKit
import Starscream

struct Stream {
    
    init(){
        
        var sss = StoreStruct.client.baseURL.replacingOccurrences(of: "https", with: "wss")
        sss = sss.replacingOccurrences(of: "http", with: "wss")
        socket = WebSocket(url: URL(string: "\(sss)/api/v1/streaming/user?access_token=\(StoreStruct.shared.currentInstance.accessToken)&stream=user")!)
        
    }
    
    static var shared = Stream()
    
    var socket: WebSocket
    
    func initStreams() {
        
//        guard let serverURL = URL.init(string: "https://social.myfreecams.com/api/v1/streaming/direct") else {return}
//
//
//        let source = LDEventSource(url: serverURL, httpHeaders: nil)
//
//        source.onMessage { (event) in
//            print("Event: \(String(describing: event)), Ready State: \(String(describing: event?.readyState)), Event Name: \(String(describing: event?.event)), Event Data: \(String(describing: event?.data))")
//
//        }
//
//        source.onError { (error) in
//            guard let theError = error  else {return}
//            print(theError.error ?? "")
//        }
//
//        source.open()
        
//        var sss = StoreStruct.client.baseURL.replacingOccurrences(of: "https", with: "wss")
//        sss = sss.replacingOccurrences(of: "http", with: "wss")
//        Stream.shared.socket = WebSocket(url: URL(string: "\(sss)/api/v1/streaming/user?access_token=\(StoreStruct.shared.currentInstance.accessToken)&stream=user")!)
//        Stream.shared.socket.onConnect = {
//            print("websocket is connected")
//        }
//        //websocketDidDisconnect
//        Stream.shared.socket.onDisconnect = { (error: Error?) in
//            print("websocket is disconnected")
//            print(error.debugDescription)
//        }
//        //websocketDidReceiveMessage
//        Stream.shared.socket.onText = { (text: String) in
//            print("Got Response: \(text)")
//        }
//        //websocketDidReceiveData
//        Stream.shared.socket.onData = { (data: Data) in
//            print("got some data: \(data.count)")
//        }
//        Stream.shared.socket.connect()
        
        streamDataDirect()
    }
    
    func streamDataDirect() {
        if UserDefaults.standard.object(forKey: "accessToken") == nil {} else {
            if (UserDefaults.standard.object(forKey: "streamToggle") == nil) || (UserDefaults.standard.object(forKey: "streamToggle") as! Int == 0) {
                
                var sss = StoreStruct.client.baseURL.replacingOccurrences(of: "https", with: "wss")
                sss = sss.replacingOccurrences(of: "http", with: "wss")
                Stream.shared.socket = WebSocket(url: URL(string: "\(sss)/api/v1/streaming/user?access_token=\(StoreStruct.shared.currentInstance.accessToken)&stream=user")!)
                 Stream.shared.socket.onConnect = {
                    print("websocket is connected")
                }
                //websocketDidDisconnect
                 Stream.shared.socket.onDisconnect = { (error: Error?) in
                    print("websocket is disconnected")
                }
                //websocketDidReceiveMessage
                 Stream.shared.socket.onText = { (text: String) in
                    
                    let data0 = text.data(using: .utf8)!
                    do {
                        let jsonResult = try JSONSerialization.jsonObject(with: data0, options: JSONSerialization.ReadingOptions.mutableContainers) as? [String: Any]
                        if let payload = jsonResult?["payload"] as? String {
                            print("JSON Payload: \(payload)")

//
//                            let jsonData = payload.data(using: .utf8)
//
//                            var dic: [String : Any]?
//                            do {
//                                dic = try JSONSerialization.jsonObject(with: jsonData!, options: []) as? [String : Any]
//
//                                print("dict: \(dic)")
//
//                                if let statusObj = dic?["status"] as? String {
//                                    print("Its string")
//
//                                } else if let statusObj = dic?["status"] as? [String: Any] {
//
//                                    print("Its dict")
//
//
//                                    let statusData = try JSONSerialization.data(withJSONObject: statusObj, options: .prettyPrinted)
//
//                                    var statusObject: Status?
//                                    do {
//                                        statusObject = try JSONDecoder().decode(Status.self, from: statusData)
//
//                                        print("dict: \(statusObject)")
//
//                                    } catch {
//                                        print(error.localizedDescription)
//                                    }
//
//                                } else if let statusObject = dic?["status"] as? Any {
//
//                                    print("Its any")
//                                }
                            
                                
//                                    if let statusData =  dic?["status"].data(using: .utf8) {
//                                        var statusObject: Status?
//                                        do {
//                                            statusObject = try JSONDecoder().decode(Status.self, from: statusData)
//
//                                            print("dict: \(statusObject)")
//
//                                        } catch {
//                                            print(error.localizedDescription)
//                                        }
//
//                                    }
                                
                                
//
//                            } catch {
//                                print(error.localizedDescription)
//                            }
//
                            if jsonResult?["event"] as? String == "notification" {
                                
                                print("")
                                Stream.shared.refreshConversations()

                                
                                //                            let te = SSEvent.init(type: "notification", data: re as! String)
                                //                            let data = te.data.data(using: .utf8)!
                                //                            guard let model = try? Notificationt.decode(data: data) else {
                                //                                return
                                //                            }
                                //
                                //                            if (model.status?.visibility) ?? Visibility.private == .direct {
                                //
                                //                                let request = Timelines.conversations(range: .since(id: StoreStruct.notificationsDirect.first?.id ?? "", limit: nil))
                                //                                StoreStruct.client.run(request) { (statuses) in
                                //                                    if let stat = (statuses.value) {
                                //                                        if stat.isEmpty {} else {
                                //                                            //                                        DispatchQueue.main.async {
                                //                                            if (UserDefaults.standard.object(forKey: "badgeMentd") == nil) || (UserDefaults.standard.object(forKey: "badgeMentd") as! Int == 0) {
                                //                                                StoreStruct.badgeCount2 = StoreStruct.badgeCount2 + 1
                                //                                                self.tabBar.items?[2].badgeValue = "\(StoreStruct.badgeCount2)" ?? "1"
                                //                                                self.tabBar.items?[2].badgeColor = Colours.tabSelected
                                //                                            }
                                //                                            StoreStruct.notificationsDirect = stat + StoreStruct.notificationsDirect
                                //                                            StoreStruct.notificationsDirect = StoreStruct.notificationsDirect.removeDuplicates()
                                //                                            NotificationCenter.default.post(name: Notification.Name(rawValue: "updateDM"), object: nil)
                                //                                            //                                        }
                                //                                        }
                                //                                    }
                                //                                }
                                //                            }
                            } else if jsonResult?["event"] as? String == "update" {
                                print("")
                               // guard let status = payload["status"] else { return }
                              //  print("\(status)") // delectus aut autem
                                Stream.shared.refreshConversations()
                                
                                
                            } else if jsonResult?["event"] as? String == "delete" {
                                print("")
                                
                            }
                        }

                        
                    } catch {
                        print("json parse failed on data stream")
                        return
                    }
                }
                //websocketDidReceiveData
                 Stream.shared.socket.onData = { (data: Data) in
                    print("got some data: \(data.count)")
                }
                 Stream.shared.socket.connect()
            }
        }
    }
    
    func refreshConversations() {
        ApiManager.shared.fetchConversations { error in
            NotificationCenter.default.post(name: Notification.Name(rawValue: "conversations_refreshed"), object: nil)

        }
    }
}
