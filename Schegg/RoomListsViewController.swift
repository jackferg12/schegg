//
//  FirstViewController.swift
//  Schegg
//
//  Created by Osei Poku on 6/16/15.
//  Copyright (c) 2015 Chegg, Inc. All rights reserved.
//

import UIKit

class RoomListsViewController: UITableViewController {
    var rooms:[RoomList] = [] {
        didSet {
            tableView.reloadData()
        }
    }

    required init(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        sharedInit()
    }

    func sharedInit() {
        OutlookAPI.getRoomLists { (roomLists) in
            self.rooms = roomLists
        }
    }

    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return rooms.count
    }

    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        self.performSegueWithIdentifier("ShowRooms", sender: indexPath)
    }

    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if let indexPath = sender as? NSIndexPath {
            let roomList = rooms[indexPath.row]
            let destinationVC = segue.destinationViewController as! RoomsViewController
            destinationVC.roomList = roomList
        }
    }

    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell: UITableViewCell
        if let aCell = tableView.dequeueReusableCellWithIdentifier("Cell") {
            cell = aCell
        } else {
            cell = UITableViewCell(style: UITableViewCellStyle.Default, reuseIdentifier: "Cell")
        }
        let roomList = rooms[indexPath.row]
        cell.textLabel?.text = roomList.name
        return cell
    }
}

