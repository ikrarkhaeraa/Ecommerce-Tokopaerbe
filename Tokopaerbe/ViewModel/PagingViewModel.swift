//
//  PagingViewModel.swift
//  Tokopaerbe
//
//  Created by Ikrar Khaera Arfat on 23/06/24.
//

import Foundation

class PagingViewModel : ObservableObject {
    
    //MARK: - Properties
    @Published var product : [Product] = []
    @Published var isLoading: Bool = true
    @Published var isLoadingPaging: Bool = false
    @Published var errorMessage: String = ""
    @Published var errorCode: String = ""
    @Published var expiredAlertMessage: String = ""
    @Published var showExpiredAlert: Bool = false
    
    var totalPages = 0
    var page : Int = 1
    
//    init() {
//        getProduct(
//            search: nil, brand: nil, lowest: nil, highest: nil, sort: nil, page: page
//        )
//    }
    
    //MARK: - PAGINATION
    func loadMoreContent(currentItem item: Product,
                         search: String?,
                         brand: String?,
                         lowest: Int?,
                         highest: Int?,
                         sort: String?
    ) {
        if let thresholdId = self.product.last?.productId, thresholdId == item.productId, (page + 1) <= totalPages {
            page += 1
            self.isLoadingPaging = true
            getProduct(
                search: search, brand: brand, lowest: lowest, highest: highest, sort: sort, page: page
            )
        }
    }
    
    //MARK: - API CALL
    func getProduct(
        search: String?, brand: String?, lowest: Int?, highest: Int?, sort: String?, page: Int
    ){
        
//        self.isLoading = true
        
        let token = UserDefaults.standard.string(forKey: "bearerToken")
        
        let request = ProductsQuery(search: search, brand: brand, lowest: lowest, highest: highest, sort: sort, limit: nil, page: page)
        
        let _ = hitApi(requestBody: request, urlApi: Url.Endpoints.products, methodApi: "POST", token: token ?? "", type: "products") { (success: Bool, responseObject: GeneralResponse<ProductsResponse>?) in
            if success, let responseBackend = responseObject {
                
                Log.d("store : \(responseObject!)")
                
                if responseObject?.code == 200 {
                    self.isLoading = false
                    self.isLoadingPaging = false
                    self.totalPages = (responseObject?.data!.totalPages)!
                    self.product.append(contentsOf: (responseObject?.data!.items)!)
                    self.errorMessage = ""
                    self.errorCode = ""
                } else if responseObject?.code == 401 {
                    self.isLoading = false
                    self.isLoadingPaging = false
                    self.errorMessage = ""
                    self.errorCode = ""
                    self.expiredAlertMessage = responseObject!.message
                    self.showExpiredAlert = true
                } else {
                    self.isLoading = false
                    self.isLoadingPaging = false
                    self.errorCode = String(responseObject!.code)
                    self.errorMessage = responseObject!.message
                }
                
            } else {
                let _ = Log.d("masuk no connection")
                self.isLoading = false
                self.isLoadingPaging = false
                self.errorCode = "Connection"
                self.errorMessage = "Koneksi anda tidak tersedia"
            }
        }
        
    }
    
}
