//
//  RoomsViewController.swift
//  Schegg
//
//  Created by Osei Poku on 6/18/15.
//  Copyright © 2015 Chegg, Inc. All rights reserved.
//

import UIKit

class RoomsViewController: UITableViewController {
    var roomList: RoomList? {
        didSet {
            if let roomList = roomList {
                title = "\(roomList.name)"
                OutlookAPI.getRooms(roomList.email, callback: { (rooms) -> Void in
                    self.rooms = rooms
                })
            }
        }
    }

    var rooms: [Room] = [] {
        didSet {
            tableView.reloadData()
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.registerClass(UITableViewCell.self, forCellReuseIdentifier: "Cell")
    }

    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return rooms.count
    }

    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("Cell", forIndexPath: indexPath) as! UITableViewCell

        cell.textLabel?.text = rooms[indexPath.row].name

        return cell
    }

}
