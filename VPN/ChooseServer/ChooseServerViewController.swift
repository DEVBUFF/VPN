//
//  ChooseServerViewController.swift
//  VPN
//
//  Created by Igor Ryazancev on 6/25/20.
//  Copyright © 2020 DEVBUFF. All rights reserved.
//

import UIKit

typealias ServerVpn = ChooseServerViewController.ServerVpn

final class ChooseServerViewController: UIViewController {

    @IBOutlet private weak var tableView: UITableView!
    @IBOutlet private weak var freeButton: UIButton!
    @IBOutlet private weak var proButton: UIButton!
    @IBOutlet private weak var tryFreeHolderView: UIView!
    @IBOutlet private weak var holderView: UIView!
    
    private var vpns: [ServerVpn] = []
    
    private var sortedVPNs: [ServerVpn] = [] {
        didSet {
            DispatchQueue.main.async { [unowned self] in
                self.tableView.reloadData()
            }
        }
    }
    

    @IBAction private func backButtonAction(_ sender: Any) {
        navigationController?.popViewController(animated: true)
    }
    
    @IBAction private func settingsButtonAction(_ sender: Any) {
        let vc = SettingsViewController(nibName: "SettingsViewController", bundle: nil)
        navigationController?.pushViewController(vc, animated: true)
    }
    
    @IBAction private func freeButtonAction(_ sender: UIButton) {
        sender.isSelected = proButton.isSelected == true ? !sender.isSelected : true
        setupButtonUI(button: sender)
        sortVpns()
    }
    
    @IBAction private func proButtonAction(_ sender: UIButton) {
        sender.isSelected = freeButton.isSelected == true ? !sender.isSelected : true
        setupButtonUI(button: sender)
        sortVpns()
    }
    
    @IBAction private func tryButtonAction(_ sender: Any) {
        showSubscriptionVC()
    }
}

//MARK: - Lifecycle
extension ChooseServerViewController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setup()
        getObjects()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        tryFreeHolderView.isHidden = IAPManager.shared.hasSubscription()
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        tryFreeHolderView.roundCorners(corners: [.topLeft, .topRight], radius: 44)
        holderView.roundCorners(corners: [.topLeft, .topRight], radius: 44)
    }
    
}
//MARK: - Setups
private extension ChooseServerViewController {
    
    func setup() {
        freeButtonAction(freeButton)
        proButtonAction(proButton)
        setupTableView()
    }
    
    func setupButtonUI(button: UIButton) {
        button.layer.borderColor = #colorLiteral(red: 0.8899999857, green: 0.9100000262, blue: 0.9369999766, alpha: 1)
        button.layer.borderWidth = button.isSelected ? 1 : 0
        button.backgroundColor = button.isSelected ? .white : #colorLiteral(red: 0.8899999857, green: 0.9100000262, blue: 0.9369999766, alpha: 1) 
    }
    
    func setupTableView() {
        tableView.dataSource = self
        tableView.delegate = self
        
        tableView.register(UINib(nibName: "CountryTableViewCell", bundle: nil), forCellReuseIdentifier: "CountryTableViewCell")
    }
    
}

//MARK: - Private methods
private extension ChooseServerViewController {
    
    func showSubscriptionVC() {
        let subsVC = SubscriptionViewController(nibName: "SubscriptionViewController", bundle: nil)
        let nc = UINavigationController(rootViewController: subsVC)
        nc.modalPresentationStyle = .fullScreen
        self.present(nc, animated: true, completion: nil)
    }
    
    func sortVpns() {
        if proButton.isSelected && freeButton.isSelected {
            sortedVPNs = vpns
        } else if proButton.isSelected && !freeButton.isSelected {
            sortedVPNs = vpns.filter({ $0.isFree == false })
        } else if !proButton.isSelected && freeButton.isSelected {
            sortedVPNs = vpns.filter({ $0.isFree == true })
        }
    }
    
    func getObjects() {
        if let path = Bundle.main.path(forResource: "vpnlist", ofType: "json") {
            do {
                let data = try Data(contentsOf: URL(fileURLWithPath: path), options: .mappedIfSafe)
                let vpnObjs = try JSONDecoder().decode([ServerVpn].self, from: data)
                self.vpns = vpnObjs
                self.sortedVPNs = vpnObjs

            } catch {
                print(error.localizedDescription)
            }
        }
    }
    
}

//MARK: - UITableViewDataSource
extension ChooseServerViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return sortedVPNs.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "CountryTableViewCell", for: indexPath) as! CountryTableViewCell
        cell.configure(vpn: sortedVPNs[indexPath.row])
        
        return cell
    }
    
    
}

//MARK: - UITableViewDelegate
extension ChooseServerViewController: UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
    }
    
}

extension ChooseServerViewController {
    
    struct ServerVpn: Codable {
        let hostname: String
        let isFree: Bool
        let country: String
        let location: String
        let name: String
        let serverID: Int
        let user: String
        let pass: String
        let psk: String
    }
    
}
