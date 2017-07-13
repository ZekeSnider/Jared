//
//  RESTModule.swift
//  Jared
//
//  Created by Zeke Snider on 4/5/16.
//  Copyright © 2016 Zeke Snider. All rights reserved.
//

import Foundation
import Alamofire
import SwiftyJSON
import JaredFramework
import Cocoa



struct RESTModule: RoutingModule {
    var routes: [Route] = []
    var description = "Integration with various REST APIs. Currently: Youtube, iTunes"
    let defaults = UserDefaults.standard
    var key: String {
        get {
            return defaults.string(forKey: "YoutubeSecret") ?? "None"
        }
    }
    
    init() {
        let youtube = Route(name: "Youtube Video Integration", comparisons: [.containsURL: ["youtu.be"]], call: self.youtubeCall, description: "Youtube integration to get details of youtube video url")
        let Reddit = Route(name: "Reddit comment integration", comparisons: [.containsURL: ["reddit.com"]], call: self.redditCall, description: "Reddit integration")
        let iTunes = Route(name: "iTunes link integration", comparisons: [.containsURL: ["itunes.apple.com"]], call: self.iTunesCall, description: "iTunes url integration")
        let iTunesShort = Route(name: "iTunes shortlink", comparisons: [.containsURL: ["itun.es"]], call: self.iTunesShortCall, description: "itun.es")
        routes = [youtube, Reddit, iTunes, iTunesShort]
    }
    
    func getVideo(_ videoID: String, toChat: Room) {
        print(videoID)
        Alamofire.request("https://www.googleapis.com/youtube/v3/videos", parameters: ["key": key, "part": "snippet", "id": videoID]).responseString {response in
            print(response.result.value!)
            self.sendVideoInfo(response.result.value!, toChat: toChat)
        }
    }
    
    func getiTunesFromID(_ iTunesID: String, toChat: Room) {
        print(iTunesID)
        Alamofire.request("https://itunes.apple.com/lookup", parameters: ["id": iTunesID]).responseString {response in
            print(response.result.value!)
            self.sendiTunesInfo(response.result.value!, toChat: toChat)
        }
    }
    
    func sendVideoInfo(_ videoJSON: String, toChat: Room) {
        if let dataFromString = videoJSON.data(using: String.Encoding.utf8, allowLossyConversion: false) {
            let JSONParse = JSON(data: dataFromString)
            let myVideo = JSONParse["items"][0]["snippet"].dictionaryValue
            
            if let videoTitle = myVideo["title"], let uploader = myVideo["channelTitle"], let publishDate = myVideo["publishedAt"]
            {
                let VideoString = "\"\(videoTitle)\"\nuploaded by \(uploader)\non \(convertYoutubeDate(publishDate.stringValue))"
                SendText(VideoString, toRoom: toChat)
                
                
                /*
                let localFileName = UUID().uuidString
                
                if let thumbnailURL = myVideo["thumbnails"]?["standard"]["url"].string {
                    //TODO: FIX THIS
                    /*
                    Alamofire.download(thumbnailURL, method: .GET,
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
                */*/
            }
        }
    }
    
    func sendRedditComment(_ commentJSON: String, toChat: Room) {
        if let dataFromString = commentJSON.data(using: String.Encoding.utf8, allowLossyConversion: false) {
            let JSONParse = JSON(data: dataFromString)
            let commentAuthor = JSONParse[1]["data"]["children"][0]["data"]["author"]
            let commentBody = JSONParse[1]["data"]["children"][0]["data"]["body"]
            let message = "\"\(commentBody)\" -\(commentAuthor)"
            SendText(message, toRoom: toChat)
        }
        
    }
    
    
    func sendiTunesInfo(_ resultJSON: String, toChat: Room) {
        if let dataFromString = resultJSON.data(using: String.Encoding.utf8, allowLossyConversion: false) {
            
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
    
    func send(_ commentJSON: String, toChat: Room) {
        if let dataFromString = commentJSON.data(using: String.Encoding.utf8, allowLossyConversion: false) {
            let JSONParse = JSON(data: dataFromString)
            let commentAuthor = JSONParse[1]["data"]["children"][0]["data"]["author"]
            let commentBody = JSONParse[1]["data"]["children"][0]["data"]["body"]
            let message = "\"\(commentBody)\" -\(commentAuthor)"
            SendText(message, toRoom: toChat)
        }
        
    }
    
    func redditCall(_ url: String, myRoom: Room) -> Void {
        let JSONurl: String = url + ".json"
        if JSONurl.contains("/comments/") {
            Alamofire.request(JSONurl).responseString {response in
                self.sendRedditComment(response.result.value!, toChat: myRoom)
            }
        }
        
    }
    
    func youtubeCall(_ url:String, myRoom: Room) -> Void {
        let regexMatches = matchesForRegexInText("(?<=v(=|/))([-a-zA-Z0-9_]+)|(?<=youtu.be/)([-a-zA-Z0-9_]+)", text:url)
        if let youtubeID = regexMatches[safe:0] {
            getVideo(youtubeID, toChat: myRoom)
        }
    }
    
    func iTunesCall(_ url:String, myRoom: Room) -> Void {
        let regexMatches = matchesForRegexInText("id(\\d+)", text:url)
        if let iTunesID = regexMatches[safe:0] {
            getiTunesFromID(String(iTunesID.characters.dropFirst(2)), toChat: myRoom)
        }
    }
    
    func iTunesShortCall(_ url:String, myRoom: Room) -> Void {
        //URL(string: url)!.resolveWithCompletionHandler {
         //   print(($0))
            self.iTunesCall(url, myRoom: myRoom)
       // }
    }
    
    
}

func convertYoutubeDate(_ inputDateString: String) -> String {
    let formatter = DateFormatter()
    
    formatter.locale = Locale(identifier: "en_US_POSIX")
    formatter.timeZone = (TimeZone.current)
    formatter.formatterBehavior = .default
    formatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSS'Z'"
    
    let indate = formatter.date(from: inputDateString)
    
    let outputFormatter = DateFormatter()
    outputFormatter.dateFormat = "hh:mm a MM/dd/yy"
    var outputDate:String?
    if let d = indate {
        outputDate = outputFormatter.string(from: d)
    }
    
    return outputDate!;
}


func convertJSONDate(_ twitterDate: String) -> String {
    let formatter = DateFormatter()
    
    formatter.locale = Locale(identifier: "en_US_POSIX")
    formatter.timeZone = (TimeZone.current)
    formatter.formatterBehavior = .default
    formatter.dateFormat = "eee MMM dd HH:mm:ss ZZZZ yyyy"
    
    let indate = formatter.date(from: twitterDate)
    
    let outputFormatter = DateFormatter()
    outputFormatter.dateFormat = "hh:mm a MM/dd/yy"
    var outputDate:String?
    if let d = indate {
        outputDate = outputFormatter.string(from: d)
    }
    
    return outputDate!;
}


