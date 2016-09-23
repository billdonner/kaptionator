//
//  TableDataCell.swift
//  ub ori
//
//  Created by bill donner on 9/12/16.
//  Copyright © 2016 Darjeeling Apps. All rights reserved.
//

import UIKit

class TableDataCell: UITableViewCell {
    // @IBOutlet fileprivate weak var stackView: UIStackView!
    @IBOutlet  fileprivate weak var detailsImageView: UIImageView!
    @IBOutlet  fileprivate weak var nameLabel: UILabel!
    
    @IBOutlet  fileprivate weak var line2Label: UILabel!
    
    override func prepareForReuse() {
        detailsImageView.image = nil // clean this out
        nameLabel.text = ""
    }
    func colorFor(options:StickerMakingOptions) {
        let  isAnimated = options.contains(.generateasis)
    nameLabel.textColor = isAnimated ? appTheme.redColor :appTheme.textColor
    }
    func twinkle() {
            UIView.animate(withDuration: 2.5, animations: {
                self.nameLabel.alpha =  0.1
                }
                , completion: { b in
                self.nameLabel.alpha =  01.0
                }
        )
    }
    // methods to adjust cell contents
    func paint(name:String,line2:String ) {
        
        nameLabel.text = name
        nameLabel.textColor = appTheme.textColor
        
        line2Label.text = line2
        line2Label.textColor = appTheme.textColor
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
