//
//  SettingsViewController.swift
//  VPN
//
//  Created by Igor Ryazancev on 6/25/20.
//  Copyright © 2020 DEVBUFF. All rights reserved.
//

import UIKit
import SafariServices


typealias BlockerList = [[String: [String: Any]]]

final class SettingsViewController: UIViewController {

    @IBOutlet private weak var goPremiumButton: UIButton!
    @IBOutlet private weak var adBlockSwitch: UISwitch! {
        didSet {
            adBlockSwitch.isOn = settings.protectionIsOn
        }
    }
    @IBOutlet private weak var autoconnectionSwitch: UISwitch! {
           didSet {
               autoconnectionSwitch.isOn = settings.autocennectIsOn
           }
       }
    
    @IBAction private func adBlockSwitchAction(_ sender: Any) {
        settings.protectionIsOn = !settings.protectionIsOn
         adBlockSwitch.isOn = settings.protectionIsOn
        
        if settings.protectionIsOn {
            createBlockerList()
        } else {
            let empty = ["1"]
            createTrackerFile(with: generateBlacklistJSON(with: empty))
        }
    }
    
    @IBAction private func autoConnectionSwitchActionn(_ sender: Any) {
        settings.autocennectIsOn = !settings.autocennectIsOn
        autoconnectionSwitch.isOn = settings.autocennectIsOn
    }
    
    @IBAction private func goPremiumButtonAction(_ sender: Any) {
        showSubscriptionVC()
    }
    
    @IBAction func backButtonAction(_ sender: Any) {
        navigationController?.popViewController(animated: true)
    }
    
    @IBAction private func shareAppButtonAction(_ sender: UIButton) {
        UIGraphicsBeginImageContext(view.frame.size)
        view.layer.render(in: UIGraphicsGetCurrentContext()!)
        let image = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()

        let textToShare = "Check out my app"

        if let myWebsite = URL(string: "http://itunes.apple.com/app/idXXXXXXXXX") {//Enter link to your app here
            let objectsToShare = [textToShare, myWebsite, image ?? #imageLiteral(resourceName: "app-logo")] as [Any]
            let activityVC = UIActivityViewController(activityItems: objectsToShare, applicationActivities: nil)

            //Excluded Activities
            activityVC.excludedActivityTypes = [UIActivity.ActivityType.airDrop, UIActivity.ActivityType.addToReadingList]
            //

            activityVC.popoverPresentationController?.sourceView = sender
            self.present(activityVC, animated: true, completion: nil)
        }
    }
}

//MARK: - Lifecycle
extension SettingsViewController {
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        goPremiumButton.isHidden = IAPManager.shared.hasSubscription()
    }
    
}

//MARK: - Private methods
private extension SettingsViewController {
    
     func createBlockerList() {
        //guard settings.protectionIsOn else { return }
        
        var JSONObject: BlockerList = [[:]]
        
        let baseBlockList = getBlockerList(with: "easylist")
    
        baseBlockList.forEach { (blockerList) in
            JSONObject.append(blockerList)
        }
        
        
        self.createTrackerFile(with: JSONObject)
        
    }
    
    func getBlockerList(with pathName: String) -> BlockerList {
        if let path = Bundle.main.path(forResource: pathName, ofType: "json") {
            do {
                let data = try Data(contentsOf: URL(fileURLWithPath: path), options: .mappedIfSafe)
                let jsonResult = try JSONSerialization.jsonObject(with: data, options: .mutableLeaves)
                if let j = jsonResult as? BlockerList {
                    return j
                } else {
                    return [[:]]
                }

            } catch {
                print(error.localizedDescription)
            }
        }
        return [[:]]
    }
    
    func generateBlacklistJSON(with domains: [String]) -> BlockerList {
        var blacklist: BlockerList = []
        for tracker in domains {
            blacklist.append([
                "action": ["type": "block"],
                "trigger": ["url-filter": String(format: "https?://(www.)?%@.*", tracker)]
            ])
        }

        return blacklist
    }
    
    func createTrackerFile(with JSONObject: BlockerList) {
        guard let jsonData = try? JSONSerialization.data(withJSONObject: JSONObject, options: .prettyPrinted) else {
            return
        }

        let documentFolder = FileManager.default.containerURL(forSecurityApplicationGroupIdentifier: "group.devbuff.adblocker")

        guard let jsonURL = documentFolder?.appendingPathComponent("customBlockerList.json") else {
            return
        }

        do {
            try jsonData.write(to: jsonURL)
        } catch {
            print("error")
        }

        SFContentBlockerManager.reloadContentBlocker(withIdentifier: "com.devbuff.apps.VPNdef.adblock-extension", completionHandler: { error in
            print(error?.localizedDescription ?? "")
        })
    }
    
    func showSubscriptionVC() {
        let subsVC = SubscriptionViewController(nibName: "SubscriptionViewController", bundle: nil)
        let nc = UINavigationController(rootViewController: subsVC)
        nc.modalPresentationStyle = .fullScreen
        self.present(nc, animated: true, completion: nil)
    }
    
}
