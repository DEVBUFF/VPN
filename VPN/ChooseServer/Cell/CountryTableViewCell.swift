//
//  CountryTableViewCell.swift
//  VPN
//
//  Created by Igor Ryazancev on 6/25/20.
//  Copyright © 2020 DEVBUFF. All rights reserved.
//

import UIKit

final class CountryTableViewCell: UITableViewCell {

    @IBOutlet private weak var flagImageView: UIImageView!
    @IBOutlet private weak var countryName: UILabel!
    @IBOutlet private weak var typeImageView: UIImageView!
    @IBOutlet private weak var connectionImageView: UIImageView!
    
    
    
    var selectedCell: Bool = false {
        didSet {
            backgroundColor = selectedCell ? .lightGray : .white
        }
    }
}

extension CountryTableViewCell {
    
    func configure(vpn: ServerVpn) {
        countryName.text = "\(vpn.ServerName)"
        typeImageView.image = vpn.isFree ?? false ? UIImage(named: "free") : UIImage(named: "pro")
        connectionImageView.image = UIImage(named: "connection-3")
        selectedCell = vpn.selected ?? false
        flagImageView.image = UIImage(named: "\(vpn.ServerName)")
       // isSelected = false//vpn.selected ?? false
    }
    
}
