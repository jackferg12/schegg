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
}

struct RoomList {
    let name: String
    let email: String
}

struct Room {
    let name: String
    let email: String
}

class RoomListsParser: NSObject, NSXMLParserDelegate, Parser {
    var rooms: [RoomList]? = nil
    var currentName: String? = nil
    var currentEmail: String? = nil
    var currentElements: [Element] = []

    func parse(data: NSData) -> [RoomList]? {
        let parser = NSXMLParser(data: data)
        parser.delegate = self
        parser.shouldProcessNamespaces = true
        parser.parse()
        return rooms
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

    func parser(parser: NSXMLParser, didStartElement elementName: String, namespaceURI: String?, qualifiedName qName: String?, attributes attributeDict: [String : String]) {
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
}