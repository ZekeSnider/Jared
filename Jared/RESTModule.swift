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
import Cocoa

extension NSURL
{
    func resolveWithCompletionHandler(completion: NSURL -> Void)
    {
        let originalURL = self
        let req = NSMutableURLRequest(URL: originalURL)
        req.HTTPMethod = "HEAD"
        
        NSURLSession.sharedSession().dataTaskWithRequest(req) { body, response, error in
            completion(response?.URL ?? originalURL)
            }.resume()
    }
}


struct RESTModule: RoutingModule {
    var routes: [Route] = []
    var description = "Integration with various REST APIs. Currently: Youtube"
    
    init() {
        let youtube = Route(name: "Youtube Video Integration", comparisons: [.ContainsURL: ["youtu.be"]], call: self.youtubeCall, description: "Youtube integration to get details of youtube video url")
        let Reddit = Route(name: "Reddit comment integration", comparisons: [.ContainsURL: ["reddit.com"]], call: self.redditCall, description: "Reddit integration")
        let iTunes = Route(name: "iTunes link integration", comparisons: [.ContainsURL: ["itunes.apple.com"]], call: self.iTunesCall, description: "iTunes url integration")
        let iTunesShort = Route(name: "iTunes shortlink", comparisons: [.ContainsURL: ["itun.es"]], call: self.iTunesShortCall, description: "itun.es")
        routes = [youtube, Reddit, iTunes, iTunesShort]
    }
    
    func apiTest() {
        Alamofire.request(.GET, "https://www.googleapis.com/youtube/v3/videos", parameters: ["key": "AIzaSyCVvhTV-pnl4Ue6Y8-lZWIrhSsoYxPy-fM", "part": "snippet", "id": "eXhNtH8CrbA"]).responseJSON {response in
            print(response.result.value)
        }
    }
    
    func getVideo(videoID: String, toChat: Room) {
        print(videoID)
        Alamofire.request(.GET, "https://www.googleapis.com/youtube/v3/videos", parameters: ["key": "AIzaSyCVvhTV-pnl4Ue6Y8-lZWIrhSsoYxPy-fM", "part": "snippet", "id": videoID]).responseString {response in
            print(response.result.value!)
            self.sendVideoInfo(response.result.value!, toChat: toChat)
        }
    }
    
    func getiTunesFromID(iTunesID: String, toChat: Room) {
        print(iTunesID)
        Alamofire.request(.GET, "https://itunes.apple.com/lookup", parameters: ["id": iTunesID]).responseString {response in
            print(response.result.value!)
            self.sendiTunesInfo(response.result.value!, toChat: toChat)
        }
    }
    
