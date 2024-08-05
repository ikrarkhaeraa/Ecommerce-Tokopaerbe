//
//  DetailProductScreen.swift
//  Tokopaerbe
//
//  Created by Ikrar Khaera Arfat on 11/07/24.
//

import SwiftUI
import CoreData
import AlertToast

struct ProductDetailScreen: View {
    
    @State var product: Product? = nil
    @State var goBack: Bool = false
    @State var goToReview: Bool = false
    @State var alertMessage: String = ""
    @State var isLoading: Bool = true
    @State var showAlert: Bool = false
    @State var isExpired: Bool = false
    @State var showExpiredAlert: Bool = false
    @State var alertExpiredMessage: String = ""
    @State var productDetailResponse: ProductDetailResponse? = nil
    @State var choosenVariantPrice: Int = 0
    @State var indicatorIndex: Int = 0
    @State var isSaved: Bool = false
    @State private var chips: [ChipState] = []
    @State var isShowingShareSheet: Bool = false
    @State var productIdDeepLink: String = ""
    @State var showToastSuccess: Bool = false
    @State var showToastFailed: Bool = false
    @State var choosenVariantString: String = ""
    @State var showErrorState: Bool = false
    @State var errorTitle: String = ""
    
    // MARK: Core data variables
        @Environment(\.managedObjectContext) var viewContext
    // MARK: Core Data
        @FetchRequest(sortDescriptors: []) private var favorites: FetchedResults<FavoriteEntity>
        @FetchRequest(sortDescriptors: []) private var carts: FetchedResults<CartEntity>

