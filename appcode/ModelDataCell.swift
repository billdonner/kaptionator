//
//  ModelDataCell.swift
//  Re-Kaptionator
//
//  Created by Bill Donner on 15/12/2015.
//  Copyright © 2016 Martoons and MedCommons. All rights reserved.
//

import UIKit


/*!
 The styles that the cell can display itself in.
 - Table: Display the cell in a table style.
 - Grid:  Display the cell in a grid style.
 */

enum ModelDataDisplayStyle {
    case table
    case grid
}
func styleForTraitCollection(_ traitCollection: UITraitCollection) -> ModelDataDisplayStyle {
    if traitCollection.verticalSizeClass == .regular &&
        traitCollection.horizontalSizeClass == .regular {
        // ipad is alwys gridded
        return .grid
    }
    //iphone gets grid in landscape mode
    return ///traitCollection.verticalSizeClass == .compact ? .grid :
        
        .grid  /// changed *****
}
private struct BorderSettings {
    static let width: CGFloat = 2.0 / UIScreen.main.scale
    static let colour = UIColor(white: 0.5, alpha: 1.0)
}
 

/// The cell responsible for displaying item data.
class ModelDataCell: UICollectionViewCell {
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
        nameLabel.textColor = appTheme.redColor
    }
    func colorFor(ra:RemoteAsset) {
       let  isAnimated = ra.options.contains(.generateasis)  
        nameLabel.textColor = isAnimated ?  appTheme.redColor :appTheme.textColor
    }
    func paintImage(path imgLocalPath: String) {
        do {
            //reads local file synchronously
            let data =  try Data(contentsOf: URL(string:imgLocalPath)!)
            let img = UIImage(data:data)
            detailsImageView.image = img
            detailsImageView.contentMode = .scaleAspectFit
        }
        catch {
            
        }
    }
    
    
    fileprivate  var displayStyle: ModelDataDisplayStyle = .table {
        didSet {
            switch (displayStyle) {
            case .table: break
            //  stackView.axis = .horizontal
            case .grid: break
                // stackView.axis = .vertical
            }
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


// MARK: - ModelDataDisplayStyle extension to provide collection view layout information based on a display style.
extension ModelDataDisplayStyle {
    
    
    func itemSizeInCollectionView(_ collectionView: UICollectionView) -> CGSize {
        let traitCollection = collectionView.traitCollection
        
        
        switch (self) {
        case .table:
            return CGSize(width: collectionView.bounds.width, height: 100)
        case .grid:
            
            if traitCollection.verticalSizeClass == .regular &&
                traitCollection.horizontalSizeClass == .regular {
                return CGSize(width: 250, height: 250) //ipad
            }
            if traitCollection.verticalSizeClass == .compact &&
                traitCollection.horizontalSizeClass == .regular {
                return CGSize(width: 200, height: 200) //7plus
            }
            return CGSize(width: 150, height: 150) //iphone
        
        }
    }
    
    var collectionViewEdgeInsets: UIEdgeInsets {
        switch (self) {
        case .table:
            return UIEdgeInsets.zero
        case .grid:
            return UIEdgeInsets(top: 5, left: 5, bottom: 5, right: 5)
        }
    }
    
    var collectionViewLineSpacing: CGFloat {
        switch (self) {
        case .table:
            return 0
        case .grid:
            return 8
        }
    }
}