    func sendVideoInfo(videoJSON: String, toChat: Room) {
        if let dataFromString = videoJSON.dataUsingEncoding(NSUTF8StringEncoding, allowLossyConversion: false) {
            let JSONParse = JSON(data: dataFromString)
            let myVideo = JSONParse["items"][0]["snippet"].dictionaryValue
            
            if let videoTitle = myVideo["title"], uploader = myVideo["channelTitle"], publishDate = myVideo["publishedAt"]
            {
                let VideoString = "\"\(videoTitle)\"\nuploaded by \(uploader)\non \(convertYoutubeDate(publishDate.stringValue))"
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
    
    func sendRedditComment(commentJSON: String, toChat: Room) {
        if let dataFromString = commentJSON.dataUsingEncoding(NSUTF8StringEncoding, allowLossyConversion: false) {
            let JSONParse = JSON(data: dataFromString)
            let commentAuthor = JSONParse[1]["data"]["children"][0]["data"]["author"]
            let commentBody = JSONParse[1]["data"]["children"][0]["data"]["body"]
            let message = "\"\(commentBody)\" -\(commentAuthor)"
            SendText(message, toRoom: toChat)
        }
        
    }
    
    
    func sendiTunesInfo(resultJSON: String, toChat: Room) {
        if let dataFromString = resultJSON.dataUsingEncoding(NSUTF8StringEncoding, allowLossyConversion: false) {
            
            let JSONParse = JSON(data: dataFromString)
            
            let theResult = JSONParse["results"][0]
            
            let collectionName = theResult["collectionName"]
            let type = theResult["collectionType"]
            let artistName = theResult["artistName"]
            let price = theResult["collectionPrice"]
            let currency = theResult["currency"]
            let genre = theResult["primaryGenreName"]
            let trackCount = theResult["trackCount"]
            
            
            let message = "\(collectionName)\nAn \(type) by \(artistName)\nGenre: \(genre)\n\(trackCount) tracks\n\(price) \(currency)"
            SendText(message, toRoom: toChat)
        }

    }
    
    func send(commentJSON: String, toChat: Room) {
        if let dataFromString = commentJSON.dataUsingEncoding(NSUTF8StringEncoding, allowLossyConversion: false) {
            let JSONParse = JSON(data: dataFromString)
            let commentAuthor = JSONParse[1]["data"]["children"][0]["data"]["author"]
            let commentBody = JSONParse[1]["data"]["children"][0]["data"]["body"]
            let message = "\"\(commentBody)\" -\(commentAuthor)"
            SendText(message, toRoom: toChat)
        }
        
    }
    
    func redditCall(url: String, myRoom: Room) -> Void {
        let JSONurl: String = url + ".json"
        if JSONurl.containsString("/comments/") {
            Alamofire.request(.GET, JSONurl).responseString {response in
                self.sendRedditComment(response.result.value!, toChat: myRoom)
            }
        }
        
    }
    
    func youtubeCall(url:String, myRoom: Room) -> Void {
        let regexMatches = matchesForRegexInText("(?<=v(=|/))([-a-zA-Z0-9_]+)|(?<=youtu.be/)([-a-zA-Z0-9_]+)", text:url)
        if let youtubeID = regexMatches[safe:0] {
            getVideo(youtubeID, toChat: myRoom)
        }
    }
    
    func iTunesCall(url:String, myRoom: Room) -> Void {
        let regexMatches = matchesForRegexInText("id(\\d+)", text:url)
        if let iTunesID = regexMatches[safe:0] {
            getiTunesFromID(String(iTunesID.characters.dropFirst(2)), toChat: myRoom)
        }
    }
    
    func iTunesShortCall(url:String, myRoom: Room) -> Void {
        NSURL(string: url)!.resolveWithCompletionHandler {
            print(($0))  // prints https://itunes.apple.com/us/album/blackstar/id1059043043
            self.iTunesCall($0.absoluteString, myRoom: myRoom)
        }
    }
    
    
}

func convertYoutubeDate(inputDateString: String) -> String {
    let formatter = NSDateFormatter()
    
    formatter.locale = NSLocale(localeIdentifier: "en_US_POSIX")
    formatter.timeZone = (NSTimeZone.systemTimeZone())
    formatter.formatterBehavior = .BehaviorDefault
    formatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSS'Z'"
    
    let indate = formatter.dateFromString(inputDateString)
    
    let outputFormatter = NSDateFormatter()
    outputFormatter.dateFormat = "hh:mm a MM/dd/yy"
    var outputDate:String?
    if let d = indate {
        outputDate = outputFormatter.stringFromDate(d)
    }
    
    return outputDate!;
}


func convertJSONDate(twitterDate: String) -> String {
    let formatter = NSDateFormatter()
    
    formatter.locale = NSLocale(localeIdentifier: "en_US_POSIX")
    formatter.timeZone = (NSTimeZone.systemTimeZone())
    formatter.formatterBehavior = .BehaviorDefault
    formatter.dateFormat = "eee MMM dd HH:mm:ss ZZZZ yyyy"
    
    let indate = formatter.dateFromString(twitterDate)
    
    let outputFormatter = NSDateFormatter()
    outputFormatter.dateFormat = "hh:mm a MM/dd/yy"
    var outputDate:String?
    if let d = indate {
        outputDate = outputFormatter.stringFromDate(d)
    }
    
    return outputDate!;
}


