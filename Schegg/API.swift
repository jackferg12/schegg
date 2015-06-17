//
//  API.swift
//  Schegg
//
//  Created by Osei Poku on 6/16/15.
//  Copyright © 2015 Chegg, Inc. All rights reserved.
//

import Foundation
let OutlookAPI = API()

enum Element: String {
    case RoomLists = "RoomLists"
    case Address = "Address"
    case Email = "EmailAddress"
    case Name = "Name"
}

struct RoomList {
    let name: String
    let email: String
}
class API : NSObject, NSURLSessionTaskDelegate, NSXMLParserDelegate {
    let username = ""
    let password = ""
    let url = NSURL(string: "https://outlook.office365.com/EWS/Exchange.asmx")!
    lazy var session: NSURLSession = NSURLSession(configuration: NSURLSessionConfiguration.defaultSessionConfiguration(), delegate: self, delegateQueue: nil)
    var rooms: [RoomList]? = nil
    var currentName: String? = nil
    var currentEmail: String? = nil
    var currentElements: [Element] = []
    func parseXML(data: NSData) {
        let parser = NSXMLParser(data: data)
        parser.delegate = self
        parser.shouldProcessNamespaces = true
        parser.shouldReportNamespacePrefixes = true
        parser.parse()
    }

    func parser(parser: NSXMLParser, didStartElement elementName: String, namespaceURI: String?, qualifiedName qName: String?, attributes attributeDict: [String : String]) {
        switch elementName {
        case Element.RoomLists.rawValue:
            currentElements.append(.RoomLists)
            rooms = []
        case Element.Address.rawValue:
            currentElements.append(.Address)
            currentName = ""
            currentEmail = ""
        case Element.Name.rawValue:
            currentElements.append(.Name)
        case Element.Email.rawValue:
            currentElements.append(.Email)
        default: ()
        }
    }
    func parser(parser: NSXMLParser, didEndElement elementName: String, namespaceURI: String?, qualifiedName qName: String?) {
        switch elementName {
        case Element.Address.rawValue:
            if let name = currentName, email = currentEmail {
                rooms?.append(RoomList(name: name, email: email))
            }
            currentElements.removeLast()
        case Element.RoomLists.rawValue, Element.Email.rawValue, Element.Name.rawValue:
            currentElements.removeLast()
        default: ()
        }
    }
    func parser(parser: NSXMLParser, foundCharacters string: String) {
        if let currentElement = currentElements.last {
            switch currentElement {
            case .Email:
                currentEmail? += string
            case .Name:
                currentName? += string
            default: ()
            }
        }
    }

    func getRoomList (callback: ([RoomList]) -> Void) {
        if let resourceURL = NSBundle.mainBundle().URLForResource("RoomLists", withExtension: "xml") {
            let request = NSMutableURLRequest(URL: url)
            request.HTTPMethod = "POST"
            request.HTTPBody = NSData(contentsOfURL: resourceURL)
            request.addValue("text/xml", forHTTPHeaderField: "Content-Type")
            let task = session.dataTaskWithRequest(request, completionHandler: { (data, response, error) -> Void in
                if let data = data {
                    self.parseXML(data)
                    if let rooms = self.rooms {
                        callback(rooms)
                    }
                }
            })
            task?.resume()
        }
    }

    func URLSession(session: NSURLSession, task: NSURLSessionTask, didReceiveChallenge challenge: NSURLAuthenticationChallenge, completionHandler: (NSURLSessionAuthChallengeDisposition, NSURLCredential?) -> Void) {
        let credential = NSURLCredential(user: username, password: password, persistence: NSURLCredentialPersistence.ForSession)
        completionHandler(NSURLSessionAuthChallengeDisposition.UseCredential, credential)
    }

}



