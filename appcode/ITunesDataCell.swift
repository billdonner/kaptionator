//
//  ITunesDataCell.swift
//  kaptionator
//
//  Created by bill donner on 10/6/16.
//  Copyright © 2016 Bill Donner/ midnightrambler. All rights reserved.
//

import UIKit
//import stikz


//
//  CatalogDataCell.swift
//  Re-Kaptionator
//
//  Created by Bill Donner on 15/12/2015.
//  Copyright © 2016 Bill Donner/midnightrambler. All rights reserved.
//



/// The cell responsible for displaying item data.
class ITunesDataCell: UICollectionViewCell {
    // @IBOutlet fileprivate weak var stackView: UIStackView!
    
    @IBOutlet weak var captionLabel: UILabel!
    
    @IBOutlet weak var animatedImageView: UIImageView!
    @IBOutlet  fileprivate weak var detailsImageView: UIImageView!
    override func prepareForReuse() {
        // carefully get this scell back to where it needs to be
        detailsImageView.image = nil // clean this out
        animatedImageView.isHidden = true // and set back to hidden
        
    }
    // methods to adjust cell contents
    func showAnimationOverlay() {
        animatedImageView.isHidden = false
    }
    
    
    func paintImageForITunesDataCell(url:URL, text: String = "") {
        do {
            //reads local file synchronously
            let data =  try Data(contentsOf:url)
            let img = UIImage(data:data)
            detailsImageView.image = img
            detailsImageView.contentMode = .scaleAspectFit
            captionLabel.text = text
        }
        catch let error {
            print ("Cant paintImage \(error)")
        }
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        selectedBackgroundView = UIView()
        selectedBackgroundView?.backgroundColor = BorderSettings.colour
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        setNeedsDisplay() // Redraw the border
    }
}




