//
//  PurchaseManager.swift
//  Fitplay
//
//  Created by Samuel Vulakh on 5/9/23.
//

import Foundation
import StoreKit
import Firebase
import SwiftUI

@MainActor class PurchaseManager: NSObject, ObservableObject {
    
    /// User Updates To Their Subscription Status
    private var updates: Task<Void, Never>? = nil
        
    /// Lacally Checks If The User Is Premium
    @AppStorage("hasPro") var hasPro: Bool = false
    
    /// All Products That Are Available For Purchase
    @Published private(set) var products: [Product] = []
    
    /// Error Handle
    @Published var handle = Handle()
    
    /// Show Subscription Screen
    @Published var showSubscribe = false
    
    // Initialization
    override init() {
        super.init()
        updates = observeTransactionUpdates()
        SKPaymentQueue.default().add(self)
    }
    
    // Removing Updates On Deinitialization
    deinit {
        updates?.cancel()
    }
    
    /// Start Monitoring Transaction Updates
    private func observeTransactionUpdates() -> Task<Void, Never> {
        Task(priority: .background) { [unowned self] in
            for await _ in Transaction.updates {
                await self.updatePurchasedProducts()
            }
        }
    }

    /// Load Available Products From StoreKit
    @Sendable func loadProducts() async {
        
        // Toggling Subscription Screen If User Is Not Subscribed
        if !hasPro { DispatchQueue.main.asyncAfter(deadline: .now() + 2) { self.showSubscribe.toggle() } }
        
        // Making Sure Products Haven't Been Fetched
        guard products.isEmpty else { return }
        
        do {
            // Fetching Products
            self.products = try await Product.products(for: ["qbikcrew.AIArtGeneratorMonthly"])
            print(products)
        } catch {
            print(error)
        }
    }

    /// Purchase A Product From StoreKit
    func purchase(_ product: Product, onError: @escaping () -> Void) async throws {
        
        // Toggling Loading
        self.set(true)
        
        do {
//            if self.subscription_with_trial {
                /// Transaction Result
//                let result = try await product.purchase(options: [.promotionalOffer(offerID: "AIArtGeneratorMonthyTrialPromotion", keyID: "", nonce: UUID(), signature: Data(), timestamp: Int(Date().timeIntervalSince1970))])
//                await managePurchaseResult(product, result: result)
//            } else {
                let result = try await product.purchase()
                await managePurchaseResult(product, result: result)
//            }
            
            // Toggling Loading
            self.set()
        } catch {
            self.set()
            onError()
        }
    }
    
    func managePurchaseResult(_ product: Product, result: StoreKit.Product.PurchaseResult) async {
        switch result {
        case let .success(.verified(transaction)):
            await transaction.finish()
            await self.purchaseSuccess(product)
        case let .success(.unverified(_, error)):
            // Successful purchase but transaction/receipt can't be verified
            // Could be a jailbroken phone
            self.set(error)
            break
        case .pending:
            // Transaction waiting on SCA (Strong Customer Authentication) or
            // approval from Ask to Buy
            break
        case .userCancelled:
            // User Cancelled Transaction
            self.set(.err("User Cancelled"))
            self.set()
            break
        @unknown default:
            self.set()
            return
        }
    }
    
    /// The Callback Function When A Subscription Is Successfully Purchased
    func purchaseSuccess(_ product: Product, restore: Bool = false) async {
                
        // Updating Local Subscription Status
        await self.updatePurchasedProducts()
                
        // Dismissing View
        showSubscribe.toggle()
    }
    
    /// Restore A Subscription
    func restore() {
        self.set(true)
        Task { self.hasPro = (try? await AppStore.sync()) != nil }
        self.set(false)
    }
    
    @Published private(set) var purchasedProductIDs = Set<String>()

    func updatePurchasedProducts() async {
        for await result in Transaction.currentEntitlements {
            guard case .verified(let transaction) = result else { continue }

            if transaction.revocationDate == nil {
                self.purchasedProductIDs.insert(transaction.productID)
            } else {
                self.purchasedProductIDs.remove(transaction.productID)
            }
        }
        print(self.purchasedProductIDs)
        self.hasPro = !self.purchasedProductIDs.isEmpty
    }

    /// Setting The Handle Object From A Thrown Error
    func set(_ error: Error) {
        DispatchQueue.main.async { withAnimation { self.handle = Handle(value: .err(error.localizedDescription), loading: false) } }
    }
    
    /// Setting The Handle Object From A Thrown Error
    func set(_ value: ErrorHandle?) {
        DispatchQueue.main.async { withAnimation { self.handle = Handle(value: value, loading: false) } }
    }
    
    /// Setting The Handle Loading Status
    func set(_ loading: Bool? = nil) {
        DispatchQueue.main.async { withAnimation { self.handle.loading = loading ?? !self.handle.loading } }
    }
}

extension PurchaseManager: SKPaymentTransactionObserver {
    func paymentQueue(_ queue: SKPaymentQueue, updatedTransactions transactions: [SKPaymentTransaction]) {

    }

    func paymentQueue(_ queue: SKPaymentQueue, shouldAddStorePayment payment: SKPayment, for product: SKProduct) -> Bool {
        return true
    }
}
