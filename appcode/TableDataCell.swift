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
    
    override func prepareForReuse() {
        detailsImageView.image = nil // clean this out
        nameLabel.text = "should not see this"
    }
    func colorFor(ce:CaptionedEntry) {
        let  isAnimated = ce.stickerOptions.contains(.generateasis)
        
        nameLabel.textColor = isAnimated ? .red :appTheme.textColor
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
    func paint(name:String) {
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
