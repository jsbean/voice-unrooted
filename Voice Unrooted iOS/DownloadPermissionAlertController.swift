//
//  DownloadPermissionAlertController.swift
//  SwiftAudioKitTest
//
//  Created by James Bean on 11/20/16.
//  Copyright © 2016 Hans Tutschku. All rights reserved.
//

import Foundation

extension UIAlertController {
    
    // This factory method exists only because `UIAlertController` doesn't support subclassing.
    static func downloadPermissionAlert(
        title: String,
        message: String,
        sourceView: UIView,
        performingUponPermission function: @escaping () -> ()
    ) -> UIAlertController
    {
        
        let alertController = UIAlertController(
            title: title,
            message: message,
            preferredStyle: .alert
        )
        
        func addActions() {
            addOKAction()
            addCancelAction()
        }
        
        func configurePopoverPresentationController() {
            alertController.popoverPresentationController?.sourceView = sourceView
            alertController.popoverPresentationController?.sourceRect = sourceView.bounds
        }
        
        func addOKAction() {
            let okAction = UIAlertAction(
                title: "OK",
                style: .default,
                handler: { _ in function() }
            )
            alertController.addAction(okAction)
            alertController.preferredAction = okAction
        }
        
        func addCancelAction() {
            let cancelAction = UIAlertAction(title: "Cancel", style: .cancel)
            alertController.addAction(cancelAction)
        }
        
        
        addActions()
        configurePopoverPresentationController()
        return alertController
    }
}
