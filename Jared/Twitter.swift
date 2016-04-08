//
//  Twitter.swift
//  Pods
//
//  Created by Jared Derulo on 4/5/16.
//
//

import Foundation
import Alamofire

class Twitter {
    var accessToken: String?
    let consumerKey = "xaiF2Dezl1ljwdEovPjFM4VUb"
    let consumerSecret = "g0mE3IIVpcOX1Og3DU4vJSmBmeK6hgtcJYYmEbRnohh6dRIFmT"
    let baseUrlString = "https://api.twitter.com/1.1/"
    let pageSize = 20
    
    init() {
        print("hi")
    }
    func authenticate(completionBlock: Void -> ()) {
        
        if accessToken != nil {
            completionBlock()
        }
        
        let credentials = "\(consumerKey):\(consumerSecret)"
        let headers = ["Authorization": "Bearer \(credentials)"]
        let params: [String : AnyObject] = ["grant_type": "client_credentials"]
        
        Alamofire.request(.POST, "https://api.twitter.com/oauth2/token", headers: headers, parameters: params)
            .responseJSON { response in
                if let JSON = response.result.value {
                    self.accessToken = JSON.objectForKey("access_token") as? String
                    completionBlock()
                }
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