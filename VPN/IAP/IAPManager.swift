//
//  IAPManager.swift
//  AdBlock
//
//  Created by Igor Ryazancev on 4/2/20.
//  Copyright © 2020 DEVBUFF. All rights reserved.
//

import StoreKit
import TPInAppReceipt
//import Firebase


typealias ProductType = IAPManager.ProductType

protocol IAPManagerDelegate: class {
    func inAppLoadingStarted()
    func inAppLoadingSucceded(productType: ProductType)
    func inAppLoadingFailed(error: Swift.Error?)
    func subscriptionStatusUpdated(value: Bool)
}

class IAPManager: NSObject {
    
    static let shared = IAPManager()
    private override init() {}
    
    private(set) var products: [SKProduct]? {
        didSet {
            products?.sort { $0.price.floatValue < $1.price.floatValue }
        }
    }
    weak var delegate: IAPManagerDelegate?
    
    var isSubscriptionAvailable: Bool = true
        {
        didSet(value) {
            self.delegate?.subscriptionStatusUpdated(value: value)
        }
    }
    
    //public methods
    func loadProducts() {
        let productIdentifiers = Set<String>(ProductType.all.map({$0.rawValue}))
        let request = SKProductsRequest(productIdentifiers: productIdentifiers)
        request.delegate = self
        request.start()
        SKPaymentQueue.default().add(self)
    }
    
    func purchaseProduct(productType: ProductType) {
        guard let products = self.products else { return }
        guard let product = products.filter({$0.productIdentifier == productType.rawValue}).first else {
            self.delegate?.inAppLoadingFailed(error: InAppErrors.noProductsAvailable)
            return
        }
        let payment = SKMutablePayment(product: product)
        SKPaymentQueue.default().add(payment)
    }
    
    func hasSubscription() -> Bool {
        var has = false
        do {
          /// Initialize receipt
            let receipt = try InAppReceipt.localReceipt()
            self.products?.forEach({ (product) in
                if !receipt.activeAutoRenewableSubscriptionPurchases.isEmpty {
                    has = true
                }
            })
            
          
        } catch {
          print(error)
        }
        return has
    }
    
    func restorePurchases() {
        if (SKPaymentQueue.canMakePayments()) {
          SKPaymentQueue.default().restoreCompletedTransactions()
        }
    }
    
}

//MARK: - SKPaymentTransactionObserver
extension IAPManager: SKPaymentTransactionObserver {
    
    func paymentQueue(_ queue: SKPaymentQueue, updatedTransactions transactions: [SKPaymentTransaction]) {
        for transaction in transactions {
            guard let productType = ProductType(rawValue: transaction.payment.productIdentifier) else {fatalError()}
            switch transaction.transactionState {
            case .purchasing:
                self.delegate?.inAppLoadingStarted()
            case .purchased:
                SKPaymentQueue.default().finishTransaction(transaction)
                //self.updateSubscriptionStatus()
                self.isSubscriptionAvailable = true
                self.delegate?.inAppLoadingSucceded(productType: productType)
               // Analytics.logEvent("bought_\(productType.rawValue)", parameters: [:])
                //self.sendPostBack()
            case .failed:
                if let transactionError = transaction.error as NSError?,
                    transactionError.code != SKError.paymentCancelled.rawValue {
                    self.delegate?.inAppLoadingFailed(error: transaction.error)
                } else {
                    self.delegate?.inAppLoadingFailed(error: InAppErrors.noSubscriptionPurchased)
                }
                SKPaymentQueue.default().finishTransaction(transaction)
               // SKPaymentQueue.default().remove(self)
            case .restored:
                SKPaymentQueue.default().finishTransaction(transaction)
                //self.updateSubscriptionStatus()
                self.isSubscriptionAvailable = true
                self.delegate?.inAppLoadingSucceded(productType: productType)
                //Analytics.logEvent("restored_\(productType.rawValue)", parameters: [:])
                //self.sendPostBack()
            case .deferred:
                self.delegate?.inAppLoadingSucceded(productType: productType)
            @unknown default:
                fatalError()
            }
        }
    }
    
    func sendPostBack() {
//        guard let subid = settings.funnelSUBID, subid != "{subid}" else { return }
//        let postbackLink = RemoteConfig.remoteConfig().configValue(forKey: "postback_link").stringValue ?? ""
//        let url = URL(string: postbackLink + "?subid=\(subid)&revenue=1")!
//
//        let task = URLSession.shared.dataTask(with: url) {(data, response, error) in
//            guard let data = data else { return }
//            print(String(data: data, encoding: .utf8)!)
//        }
//
//        task.resume()
    }
    
}

//MARK: - SKProductsRequestDelegate
extension IAPManager: SKProductsRequestDelegate {
    
    func productsRequest(_ request: SKProductsRequest, didReceive response: SKProductsResponse) {
        self.products = response.products
    }
    
}

//MARK: - Common
extension IAPManager {
    
    enum ProductType: String {
        case weekly = "com.module.vpn.one.week.subscription"
        case monthly = "com.module.vpn.one.month.subscription"
       
        static var all: [ProductType] {
            return [.weekly, .monthly]
        }
    }
    
    enum InAppErrors: Swift.Error {
        case noSubscriptionPurchased
        case noProductsAvailable
        
        var localizedDescription: String {
            switch self {
            case .noSubscriptionPurchased:
                return "No subscription purchased"
            case .noProductsAvailable:
                return "No products available"
            }
        }
    }
    
}
