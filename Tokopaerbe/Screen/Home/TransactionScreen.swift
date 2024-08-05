//
//  TransactionScreen.swift
//  Tokopaerbe
//
//  Created by Ikrar Khaera Arfat on 11/06/24.
//

import SwiftUI

struct TransactionScreen: View {
    
    @State var isLoading: Bool = false
    @State var isExpired: Bool = false
    @State var showExpiredAlert: Bool = false
    @State var alertExpiredMessage: String = ""
    @State var showErrorAlert: Bool = false
    @State var errorMessageAlert: String = ""
    @State var transactionResponse: [TransactionResponse]? = nil
    
    var body: some View {
        ScrollView {
            VStack {
                ForEach(transactionResponse!.indices, id: \.self) { i in
                    
                }
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
            .onAppear {
                getTransactionHistory()
            }
            .alert(isPresented: $showExpiredAlert, content: {
            Alert(
                title: Text("Error"),
                message: Text(alertExpiredMessage),
                dismissButton: .default(Text("OK"), action: {
                    isExpired = true
                })
            )
        })
            .alert(isPresented: $showErrorAlert, content: {
            Alert(
                title: Text("Error"),
                message: Text(errorMessageAlert),
                dismissButton: .default(Text("OK"))
            )
        })
        
    }
    
    private func getTransactionHistory() {
        
        hitApi(requestBody: TransactionRequest(), urlApi: Url.Endpoints.transaction, methodApi: "GET", token: UserDefaults().string(forKey: "bearerToken")!, type: "transaction", completion: { (success: Bool, responseObject: GeneralResponse<[TransactionResponse]>?) in
            if success, let responseBackend = responseObject {
                
                if responseObject?.code == 200 {
                    transactionResponse = responseObject?.data
                    isLoading = false
                } else if responseObject?.code == 401 {
                    alertExpiredMessage = responseObject!.message
                    isLoading = false
                    showExpiredAlert = true
                } else {
                    isLoading = false
                    showErrorAlert = true
                    errorMessageAlert = responseObject!.message
                }
                
            } else {
                isLoading = false
                showErrorAlert = true
                errorMessageAlert = "Server tidak dapat melayani permintaan anda"
            }
        })
    }
    
}

#Preview {
    TransactionScreen()
}
