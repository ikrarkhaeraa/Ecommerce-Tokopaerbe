//
//  ProductReviewScreen.swift
//  Tokopaerbe
//
//  Created by Ikrar Khaera Arfat on 22/07/24.
//

import SwiftUI

struct ProductReviewScreen: View {
    
    @State var product: Product
    @State var goBack: Bool = false
    @State var isLoading: Bool = true
    @State var reviewResponse: [ReviewResponse]? = nil
    @State var alertMessage: String = ""
    @State var showAlert: Bool = false
    @State var isExpired: Bool = false
    @State var showExpiredAlert: Bool = false
    @State var alertExpiredMessage: String = ""
    
    var body: some View {
        VStack {
            HStack {
                Image(uiImage: .arrowleft).padding().onTapGesture {
                    goBack = true
                }
                
                Text("Ulasan Pembeli").frame(maxWidth: .infinity, alignment: .leading).font(.system(size: 22))
                
            }.frame(maxWidth: .infinity, alignment: .top)
            Divider()
            
            if isLoading {
                LoadingView()
                let _ = getData()
            } else {
                let _ = Log.d("\(reviewResponse!)")
                ScrollView {
                    VStack {
                        ForEach (reviewResponse!, id: \.self) { data in
                            if data.userRating != 0 && data.userReview != "" {
                                VStack {
                                    HStack {
                                        if data.userImage.isEmpty {
                                            Image(uiImage: .imageUserDefault)
                                        } else {
                                            ImageLoader(contentMode: .constant("circle36"), urlString: data.userImage)
                                        }
                                        
                                        VStack {
                                            Text("\(data.userName)").font(.system(size: 12)).bold().foregroundColor(Color(hex: "#49454F")).frame(maxWidth: .infinity, alignment: .leading)
                                            HStack {
                                                ForEach(1...data.userRating, id: \.self) { i in
                                                    if (i > 1) {
                                                        Image(uiImage: .star).padding(.leading, -8)
                                                    } else {
                                                        Image(uiImage: .star)
                                                    }
                                                }
                                            }.frame(maxWidth: .infinity, alignment: .leading)
                                        }
                                    }.padding(.top)
                                    
                                    Text("\(data.userReview)").font(.system(size: 12)).foregroundColor(Color(hex: "#49454F")).frame(maxWidth: .infinity, alignment: .leading).padding(.bottom).padding(.top, 4)
                                }.padding(.leading)
                                
                                Divider()
                            }
                        }
                    }
                }
            }
            
        }.frame(maxWidth: .infinity, alignment: .top)
            .navigationBarBackButtonHidden()
            .alert(isPresented: $showExpiredAlert, content: {
                Alert(
                    title: Text("Error"),
                    message: Text(alertExpiredMessage),
                    dismissButton: .default(Text("OK"), action: {
                        isExpired = true
                    })
                )
            })
        
        if goBack {
            NavigationLink(destination: ProductDetailScreen(product: product), isActive: $goBack) {
                EmptyView()
            }
        }
    }
    
    
    private func getData() {
        let request = ReviewRequest(id: product.productId)
        let token = UserDefaults.standard.string(forKey: "bearerToken")
        let _ = hitApi(requestBody: request, urlApi: Url.Endpoints.review, methodApi: "GET", token: token!, type: "review") { (success: Bool, responseObject: GeneralResponse<[ReviewResponse]>?) in
            if success, let responseBackend = responseObject {
                
                if responseObject?.code == 200 {
                    reviewResponse = responseObject?.data
                    isLoading = false
                } else if responseObject?.code == 401 {
                    alertExpiredMessage = responseObject!.message
                    showExpiredAlert = true
                } else {
                    isLoading = false
                    showAlert = true
                    alertMessage = responseObject!.message
                }
                
            } else {
                isLoading = false
                showAlert = true
                alertMessage = "Server tidak dapat melayani permintaan anda"
            }
        }
    }
}

#Preview {
    ProductReviewScreen(product: Product(productId : "",
                                         productName : "",
                                         productPrice : 0,
                                         image : "",
                                         brand : "",
                                         store : "",
                                         sale : 0,
                                         productRating: 0.0))
}
