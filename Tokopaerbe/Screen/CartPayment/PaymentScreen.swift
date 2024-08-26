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
                        
//                        Text("Transfer Virtual Account").font(.system(size: 16)).bold().foregroundColor(isDark ? .white :Color(hex: "#49454F")).frame(maxWidth: .infinity, alignment: .leading).padding()
//                        
//                        ForEach(1...4, id: \.self) { i in
//                            VStack {
//                                HStack {
//                                    
//                                    if i == 1 {
//                                        Image(uiImage: .bca)
//                                        Text("BCA Virtual Account").font(.system(size: 14)).foregroundColor(isDark ? .white :Color(hex: "#49454F")).fontWeight(.medium).frame(maxWidth: .infinity, alignment: .leading).padding(.leading, 4)
//                                    } else if i == 2 {
//                                        Image(uiImage: .bni)
//                                        Text("BNI Virtual Account").font(.system(size: 14)).foregroundColor(isDark ? .white :Color(hex: "#49454F")).fontWeight(.medium).frame(maxWidth: .infinity, alignment: .leading).padding(.leading, 4)
//                                    } else if i == 3 {
//                                        Image(uiImage: .bri)
//                                        Text("BRI Virtual Account").font(.system(size: 14)).foregroundColor(isDark ? .white :Color(hex: "#49454F")).fontWeight(.medium).frame(maxWidth: .infinity, alignment: .leading).padding(.leading, 4)
//                                    } else if i == 4 {
//                                        Image(uiImage: .mandiri)
//                                        Text("Mandiri Virtual Account").font(.system(size: 14)).foregroundColor(isDark ? .white :Color(hex: "#49454F")).fontWeight(.medium).frame(maxWidth: .infinity, alignment: .leading).padding(.leading, 4)
//                                    } else {
//                                        Image (uiImage: .addCard)
//                                        Text("Lainnya").font(.system(size: 14)).foregroundColor(isDark ? .white :Color(hex: "#49454F")).fontWeight(.medium).frame(maxWidth: .infinity, alignment: .leading).padding(.leading, 4)
//                                    }
//                                    
//                                    Image(uiImage: .arrowForwardIos)
//                                        .renderingMode(isDark ? .template : .original)
//                                        .foregroundColor(isDark ? .white : nil)
//                                }.frame(maxWidth: .infinity, alignment: .leading).background(isDark ? .black : Color.white).padding().onTapGesture {
//                                    
//                                    print ("clicked")
//                                    
//                                    if i == 1 {
//                                        imagePayment = Image(uiImage: .bca)
//                                        namePayment = "BCA Virtual Account"
//                                    } else if i == 2 {
//                                        imagePayment = Image(uiImage: .bni)
//                                        namePayment = "BNI Virtual Account"
//                                    } else if i == 3 {
//                                        imagePayment = Image(uiImage: .bri)
//                                        namePayment = "BRI Virtual Account"
//                                    } else if i == 4 {
//                                        imagePayment = Image(uiImage: .mandiri)
//                                        namePayment = "Mandiri Virtual Account"
//                                    }
//                                    isChoosePaymentMethod = true
//                                    self.presentationMode.wrappedValue.dismiss()
//                                }
//                                
//                                Divider().padding(.leading)
//                            }
//                        }
//                        
//                        Rectangle().foregroundColor(Color(hex: "#D9D9D9")).frame(maxWidth: .infinity, maxHeight: 4).padding(.top)
//                        
//                        Text("Transfer Bank").font(.system(size: 16)).bold().foregroundColor(isDark ? .white :Color(hex: "#49454F")).frame(maxWidth: .infinity, alignment: .leading).padding()
//                        
//                        ForEach(1...4, id: \.self) { i in
//                            VStack {
//                                HStack {
//                                    
//                                    if i == 1 {
//                                        Image(uiImage: .bca)
//                                        Text("Bank BCA").font(.system(size: 14)).foregroundColor(isDark ? .white :Color(hex: "#49454F")).fontWeight(.medium).frame(maxWidth: .infinity, alignment: .leading).padding(.leading, 4)
//                                    } else if i == 2 {
//                                        Image(uiImage: .bni)
//                                        Text("Bank BNI").font(.system(size: 14)).foregroundColor(isDark ? .white :Color(hex: "#49454F")).fontWeight(.medium).frame(maxWidth: .infinity, alignment: .leading).padding(.leading, 4)
//                                    } else if i == 3 {
//                                        Image(uiImage: .bri)
//                                        Text("Bank BRI").font(.system(size: 14)).foregroundColor(isDark ? .white :Color(hex: "#49454F")).fontWeight(.medium).frame(maxWidth: .infinity, alignment: .leading).padding(.leading, 4)
//                                    } else if i == 4 {
//                                        Image(uiImage: .mandiri)
//                                        Text("Bank Mandiri").font(.system(size: 14)).foregroundColor(isDark ? .white :Color(hex: "#49454F")).fontWeight(.medium).frame(maxWidth: .infinity, alignment: .leading).padding(.leading, 4)
//                                    } else {
//                                        Image (uiImage: .addCard)
//                                        Text("Lainnya").font(.system(size: 14)).foregroundColor(isDark ? .white :Color(hex: "#49454F")).fontWeight(.medium).frame(maxWidth: .infinity, alignment: .leading).padding(.leading, 4)
//                                    }
//                                    
//                                    Image(uiImage: .arrowForwardIos)
//                                        .renderingMode(isDark ? .template : .original)
//                                        .foregroundColor(isDark ? .white : nil)
//                                }.frame(maxWidth: .infinity, alignment: .leading).background(isDark ? .black: Color.white).padding().onTapGesture {
//                                    if i == 1 {
//                                        imagePayment = Image(uiImage: .bca)
//                                        namePayment = "Bank BCA"
//                                    } else if i == 2 {
//                                        imagePayment = Image(uiImage: .bni)
//                                        namePayment = "Bank BNI"
//                                    } else if i == 3 {
//                                        imagePayment = Image(uiImage: .bri)
//                                        namePayment = "Bank BRI"
//                                    } else if i == 4 {
//                                        imagePayment = Image(uiImage: .mandiri)
//                                        namePayment = "Bank Mandiri"
//                                    }
//                                    
//                                    isChoosePaymentMethod = true
//                                    self.presentationMode.wrappedValue.dismiss()
//                                }
//                                
//                                Divider().padding(.leading)
//                            }
//                        }
//                        
//                        Rectangle().foregroundColor(Color(hex: "#D9D9D9")).frame(maxWidth: .infinity, maxHeight: 4).padding(.top)
//                        
//                        Text(isEN ? "Instant Payment" :"Pembayaran Instant").font(.system(size: 16)).bold().foregroundColor(isDark ? .white :Color(hex: "#49454F")).frame(maxWidth: .infinity, alignment: .leading).padding()
//                        
//                        ForEach(1...2, id: \.self) { i in
//                            VStack {
//                                HStack {
//                                    
//                                    if i == 1 {
//                                        Image(uiImage: .gopay)
//                                        Text("Gopay").font(.system(size: 14)).foregroundColor(isDark ? .white :Color(hex: "#49454F")).fontWeight(.medium).frame(maxWidth: .infinity, alignment: .leading).padding(.leading, 4)
//                                    } else if i == 2 {
//                                        Image(uiImage: .ovo)
//                                        Text("OVO").font(.system(size: 14)).foregroundColor(isDark ? .white :Color(hex: "#49454F")).fontWeight(.medium).frame(maxWidth: .infinity, alignment: .leading).padding(.leading, 4)
//                                    } else {
//                                        Image (uiImage: .addCard)
//                                        Text("Lainnya").font(.system(size: 14)).foregroundColor(isDark ? .white :Color(hex: "#49454F")).fontWeight(.medium).frame(maxWidth: .infinity, alignment: .leading).padding(.leading, 4)
//                                    }
//                                    
//                                    Image(uiImage: .arrowForwardIos)
//                                        .renderingMode(isDark ? .template : .original)
//                                        .foregroundColor(isDark ? .white : nil)
//                                    
//                                }.frame(maxWidth: .infinity, alignment: .leading).background(isDark ? .black : Color.white).padding().onTapGesture {
//                                    if i == 1 {
//                                        imagePayment = Image(uiImage: .gopay)
//                                        namePayment = "Gopay"
//                                    } else if i == 2 {
//                                        imagePayment = Image(uiImage: .ovo)
//                                        namePayment = "OVO"
//                                    }
//                                    isChoosePaymentMethod = true
//                                    self.presentationMode.wrappedValue.dismiss()
//                                }
//                                
//                                Divider().padding(.leading)
//                            }
//                        }
                        
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
