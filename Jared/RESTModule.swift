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
    var description = "Integration with various REST APIs. Currently: Youtube"
    
    init() {
        let youtube = Route(comparisons: [.ContainsURL: "youtu.be"], call: self.youtubeCall)
        routes = [youtube]
    }
    
    func getVideo(videoID: String, toChat: Room) {
        print(videoID)
        Alamofire.request(.GET, "https://www.googleapis.com/youtube/v3/videos", parameters: ["key": "AIzaSyCVvhTV-pnl4Ue6Y8-lZWIrhSsoYxPy-fM", "part": "snippet", "id": videoID]).responseString {response in
            print(response.result.value!)
            self.sendVideoInfo(response.result.value!, toChat: toChat)
        }
    }
    
    func sendVideoInfo(videoJSON: String, toChat: Room) {
        if let dataFromString = videoJSON.dataUsingEncoding(NSUTF8StringEncoding, allowLossyConversion: false) {
            let JSONParse = JSON(data: dataFromString)
            let myVideo = JSONParse["items"][0]["snippet"].dictionaryValue
            
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
        }
    }
    
    func youtubeCall(url:String, myRoom: Room) -> Void {
        let regexMatches = matchesForRegexInText("(?<=v(=|/))([-a-zA-Z0-9_]+)|(?<=youtu.be/)([-a-zA-Z0-9_]+)", text:url)
        if let youtubeID = regexMatches[safe:0] {
            getVideo(youtubeID, toChat: myRoom)
        }
    }
}


