//
//  icloudpickerviewcontroller.swift
//  kaptionator
//
//  Created by bill donner on 10/18/16.
//  Copyright © 2016 midnightrambler. All rights reserved.
//

import UIKit

class ICloudPickerViewController : UIViewController, UIDocumentPickerDelegate {
    
    static let supportedCloudUTIs =
        ["com.compuserve.gif",
         "public.png",
         "public.jpeg"]
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        let importMenu = UIDocumentPickerViewController(documentTypes: ICloudPickerViewController.supportedCloudUTIs, in: .import)
        importMenu.delegate = self
        self.present (importMenu, animated: true, completion: nil)
    }

    func documentPickerWasCancelled(_ controller: UIDocumentPickerViewController) {
        print("cancelled from doc picker"_)
    }
    
    func documentPicker(_ controller: UIDocumentPickerViewController, didPickDocumentAt url: URL) {
        print("picked new document at \(url)")
    }
}
