//
//  ReorderCollectionViewCell.swift
//  Re-Kaptionator
//
//  Created by Bill Donner on 15/12/2015.
//  Copyright © 2016 Bill Donner/midnightrambler. All rights reserved.
//

import UIKit

//import stikz

/// The cell responsible for displaying item data.
class ReorderCollectionViewCell: UICollectionViewCell {
    // @IBOutlet fileprivate weak var stackView: UIStackView!
    
    @IBOutlet  fileprivate weak var detailsImageView: UIImageView!
    
    
    @IBOutlet  fileprivate weak var nameLabel: UILabel!
    
    override func prepareForReuse() {
        detailsImageView.image = nil // clean this out
        nameLabel.text = ""
    }
    // methods to adjust cell contents
    func paint(name:String) {
        nameLabel.text = name
        nameLabel.textColor = //appTheme
            .red
    }
    func colorFor(ra:SharedCE) {
       let  isAnimated =
        
        ra.stickerOptions.contains(.generateasis)
        nameLabel.textColor = isAnimated ?  appTheme.redColor :appTheme.textColor
    }
    func paintImageForReorderCollectionViewCell(url: URL) {
        do {
            //reads local file synchronously
            let data =  try Data(contentsOf:url)
            let img = UIImage(data:data,scale:0.4)
            detailsImageView.image = img
          
        }
        catch {
            
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



