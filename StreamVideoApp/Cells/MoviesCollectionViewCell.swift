//
//  MoviesCollectionViewCell.swift
//  StreamVideoApp
//
//  Created by iMad on 10/02/2024.
//

import UIKit

class MoviesCollectionViewCell: UICollectionViewCell {
    class var identifier: String { return String(describing: self) }
    class var nib: UINib { return UINib(nibName: identifier, bundle: nil) }
    
    @IBOutlet weak var coverImage: UIImageView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

}
