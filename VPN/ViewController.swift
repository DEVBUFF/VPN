//
//  ViewController.swift
//  VPN
//
//  Created by Igor Ryazancev on 6/23/20.
//  Copyright © 2020 DEVBUFF. All rights reserved.
//

import UIKit
import NetworkExtension

final class ViewController: UIViewController {
    
    enum ConnectionState {
        case disconnected
        case connected
        case connecting
    }
    
    //MARK: - Variables private
    @IBOutlet private weak var holderView: UIView!
    @IBOutlet private weak var earthImageView: UIImageView!
    @IBOutlet private weak var connectButton: UIButton!
    @IBOutlet private weak var connectLabel: UILabel!
    @IBOutlet private weak var backgroundImageView: UIImageView!
    @IBOutlet private weak var timerLabel: UILabel!
    @IBOutlet private weak var fasterHolderView: UIView!
    @IBOutlet private weak var tryFreeStackView: UIStackView!
    @IBOutlet  private weak var stackViewHeghtConstraint: NSLayoutConstraint!
    //country view
    @IBOutlet private weak var countryView: UIView!
    @IBOutlet private weak var countryImageView: UIImageView!
    @IBOutlet private weak var countryLabel: UILabel!
    
    private var connectionState: ConnectionState = .disconnected
    private var timer: Timer?
    var counter = 0
    
    //MARK: - Actions
    @IBAction private func connectButtonAction(_ sender: Any) {
        connectionState = connectionState == .disconnected ? .connected : .disconnected
        
        
        if connectionState == .connected {
            VPNHandler.connectVPN()
           // startTimer()
        } else {
            VPNHandler.disconnectVPN()
            stopTimer()
        }
        
       // setupUI()
    }
    
    @IBAction func settingsButtonAction(_ sender: Any) {
        let vc = SettingsViewController(nibName: "SettingsViewController", bundle: nil)
        navigationController?.pushViewController(vc, animated: true)
    }
    
    @IBAction func tryButtonAction(_ sender: Any) {
        showSubscriptionVC()
    }
    
    @objc private func statusDidChange(_ notification: Notification) {
        if let status = notification.object as? NEVPNStatus {
            if status == .connecting {
                guard connectionState != .connecting else { return }
                connectionState = .connecting
                setupUI()
            } else if status == .connected {
                connectionState = .connected
                setupUI()
            } else if status == .disconnected {
                connectionState = .disconnected
                setupUI()
            }
        }
    }
    
    @objc private func fasterViewTapped() {
        let vc = ChooseServerViewController(nibName: "ChooseServerViewController", bundle: nil)
        navigationController?.pushViewController(vc, animated: true)
    }
    
}

//MARK: - Lifecycle
extension ViewController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
       
        
        navigationController?.navigationBar.isHidden = true
        setup()
        setupUI()
        showOnboardingIfNeeded()
        
        if settings.autocennectIsOn && connectionState != .connected {
            connectButtonAction(connectButton as Any)
        }
        
        NotificationCenter.default.addObserver(self, selector: #selector(statusDidChange(_:)), name: NSNotification.Name("kUpdateUIWithStatus"), object: nil)
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        if connectionState == .connected {
            counter = Int(VPNHandler.getConnectionTimeSeconds())
            startTimer()
        }
    
        if IAPManager.shared.hasSubscription() {
            tryFreeStackView.isHidden = true
            stackViewHeghtConstraint.constant = 0
        }
        
        
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        holderView.roundCorners(corners: [.topLeft, .topRight], radius: 44)
    }
}

extension ViewController {
    
    func setup() {
        setupFasterView()
    }
    
