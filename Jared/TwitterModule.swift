//
//  TwitterModule.swift
//  Jared
//
//  Created by Zeke Snider on 4/9/16.
//  Copyright © 2016 Zeke Snider. All rights reserved.
//

import Foundation
import Alamofire
import JaredFramework
import SwiftyJSON

private extension String {
    func getBase64() -> String {
        let credentialData = self.data(using: String.Encoding.utf8)!
        return credentialData.base64EncodedString(options: [])
    }
}

struct Tweet {
    var Text: String
}

class TwitterModule: RoutingModule {
    var routes: [Route] = []
    var description = "Twitter Integration"
    var accessToken: String?
    let defaults = UserDefaults.standard
    var consumerKey: String {
        get {
            return defaults.string(forKey: "TwitterKey") ?? "None"
        }
    }
    var consumerSecret: String {
        get {
            return defaults.string(forKey: "TwitterSecret") ?? "None"
        }
    }
    
    let baseUrlString = "https://api.twitter.com/1.1/"
    let pageSize = 20
    
    required init() {        
        let twitterStatus = Route(name: "Twitter Tweet Integration", comparisons: [.containsURL: ["twitter.com"]], call: self.twitterStatusID, description: "Twitter integration to get detail of a tweet URLs")
        
        routes = [twitterStatus]
    }
    
    
    func twitterStatusID(_ message:String, myRoom: Room) -> Void {
        if message.contains("/status") {
            let urlComp = message.components(separatedBy: "/status/")
            let tweetID = urlComp[1]
            getTweet(tweetID, sendToGroupID: myRoom.GUID)
        }
        else {
            let urlComp = message.components(separatedBy: "/")
            let count = urlComp.count
            getTwitterUser(urlComp[count-1], sendToGroupID: myRoom.GUID)
        }
        
    }
    
    func authenticate(_ completionBlock: @escaping (Void) -> ()) {
        if accessToken != nil {
            completionBlock()
        }
        
        //let credentials = "\(consumerKey):\(consumerSecret)"
        //let headers = ["Authorization": "Basic \(credentials.getBase64())"]
        let params: [String : AnyObject] = ["grant_type": "client_credentials" as AnyObject]
        
        Alamofire.request("https://api.twitter.com/oauth2/token", method: .get, parameters: params, encoding: JSONEncoding.default)
            .responseJSON { response in
                if let JSON = response.result.value as? NSDictionary {
                    print(response)
                    self.accessToken = JSON["access_token"] as? String
                    completionBlock()
                }
        }
    }
    func getTweet(_ fromID: String, sendToGroupID: String) {
        authenticate {
            guard let token = self.accessToken else {
                // TODO: Show authentication error
                return
            }
            
            let headers = ["Authorization": "Bearer \(token)"]
            let params: [String : AnyObject] = [
                "id" : fromID as AnyObject,
                "include_entities": false as AnyObject
            ]
            Alamofire.request(self.baseUrlString + "statuses/show.json", parameters: params, headers: headers)
                .responseString { response in
                    print(response.response ?? "no response")
                    
                    self.sendTweet(response.result.value!, toChat: sendToGroupID)
            }
            
        }
    }
    
    func getTwitterUser(_ fromUser: String, sendToGroupID: String) {
        authenticate {
            guard let token = self.accessToken else {
                // TODO: Show authentication error
                return
            }
            
            let headers = ["Authorization": "Bearer \(token)"]
            let params: [String : AnyObject] = [
                "screen_name" : fromUser as AnyObject
            ]
            Alamofire.request(self.baseUrlString + "users/show.json", parameters: params, headers: headers)
                .responseString { response in
                    print(response.response ?? "no response")
                    
                    self.sendTwitterUser(response.result.value!, toChat: sendToGroupID)
            }
            
        }
    }
    
    func sendTweet(_ tweetJSON: String, toChat: String) {
        if let dataFromString = tweetJSON.data(using: String.Encoding.utf8, allowLossyConversion: false) {
            let JSONParse = JSON(data: dataFromString)
            let TweetString = "\"\(JSONParse["text"].stringValue)\"\n-\(JSONParse["user"]["name"].stringValue)\n\(convertJSONDate(JSONParse["created_at"].stringValue))"
            SendText(TweetString, toRoom: Room(GUID: toChat))
        }
    }
    
    func sendTwitterUser(_ tweetJSON: String, toChat: String) {
        if let dataFromString = tweetJSON.data(using: String.Encoding.utf8, allowLossyConversion: false) {
            let JSONParse = JSON(data: dataFromString)
            let TweetString = "\(JSONParse["name"].stringValue)\n\"\(JSONParse["description"].stringValue)\"\n\(JSONParse["statuses_count"]) Tweets\n\(JSONParse["followers_count"]) Followers\n\(JSONParse["friends_count"]) Following\nJoined Twitter on \(convertJSONDate(JSONParse["created_at"].stringValue))\n"
            SendText(TweetString, toRoom: Room(GUID: toChat))
        }
    }
    
    func getTimelineForScreenName(_ screenName: String) {
        
        authenticate {
            
            guard let token = self.accessToken else {
                // TODO: Show authentication error
                return
            }
            
            let headers = ["Authorization": "Bearer \(token)"]
            let params: [String : AnyObject] = [
                "screen_name" : screenName as AnyObject,
                "count": self.pageSize as AnyObject
            ]
            Alamofire.request(self.baseUrlString + "statuses/user_timeline.json", parameters: params, headers: headers)
                .responseJSON { response in
                    print(response.response ?? "no response")
                    
                    if let JSON = response.result.value {
                        print(JSON)
                    }
            }
        }
    }
    
}
