//
//  Authentication.swift
//  Schegg
//
//  Created by Osei Poku on 6/17/15.
//  Copyright © 2015 Chegg, Inc. All rights reserved.
//

import UIKit

class Authentication: NSObject, UIAlertViewDelegate {
    let title = "Authentication Required"
    let message = "Email and password"
    let emailPlaceholder = "Email"
    let passwordPlaceholder = "Password"

    let cancelButtonTitle = "Cancel"
    let signinButtonTitle = "Sign In"

    var completionBlock: ((email:String?, password:String?) -> Void)?

    func auth (completionBlock:(email: String?, password: String?) -> Void) {
        let popup = UIAlertController(title: title, message: message, preferredStyle: UIAlertControllerStyle.Alert)
        popup.addTextFieldWithConfigurationHandler { (textField) -> Void in
            textField.placeholder = self.emailPlaceholder
        }
        popup.addTextFieldWithConfigurationHandler { (textField) -> Void in
            textField.placeholder = self.passwordPlaceholder
            textField.secureTextEntry = true
        }
        popup.addAction(UIAlertAction(title: cancelButtonTitle, style: UIAlertActionStyle.Cancel, handler: { (action) -> Void in
            popup.dismissViewControllerAnimated(true, completion: nil)
        }))
        popup.addAction(UIAlertAction(title: signinButtonTitle, style: UIAlertActionStyle.Default, handler: { (action) -> Void in
            let email = (popup.textFields![0] as! UITextField).text
            let password = (popup.textFields![1] as! UITextField).text
            completionBlock(email: email, password:password)
            popup.dismissViewControllerAnimated(true, completion: nil)
        }))
        UIApplication.sharedApplication().keyWindow?.rootViewController?.presentViewController(popup, animated: true, completion: nil)
    }
}
