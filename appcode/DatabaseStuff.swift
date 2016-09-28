//
//  DatabaseStuff.swift
//  kaptionator
//
//  Created by bill donner on 9/28/16.
//  Copyright © 2016 midnightrambler. All rights reserved.
//

import UIKit

func databaseStuff() {
    //
    // restore or create captions db
    if let _ = try? AppCaptionSpace.restoreAppspaceFromDisk() {
        print ("AppPrivateDataSpace restored,\(AppCaptionSpace.itemCount()) items ")
    } else { // nothing there
        AppCaptionSpace.reset()
        print ("AppPrivateDataSpace reset,\(AppCaptionSpace.itemCount()) items ")
        AppCaptionSpace.saveToDisk()
    }
    //
    // restore or create shared memspace db for SharedCaptionSpace extension
    if let _ = try? restoreSharespaceFromDisk() {
        print ("SharedCaptionSpace restored,\(SharedCaptionSpace.itemCount()) items ")
    } else { // nothing there
        SharedCaptionSpace.reset()
        print ("SharedCaptionSpace reset,\(SharedCaptionSpace.itemCount()) items ")
        SharedCaptionSpace.saveData()
    }
}
