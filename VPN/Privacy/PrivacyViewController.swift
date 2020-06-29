//
//  PrivacyViewController.swift
//  VPN
//
//  Created by Igor Ryazancev on 6/24/20.
//  Copyright © 2020 DEVBUFF. All rights reserved.
//

import UIKit

final class PrivacyViewController: UIViewController {

    //MARK: - Variables private
    @IBOutlet private weak var holderView: UIView!
    @IBOutlet private weak var buttonHolderView: UIView!
    
    //MARK: - Actions
    @IBAction private func settingsButtonAction(_ sender: Any) {
    }
    
    @IBAction private func backButtonAction(_ sender: Any) {
        guard navigationController == nil else {
            navigationController?.popViewController(animated: true)
            return
        }
        dismiss(animated: true, completion: nil)
    }
    
    @IBAction private func startTrialButtonAction(_ sender: Any) {
        guard let navigation = navigationController else {
            showSubscriptionVC()
            return
        }
        
        if navigation.viewControllers[0] is SubscriptionViewController {
            navigation.popViewController(animated: true)
        }
    }
    
}

//MARK: - Lifecycle
extension PrivacyViewController {
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        holderView.roundCorners(corners: [.topLeft, .topRight], radius: 44)
        buttonHolderView.roundCorners(corners: [.topLeft, .topRight], radius: 44)
    }
    
}

//MARK: - Private methods
private extension PrivacyViewController {
    
    func showSubscriptionVC() {
        let subsVC = SubscriptionViewController(nibName: "SubscriptionViewController", bundle: nil)
        let nc = UINavigationController(rootViewController: subsVC)
        nc.modalPresentationStyle = .fullScreen
        self.present(nc, animated: true, completion: nil)
    }
    
}
