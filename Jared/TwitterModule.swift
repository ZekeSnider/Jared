//
//  TwitterModule.swift
//  Jared
//
//  Created by Zeke Snider on 4/9/16.
//  Copyright © 2016 Zeke Snider. All rights reserved.
//

import Foundation
import Alamofire
import SwiftyJSON

private extension String {
    func getBase64() -> String {
        let credentialData = self.dataUsingEncoding(NSUTF8StringEncoding)!
        return credentialData.base64EncodedStringWithOptions([])
    }
}

struct Tweet {
    var Text: String
}

class TwitterModule: RoutingModule {
    var routes: [Route] = []
    var description = "Twitter Integration"
    var accessToken: String?
    let consumerKey = "xV2TXhB3w0GPxuSAm6pIuzpwy"
    let consumerSecret = "0LxuGGcy2JugU8NjOkXDEvvCqRVwIrjM6WvmLQE7lcPFuMqdnk"
    
    
    
    let baseUrlString = "https://api.twitter.com/1.1/"
    let pageSize = 20
    
    init() {
        let twitterStatus = Route(comparisons: [.ContainsURL: "twitter.com"], call: self.twitterStatusID)
        
        routes = [twitterStatus]
        
        print("hi")
    }
    
    
    func twitterStatusID(message:String, myRoom: Room) -> Void {
        let urlComp = message.componentsSeparatedByString("/status/")
        let tweetID = urlComp[1]
        getTweet(tweetID, sendToGroupID: myRoom.GUID)
    }
    
    func authenticate(completionBlock: Void -> ()) {
        if accessToken != nil {
            completionBlock()
        }
        
        let credentials = "\(consumerKey):\(consumerSecret)"
        let headers = ["Authorization": "Basic \(credentials.getBase64())"]
        let params: [String : AnyObject] = ["grant_type": "client_credentials"]
        
        Alamofire.request(.POST, "https://api.twitter.com/oauth2/token", headers: headers, parameters: params)
            .responseJSON { response in
                if let JSON = response.result.value {
                    print(response)
                    self.accessToken = JSON.objectForKey("access_token") as? String
                    completionBlock()
                }
        }
    }
    func getTweet(fromID: String, sendToGroupID: String) {
        authenticate {
            guard let token = self.accessToken else {
                // TODO: Show authentication error
                return
            }
            
            let headers = ["Authorization": "Bearer \(token)"]
            let params: [String : AnyObject] = [
                "id" : fromID,
                "include_entities": false
            ]
            Alamofire.request(.GET, self.baseUrlString + "statuses/show.json", headers: headers, parameters: params)
                .responseString { response in
                    print(response.response)
                    
                    self.sendTweet(response.result.value!, toChat: sendToGroupID)
            }
            
        }
    }
    
    func sendTweet(tweetJSON: String, toChat: String) {
        if let dataFromString = tweetJSON.dataUsingEncoding(NSUTF8StringEncoding, allowLossyConversion: false) {
            let JSONParse = JSON(data: dataFromString)
            let TweetString = "\"\(JSONParse["text"].stringValue)\" -\(JSONParse["user"]["name"].stringValue) \n\(JSONParse["created_at"])"
            SendText(TweetString, toRoom: Room(GUID: toChat, buddyName: nil))
        }
    }
    
    func getTimelineForScreenName(screenName: String) {
        
        authenticate {
            
            guard let token = self.accessToken else {
                // TODO: Show authentication error
                return
            }
            
            let headers = ["Authorization": "Bearer \(token)"]
            let params: [String : AnyObject] = [
                "screen_name" : screenName,
                "count": self.pageSize
            ]
            Alamofire.request(.GET, self.baseUrlString + "statuses/user_timeline.json", headers: headers, parameters: params)
                .responseJSON { response in
                    print(response.response)
                    
                    if let JSON = response.result.value {
                        print(JSON)
                    }
            }
        }
    }
    
}