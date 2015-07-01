//
//  Parsers.swift
//  Schegg
//
//  Created by Osei Poku on 6/17/15.
//  Copyright © 2015 Chegg, Inc. All rights reserved.
//

import Foundation

protocol Parser {
    typealias ResultType
    func parse(data: NSData) -> ResultType?
}

enum Element: String {
    case RoomLists = "RoomLists"
    case Rooms = "Rooms"
    case Address = "Address"
    case Room = "Room"
    case Id = "Id"
    case Email = "EmailAddress"
    case Name = "Name"
    case Available = "MergedFreeBusy"
}

class RoomListsParser: NSObject, NSXMLParserDelegate, Parser {
    var roomLists: [RoomList]? = nil
    var currentName: String? = nil
    var currentEmail: String? = nil
    var currentElements: [Element] = []

    func parse(data: NSData) -> [RoomList]? {
        let parser = NSXMLParser(data: data)
        parser.delegate = self
        parser.shouldProcessNamespaces = true
        parser.parse()
        return roomLists
    }

    func parser(parser: NSXMLParser, didStartElement elementName: String, namespaceURI: String?, qualifiedName qName: String?, attributes attributeDict: [NSObject : AnyObject]) {
        switch elementName {
        case Element.RoomLists.rawValue:
            currentElements.append(.RoomLists)
            roomLists = []
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
                roomLists?.append(RoomList(name: name, email: email))
            }
            currentElements.removeLast()
        case Element.RoomLists.rawValue, Element.Email.rawValue, Element.Name.rawValue:
            currentElements.removeLast()
        default: ()
        }
    }

    func parser(parser: NSXMLParser, foundCharacters string: String?) {
        if let currentElement = currentElements.last {
            switch currentElement {
            case .Email:
                currentEmail? += string!
            case .Name:
                currentName? += string!
            default: ()
            }
        }
    }
}

class RoomsParser: NSObject, NSXMLParserDelegate, Parser {
    var rooms: [Room]? = nil
    var currentName: String? = nil
    var currentEmail: String? = nil
    var currentElements: [Element] = []

    func parse(data: NSData) -> [Room]? {
        let parser = NSXMLParser(data: data)
        parser.delegate = self
        parser.shouldProcessNamespaces = true
        parser.parse()
        return rooms
    }
    func parser(parser: NSXMLParser, didStartElement elementName: String, namespaceURI: String?, qualifiedName qName: String?, attributes attributeDict: [NSObject : AnyObject]) {
        switch elementName {
        case Element.Rooms.rawValue:
            currentElements.append(.Rooms)
            rooms = []
        case Element.Room.rawValue:
            currentElements.append(.Room)
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
        case Element.Room.rawValue:
            if let name = currentName, email = currentEmail {
                rooms?.append(Room(name: name, email: email))
            }
            currentElements.removeLast()
        case Element.Rooms.rawValue, Element.Email.rawValue, Element.Name.rawValue:
            currentElements.removeLast()
        default: ()
        }
    }

    func parser(parser: NSXMLParser, foundCharacters string: String?) {
        if let currentElement = currentElements.last {
            switch currentElement {
            case .Email:
                currentEmail? += string!
            case .Name:
                currentName? += string!
            default: ()
            }
        }
    }
}

class AvailabilityParser: NSObject, NSXMLParserDelegate, Parser {
    var currentAvailability: String? = ""
    var decodedAvailability: [Bool]? = []
    var availabilitys: [[Bool]]? = []
    var currentElements: [Element] = []
    
    func parse(data: NSData) -> [[Bool]]? {
        let parser = NSXMLParser(data: data)
        parser.delegate = self
        parser.shouldProcessNamespaces = true
        parser.parse()
        return availabilitys
    }
    func parser(parser: NSXMLParser, didStartElement elementName: String, namespaceURI: String?, qualifiedName qName: String?, attributes attributeDict: [NSObject : AnyObject]) {
        switch elementName {
        case Element.Available.rawValue:
            currentElements.append(.Available)
        default: ()
        }
    }
    
    func parser(parser: NSXMLParser, didEndElement elementName: String, namespaceURI: String?, qualifiedName qName: String?) {
        switch elementName {
        case Element.Available.rawValue:
            if let currentAvailability = currentAvailability{
                for c in currentAvailability{
                    if(c == "0"){
                        decodedAvailability?.append(true)
                    }else{
                        decodedAvailability?.append(false)
                    }
                }
                availabilitys?.append(decodedAvailability!)
            }
            currentAvailability = ""
            currentElements.removeLast()
        case Element.Rooms.rawValue, Element.Email.rawValue, Element.Name.rawValue:
            currentElements.removeLast()
        default: ()
        }
    }
    
    func parser(parser: NSXMLParser, foundCharacters string: String?) {
        if let currentElement = currentElements.last {
            switch currentElement {
            case .Available:
                currentAvailability? += string!
            default: ()
            }
        }
    }
}