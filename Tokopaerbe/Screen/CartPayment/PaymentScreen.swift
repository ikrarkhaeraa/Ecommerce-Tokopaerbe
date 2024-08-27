//
//  PaymentScreen.swift
//  Tokopaerbe
//
//  Created by Ikrar Khaera Arfat on 01/08/24.
//

import SwiftUI

struct PaymentScreen: View {
    
    @AppStorage("isDark") private var isDark: Bool = false
    @AppStorage("isEN") private var isEN: Bool = false
    
    @Environment(\.presentationMode) var presentationMode
    @Binding var imagePayment: String
    @Binding var namePayment: String
    @Binding var isChoosePaymentMethod: Bool
    @State var isExpired: Bool = false
    @State var showExpiredAlert: Bool = false
    @State var alertExpiredMessage: String = ""
    @State var showErrorAlert: Bool = false
    @State var errorMessageAlert: String = ""
    @State private var isLoading: Bool = true
    @State var paymentMethodResponse: [PaymentRemoteConfigResponse]? = nil

    
    var body: some View {
        VStack {
            
            if isLoading {
                CircularLoadingView().frame(maxWidth: .infinity, maxHeight: .infinity)
            } else {
                
                HStack {
                    Image(uiImage: .arrowleft)
                        .renderingMode(isDark ? .template : .original)
                        .foregroundColor(isDark ? .white : nil)
                        .padding().onTapGesture {
                        self.presentationMode.wrappedValue.dismiss()
                    }
                    
                    Text(isEN ? "Payment" :"Pembayaran").frame(maxWidth: .infinity, alignment: .leading).font(.system(size: 22))
                    
                }.frame(maxWidth: .infinity, alignment: .leading)
                
                Divider()
                
                VStack {
                    ScrollView {
                        
                        ForEach((paymentMethodResponse!.indices), id: \.self) { i in
                            VStack {
                                Text("\(paymentMethodResponse![i].title)").font(.system(size: 16)).bold().foregroundColor(isDark ? .white :Color(hex: "#49454F")).frame(maxWidth: .infinity, alignment: .leading).padding()
                                
                                ForEach(paymentMethodResponse![i].item.indices, id: \.self) { j in
                                    HStack {
                                        ImageLoader(contentMode: .constant("fit"), urlString: paymentMethodResponse![i].item[j].image).frame(maxWidth: 50.0, maxHeight: 20.0)
                                        Text("\(paymentMethodResponse![i].title)").font(.system(size: 14)).foregroundColor(isDark ? .white :Color(hex: "#49454F")).fontWeight(.medium).frame(maxWidth: .infinity, alignment: .leading).padding(.leading, 4)
                                        
                                        Image(uiImage: .arrowForwardIos)
                                            .renderingMode(isDark ? .template : .original)
                                            .foregroundColor(isDark ? .white : nil)
                                    }.frame(maxWidth: .infinity, alignment: .leading).background(isDark ? .black : Color.white).padding().onTapGesture {
                                        
                                        imagePayment = paymentMethodResponse![i].item[j].image
                                        namePayment = paymentMethodResponse![i].item[j].label
                                        isChoosePaymentMethod = true
                                        self.presentationMode.wrappedValue.dismiss()
                                    }
                                    
                                    Divider().padding(.leading)
                                }
                                
                                Rectangle().foregroundColor(Color(hex: "#D9D9D9")).frame(maxWidth: .infinity, maxHeight: 4).padding(.top)
                            }
                        }
                        
                    }.frame(maxWidth: .infinity, alignment: .leading)
                }.frame(maxWidth: .infinity, maxHeight: .infinity)
            }
            
        }.navigationBarBackButtonHidden().onAppear {
            getPaymentMethod()
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
    
    private func getPaymentMethod() {
        
        hitApi(requestBody: PaymentMethodRequest(), urlApi: Url.Endpoints.payment, methodApi: "GET", token: UserDefaults().string(forKey: "bearerToken")!, type: "payment", completion: { (success: Bool, responseObject: GeneralResponse<[PaymentRemoteConfigResponse]>?) in
            if success, let responseBackend = responseObject {
                
                if responseObject?.code == 200 {
                    paymentMethodResponse = responseObject!.data
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
    PaymentScreen(imagePayment: .constant(""), namePayment: .constant(""), isChoosePaymentMethod: .constant(true))
}
