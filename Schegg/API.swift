//
//  API.swift
//  Schegg
//
//  Created by Osei Poku on 6/16/15.
//  Copyright © 2015 Chegg, Inc. All rights reserved.
//

import Foundation
let OutlookAPI = API()

class TemplateImporter {
    var data: NSData?
    var mData: NSMutableData?
    init(name: String, mutable: Bool = false) {
        if let resourceURL = NSBundle.mainBundle().URLForResource(name, withExtension: "xml") {
            if mutable {
                mData = NSMutableData(contentsOfURL: resourceURL)
            } else {
                data = NSData(contentsOfURL: resourceURL)
            }
        }
    }
}

class API : NSObject, NSURLSessionTaskDelegate, NSXMLParserDelegate {
    var username: String?
    var password: String?
    let url = NSURL(string: "https://outlook.office365.com/EWS/Exchange.asmx")!
    lazy var session: NSURLSession = NSURLSession(configuration: NSURLSessionConfiguration.defaultSessionConfiguration(), delegate: self, delegateQueue: nil)

    lazy var roomListsTemplate: TemplateImporter = TemplateImporter(name: "RoomLists")
    lazy var roomsTemplate: TemplateImporter = TemplateImporter(name: "Rooms")

    func getRoomLists (callback: ([RoomList]) -> Void) {
        if let inputData = roomListsTemplate.data {
            self.request(inputData, parser: RoomListsParser(), callback: callback)
        }
    }

    func getRooms (roomId: String, callback: ([Room]) -> Void) {
        if let inputData = roomsTemplate.data, inputString = NSString(data: inputData, encoding: NSUTF8StringEncoding) {
            let transformedString = inputString.stringByReplacingOccurrencesOfString("{{}}", withString: roomId)
            self.request(transformedString.dataUsingEncoding(NSUTF8StringEncoding)!, parser: RoomsParser(), callback: callback)
        }
    }

    func request<P:Parser> (inputData: NSData, parser: P, callback: (result: P.ResultType) -> Void) {
        let request = NSMutableURLRequest(URL: url)
        request.HTTPMethod = "POST"
        request.HTTPBody = inputData
        request.addValue("text/xml", forHTTPHeaderField: "Content-Type")
        let task = session.dataTaskWithRequest(request, completionHandler: { (data, response, error) in
            if let data = data, result = parser.parse(data) {
                dispatch_async(dispatch_get_main_queue(), { () -> Void in
                    callback(result: result)
                })
            }
        })
        task?.resume()
    }

    func URLSession(session: NSURLSession, task: NSURLSessionTask, didReceiveChallenge challenge: NSURLAuthenticationChallenge, completionHandler: (NSURLSessionAuthChallengeDisposition, NSURLCredential?) -> Void) {
        if let credential = NSURLCredentialStorage.sharedCredentialStorage().defaultCredentialForProtectionSpace(challenge.protectionSpace) {
            completionHandler(NSURLSessionAuthChallengeDisposition.UseCredential, credential)
        } else {
            submitCredentials(challenge, completionHandler:completionHandler)
        }
    }

    func submitCredentials(challenge: NSURLAuthenticationChallenge, completionHandler:(NSURLSessionAuthChallengeDisposition, NSURLCredential?) -> Void) {
        if let username = username, password = password {
            let credential = NSURLCredential(user: username, password: password, persistence: NSURLCredentialPersistence.Permanent)
            NSURLCredentialStorage.sharedCredentialStorage().setDefaultCredential(credential, forProtectionSpace: challenge.protectionSpace)
            completionHandler(NSURLSessionAuthChallengeDisposition.UseCredential, credential)
        } else {
            promptForCredentials(challenge, completionHandler: completionHandler)
        }
    }

    func promptForCredentials (challenge: NSURLAuthenticationChallenge, completionHandler:(NSURLSessionAuthChallengeDisposition, NSURLCredential?) -> Void) {
        dispatch_async(dispatch_get_main_queue()) { () -> Void in
            let auth = Authentication()
            auth.auth({ (email, password) -> Void in
                self.username = email
                self.password = password
                self.submitCredentials(challenge, completionHandler: completionHandler)
            })
        }
    }

}



