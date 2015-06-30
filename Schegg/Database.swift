//
//  Database.swift
//  Schegg
//
//  Created by Osei Poku on 6/30/15.
//  Copyright (c) 2015 Chegg, Inc. All rights reserved.
//

import Foundation


struct RoomList {
    let name: String
    let email: String
}

struct Room {
    let name: String
    let email: String
}

struct Availability {
    let start: NSDate
    let end: NSDate
    let interval: NSTimeInterval
    let availability: [Bool]
    var fullRange: NSTimeInterval {
        return end.timeIntervalSinceDate(start)
    }
    func getAvailability(#startDate:NSDate, endDate:NSDate) -> Availability? {
        let maxStart = start.laterDate(startDate)
        let minEnd = end.earlierDate(endDate)
        if maxStart.timeIntervalSinceDate(minEnd) >= 0 {
            return nil
        }
        let startIndex = Int(maxStart.timeIntervalSinceDate(start)/interval)
        let endIndex = Int(minEnd.timeIntervalSinceDate(start)/interval)
        return Availability(start: maxStart, end: minEnd, interval: interval, availability: Array(availability[startIndex...endIndex]))
    }


}

class DB {

    var availabilityDict : [String:[Availability]] = [:]
    var roomsDict: [String:[Room]] = [:]
    var roomLists: [RoomList] = []
    func updateRooms() {
//        let now = NSDate()
//        roomLists { (roomLists) -> Void in
//            for roomList in roomLists {
//                self.rooms(roomList, completion: { (rooms) -> Void in
//                    for room in rooms {
//                        self.availablity(room, start: now, end: NSDate(timeInterval: 6000, sinceDate: now), completion: { (availability) -> Void in
//
//                        })
//                    }
//                })
//            }
//        }
    }

    func roomLists (completion:([RoomList]) -> Void) {
        if roomLists.count > 0 {
            completion(roomLists)
        } else {
            OutlookAPI.getRoomLists({ (roomLists) -> Void in
                self.roomLists = roomLists
                completion(roomLists)
            })
        }
    }
    func rooms(roomList: RoomList, completion:([Room]) -> Void) {
        if let rooms = roomsDict[roomList.email] {
            completion(rooms)
        } else {
            OutlookAPI.getRooms(roomList.email, callback: { (rooms) -> Void in
                self.roomsDict[roomList.email] = rooms
                completion(rooms)
            })
        }
    }
    func availablity (room: Room, start:NSDate, end:NSDate, completion:(Availability?) -> Void) {
        if start.timeIntervalSinceDate(end) > 0 {
            completion(nil)
        }
        if let availabilityList = availabilityDict[room.email] {
            for availability in availabilityList {
                if let av = availability.getAvailability(startDate: start, endDate: end) {
                    completion(av)
                    return
                }
            }
        }
        OutlookAPI.getAvailability([room.email], start: getDayStart(start), end: getDayEnd(end)) { (availabilityList) -> Void in
            if availabilityList.count == 0 {
                completion(nil)
            } else {
                let availability = availabilityList[0]
                var currentAvailability = self.availabilityDict[room.email] ?? []
                currentAvailability.append(availability)
                completion(availability.getAvailability(startDate: start, endDate: end))
            }
        }

    }

    func getDayStart(date:NSDate) -> NSDate {
        return date
    }

    func getDayEnd(date:NSDate) -> NSDate {
        return date
    }
}