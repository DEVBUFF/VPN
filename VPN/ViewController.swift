//
//  ViewController.swift
//  VPN
//
//  Created by Igor Ryazancev on 6/23/20.
//  Copyright © 2020 DEVBUFF. All rights reserved.
//

import UIKit
import NetworkExtension
import Lottie

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
    @IBOutlet weak var animateImageView: UIImageView!

    
    private var animationView: AnimationView?
    
    private var selectedVPN: ServerVpn?
    
    private var connectionState: ConnectionState = .disconnected
    private var timer: Timer?
    var counter = 0
    
    //MARK: - Actions
    @IBAction private func connectButtonAction(_ sender: Any) {
        connectionState = connectionState == .disconnected ? .connected : .disconnected
        
        
        if connectionState == .connected {
            
            if let vpn = selectedVPN {
                VPNHandler.connectVPN(with: vpn)
            }  else {
                VPNHandler.connectVPN(with: ServerVpn(RemoteAddress: "188.166.28.14",
                                                      SharedSecret: "123YA2EZlc4oR57kBIOTf3Hv80x3tgcP03aYOZNpvx/0go=",
                                                      ServerName: "Singapore",
                                                      isFree: true))
            }
            
           // startTimer()
        } else {
            VPNHandler.disconnectVPN()
            stopTimer()
            setupUI()
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
                animateImageView.isHidden = false
                setupUI()
            } else if status == .connected {
                connectionState = .connected
                animateImageView.isHidden = true
                setupUI()
            } else if status == .disconnected {
                connectionState = .disconnected
                animateImageView.isHidden = true
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
        
        getObjects()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
//        DispatchQueue.main.async {
//            self.playLottie()
//        }
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        holderView.roundCorners(corners: [.topLeft, .topRight], radius: 44)
    }
}

extension ViewController {
    
    func setup() {
        setupFasterView()
        setupAnimateImageView()
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
    
    func setupAnimateImageView() {
        var images: [UIImage] = []
        for n in 0...90 {
            if n < 10 {
                let image = UIImage(named: "Comp 1_0000\(n)") ?? UIImage()
                images.append(image)
            } else {
                let image = UIImage(named: "Comp 1_000\(n)") ?? UIImage()
                images.append(image)
            }
        }
        
        let animatedImage = UIImage.animatedImage(with: images, duration: 1.8)
        animateImageView.image = animatedImage
        animateImageView.isHidden = true
    }
    
}

//MARK: - Private methods
extension ViewController {
    
    func getObjects() {
        if let path = Bundle.main.path(forResource: "final", ofType: "json") {
            do {
                let data = try Data(contentsOf: URL(fileURLWithPath: path), options: .mappedIfSafe)
                let vpnObjs = try JSONDecoder().decode([ServerVpn].self, from: data)
                self.selectedVPN = vpnObjs.filter({ $0.ServerName == settings.selectedVPN }).first
                print("-----loaded")
            } catch {
                print(error.localizedDescription)
            }
        }
    }
    
   
    
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
        countryLabel.text = selectedVPN?.ServerName
        countryImageView.image = UIImage(named: "\(selectedVPN?.ServerName ?? "")")
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

