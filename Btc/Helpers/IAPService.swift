//
//  IAPService.swift
//  Btc
//
//  Created by Akshit Talwar on 20/02/2018.
//  Copyright © 2018 atalw. All rights reserved.
//

import Foundation
import StoreKit

class IAPService: NSObject {
    
    let defaults = UserDefaults.standard
    
    // cant create IAPService object
    private override init() {}
    
    // use singleton
    static let shared = IAPService()
    
    var products = [SKProduct]()
    let paymentQueue = SKPaymentQueue.default()
    
    var completionHandler: ((Bool, [SKProduct]?) -> Void)!
    var completionHandlerBool: ((Bool) -> Void)!

    func requestProductsWithCompletionHandler(completionHandler:@escaping (Bool, [SKProduct]?) -> Void){
        self.completionHandler = completionHandler
        
        #if DEBUG
            let products: Set = [IAPProductDev.removeAds.rawValue, IAPProductDev.unlockMarkets.rawValue]
        #else
            let products: Set = [IAPProduct.removeAds.rawValue, IAPProduct.unlockMarkets.rawValue]
        #endif
        
        let request = SKProductsRequest(productIdentifiers: products)
        
        request.delegate = self
        request.start()
        paymentQueue.add(self)
    }
    
    func purchase(product: IAPProduct, completionHandlerBool:@escaping (Bool) -> Void) {
        self.completionHandlerBool = completionHandlerBool
        print(product.rawValue, products[0].productIdentifier)
        guard let productToPurchase = products.filter({ $0.productIdentifier == product.rawValue }).first else { return }
        let payment = SKPayment(product: productToPurchase)
        paymentQueue.add(payment)
    }
    
    func restorePurchases() {
        paymentQueue.restoreCompletedTransactions()
    }
    
}

extension IAPService: SKProductsRequestDelegate {
    
    func productsRequest(_ request: SKProductsRequest, didReceive response: SKProductsResponse) {
        self.products = response.products
        for product in response.products {
            print(product.localizedTitle)
            print(product.priceLocale)
            print(product.price)
        }
        
        completionHandler(true, products)
    }
}

extension IAPService: SKPaymentTransactionObserver {
    
    func paymentQueue(_ queue: SKPaymentQueue, updatedTransactions transactions: [SKPaymentTransaction]) {
        for transaction in transactions {
            print(transaction.transactionState.status(), transaction.payment.productIdentifier)
            if transaction.payment.productIdentifier == IAPProduct.removeAds.rawValue {
                switch transaction.transactionState {
                case .purchased:
                    print("AHSDFHAHF")
                    defaults.set(true, forKey: "removeAdsPurchased")
                    queue.finishTransaction(transaction)
                case .restored:
                    print("restoring it bitch")
                    queue.restoreCompletedTransactions()
                    defaults.set(true, forKey: "removeAdsPurchased")
                case .purchasing:
                    print("adsfadfadfa")
                default:
                    print("nonneeeee")
                    queue.finishTransaction(transaction)
                    break
                }
            }
            
            if transaction.payment.productIdentifier == IAPProduct.unlockMarkets.rawValue {
                switch transaction.transactionState {
                case .purchased:
                    print("AHSDFHAHF")
                    defaults.set(true, forKey: "unlockMarketsPurchased")
                    queue.finishTransaction(transaction)
                    completionHandlerBool(true)
                case .restored:
                    print("restoring it bitch")
                    queue.restoreCompletedTransactions()
                    defaults.set(true, forKey: "unlockMarketsPurchased")
                case .purchasing:
                    print("adsfadfadfa")
                default:
                    print("nonneeeee")
                    queue.finishTransaction(transaction)
                    break
                }
            }
            
        }
    }
}

extension SKPaymentTransactionState {
    func status() -> String {
        switch self {
        case .deferred: return "deferred"
        case .failed: return "failed"
        case .purchased: return "purchased"
        case .purchasing: return "purchasing"
        case .restored: return "restored"
        }
    }
}


extension SKProduct {
    func localizedPrice() -> String {
        let formatter = NumberFormatter()
        formatter.numberStyle = .currency
        formatter.locale = self.priceLocale
        return formatter.string(from: self.price)!
    }
}
