//
//  SubscriptionViewController.swift
//  VPN
//
//  Created by Igor Ryazancev on 6/24/20.
//  Copyright © 2020 DEVBUFF. All rights reserved.
//

import UIKit

final class SubscriptionViewController: UIViewController {

    //MARK: - Variables private
    @IBOutlet private weak var firstBBuyButton: UIButton!
    @IBOutlet private weak var secondBuyButton: UIButton!
    @IBOutlet private weak var holderView: UIView!
    @IBOutlet private weak var weekTrialLabel: UILabel!
    @IBOutlet private weak var monthTrialLabel: UILabel!
    
    private let iap = IAPManager.shared
    
    //MARK: - Actions
    @IBAction private func backButtonAction(_ sender: Any) {
        dismiss(animated: true, completion: nil)
    }
    
    @IBAction private func settingsButtonAction(_ sender: Any) {
    }
    
    @IBAction private func firstBuyButtonAction(_ sender: Any) {
        IAPManager.shared.purchaseProduct(productType: .weekly)
    }
    
    @IBAction private func secondBuyButtonAction(_ sender: Any) {
        IAPManager.shared.purchaseProduct(productType: .monthly)
    }
    
    @IBAction private func privacyButtonAction(_ sender: Any) {
        let privacyVC = PrivacyViewController(nibName: "PrivacyViewController", bundle: nil)
        privacyVC.modalPresentationStyle = .fullScreen
        navigationController?.pushViewController(privacyVC, animated: true)
    }
    
    @IBAction private func subscriptionButtonAction(_ sender: Any) {
    }
    
    @IBAction private func termsButtonAction(_ sender: Any) {
    }
    
}

//MARK: - Lifecycle
extension SubscriptionViewController {
    
    override func viewDidLoad() {
        super.viewDidLoad()

        navigationController?.navigationBar.isHidden = true
        setup()
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        holderView.roundCorners(corners: [.topRight, .topLeft], radius: 44)
    }
    
}

//MARK: - Setups
private extension SubscriptionViewController {
    
    func setup() {
        setupIAPS()
    }
    
    func setupIAPS() {
        iap.delegate = self
        
        let weeklyPrice = (iap.products?.first?.priceLocale.currencySymbol ?? "") + "\(iap.products?.first?.price ?? 0)"
        let monthlyPrice = (iap.products?.last?.priceLocale.currencySymbol ?? "") + "\(iap.products?.last?.price ?? 0)"
        firstBBuyButton.setTitle(weeklyPrice + " / week", for: .normal)
        secondBuyButton.setTitle(monthlyPrice + " / month", for: .normal)
        weekTrialLabel.text = "3 days trial then \(weeklyPrice)"
        monthTrialLabel.text = "3 days trial then \(monthlyPrice)"
    }
    
}

//MARK: - IAPManagerDelegate
extension SubscriptionViewController: IAPManagerDelegate {
    
    func inAppLoadingStarted() {
        showSpinner(onView: view)
    }
    
    func inAppLoadingSucceded(productType: ProductType) {
        removeSpinner()
        if let navigation = self.navigationController {
            navigation.popViewController(animated: true)
        } else {
            self.dismiss(animated: true, completion: nil)
        }
    }
    
    func inAppLoadingFailed(error: Error?) {
        removeSpinner()
    }
    
    func subscriptionStatusUpdated(value: Bool) {
        
    }
    
}
