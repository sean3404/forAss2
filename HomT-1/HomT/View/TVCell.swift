//
//  TVCell.swift
//  HomT
//
//  Created by Sean on 31/5/20.
//  Copyright © 2020 Changkeun Hyun. All rights reserved.
//

import UIKit
protocol TVCellActionDelegate {
    func CellChecked(indexPath: IndexPath, tableView : UITableView)
}

class TVCell: UITableViewCell {
    
    @IBOutlet weak var label: UILabel!
    @IBOutlet weak var CheckBtn: UIButton!

    var delegate : TVCellActionDelegate?
    var tableView : UITableView?
    var indexPath : IndexPath?
    
    @IBAction func CellChecked(_ sender: Any) {
        delegate?.CellChecked(indexPath: indexPath!, tableView : tableView!)
    }
}
