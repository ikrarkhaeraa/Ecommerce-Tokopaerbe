//
//  SearchViewModel.swift
//  Tokopaerbe
//
//  Created by Ikrar Khaera Arfat on 25/06/24.
//

import Foundation

class SearchViewModel: ObservableObject {
    
    //MARK: - Properties
    @Published var product : [String] = []
    @Published var isLoading: Bool = false
    @Published var errorMessage: String = ""
    @Published var errorCode: String = ""
    @Published var expiredAlertMessage: String = ""
    @Published var showExpiredAlert: Bool = false
    @Published var searchText: String = ""


    //MARK: - API CALL
    func searchProduct(query: String?){
        
        self.isLoading = true
        
        let token = UserDefaults.standard.string(forKey: "bearerToken")
        
        
        var request = SearchQuery(query: query)
//        if query != "" || query != nil {
//            request = SearchQuery(query: query!)!
//        }
        
        let _ = hitApi(requestBody: request, urlApi: Url.Endpoints.search, methodApi: "POST", token: token ?? "", type: "search") { (success: Bool, responseObject: GeneralResponse<[String]>?) in
            if success, let responseBackend = responseObject {
                
                Log.d("search : \(responseObject!)")
                
                if responseObject?.code == 200 {
                    self.isLoading = false
                    self.product = (responseObject?.data!)!
                    self.errorMessage = ""
                    self.errorCode = ""
                } else if responseObject?.code == 401 {
                    self.isLoading = false
                    self.errorMessage = ""
                    self.errorCode = ""
                    self.expiredAlertMessage = responseObject!.message
                    self.showExpiredAlert = true
                } else {
                    self.isLoading = false
                    self.errorCode = String(responseObject!.code)
                    self.errorMessage = responseObject!.message
                }
                
            } else {
                let _ = Log.d("masuk no connection")
                self.isLoading = false
                self.errorCode = "Connection"
                self.errorMessage = "Koneksi anda tidak tersedia"
            }
        }
        
    }
    
    
}
