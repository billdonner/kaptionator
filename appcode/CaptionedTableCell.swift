//
//  CaptionedTableCell.swift
//  Kaptionator
//
//  Created by bill donner on 9/12/16.
//  Copyright © 2016 Bill Donner/midnightrambler. All rights reserved.
//
import UIKit
class CaptionedTableCell: UITableViewCell {
    @IBOutlet  fileprivate weak var detailsImageView: UIImageView!
    @IBOutlet  fileprivate weak var nameLabel: UILabel!
 
    override func prepareForReuse() {
        detailsImageView.image = nil // clean this out
        nameLabel.text = ""
    }
    func colorFor(options:StickerMakingOptions) {
        let  isAnimated = options.contains(.generateasis)
        nameLabel.textColor = isAnimated ? appTheme.redColor : appTheme.textColor
    }
    // methods to adjust cell contents
    func paint2(name:String,line2:String ) {
        nameLabel.text = name
        nameLabel.textColor = appTheme.textColor 
    }
    func paint(name:String ) {
        nameLabel.text = name
        nameLabel.textColor = appTheme.textColor
    }
    func paintImage(path: String) {
        do {
            let data =  try Data(contentsOf: URL(string:path)!)
            let img = UIImage(data:data)
            if let img = img {
                detailsImageView.image = img
            }
        }
        catch {
        }
    }
    override func awakeFromNib() {
        super.awakeFromNib()
        // selectedBackgroundView = UIView()
        // selectedBackgroundView?.backgroundColor = BorderSettings.colour
    }
    override func layoutSubviews() {
        super.layoutSubviews()
        setNeedsDisplay() // Redraw the border
    }
}
