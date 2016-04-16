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
import JaredFramework


struct RESTModule: RoutingModule {
    var routes: [Route] = []
    var description = "Integration with various REST APIs. Currently: Youtube"
    
    init() {
        let youtube = Route(comparisons: [.ContainsURL: "youtu.be"], call: self.youtubeCall, description: "Youtube integration to get details of youtube video url")
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
            
            if let videoTitle = myVideo["title"], uploader = myVideo["channelTitle"], publishDate = myVideo["publishedAt"]
                {
                    let VideoString = "\(videoTitle) uploaded by \(uploader) \non \(publishDate)"
                    SendText(VideoString, toRoom: toChat)
                    
                    let localFileName = NSUUID().UUIDString
                    
                    if let thumbnailURL = myVideo["thumbnails"]?["standard"]["url"].string {
                        Alamofire.download(.GET, thumbnailURL,
                            destination: { (temporaryURL, response) in
                                let localPath = getAppSupportDirectory().URLByAppendingPathComponent(localFileName + response.suggestedFilename!)
                                return localPath
                        })
                            .response { (request, response, _, error) in
                                print(response)
                                let localPath = getAppSupportDirectory().URLByAppendingPathComponent(localFileName + response!.suggestedFilename!)
                                SendImage(localPath.path!, toRoom: toChat, blockThread: true)
                                try! NSFileManager.defaultManager().removeItemAtPath(localPath.path!)
                                
                                
                                print("Downloaded file to \(localPath)!")
                        }
                    }
            }
            
        } catch _ {
            print("error")
        }*/
    }
}