    var body: some View {
        
        VStack {
        
            HStack {
                Image(uiImage: .arrowleft).padding().onTapGesture {
                    goBack = true
                }
                
                Text("Detail Produk").frame(maxWidth: .infinity, alignment: .leading).font(.system(size: 22))
                
            }.frame(maxWidth: .infinity, alignment: .leading)
            Divider()
            
            if isLoading {
                LoadingView().onAppear {
                    getData()
                }
            } else if showErrorState {
                
                VStack {
                    Image(uiImage: UIImage.errorState)
                    Text("\(errorTitle)").font(.system(size: 32)).bold()
                    Text("\(alertMessage)")
                    Button(action: {
                        isLoading = true
                        getData()
                    }, label: {
                        Text("Refresh").foregroundColor(.white)
                    }).padding(16).padding(.horizontal, 16).background(Color(hex: "#6750A4")).cornerRadius(100).padding(8)
                }.frame(maxWidth: .infinity ,maxHeight: .infinity, alignment: .center)
                
            } else {
                ScrollView {
                    NavigationView {
                        TabView(selection: $indicatorIndex) {
                            ForEach(productDetailResponse!.image.indices, id: \.self) { item in
                                ImageLoader(contentMode: .constant("fill"),urlString: productDetailResponse!.image[item]).tag(item)
                            }
                        }.tabViewStyle(PageTabViewStyle(indexDisplayMode: .always))
                            .onAppear {
                            UIPageControl.appearance().currentPageIndicatorTintColor = UIColor(Color(hex: "#6750A4"))
                            UIPageControl.appearance().pageIndicatorTintColor = UIColor.gray
                        }
                            .onChange(of: indicatorIndex) { newValue in
                                // Handle index change if needed
                                let _ = Log.d("cek selection tab: \(indicatorIndex)")
                            }
                    }
                    .frame(maxWidth: .infinity, maxHeight: .infinity ,alignment: .top)
                    
                    VStack {
                        
                        HStack {
                            Text("Rp\(productDetailResponse!.productPrice + choosenVariantPrice)").foregroundColor(Color(hex: "#49454F")).font(.system(size: 20)).bold().frame(maxWidth: .infinity, alignment: .leading).padding(.top, 12)
                            
                            Image(uiImage: .share).padding(.trailing, 8).padding(.top, 4).onTapGesture {
                                isShowingShareSheet = true
                            }
            
                            
                            if !isSaved {
                                Image(uiImage: .favoriteBorder).padding(.trailing).padding(.top, 4).onTapGesture {
                                    isSaved = true
                                    saveProduct(id: productDetailResponse!.productId, name: productDetailResponse!.productName ,image: productDetailResponse!.image[0] ,price: productDetailResponse!.productPrice + choosenVariantPrice, store: productDetailResponse!.store, rating: productDetailResponse!.productRating, sale: productDetailResponse!.sale, stock: productDetailResponse!.stock)
                                    let _ = Log.d("saved state : \(isSaved)")
                                }
                            } else {
                                Image(uiImage: .favoriteFull).padding(.trailing).padding(.top, 4).onTapGesture {
                                    isSaved = false
                                    unSaveProduct(withId: productDetailResponse!.productId)
                                    let _ = Log.d("saved state : \(isSaved)")
                                }
                            }
                            
                        }.onAppear {
                            isSaved = favorites.contains { $0.productId == productDetailResponse?.productId }
                        }
                        
                        Text("\(productDetailResponse!.productName)").frame(maxWidth: .infinity, alignment: .leading).font(.system(size: 14)).foregroundColor(Color(hex: "#49454F")).padding(.top, 8)
                        
                        HStack {
                            Text("Terjual \(productDetailResponse!.sale)").font(.system(size: 12)).foregroundColor(Color(hex: "#49454F"))
                            
                            ZStack {
                                HStack {
                                    Image(uiImage: .star)
                                    Text("\(productDetailResponse!.totalRating)").font(.system(size: 12)).foregroundColor(Color(hex: "#49454F"))
                                    Text("(\(productDetailResponse!.totalReview))").font(.system(size: 12)).foregroundColor(Color(hex: "#49454F"))
                                }.padding(.horizontal, 4).padding(.vertical, 2)
                            } .overlay(RoundedRectangle(cornerRadius: 4).stroke(Color(hex: "#79747E"), lineWidth: 1))
                            
                        }.frame(maxWidth: .infinity, alignment: .leading).padding(.top, 8)
                        
                    }.padding(.leading)
                    
                    Divider().padding(.vertical, 4)
                    
                    VStack {
                        
                        Text("Pilih Varian").font(.system(size: 16)).foregroundColor(Color(hex: "#49454F")).bold().frame(maxWidth: .infinity, alignment: .leading)
                        
                        HStack {
                            
                            if let indices = productDetailResponse?.productVariant.indices {
                                ForEach(indices, id: \.self) { i in
                                    if i < chips.count {
                                        ChipView(titleKey: chips[i].titleKey!, isSelected: $chips[i].isSelected, choosenVariantPrice: $choosenVariantPrice, choosenVariantString: $choosenVariantString ,productDetailResponse: productDetailResponse! ,chipIteration: chips[i].chipIteration, chipAll: $chips)
                                    }
                                }
                            }
                        }.frame(maxWidth: .infinity, alignment: .leading).onAppear {
                            choosenVariantString = productDetailResponse!.productVariant[0].variantName
                            chips = productDetailResponse!.productVariant.indices.map { i in
                                if i == 0 {
                                    ChipState(
                                        titleKey: productDetailResponse!.productVariant[i].variantName,
                                        isSelected: true,
                                        chipIteration: i,
                                        chipVariantPrice: productDetailResponse!.productVariant[i].variantPrice
                                    )
                                } else {
                                    ChipState(
                                        titleKey: productDetailResponse!.productVariant[i].variantName,
                                        isSelected: false,
                                        chipIteration: i,
                                        chipVariantPrice: productDetailResponse!.productVariant[i].variantPrice
                                    )
                                }
                                
                            }
                        }
                        
                    }.padding(.leading)
                    
                    Divider().padding(.vertical, 4)
                    
                    VStack {
                        Text("Deskripsi Produk").font(.system(size: 16)).bold().foregroundColor(Color(hex: "#49454F")).frame(maxWidth: .infinity, alignment: .leading)
                        Text("\(productDetailResponse!.description)").font(.system(size: 14)).foregroundColor(Color(hex: "#49454F")).padding(.top, 8)
                    }.padding(.leading)
                    
                    Divider().padding(.vertical, 4)
                    
                    VStack {
                        
                        HStack {
                            Text("Ulasan Pembeli").font(.system(size: 16)).bold().foregroundColor(Color(hex: "#49454F")).frame(maxWidth: .infinity, alignment: .leading)
                            
                            Text("Lihat Semua").font(.system(size: 12)).bold().foregroundColor(Color(hex: "#6750A4")).padding(.trailing).onTapGesture {
                                goToReview = true
                            }
                        }
                        
                        HStack {
                            
                            HStack {
                                Image(uiImage: .starBig)
                                Text("\(productDetailResponse!.productRating)").font(.system(size: 20)).bold().foregroundColor(Color(hex: "#49454F"))
                                Text("/5.0").font(.system(size: 16)).foregroundColor(Color(hex: "#49454F"))
                            }
                            
                            VStack(alignment: .leading) {
                                Text("\(productDetailResponse!.totalSatisfaction)% pembeli merasa puas").font(.system(size: 12)).bold().foregroundColor(Color(hex: "#49454F"))
                                HStack {
                                    Text("\(productDetailResponse!.totalRating) rating").font(.system(size: 12)).foregroundColor(Color(hex: "#49454F"))
                                    Text(".").padding(.bottom,8).font(.system(size: 12)).foregroundColor(Color(hex: "#49454F"))
                                    Text("\(productDetailResponse!.totalReview) ulasan").font(.system(size: 12)).foregroundColor(Color(hex: "#49454F"))
                                }
                            }.frame(maxWidth: .infinity).padding(.trailing)
                        }
    
                    }.padding(.leading)
                }.padding(.bottom, 20)
                
                VStack {
                    Divider()
                    
                    HStack {
                        Button(action: {
                            
                        }, label: {
                            Text("Beli Langsung")
                                .foregroundColor(Color(hex: "#6750A4"))
                                .frame(maxWidth: .infinity)
                                .padding()
                                .background(RoundedRectangle(cornerRadius:25).stroke(Color.gray,lineWidth:2))
                                .cornerRadius(25)
                        }).padding(.leading, 10).padding(.vertical, 10).padding(.trailing, 5)
                        
                        
                        Button(action: {
                            handleAddToCart()
                        }, label: {
                               Text("+ Keranjang")
                                   .foregroundColor(.white)
                                   .frame(maxWidth: .infinity)
                                   .padding()
                                   .background(Color(hex: "#6750A4"))
                                   .cornerRadius(25)
                        }).padding(.trailing, 10).padding(.vertical, 10).padding(.leading, 5)
                    }
                    
                }.background(Color.white).frame(maxHeight: 40)
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
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
        .sheet(isPresented: $isShowingShareSheet) {
            ShareSheet(items: ["Product : \(productDetailResponse!.productName) \n" + "Price : \(productDetailResponse!.productPrice)\n" + "Link : myapp://ecommerce.tokopaerbe.com/product/\(productDetailResponse!.productId)"])
                .background(Color.clear)
        }
        .toast(isPresenting: $showToastSuccess) {
            AlertToast(type: .complete(.green), subTitle: "Berhasil menambahkan produk ke keranjang")
        }
        .toast(isPresenting: $showToastFailed) {
            AlertToast(type: .error(.red), subTitle: "Stok barang tidak mencukupi")
        }
        
        
        if goBack {
            NavigationLink(destination: MainScreen(page: 1), isActive: $goBack) {
                EmptyView()
            }
        }
        
        if goToReview {
            NavigationLink(destination: ProductReviewScreen(product: product!), isActive: $goToReview) {
                EmptyView()
            }
        }
        
        if isExpired {
            NavigationLink(destination: LoginScreen(), isActive: $isExpired) {
                EmptyView()
            }
        }
        
    }
    
    private func handleAddToCart() {
            let product = productDetailResponse!
        
        print(product.productId)
        if let existingCartItem = carts.first(where: { $0.productId == product.productId && $0.productVariant == choosenVariantString }) {
                
                if (existingCartItem.productQuantity < product.stock) {
                    existingCartItem.productQuantity += 1
                    do {
                        try viewContext.save()
                        print("add quantity")
                        showToastFailed = false
                        showToastSuccess = true
                    } catch {
                        print("failed to update quantity")
                    }
                } else {
                    print("no stock")
                    showToastFailed = true
                    showToastSuccess = false
                }
                
            } else {
                addToCart(id: product.productId,
                          name: product.productName,
                          image: product.image[0],
                          price: product.productPrice + choosenVariantPrice,
                          variant: choosenVariantString,
                          stock: product.stock,
                          quantity: 1)
            }
        }
    
    private func getData() {
        var request: ProductDetailRequest? = nil
        if productIdDeepLink != "" {
            request = ProductDetailRequest(id: productIdDeepLink)
        } else  {
            request = ProductDetailRequest(id: product!.productId)
        }
        let token = UserDefaults.standard.string(forKey: "bearerToken")
        let _ = hitApi(requestBody: request, urlApi: Url.Endpoints.products, methodApi: "GET", token: token!, type: "product detail") { (success: Bool, responseObject: GeneralResponse<ProductDetailResponse>?) in
            if success, let responseBackend = responseObject {
                
                if responseObject?.code == 200 {
                    productDetailResponse = responseObject?.data
                    showErrorState = false
                    isLoading = false
                } else if responseObject?.code == 401 {
                    alertExpiredMessage = responseObject!.message
                    showErrorState = false
                    showExpiredAlert = true
                } else {
                    isLoading = false
                    showErrorState = true
                    alertMessage = responseObject!.message
                }
                
            } else {
                isLoading = false
                showErrorState = true
                alertMessage = "Server tidak dapat melayani permintaan anda"
            }
        }
    }
    
    struct ChipView: View {
        
        @State var titleKey: String
        @Binding var isSelected: Bool
        @Binding var choosenVariantPrice: Int
        @Binding var choosenVariantString: String
        @State var productDetailResponse: ProductDetailResponse
        @State var chipIteration: Int
        @Binding var chipAll: [ChipState]

        var body: some View {
            HStack() {
                Text("\(titleKey)").padding(4).font(.system(size: 14)).foregroundColor(Color(hex: "#49454F"))
            }
            .padding(.vertical, 4)
            .padding(.horizontal, 8)
            .foregroundColor(isSelected ? .black : Color(hex: "#49454F"))
            .background(isSelected ? Color(hex: "#E8DEF8") : Color.white)
            .cornerRadius(8)
            .overlay(
                RoundedRectangle(cornerRadius: 8)
                    .stroke(isSelected ? Color.clear : Color(hex: "#79747E"), lineWidth: 1.5)
                
            )
            .onTapGesture {
                
                for i in 0...chipAll.count-1 {
                    if chipAll[i].isSelected == true {
                        chipAll[i].isSelected.toggle()
                    }
                }
                
                if chipIteration != 0 {
                    choosenVariantPrice = productDetailResponse.productVariant[1].variantPrice
                    choosenVariantString = productDetailResponse.productVariant[1].variantName
                } else {
                    choosenVariantPrice = productDetailResponse.productVariant[0].variantPrice
                    choosenVariantString = productDetailResponse.productVariant[0].variantName
                }
                
                isSelected.toggle()
            
            }
        }
    }
    
    struct ChipState {
        var titleKey: String?
        var isSelected: Bool
        var chipIteration: Int
        var chipVariantPrice: Int?
    }
    
    struct ShareSheet: UIViewControllerRepresentable {
        var items: [Any]

        func makeUIViewController(context: Context) -> UIActivityViewController {
            let controller = UIActivityViewController(activityItems: items, applicationActivities: nil)
            return controller
        }

        func updateUIViewController(_ uiViewController: UIActivityViewController, context: Context) {}
    }
    
    func saveProduct(id: String, name: String ,image: String ,price: Int, store: String, rating: Float16, sale: Int, stock: Int) {
        let favorite = FavoriteEntity(context: self.viewContext)
        favorite.productId = id
        favorite.productName = name
        favorite.productPrice = price
        favorite.productStore = store
        favorite.productRating = Float(rating)
        favorite.productSale = sale
        favorite.productImage = image
        favorite.productVariant = choosenVariantString
        favorite.productStock = stock
        
        
        do {
            try self.viewContext.save()
            print("Product saved!")
        } catch {
            print("whoops \\(error.localizedDescription)")
        }
    }
    
    func addToCart(id: String, name: String ,image: String ,price: Int, variant: String, stock: Int, quantity: Int) {
        let cart = CartEntity(context: viewContext)
        cart.productId = id
        cart.productName = name
        cart.productPrice = price
        cart.productStock = stock
        cart.productImage = image
        cart.productVariant = variant
        cart.productQuantity = quantity
        cart.productChecked = false
        
        do {
            try viewContext.save()
            print("Product add to cart!")
            showToastFailed = false
            showToastSuccess = true
        } catch {
            print("whoops \\(error.localizedDescription)")
        }
    }
    
    private func unSaveProduct(withId productId: String) {
            let fetchRequest: NSFetchRequest<FavoriteEntity> = FavoriteEntity.fetchRequest()
            fetchRequest.predicate = NSPredicate(format: "productId == %@", productId)

            do {
                let products = try viewContext.fetch(fetchRequest)
                let _ = Log.d("delete product: \(products)")
                guard !products.isEmpty else {
                    print("No product found with productId \(productId)")
                    return
                }

                for product in products {
                    viewContext.delete(product)
                }

                // Save the context to persist the changes
                try viewContext.save()
                print("Product deleted successfully")
            } catch {
                let nsError = error as NSError
                print("Unresolved error \(nsError), \(nsError.userInfo)")
            }
        }
}

//#Preview {
//    ProductDetailScreen(product: Product(productId : "",
//                                         productName : "",
//                                         productPrice : 0,
//                                         image : "",
//                                         brand : "",
//                                         store : "",
//                                         sale : 0,
//                                         productRating: 0.0))
//}
