//
//  Authentication.swift
//  Schegg
//
//  Created by Osei Poku on 6/17/15.
//  Copyright © 2015 Chegg, Inc. All rights reserved.
//

import UIKit

class Authentication: NSObject {
    class func auth (completionBlock:(email:String, password:String) -> Void) {
        let popup = UIAlertController(title: "Authentication Required", message: "Username and password", preferredStyle: UIAlertControllerStyle.Alert)
        popup.addTextFieldWithConfigurationHandler { (textField) -> Void in
            textField.placeholder = "Email"
        }
        popup.addTextFieldWithConfigurationHandler { (textField) -> Void in
            textField.placeholder = "Password"
            textField.secureTextEntry = true
        }
        popup.addAction(UIAlertAction(title: "Cancel", style: UIAlertActionStyle.Cancel, handler: { (action) -> Void in
            popup.dismissViewControllerAnimated(true, completion: nil)
        }))
        popup.addAction(UIAlertAction(title: "Sign In", style: UIAlertActionStyle.Default, handler: { (action) -> Void in
            completionBlock(email: popup.textFields![0].text!, password: popup.textFields![1].text!)
            popup.dismissViewControllerAnimated(true, completion: nil)
        }))
        UIApplication.sharedApplication().keyWindow?.rootViewController?.presentViewController(popup, animated: true, completion: nil)

    }
}
