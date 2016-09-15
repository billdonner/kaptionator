//
//  theme.swift
//  ub ori
//
//  Created by bill donner on 9/12/16.
//  Copyright © 2016 Darjeeling Apps. All rights reserved.
//

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


