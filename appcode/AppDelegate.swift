//
//  AppDelegate.swift
//  Re-Kaptionator
//
//  Created by Bill Donner on 15/12/2015.
//  Copyright © 2016 Bill Donner/midnightrambler. All rights reserved.
//


/// Modified here
///
/// 1 - all devices show landscape mode
///
/// 2 - black on white or white on black
///
/// 3 - tab selector chooses child view controller
///
/// 4 - child view controllers can rotate and look good
///
/// 5 - stickers downloaded on distributed basis first time up


import UIKit
enum BackTheme {
    case white
    case black
}


let appTheme = Theme(.white)
struct Theme {
    
    var theme:BackTheme = .black  /// new
    
    let redColor = #colorLiteral(red: 0.7586702704, green: 0.2098190188, blue: 0.1745614707, alpha: 1)   // #b22222
    let blueColor = #colorLiteral(red: 0.2389388382, green: 0.5892125368, blue: 0.8818323016, alpha: 1)
    let catalogColor = UIColor.orange
    let stickerzColor = #colorLiteral(red: 0.7586702704, green: 0.2098190188, blue: 0.1745614707, alpha: 1)
    let iMessageColor = #colorLiteral(red: 0.2389388382, green: 0.5892125368, blue: 0.8818323016, alpha: 1)
    
    var backgroundColor:UIColor {
        switch theme {
        case .black : return .black
        case .white : return .white
        }
    }
    var textColor:UIColor {
        switch theme {
        case .black : return .white
        case .white : return .darkGray
        }
    }
    var textFieldColor:UIColor {
        
        // imageCaption.textColor = .darkGray
        // imageCaption.backgroundColor = .white
        
        switch theme {
        case .black : return .white
        case .white : return .darkGray
        }
    }
    var textFieldBackgroundColor:UIColor {
        
        // imageCaption.textColor = .darkGray
        // imageCaption.backgroundColor = .white
        
        switch theme {
        case .black : return .clear
        case .white : return .white
        }
    }
    var buttonTextColor:UIColor {
        switch theme {
        case .black : return .white
        case .white : return .white
        }
    }
    
    var statusBarStyle:UIStatusBarStyle {
        switch theme {
        case .black : return .lightContent
        case .white : return .default
        }
    }
    var altstatusBarStyle:UIStatusBarStyle {
        switch theme {
        case .black : return .default
        case .white : return .lightContent
        }
    }
    var dismissButtonImageName:String {
        switch theme {
        case .black : return "DismissXTransparent"
        case .white : return "DismissXBlack"
        }
    }
    var dismissButtonAltImageName:String {
        switch theme {
        case .white : return "DismissXTransparent"
        case .black : return "DismissXBlack"
        }
    }
    init(_ theme:BackTheme){
        self.theme = theme
    }
}



@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate
    {
    var window: UIWindow?
    
    func application(_ app: UIApplication, open url: URL, options: [UIApplicationOpenURLOptionsKey : Any] = [:]) -> Bool {
        
        RemoteAsset.QuietlyAddNewURL(url,options:StickerMakingOptions.generatelarge)
        // try to reload the main controller if its showing
        var vc: UIViewController? =   window!.rootViewController
        if let nvc  = vc as? UINavigationController {
            nvc.popToRootViewController(animated: true)
               vc = nvc.topViewController
        }
        if let mvc = vc as? MasterViewController {
            let ccvc = mvc.childViewControllers[0] // should be first
            if  let cvc = ccvc as? UICollectionViewController {
                cvc.collectionView?.reloadData()
            }
        }
        return true
    }
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey : Any]? = nil) -> Bool {
        /*
         UIApplication.shared.statusBarStyle = appTheme.altstatusBarStyle
         UINavigationBar.appearance().barStyle = .black
         // Set navigation bar tint / background colour
         UINavigationBar.appearance().barTintColor = appTheme.backgroundColor
         // Set Navigation bar Title colour
         UINavigationBar.appearance().titleTextAttributes = [NSForegroundColorAttributeName:appTheme.textColor]
         */
        
        //spotlightController.indexCounties(DataItem.allItems)
        
        if let navigationController = window?.rootViewController as? UINavigationController, let _ = navigationController.topViewController as? MasterViewController {
           // masterViewController = m
            //masterViewController.history = history
            //applicationShortcutHandler = ApplicationShortcutHandler(masterViewController: masterViewController)
        }
        
        //// experiment
        
        //    let docsPath = Bundle.main.resourcePath! + "/Assets.xcassets"
        //    let fileManager = FileManager.default
        //
        //    do {
        //        let docsArray = try fileManager.subpathsOfDirectory(atPath: docsPath)
        //
        //        print(docsArray)
        //    } catch {
        //        print(error)
        //    }
        
        //    if let asset = NSDataAsset(name: "Data") {
        //        let data = asset.data
        //        let d = try? JSONSerialization.jsonObject(with: data, options: [])
        //        print(d)
        //    }
        
        
        return true
    }
    func application(_ application: UIApplication, continue userActivity: NSUserActivity, restorationHandler: @escaping ([Any]?) -> Swift.Void) -> Bool {
        let handled = false
        // Loop over our user activity handlers to handle the activity
        //        for userActivityHandler in userActivityHandlers {
        //            handled = userActivityHandler.handleUserActivity(userActivity, completionHandler: { (item) -> Void in
        //                dismissExistingCountyViewIfRequired({ (masterViewController) -> (Void) in
        //                    //masterViewController.showDetails(item: item, animated: true)
        //                })
        //            })
        //            if handled {
        //                // The user activity was handled so we don't need to query any more activity handlers
        //                break
        //            }
        //        }
        
        return handled
    }
    
    //    func application(_ application: UIApplication, performActionFor shortcutItem: UIApplicationShortcutItem, completionHandler: @escaping (Bool) -> Void) {
    //        dismissExistingCountyViewIfRequired { [unowned self] (masterViewController) -> (Void) in
    //            self.applicationShortcutHandler?.handleApplicationShortcutItem(shortcutItem, completionHandler: completionHandler)
    //        }
    //    }
    //
    //    fileprivate func dismissExistingCountyViewIfRequired(_ completion: (MasterViewController) -> (Void)) {
    //        let navigationController = window?.rootViewController as! UINavigationController
    //        // Dismiss any existing county that is being shown
    //        navigationController.dismiss(animated: false, completion: nil)
    //        let viewController = navigationController.topViewController as! MasterViewController
    //        completion(viewController)
    //    }
    
    //MARK: ModelDataHistoryDelegate
    //    func countyHistoryDidUpdate(_ countyHistory: ModelDataHistory) {
    //        UIApplication.shared.shortcutItems = countyHistory.recentlyViewedCounties.map({ (county) -> UIApplicationShortcutItem in
    //            return UIApplicationShortcutItem(type: CountyItemShortcutType, localizedTitle: county.name)
    //        })
    //    }
}

