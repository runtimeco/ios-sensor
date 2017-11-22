//
//  ViewControllerUtils.swift
//  cigatewayconfig
//
//  Created by Brian Giori on 8/18/17.
//  Copyright © 2017 Brian Giori. All rights reserved.
//

import Foundation
import CoreGraphics
import UIKit

class ViewControllerUtils {
    
    static var container: UIView = UIView()
    static var loadingView: UIView = UIView()
    
    static var activityIndicator: UIActivityIndicatorView = UIActivityIndicatorView()
    
    
    private static var isActivityIndicatorShowing: Bool = false
    /*
     Show customized activity indicator,
     actually add activity indicator to passing view
     
     @param uiView - add activity indicator to this view
     */
    static func showActivityIndicator(uiView: UIView) {
        objc_sync_enter(self)
        isActivityIndicatorShowing = true
        container.frame = uiView.frame
        container.center = uiView.center
        //        container.backgroundColor = UIColorFromHex(rgbValue: 0x000000, alpha: 0.3)
        
        loadingView.frame = CGRect(x:0, y:0, width:80, height:80)
        loadingView.center = uiView.center
        loadingView.backgroundColor = UIColorFromHex(rgbValue: 0x000000, alpha: 0.7)
        loadingView.clipsToBounds = true
        loadingView.layer.cornerRadius = 10
        loadingView.layer.zPosition = 2
        
        activityIndicator.frame = CGRect(x:0.0, y:0.0, width:40.0, height:40.0);
        activityIndicator.activityIndicatorViewStyle = UIActivityIndicatorViewStyle.whiteLarge
        activityIndicator.center = CGPoint(x:loadingView.frame.size.width / 2, y:loadingView.frame.size.height / 2);
        activityIndicator.layer.zPosition = 3
        
        
        loadingView.addSubview(activityIndicator)
        container.addSubview(loadingView)
        uiView.addSubview(container)
        activityIndicator.startAnimating()
        objc_sync_exit(self)
    }
    
    /*
     Hide activity indicator
     Actually remove activity indicator from its super view
     
     @param uiView - remove activity indicator from this view
     */
    static func hideActivityIndicator(uiView: UIView) {
        objc_sync_enter(self)
        if isActivityIndicatorShowing {
            activityIndicator.stopAnimating()
            container.removeFromSuperview()
            isActivityIndicatorShowing = false
        }
        objc_sync_exit(self)
    }
    
    /*
     Define UIColor from hex value
     
     @param rgbValue - hex color value
     @param alpha - transparency level
     */
    static func UIColorFromHex(rgbValue:UInt32, alpha:Double=1.0)->UIColor {
        let red = CGFloat((rgbValue & 0xFF0000) >> 16)/256.0
        let green = CGFloat((rgbValue & 0xFF00) >> 8)/256.0
        let blue = CGFloat(rgbValue & 0xFF)/256.0
        return UIColor(red:red, green:green, blue:blue, alpha:CGFloat(alpha))
    }
    
    /**
     * Utility for showing error messages with a title and message
     */
    static func showAlert(title: String, message: String, viewController: UIViewController) {
        let alertView = UIAlertController(title: title,
                                          message: message,
                                          preferredStyle: .alert)
        let okAction = UIAlertAction(title: "Dismiss", style: .default, handler: nil)
        alertView.addAction(okAction)
        viewController.present(alertView, animated: true, completion: nil)
    }
    
//    static func showHttpError(status: Status!, viewController: UIViewController) {
//        showAlert(title: "Error \(status.code!)", message: status.msg, viewController: viewController)
//    }
    
    
    // MARK: - Synchronization Helper
    
    static func synced(_ lock: Any, closure: () -> ()) {
        objc_sync_enter(lock)
        closure()
        objc_sync_exit(lock)
    }
}

//// In order to show the activity indicator, call the function from your view controller
//// ViewControllerUtils().showActivityIndicator(self.view)
//// In order to hide the activity indicator, call the function from your view controller
//// ViewControllerUtils().hideActivityIndicator(self.view)

