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
    
}

extension CountryTableViewCell {
    
    func configure(vpn: ServerVpn) {
        countryName.text = "\(vpn.country), \(vpn.location)"
        typeImageView.image = vpn.isFree ? UIImage(named: "free") : UIImage(named: "pro")
        connectionImageView.image = UIImage(named: "connection-3")
    }
    
}
