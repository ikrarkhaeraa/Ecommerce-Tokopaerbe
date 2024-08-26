//
//  TransactionScreen.swift
//  Tokopaerbe
//
//  Created by Ikrar Khaera Arfat on 11/06/24.
//

import SwiftUI

struct TransactionScreen: View {
    
    @AppStorage("isDark") private var isDark: Bool = false
    @AppStorage("isEN") private var isEN: Bool = false
    
    @State var isLoading: Bool = true
    @State var isExpired: Bool = false
    @State var showExpiredAlert: Bool = false
    @State var alertExpiredMessage: String = ""
    @State var showErrorAlert: Bool = false
    @State var errorMessageAlert: String = ""
    @State var transactionResponse: [TransactionResponse]? = nil
    @State var goToRating: Bool = false
    @State var chosenItem: Int = 0
    
    var body: some View {
        
        if isLoading {
            ZStack {
                CircularLoadingView().onAppear {
                    getTransactionHistory()
                }
            }.frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .center)
        } else {
            if transactionResponse == nil {
                VStack {
                    Image(uiImage: UIImage.errorState)
                    Text("Empty").font(.system(size: 32)).foregroundColor(isDark ? .white : .black).bold()
                    Text("\(errorMessageAlert)")
                    Button(action: {
                        getTransactionHistory()
                        isLoading = true
                    }, label: {
                        Text("Refresh").foregroundColor(.white)
                    }).padding(16).padding(.horizontal, 16).background(Color(hex: "#6750A4")).cornerRadius(100).padding(8)
                }.frame(maxWidth: .infinity ,maxHeight: .infinity, alignment: .center)
            } else {
                ScrollView {
                        ForEach(transactionResponse!.indices, id: \.self) { i in
                            VStack {
                                
                                HStack {
                                    Image(uiImage: .shoppingBag)
                                        .renderingMode(isDark ? .template : .original)
                                        .foregroundColor(isDark ? .white : nil)
                                    VStack {
                                        Text(isEN ? "Shopping" :"Belanja").font(.system(size: 10)).fontWeight(.bold).foregroundColor(isDark ? .white :Color(hex: "#49454F")).frame(maxWidth: .infinity, alignment: .leading)
                                        Text("\(transactionResponse![i].date)").font(.system(size: 10)).frame(maxWidth: .infinity, alignment: .leading)
                                    }
                                    
                                    ZStack {
                                        Text(isEN ? "Done" :"Selesai").font(.system(size: 10)).fontWeight(.bold).foregroundColor(isDark ? .black :Color(hex: "#6750A4")).padding(4.0).background(Color(hex: "#EADDFF")).cornerRadius(4.0)
                                    }
                                }
                                
                                Divider()
                                
                                VStack {
                                    HStack {
                                        ImageLoader(contentMode: .constant("fill"), urlString: transactionResponse![i].image)
                                            .frame(maxWidth: 60, maxHeight: 60)
                                        
                                        VStack {
                                            Text("\(transactionResponse![i].name)").font(.system(size: 14)).foregroundColor(isDark ? .white :Color(hex: "#49454F")).fontWeight(.medium).lineLimit(1)
                                                .truncationMode(.tail)
                                                .fixedSize(horizontal: false, vertical: true)
                                                .frame(maxWidth: .infinity, alignment: .leading)
                                                .padding(.trailing)
                                            
                                            Text(isEN ? "\(transactionResponse![i].items.count) items" :"\(transactionResponse![i].items.count) barang").font(.system(size: 10)).foregroundColor(isDark ? .white :Color(hex: "#49454F"))
                                                .frame(maxWidth: .infinity, alignment: .leading).padding(.top, 2)
                                        }
                                    }
                                    
                                    HStack {
                                        VStack {
                                            Text(isEN ? "Total Price" :"Total Belanja").font(.system(size: 10)).foregroundColor(isDark ? .white :Color(hex: "#49454F"))
                                                .frame(maxWidth: .infinity, alignment: .leading).padding(.top, 4).padding(.bottom, 2)
                                            
                                            Text("Rp\(transactionResponse![i].total)").font(.system(size: 14)).foregroundColor(isDark ? .white :Color(hex: "#49454F")).fontWeight(.bold)
                                                .frame(maxWidth: .infinity, alignment: .leading)
                                        }
                                        
                                        if transactionResponse![i].review == ""  {
                    
                                            Button(action: {
                                                chosenItem = i
                                                goToRating = true
                                            }, label: {
                                                Text("Ulas").font(.system(size: 12)).foregroundColor(.white).fontWeight(.medium)
                                                    .padding(.vertical, 4)
                                                    .padding(.horizontal, 20)
                                                    .background(Color(hex: "#6750A4"))
                                                    .cornerRadius(25)
                                            
                                            })
                                        }
                                    
                                    }
                                }
                                
                            }
                            .padding()
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .background(isDark ? .black :Color.white)
                                .cornerRadius(8)
                                .shadow(color: .gray, radius: 2, x: 0, y: 2)
                        }.padding(.horizontal).padding(.vertical, 4)
                    
                    if !transactionResponse!.isEmpty {
                        NavigationLink(
                            destination: SuccessPaymentScreen(fulfillmentResponse: .constant(FulfillmentResponse(invoiceId: transactionResponse![chosenItem].invoiceId, status: transactionResponse![chosenItem].status, date: transactionResponse![chosenItem].date, time: transactionResponse![chosenItem].time, payment: transactionResponse![chosenItem].payment, total: transactionResponse![chosenItem].total))),
                            isActive: $goToRating) {
                                EmptyView()
                            }
                    }
                    
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
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
        }
        
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
