//
//  RESTModule.swift
//  Jared
//
//  Created by Jared Derulo on 4/5/16.
//  Copyright © 2016 Zeke Snider. All rights reserved.
//

import Foundation
import Alamofire
import SwiftyJSON


struct RESTModule: RoutingModule {
    var routes: [Route] = []
    
    init() {
        let youtube = Route(comparisons: [.Contains: "https://www.youtube.com"], call: self.youtubeCall)
        routes = [youtube]
        
    }
    
    func apiTest() {
        Alamofire.request(.GET, "https://www.googleapis.com/youtube/v3/videos", parameters: ["key": "AIzaSyCVvhTV-pnl4Ue6Y8-lZWIrhSsoYxPy-fM", "part": "snippet", "id": "eXhNtH8CrbA"]).responseJSON {response in
            print(response.result.value)
        }
    }
    
    func youtubeCall(message:String, myRoom: Room) -> Void {
        apiTest()
        /*
        do {
            let regex = try NSRegularExpression(pattern: "v=(.+?)(?=$|&)", options: NSRegularExpressionOptions.CaseInsensitive)
            let match: NSTextCheckingResult? = regex.firstMatchInString(message, options: NSMatchingOptions(rawValue: 0), range: NSMakeRange(0, message.characters.count))
            print(match)
            let videoID = (message as NSString).substringWithRange(match!.range).stringByReplacingOccurrencesOfString("v=", withString: "")
            print(videoID)
            
            Alamofire.request(.GET, "https://gdata.youtube.com/feeds/api/videos/\(videoID)?v=2").responseJSON { response in
                
            }
            
        } catch _ {
            print("error")
        }*/
    }
}


