//
//  OnboardingViewController.swift
//  VPN
//
//  Created by Igor Ryazancev on 6/24/20.
//  Copyright © 2020 DEVBUFF. All rights reserved.
//

import UIKit

final class OnboardingViewController: UIViewController {

    //MARK: - Variables private
    @IBOutlet weak var nextButton: UIButton!
    @IBOutlet weak var pageControl: UIPageControl!
    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var holderView: UIView!
    
    private var  page: Int  {
        get {
            return Int(scrollView.contentOffset.x / scrollView.frame.size.width)
        }
        set {
            scrollToPage(page: newValue, animated: true)
            setupChangedPageUI(newValue)
        }
    }
    
    //MARK: - Variables public
    var closeClosure: (()->())? = nil

    @IBAction func backButtonAction(_ sender: Any) {
        dismiss(animated: true, completion: nil)
    }
    
    @IBAction func settingsButtonAction(_ sender: Any) {
    }
    
    @IBAction func nextButtonAction(_ sender: Any) {
        page += page == 2 ? 0 : 1
        
        if page == 2 {
            dismiss(animated: true) { [weak self] in
                guard let `self` = self else { return }
                self.closeClosure?()
            }
        }
    }
}

//MARK: - Lifecycle
extension OnboardingViewController {
    
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        holderView.roundCorners(corners: [.topLeft, .topRight], radius: 44)
    }
    
}

//MARK: - Setups
private extension OnboardingViewController {
    
    func setupChangedPageUI(_ page: Int) {
        pageControl.currentPage = page
        nextButton.setTitle(page == 2 ? "Start your 7 day trial" : "Continue", for: .normal)
        nextButton.backgroundColor = page == 2 ? .appOrange : .appGreen
    }
    
}

//MARK: - Private methods
private extension OnboardingViewController {
    
    func scrollToPage(page: Int, animated: Bool) {
        var frame: CGRect = self.scrollView.frame
        frame.origin.x = frame.size.width * CGFloat(page)
        frame.origin.y = 0
        self.scrollView.scrollRectToVisible(frame, animated: animated)
    }
    
}
