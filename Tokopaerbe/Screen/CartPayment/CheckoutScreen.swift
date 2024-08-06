//
//  CheckoutScreen.swift
//  Tokopaerbe
//
//  Created by Ikrar Khaera Arfat on 01/08/24.
//

import SwiftUI
import CoreData

struct CheckoutScreen: View {
    
    @Environment(\.presentationMode) var presentationMode
    @FetchRequest(
        entity: CartEntity.entity(),
        sortDescriptors: [],
        predicate: NSPredicate(format: "productChecked == true")
    ) var checkoutCarts: FetchedResults<CartEntity>
    @State var itemfromDetail: ProductDetailResponse? = nil
    @State var chosenVariantFromDetail: String = ""
    @State var priceFromDetail: Int = 0
    @Environment(\.managedObjectContext) var viewContext
    @State var isChoosePaymentMethod: Bool = false
    @State private var appBarViewSize: CGSize = .zero
    @State private var scrollViewSize: CGSize = .zero
    @State private var pembayaranView: CGSize = .zero
    @State private var totalBayarView: CGSize = .zero
    @State var isExpired: Bool = false
    @State var showExpiredAlert: Bool = false
    @State var alertExpiredMessage: String = ""
    @State var showErrorAlert: Bool = false
    @State var errorMessageAlert: String = ""
    @State private var isLoading: Bool = false
    @State private var goToPayment: Bool = false
    @State private var goToSuccessPayment: Bool = false
    @State private var imagePayment: Image = Image(uiImage: .addCard)
    @State private var namePayment: String = "Pilih Pembayaran"
    @State private var fulfillmentResponse: FulfillmentResponse? = nil
    let columns: [GridItem] = Array(repeating: .init(.flexible()), count: 2)
    var totalPrice: Int {  checkoutCarts.filter { $0.productChecked }
        .reduce(0) { $0 + ($1.productQuantity * $1.productPrice) }}
    
    
    var body: some View {
        GeometryReader { proxy in
            VStack {
                
                VStack {
                    HStack {
                        Image(uiImage: .arrowleft).padding().onTapGesture {
                            self.presentationMode.wrappedValue.dismiss()
                        }
                        
                        Text("Checkout").frame(maxWidth: .infinity, alignment: .leading).font(.system(size: 22))
                        
                    }.frame(maxWidth: .infinity, alignment: .leading)
                    
                    Divider()
                    Text("Barang yang dibeli").font(.system(size: 16)).fontWeight(.medium).foregroundColor(Color(hex: "#49454F")).frame(maxWidth: .infinity, alignment: .leading).padding()
                }.getSize {
                    appBarViewSize = $0
                }
                
                Text("").background(Color.white)
                
            
                ScrollView {
                    
                    if itemfromDetail != nil {
                        HStack {
                            ImageLoader(contentMode: .constant("fit"), urlString: (itemfromDetail!.image[0])).frame(maxWidth: 80, maxHeight: 80).background(RoundedRectangle(cornerRadius: 8).foregroundColor(.white))
                            
                            VStack {
                                Text("\(itemfromDetail!.productName)").font(.system(size: 14)).bold().foregroundColor(Color(hex: "#49454F"))
                                    .lineLimit(1)
                                    .truncationMode(.tail)
                                    .fixedSize(horizontal: false, vertical: true)
                                    .frame(maxWidth: .infinity, alignment: .leading)
                                
                                Text("\(chosenVariantFromDetail)").font(.system(size: 10)).foregroundColor(Color(hex: "#49454F"))
                                    .frame(maxWidth: .infinity, alignment: .leading)
                                
                                Text("Stok \(itemfromDetail!.stock)").font(.system(size: 10)).foregroundColor(Color(hex: "#49454F"))
                                    .frame(maxWidth: .infinity, alignment: .leading)
                                
                                HStack {
                                    Text("Stok \(priceFromDetail)").font(.system(size: 14)).bold().foregroundColor(Color(hex: "#49454F"))
                                        .frame(maxWidth: .infinity, alignment: .leading).padding(.top, 8)
                                    
                                }.frame(maxWidth: .infinity)
                                
                                
                            }.padding(.horizontal, 2).frame(maxWidth: .infinity, alignment: .leading)
                            
                        }.padding().getSize {scrollViewSize = $0}
                        
                        Divider()
                        
                    } else {
                        ForEach(checkoutCarts.indices, id: \.self) { i in
                            
                            HStack {
                                ImageLoader(contentMode: .constant("fit"), urlString: checkoutCarts[i].productImage!).frame(maxWidth: 80, maxHeight: 80).background(RoundedRectangle(cornerRadius: 8).foregroundColor(.white))
                                
                                VStack {
                                    Text("\(checkoutCarts[i].productName!)").font(.system(size: 14)).bold().foregroundColor(Color(hex: "#49454F"))
                                        .lineLimit(1)
                                        .truncationMode(.tail)
                                        .fixedSize(horizontal: false, vertical: true)
                                        .frame(maxWidth: .infinity, alignment: .leading)
                                    
                                    Text("\(checkoutCarts[i].productVariant!)").font(.system(size: 10)).foregroundColor(Color(hex: "#49454F"))
                                        .frame(maxWidth: .infinity, alignment: .leading)
                                    
                                    Text("Stok \(checkoutCarts[i].productStock)").font(.system(size: 10)).foregroundColor(Color(hex: "#49454F"))
                                        .frame(maxWidth: .infinity, alignment: .leading)
                                    
                                    HStack {
                                        Text("Stok \(checkoutCarts[i].productPrice)").font(.system(size: 14)).bold().foregroundColor(Color(hex: "#49454F"))
                                            .frame(maxWidth: .infinity, alignment: .leading).padding(.top, 8)
                                        
                                    }.frame(maxWidth: .infinity)
                                    
                                    
                                }.padding(.horizontal, 2).frame(maxWidth: .infinity, alignment: .leading)
                                
                            }.padding()
                            
                            Divider()
                            
                        }.getSize {scrollViewSize = $0}
                    }
                    

                }
                .frame(maxHeight: calculateScrollViewHeight(proxy: proxy))

                
                VStack {
                    Rectangle().foregroundColor(Color(hex: "#D9D9D9")).frame(maxWidth: .infinity, maxHeight: 4)
                    
                    Text("Pembayaran").font(.system(size: 16)).fontWeight(.medium).foregroundColor(Color(hex: "#49454F")).frame(maxWidth: .infinity, alignment: .leading).padding()
                    
                    HStack {
                        HStack {
                            imagePayment
                            Text("\(namePayment)").font(.system(size: 14)).foregroundColor(Color(hex: "#49454F")).fontWeight(.medium).frame(maxWidth: .infinity, alignment: .leading).padding(.leading, 4)
                            Image(uiImage: .arrowForwardIos)
                        }.frame(maxWidth: .infinity, alignment: .leading).padding()
                    }.background(Color.white)
                        .cornerRadius(8)
                        .shadow(color: .gray, radius: 2, x: 0, y: 2)
                        .padding(.horizontal)
                        .padding(.bottom)
                        .padding(.top, -12)
                        .onTapGesture {
                            goToPayment = true
                        }
                }
                .getSize {
                    pembayaranView = $0
                }
                
                
                VStack {
                    Divider()
                    
                    HStack {
                        VStack {
                            Text("Total Bayar").font(.system(size: 12)).foregroundColor(Color(hex: "#49454F")).frame(maxWidth: .infinity, alignment: .leading)
                            
                            if itemfromDetail != nil {
                                Text("Rp\(priceFromDetail)").font(.system(size: 16)).bold().foregroundColor(Color(hex: "#49454F")).padding(.top, 2).frame(maxWidth: .infinity, alignment: .leading)
                            } else {
                                Text("Rp\(totalPrice)").font(.system(size: 16)).bold().foregroundColor(Color(hex: "#49454F")).padding(.top, 2).frame(maxWidth: .infinity, alignment: .leading)
                            }
                            
                        }.frame(maxWidth: .infinity, alignment: .leading)
                        
                        if isChoosePaymentMethod {
                            
                            if isLoading {
                                CircularLoadingView().padding(.trailing).padding(.trailing)
                            } else {
                                Button(action: {
                                    isLoading = true
                                    fulfillmentProcess()
                                }, label: {
                                    Text("Bayar")
                                        .font(.system(size: 14))
                                        .foregroundColor(.white)
                                        .padding()
                                        .padding(.horizontal, 12)
                                        .background(Color(hex: "#6750A4"))
                                        .cornerRadius(25)
                                })
                            }
                            
                            
                        } else {
                            Button(action: {}, label: {
                                Text("Bayar")
                                    .font(.system(size: 14))
                                    .foregroundColor(.white)
                                    .padding()
                                    .padding(.horizontal, 12)
                                    .background(Color(hex: "CAC4D0"))
                                    .cornerRadius(25)
                            }).disabled(true)
                        }
                        
                        
                    }.frame(maxWidth: .infinity).padding()
                }.frame(maxWidth: .infinity,alignment: .bottom)
                    .getSize {
                    totalBayarView = $0
                }
                
                NavigationLink(destination: PaymentScreen(imagePayment: $imagePayment, namePayment: $namePayment, isChoosePaymentMethod: $isChoosePaymentMethod), isActive: $goToPayment) {
                    EmptyView()
                }
                
                NavigationLink(destination: SuccessPaymentScreen(fulfillmentResponse: $fulfillmentResponse), isActive: $goToSuccessPayment) {
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
    }
    
    private func fulfillmentProcess() {
        
        var items: [Items] {
            checkoutCarts.map { cartEntity in
                
                if itemfromDetail != nil {
                    Items(
                        productId: itemfromDetail!.productId,
                        variantName: chosenVariantFromDetail,
                        quantity: 1
                    )
                } else {
                    Items(
                        productId: cartEntity.productId!,
                        variantName: cartEntity.productVariant!,
                        quantity: cartEntity.productQuantity
                    )
                }
        
            }
        }

        let request = FulfillmentRequst(payment: namePayment, items: items)
        
        hitApi(requestBody: request, urlApi: Url.Endpoints.fulfillment, methodApi: "POST", token: UserDefaults().string(forKey: "bearerToken")!, type: "fulfillment", completion: { (success: Bool, responseObject: GeneralResponse<FulfillmentResponse>?) in
            if success, let responseBackend = responseObject {
                
                if responseObject?.code == 200 {
                    fulfillmentResponse = responseObject!.data
                    isLoading = false
                    goToSuccessPayment = true
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
    
    private func calculateScrollViewHeight(proxy: GeometryProxy) -> CGFloat {
        
        Log.d("cek app bar view: \(appBarViewSize.height)")
        Log.d("cek total bayar view: \(totalBayarView.height)")
        Log.d("cek pembayaran view: \(pembayaranView.height)")
        
        // Calculate the heights as fractions of the total height
        let appBarHeightFraction = 129 / proxy.size.height
        let pembayaranHeightFraction = 131 / proxy.size.height
        let totalBayarHeightFraction = 89 / proxy.size.height
        
        print("appBar: \(appBarHeightFraction)")
        print("pembayaran: \(pembayaranHeightFraction)")
        print("total: \(totalBayarHeightFraction)")
        
        // Sum up the fractions
        let occupiedHeightFraction = appBarHeightFraction + pembayaranHeightFraction + totalBayarHeightFraction
        
        print("occupied: \(occupiedHeightFraction)")
        
        // Calculate the remaining height fraction
        let remainingHeightFraction = 1 - occupiedHeightFraction
        
        print("remainFrac: \(remainingHeightFraction)")
        
        // Calculate the actual remaining height
        let remainingHeight = remainingHeightFraction * proxy.size.height
        
        print ("sizeeee: \(remainingHeight)")
        
        // Return the minimum of scrollViewSize.height and remainingHeight
        return min(scrollViewSize.height, remainingHeight)
    }
    
}

struct SizePreferenceKey: PreferenceKey {
    static var defaultValue: CGSize = .zero

    static func reduce(value: inout CGSize, nextValue: () -> CGSize) {
        value = nextValue()
    }
}

struct SizeModifier: ViewModifier {
    private var sizeView: some View {
        GeometryReader { geometry in
            Color.clear.preference(key: SizePreferenceKey.self, value: geometry.size)
        }
    }

    func body(content: Content) -> some View {
        content.overlay(sizeView)
    }
}

extension View {
    func getSize(perform: @escaping (CGSize) -> ()) -> some View {
        self
            .modifier(SizeModifier())
            .onPreferenceChange(SizePreferenceKey.self) {
                perform($0)
            }
    }
}

#Preview {
    CheckoutScreen()
}
