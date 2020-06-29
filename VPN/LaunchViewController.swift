//
//  LaunchViewController.swift
//  VPN
//
//  Created by Igor Ryazancev on 6/23/20.
//  Copyright © 2020 DEVBUFF. All rights reserved.
//

import UIKit

class LaunchViewController: UIViewController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if let mainVC = UIStoryboard(name: "Main", bundle: nil).instantiateInitialViewController() as? ViewController {
            let nc = UINavigationController(rootViewController: mainVC)
            DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                SceneDelegate.shared?.window?.rootViewController = nc
            }
        }
        
    }


}
