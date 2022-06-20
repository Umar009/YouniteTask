//
//  HomeCollectionViewCell.swift
//  YouniteTask
//
//  Created by The Mac Store on 19/06/2022.
//

import UIKit

class HomeCollectionViewCell: UICollectionViewCell {

    @IBOutlet weak var lbPercentage: UILabel!
    @IBOutlet weak var imImageView: CustomImageView!
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    static func getCell(collectionView : UICollectionView,indexPath : IndexPath) -> HomeCollectionViewCell
    {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "HomeCollectionViewCell", for: indexPath) as! HomeCollectionViewCell
        cell.setViews()
        
        return cell
    }
    static func RegisterCell(collectionView : UICollectionView)
    {
        let nib = UINib(nibName: "HomeCollectionViewCell", bundle: nil)
        
        collectionView.register(nib, forCellWithReuseIdentifier: "HomeCollectionViewCell")
    }
    func setViews()
    {
        imImageView.layer.cornerRadius = 4
        imImageView.clipsToBounds = true
    }
    func downloadImage(url : String)
    {
        if let imageURL = url.convertToURL() {
            imImageView.download(from: imageURL, label: lbPercentage)
        }
    }

}
