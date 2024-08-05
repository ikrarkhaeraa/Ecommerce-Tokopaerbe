//
//  SuccessPaymentScreen.swift
//  Tokopaerbe
//
//  Created by Ikrar Khaera Arfat on 02/08/24.
//

import SwiftUI

struct SuccessPaymentScreen: View {
    
    @State private var reviewText: String = ""
    @Binding var fulfillmentResponse: FulfillmentResponse?
    @State var isStarFilled: Bool = false
    @State var starFilledArray: [Bool] = [false, false, false, false, false]
    @State var goToHomeScreen: Bool = false
    @State var isLoading: Bool = false
    @State var totalRating: Int = 0
    
    @State var isExpired: Bool = false
    @State var showExpiredAlert: Bool = false
    @State var alertExpiredMessage: String = ""
    @State var showErrorAlert: Bool = false
    @State var errorMessageAlert: String = ""
    
    var body: some View {
        
        VStack {
            HStack {
                Text("Status").frame(maxWidth: .infinity, alignment: .center).font(.system(size: 22))
            }.frame(maxWidth: .infinity, alignment: .center)
            
            Divider()
            
            VStack {
                
                ZStack {
                    
                    ZStack {
                        VStack {
                            Text("Pembayaran Berhasil").font(.system(size: 24)).fontWeight(.semibold).foregroundColor(Color(hex: "#6750A4")).padding(.top, 60)
                            
                            HStack{
                                ForEach(0...4, id: \.self) { i in
                                    ratingStarView(isFilled: $starFilledArray[i], starFilledArray: $starFilledArray, totalRating: $totalRating, iteration: i)
                                }
                            }.frame(maxWidth: .infinity, alignment: .center).padding(.top, 8)
                            
                            Text("Beri ulasan").font(.system(size: 14)).fontWeight(.medium).foregroundColor(Color(hex: "#49454F")).frame(maxWidth: .infinity, alignment: .leading).padding(.horizontal).padding(.top, 32)
                            
                            TextEditor(text: $reviewText)
                                .frame(height: 100)
                                .padding(.all, 4)
                                .background(RoundedRectangle(cornerRadius: 8).stroke(Color.black, lineWidth: 2))
                                .cornerRadius(10)
                                .padding()
                                .font(.system(size: 16))
                                .autocapitalization(.none)

                            
                        }.frame(maxWidth: .infinity)
                            .background(Color.white)
                            .cornerRadius(8)
                            .padding(.top, 24)
                            .padding(.horizontal, 20)
                            .shadow(color: .gray, radius: 2, x: 0, y: 2)
                    }.frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top).padding(.top)
                    
                    ZStack {
                        Circle().fill(Color(hex: "#EADDFF")).frame(maxWidth: 64, maxHeight: 64)
                        Image(uiImage: .check)
                    }.frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
                        .padding(.top)
                }
                
                VStack {
                    Text("Detail Produk").font(.system(size: 14)).fontWeight(.medium).foregroundColor(Color(hex: "#49454F")).frame(maxWidth: .infinity, alignment: .leading)
                    
                    HStack {
                        Text("ID Transaksi").font(.system(size: 12)).foregroundColor(Color(hex: "#49454F")).frame(maxWidth: .infinity, alignment: .leading)
                        
                        Text("\(fulfillmentResponse!.invoiceId)").font(.system(size: 12)).fontWeight(.medium)
                    }.padding(.top)
                    
                    HStack {
                        Text("Status").font(.system(size: 12)).foregroundColor(Color(hex: "#49454F")).frame(maxWidth: .infinity, alignment: .leading)
                        
                        Text("\(fulfillmentResponse!.status)").font(.system(size: 12)).fontWeight(.medium)
                    }.padding(.top, 4)
                    
                    HStack {
                        Text("Tanggal").font(.system(size: 12)).foregroundColor(Color(hex: "#49454F")).frame(maxWidth: .infinity, alignment: .leading)
                        
                        Text("\(fulfillmentResponse!.date)").font(.system(size: 12)).fontWeight(.medium)
                    }.padding(.top, 4)
                    
                    HStack {
                        Text("Waktu").font(.system(size: 12)).foregroundColor(Color(hex: "#49454F")).frame(maxWidth: .infinity, alignment: .leading)
                        
                        Text("\(fulfillmentResponse!.time)").font(.system(size: 12)).fontWeight(.medium)
                    }.padding(.top, 4)
                    
                    HStack {
                        Text("Metode Pembayaran").font(.system(size: 12)).foregroundColor(Color(hex: "#49454F")).frame(maxWidth: .infinity, alignment: .leading)
                        
                        Text("\(fulfillmentResponse!.payment)").font(.system(size: 12)).fontWeight(.medium)
                    }.padding(.top, 4)
                    
                    HStack {
                        Text("Total Pembayaran").font(.system(size: 12)).foregroundColor(Color(hex: "#49454F")).frame(maxWidth: .infinity, alignment: .leading)
                        
                        Text("\(fulfillmentResponse!.total)").font(.system(size: 12)).fontWeight(.medium)
                    }.padding(.top, 4)
                    
                }.frame(maxWidth:.infinity, maxHeight: .infinity, alignment: .topLeading).padding()
                
            
            }.frame(maxWidth: .infinity, maxHeight: .infinity)
            
            Divider()
            
            if isLoading {
                CircularLoadingView()
            } else {
                Button(action: {
                    postRating(fulfillmentResponse: fulfillmentResponse!)
                    isLoading = true
                }, label: {
                    Text("Selesai")
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color(hex: "#6750A4"))
                        .cornerRadius(25)
                }).padding()
            }
            
            
            NavigationLink(destination: MainScreen(page: 0), isActive: $goToHomeScreen) {
                EmptyView()
            }
            
            NavigationLink(destination: LoginScreen(), isActive: $isExpired) {
                EmptyView()
            }
            
        }.navigationBarBackButtonHidden()
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
    
    private func postRating(fulfillmentResponse: FulfillmentResponse) {

        let request = RatingBody(invoiceId: fulfillmentResponse.invoiceId, rating: 0, review: reviewText)
        
        hitApi(requestBody: request, urlApi: Url.Endpoints.rating, methodApi: "POST", token: UserDefaults().string(forKey: "bearerToken")!, type: "rating", completion: { (success: Bool, responseObject: GeneralResponse<RatingResponse>?) in
            if success, let responseBackend = responseObject {
                
                if responseObject?.code == 200 {
                    isLoading = false
                    goToHomeScreen = true
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
    SuccessPaymentScreen(fulfillmentResponse: .constant(FulfillmentResponse(invoiceId: "", status: true, date: "", time: "", payment: "", total: 0)))
}

struct ratingStarView: View {
    
    @Binding var isFilled: Bool
    @Binding var starFilledArray: [Bool]
    @Binding var totalRating: Int
    var iteration: Int
    
    var body: some View {
        Image(systemName: "star.fill").font(.system(size: 30)).foregroundColor(isFilled ? Color.yellow : Color(hex: "#49454F")).onTapGesture {
            
            for i in 0...4 {
                if i == iteration {
                    isFilled = true
                    for i in 0...iteration {
                        starFilledArray[i] = true
                    }
                    if i < 4 {
                        for i in iteration+1...4 {
                            starFilledArray[i] = false
                        }
                    }
                }
            }
            
            for i in 0...4 {
                if starFilledArray[i] == true {
                    totalRating += 1
                }
            }
        }
    }
}
