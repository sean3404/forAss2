//
//  MainTVRecipeCell.swift
//  HomT
//
//  Created by Sean on 31/5/20.
//  Copyright © 2020 Changkeun Hyun. All rights reserved.
//
import UIKit
protocol CellActionDelegate {
    func shareARecipe(indexPath: IndexPath)
    func addToFav(indexPath: IndexPath)
}

class MainTVRecipeCell: UITableViewCell {
    
    @IBOutlet weak var myImageView: UIImageView!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var shareBtn: UIButton!
    @IBOutlet weak var favBtn: UIButton!
    @IBOutlet weak var ActivityIndicator: UIActivityIndicatorView!
    
    var delegate: CellActionDelegate?
    var indexPath: IndexPath!
    
    @IBAction func favBtnPressed(_ sender: UIButton) {
        delegate?.addToFav(indexPath: self.indexPath)
    }
    
    @IBAction func shareBtnPressed(_ sender: UIButton) {
        delegate?.shareARecipe(indexPath: self.indexPath)
    }
}
