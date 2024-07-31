////
////  RealmProductDetailViewModel.swift
////  Tokopaerbe
////
////  Created by Ikrar Khaera Arfat on 23/07/24.
////
//
//import Foundation
//import RealmSwift
//
//class RealmProductDetailViewModel: ObservableObject {
//
//    @ObservedResults(ProductObject.self) var productSavedList
//    @Published var products: [ProductModel] = []
//
//    private var token: NotificationToken?
//
//    init() {
//        setupObserver()
//    }
//
//    deinit {
//        token?.invalidate()
//    }
//// fetch and update contactList
//    private func setupObserver() {
//        do {
//            let realm = try Realm()
//            let results = realm.objects(ProductObject.self)
//
//            token = results.observe({ [weak self] changes in
//                self?.products = results.map(ProductModel.init)
//                    .sorted(by: { $0.name > $1.name })
//            })
//        } catch let error {
//            print(error.localizedDescription)
//        }
//    }
//        // Add contact
//    func addProduct(id: String, name: String, price: Int, store: String, rating: Float16, sale: Int) {
//        let product = ProductObject()
//        product.id = id
//        product.productName = name
//        product.productPrice = price
//        product.productStore = store
//        product.productRating = rating
//        product.productSale = sale
//        $productSavedList.append(product)
//    }
//
//        // Delete contact
//    func remove(id: String) {
//        do {
//            let realm = try Realm()
//            let objectId = id
//            if let product = realm.object(ofType: ProductObject.self, forPrimaryKey: id) {
//                try realm.write {
//                    realm.delete(product)
//                }
//            }
//        } catch let error {
//            print(error)
//        }
//    }
//        // Update contact
////    func update(id: String, name: String, phone: String, isBuddy: Bool) {
////        do {
////            let realm = try Realm()
////            let objectId = try ObjectId(string: id)
////            let contact = realm.object(ofType: ContactObject.self, forPrimaryKey: objectId)
////            try realm.write {
////                contact?.name = name
////                contact?.phone = phone
////                contact?.isBuddy = isBuddy
////            }
////        } catch let error {
////            print(error.localizedDescription)
////        }
////    }
//}
//
//class ProductObject: Object, Identifiable {
//    @Persisted(primaryKey: true) var id: String
//    @Persisted var productName: String
//    @Persisted var productPrice: Int
//    @Persisted var productStore: String
//    @Persisted var productRating: Float16
//    @Persisted var productSale: Int
//}
//
//// Newly Updated ContactModel
//struct ProductModel: Identifiable {
//    var id: String
//    var productName: String
//    var productPrice: Int
//    var productStore: String
//    var productRating: Float16
//    var productSale: Int
//
//    init(product: ProductObject) {
//        self.id = product.id
//        self.productName = product.productName
//        self.productPrice = product.productPrice
//        self.productStore = product.productStore
//        self.productRating = product.productRating
//        self.productSale = product.productSale
//    }
//}
