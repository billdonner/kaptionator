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
    let catalogColor = UIColor.orange
    let stickerzColor = UIColor.red
    let iMessageColor = UIColor.blue
    
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


