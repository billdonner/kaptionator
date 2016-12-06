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
//import stikz

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
        switch theme {
        case .black : return .white
        case .white : return .darkGray
        }
    }
    var textFieldBackgroundColor:UIColor {
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
        
        StickerAsset.quietlyAddNewURL(url,options:StickerOptions.generatelarge)
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

        return true
    }

    

}
