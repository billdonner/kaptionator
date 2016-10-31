//
//  mlib.swift
//  shtickerz
//
//  Created by bill donner on 7/20/16.
//  Copyright © 2016 martoons. All rights reserved.
//

import UIKit





//MARK: - Global Data Structs



enum KaptionatorErrors : Error  {
    case generalFailure
    case restoreFailure
    case cant
    case assetnotfound
    case colornotfound
    case propertynotfound
    case badasset
}

/// json
typealias JSONDict  = [String:Any ]
typealias JSONArray = [JSONDict]
typealias JSONPayload = [JSONArray]

 


