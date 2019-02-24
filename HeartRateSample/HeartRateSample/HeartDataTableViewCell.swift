//
//  HeartDataTableViewCell.swift
//  HeartRateSample
//
//  Created by Francis Bosse on 2019-02-24.
//  Copyright © 2019 bosse. All rights reserved.
//

import UIKit

class HeartDataTableViewCell: UITableViewCell {
    
    @IBOutlet weak var lblHeartRate: UILabel!
    @IBOutlet weak var lblTimes: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        
        // Configure the view for the selected state
    }
    
}
