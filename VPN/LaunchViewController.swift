//
//  LaunchViewController.swift
//  VPN
//
//  Created by Igor Ryazancev on 6/23/20.
//  Copyright © 2020 DEVBUFF. All rights reserved.
//

import UIKit

class LaunchViewController: UIViewController {
    
    @IBOutlet weak var animateImageView: UIImageView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        var images: [UIImage] = []
        for n in 0...45 {
            if n < 10 {
                let image = UIImage(named: "Icon_0000\(n)") ?? UIImage()
                images.append(image)
            } else {
                let image = UIImage(named: "Icon_000\(n)") ?? UIImage()
                images.append(image)
            }
        }
        
        let animatedImage = UIImage.animatedImage(with: images, duration: 1.5)
        animateImageView.image = animatedImage
        
        
        if let mainVC = UIStoryboard(name: "Main", bundle: nil).instantiateInitialViewController() as? ViewController {
            let nc = UINavigationController(rootViewController: mainVC)
            DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                SceneDelegate.shared?.window?.rootViewController = nc
            }
        }
        
    }


}