    func setupFasterView() {
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(fasterViewTapped))
        fasterHolderView.addGestureRecognizer(tapGesture)
    }
    
    func setupUI() {
        switch connectionState {
        case .disconnected:
            showOrHideCountryView(hide: true)
            earthImageView.image = UIImage(named: "earth")
            connectButton.backgroundColor = .appGreen
            connectButton.setImage(UIImage(named: "power.green"), for: .normal)
            connectButton.setTitle("Connect now", for: .normal)
            connectButton.setTitleColor(.white, for: .normal)
            backgroundImageView.image = UIImage(named: "background.orange")
            connectLabel.text = "Disconnected"
            timerLabel.isHidden = true
            connectLabel.textColor = .appBlue
            view.backgroundColor = .appOrange
                
        case .connected:
            showOrHideCountryView(hide: false)
            earthImageView.image = UIImage(named: "earth.selected")
            connectButton.backgroundColor = .appOrange
            connectButton.setImage(UIImage(named: "power.orange"), for: .normal)
            connectButton.setTitle("Disconnect", for: .normal)
            connectButton.setTitleColor(.white, for: .normal)
            backgroundImageView.image = UIImage(named: "background.green")
            connectLabel.text = "Connected"
            timerLabel.isHidden = false
            timerLabel.text = "00:00:00"
            connectLabel.textColor = .appGreen
            view.backgroundColor = .appGreen
            
        case .connecting:
            earthImageView.image = UIImage(named: "earth")
            connectButton.backgroundColor = #colorLiteral(red: 0.8901960784, green: 0.9098039216, blue: 0.937254902, alpha: 1)
            connectButton.setImage(UIImage(named: "search"), for: .normal)
            connectButton.setTitle("looking for server..", for: .normal)
            connectButton.setTitleColor(.lightGray, for: .normal)
            backgroundImageView.image = UIImage(named: "background.orange")
            connectLabel.text = "Connecting.."
            timerLabel.isHidden = false
                       timerLabel.text = "Please wait"
            connectLabel.textColor = .appOrange
            view.backgroundColor = .appOrange
            
        }
    }
    
}

//MARK: - Private methods
extension ViewController {
    
    func showOnboardingIfNeeded() {
        if !settings.didFirstLoad {
            let onboardingVC = OnboardingViewController(nibName: "OnboardingViewController", bundle: nil)
            onboardingVC.modalPresentationStyle = .fullScreen
            
            onboardingVC.closeClosure = { [weak self] in
                guard let `self` = self else { return }
                self.showSubscriptionVC()
            }
            
            self.present(onboardingVC, animated: true, completion: nil)
            settings.didFirstLoad = true
        }
    }
    
    func showSubscriptionVC() {
        let subsVC = SubscriptionViewController(nibName: "SubscriptionViewController", bundle: nil)
        let nc = UINavigationController(rootViewController: subsVC)
        nc.modalPresentationStyle = .fullScreen
        self.present(nc, animated: true, completion: nil)
    }
    
    func secondsToHoursMinutesSeconds (seconds : Int) -> (Int, Int, Int) {
      return (seconds / 3600, (seconds % 3600) / 60, (seconds % 3600) % 60)
    }
    
    func startTimer() {
        stopTimer()
        
        timer = Timer.scheduledTimer(withTimeInterval: 1, repeats: true, block: { [weak self] _ in
            guard let `self` = self else { return }
            self.counter += 1
            let hms = self.secondsToHoursMinutesSeconds(seconds: self.counter)
            let hString = hms.0 > 9 ? "\(hms.0)" : "0\(hms.0)"
            let mString = hms.1 > 9 ? "\(hms.1)" : "0\(hms.1)"
            let sString = hms.2 > 9 ? "\(hms.2)" : "0\(hms.2)"
            
            DispatchQueue.main.async {
                self.timerLabel.text = "\(hString):\(mString):\(sString)"
            }
        })
    }
    
    func stopTimer() {
        timer?.invalidate()
        timer = nil
    }
    
    func showOrHideCountryView(hide: Bool) {
        self.countryView.alpha = hide ? 1 : 0
        UIView.animate(withDuration: 0.5) { [weak self] in
            guard let `self` = self else { return }
            self.countryView.alpha = hide ? 0 : 1
            self.countryView.isHidden = hide
            if !hide {
                DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) {
                    self.showOrHideCountryView(hide: true)
                }
            }
        }
    }
    
}

