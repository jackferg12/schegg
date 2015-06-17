//
//  FirstViewController.swift
//  Schegg
//
//  Created by Osei Poku on 6/16/15.
//  Copyright (c) 2015 Chegg, Inc. All rights reserved.
//

import UIKit

class FirstViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.

    }

    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        OutlookAPI.getRoomList { (rooms) in
            print("rooms: \(rooms)")
        }

    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }


}