/// The shortcut item type for county history shortcut items.
//let CountyItemShortcutType = "CountyItem"

/// The class responsible for handling the response to application shortcuts.
//class ApplicationShortcutHandler: NSObject {
//    fileprivate let masterViewController: MasterViewController
//
//    init(masterViewController: MasterViewController) {
//        self.masterViewController = masterViewController
//    }
//
//    func handleApplicationShortcutItem(_ applicationShortcutItem: UIApplicationShortcutItem, completionHandler: (Bool) -> Void) {
//        var handled = false
//        if applicationShortcutItem.type == "Search" {
//            masterViewController.beginSearch()
//            handled = true
//        }
//        else if applicationShortcutItem.type == CountyItemShortcutType {
//            // masterViewController.showDetails(item: DataItem.itemForName(applicationShortcutItem.localizedTitle)!, animated: true)
//            handled = true
//        }
//        completionHandler(handled)
//    }
//}
///**
// The protocol to conform to for classes that handle user activities.
// */
//protocol ModelDataUserActivityHandling: class {
//    /// The activity type handled by the activity handler.
//    var handledActivityType: String {get}
//
//    /**
//     Called when the receiver is to handle a user activity. Will only be called
//     with user activities whose `activityType` matches the type returned by
//     the reveiver's `handledActivityType` property.
//     - parameter userActivity: The user activity to handle.
//     - returns: The county contained in the user activity if one was found, nil
//     otherwise.
//     */
//    func modeldataFromUserActivity(_ userActivity: NSUserActivity) -> DataItem?
//}
//
//extension ModelDataUserActivityHandling {
//    /**
//     Called when the receiver is to handle a user activity involving a county.
//     - parameter userActivity:      The user activity to handle.
//     - parameter completionHandler: Supplies the county specified by the user
//     activity if it could be handled.
//     - returns: A boolean indicating whether the user activity was handled or
//     not.
//     */
//    func handleUserActivity(_ userActivity: NSUserActivity, completionHandler: (DataItem) -> Void) -> Bool {
//        if let selectedCounty = modeldataFromUserActivity(userActivity) , userActivity.activityType == handledActivityType {
//            completionHandler(selectedCounty)
//            return true
//        }
//        return false
//    }
//}
/// The object responsible for recording which counties the user has viewed.
//class ModelDataHistory: NSObject {
//    var delegate: ModelDataHistoryDelegate?
//    fileprivate(set) var recentlyViewedCounties: [DataItem] {
//        get {
//            let countyNames = NSArray(contentsOf: urlToArchivedData) as? [String]
//            if let countyNames = countyNames {
//                return countyNames.map({ (countyName) -> DataItem in
//                    DataItem.itemForName(countyName)!
//                })
//            }
//            else {
//                return []
//            }
//        }
//        set {
//            let countyNames = newValue.map({$0.name}) as NSArray
//            countyNames.write(to: urlToArchivedData, atomically: true)
//        }
//    }
//    fileprivate var urlToArchivedData: URL {
//        get {
//            let documentsURL = URL(fileURLWithPath: NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true).first!)
//            return documentsURL.appendingPathComponent("ModelDataHistory")
//        }
//    }
//
//    /**
//     Call this function when the user views a county.
//     - parameter county: The county viewed by the user.
//     */
//    func viewed(_ county: DataItem) {
//        if let countyIndex = recentlyViewedCounties.index(of: county) {
//            recentlyViewedCounties.remove(at: countyIndex)
//        }
//        recentlyViewedCounties.insert(county, at: 0)
//        recentlyViewedCounties = Array(recentlyViewedCounties.prefix(3))
//        delegate?.countyHistoryDidUpdate(self)
//    }
//}
//
///**
// The protocol for `ModelDataHistory` delegates to conform to.
// */
//protocol ModelDataHistoryDelegate: NSObjectProtocol {
//    /**
//     The message sent when the county history was updated.
//     - parameter countyHistory: The county history that was updated.
//     */
//    func countyHistoryDidUpdate(_ countyHistory: ModelDataHistory)
//}

