//
//  StoreScreen.swift
//  Tokopaerbe
//
//  Created by Ikrar Khaera Arfat on 11/06/24.
//

import SwiftUI

struct StoreScreen: View {
    
    @AppStorage("isDark") private var isDark: Bool = false
    @AppStorage("isEN") private var isEN: Bool = false
    
    @State var responseProduct: GeneralResponse<ProductsResponse>? = nil
    @State var listProducts: [[Product]] = []
    @State var product: Product? = nil
    @State var isGrid: Bool = UserDefaults.standard.bool(forKey: "isGrid")
    @State private var search: String? = nil
    @State private var brand: String? = nil
    @State private var lowest: Int? = nil
    @State private var highest: Int? = nil
    @State private var sort: String? = nil
    
    
    @State var showAlert: Bool = false
    @State var alertMessage: String = ""
    @State var page: Int = 1
    @State var temp: String = ""
    
    @Binding var showSearchDialog: Bool
    @Binding var showExpiredAlert: Bool
    @Binding var alertExpiredMessage: String
    @Binding var searchedText: String
    @Binding var showBottomSheet: Bool
    @Binding var filterProducts: Bool
    
    //MARK:- PROPERTIES
    @StateObject var pagingVM = PagingViewModel()
    @StateObject var bottomSheetVM: BottomSheetViewModel
    
    @Binding var goToDetailProduct: Bool
    @Binding var chosenProduct: Product
    
    private let adaptiveColumn = [
            GridItem(.adaptive(minimum: 150))
        ]
    
    let columns: [GridItem] = Array(repeating: .init(.flexible()), count: 2)
    
    
    var body: some View {
        NavigationView {
            
            VStack {

                ZStack {
                    HStack {
                        Image(uiImage: UIImage.searchIcon)
                            .renderingMode(isDark ? .template : .original)
                            .foregroundColor(isDark ? .white : nil)
                        
                        if searchedText != "" {
                            
                            if searchedText != temp {
                                Text("\(searchedText)").font(.system(size: 16)).onAppear {
                                    temp = searchedText
                                    getProductsWithFilter()
                                }
                                
                            } else {
                                Text("\(temp)").font(.system(size: 16))
                            }
                            
                            let _ = Log.d("searchedText: \(searchedText)")
                            
                        } else {
                            Text("Search").font(.system(size: 16)).onAppear {
                                getProductsWithFilter()
                            }
                        }
                        
                    }.padding(.vertical, 10).frame(maxWidth: .infinity, alignment: .leading)
                }.padding(8).background(RoundedRectangle(cornerRadius:8).stroke(isDark ? .white :Color.black,lineWidth:1).background(isDark ? .black :Color.white)).padding(.horizontal, 12).frame(maxWidth: .infinity).onTapGesture {
                    showSearchDialog = true
                }
                
                if !pagingVM.isLoading {
                    
                    let _ = Log.d("store masuk not loading")
                    
                    HStack {
                        
                        HStack {
                            Image(uiImage: UIImage.tune)
                                .renderingMode(isDark ? .template : .original)
                                .foregroundColor(isDark ? .white : nil)
                            Text("Filter")
                        }.padding(8).background(RoundedRectangle(cornerRadius:8).stroke(isDark ? .white :Color.black,lineWidth:1)).padding(.top, 10).frame(alignment: .leading).onTapGesture {
                            showBottomSheet = true
                        }
                        
                            
                        ScrollView(.horizontal) {
                            HStack {
                                
                                if bottomSheetVM.selectedSortChip != nil {
                                    HStack {
                                        Text("\(bottomSheetVM.selectedSortChip!)")
                                    }.padding(8).background(RoundedRectangle(cornerRadius:8).stroke(isDark ? .white :Color.black,lineWidth:1)).frame(alignment: .leading)
                                }
                                
                                if bottomSheetVM.selectedCategoryChip != nil {
                                    HStack {
                                        Text("\(bottomSheetVM.selectedCategoryChip!)")
                                    }.padding(8).background(RoundedRectangle(cornerRadius:8).stroke(isDark ? .white :Color.black,lineWidth:1)).frame(alignment: .leading)
                                }
                                
                                if bottomSheetVM.hargaTerendah != nil && bottomSheetVM.hargaTerendah != "" {
                                    HStack {
                                        Text("Rp.\(bottomSheetVM.hargaTerendah!)")
                                    }.padding(8).background(RoundedRectangle(cornerRadius:8).stroke(isDark ? .white :Color.black,lineWidth:1)).frame(alignment: .leading)
                                }
                                
                                if bottomSheetVM.hargaTertinggi != nil && bottomSheetVM.hargaTertinggi != "" {
                                    HStack {
                                        Text("Rp.\(bottomSheetVM.hargaTertinggi!)")
                                    }.padding(8).background(RoundedRectangle(cornerRadius:8).stroke(isDark ? .white :Color.black,lineWidth:1)).frame(alignment: .leading)
                                }
                 
                                if filterProducts {
                                    
                                    VStack{
                                        EmptyView()
                                    }.onAppear {
                                        
                                        getProductsWithFilter()
                                        
                                        filterProducts = false
                                    }
                                }
                                
                            }
                        }.padding(.top, 9).frame(alignment: .leading)
                        
                        
                        HStack {
                            Divider().padding(.top, 8)
                            
                            if !isGrid {
                                Image(uiImage: UIImage.formatListBulleted)
                                    .renderingMode(isDark ? .template : .original)
                                    .foregroundColor(isDark ? .white : nil)
                                    .padding(.top, 8).onTapGesture {
                                    isGrid = true
                                    UserDefaults.standard.setValue(true, forKey: "isGrid")
                                }
                            } else {
                                Image(uiImage: UIImage.gridView)
                                    .renderingMode(isDark ? .template : .original)
                                    .foregroundColor(isDark ? .white : nil)
                                    .padding(.top, 8)
                                    .onTapGesture {
                                    isGrid = false
                                    UserDefaults.standard.setValue(false, forKey: "isGrid")
                                }
                            }
                        }.frame(alignment: .trailing)
                        
                        
                    }.frame(maxWidth: .infinity, maxHeight: 40).padding(.horizontal, 12)
                    
                    if pagingVM.showExpiredAlert {
                        VStack {
                            EmptyView()
                        }.onAppear {
                            alertExpiredMessage = pagingVM.expiredAlertMessage
                            showExpiredAlert = pagingVM.showExpiredAlert
                        }
                        
                    } else if pagingVM.errorCode != "" {
                        
                        VStack {
                            Image(uiImage: UIImage.errorState)
                            Text("\(pagingVM.errorCode)").font(.system(size: 32)).bold()
                            Text("\(pagingVM.errorMessage)")
                            Button(action: {
                                pagingVM.isLoading = true
                                searchedText = ""
                                pagingVM.getProduct(
                                    search: nil, brand: nil, lowest: nil, highest: nil, sort: nil, page: 1
                                )
                            }, label: {
                                if(pagingVM.errorMessage == "Not Found") {
                                    Text("Reset").foregroundColor(.white)
                                } else {
                                    Text("Refresh").foregroundColor(.white)
                                }
                            }).padding(16).padding(.horizontal, 16).background(Color(hex: "#6750A4")).cornerRadius(100).padding(8)
                        }.frame(maxWidth: .infinity ,maxHeight: .infinity, alignment: .center)
                        
                    } else {
                        if !isGrid {
                            ScrollView(.vertical) {
                                PullToRefreshView {
                                    getProductsWithFilter()
                                }
                                LazyVStack {
                                    let product = pagingVM.product
                                    ForEach(product, id: \.self) { i in
                                        HStack {
                                            let image = i.image
                                            ImageLoader(contentMode: .constant("fill"), urlString: image).frame(width: 80, height: 80).padding(.leading, 4)
                                            
                                            VStack {
                                                Text("\(i.productName)").font(.system(size: 14)).padding(.top, 8).frame(maxWidth: .infinity, alignment: .leading).padding(.trailing)
                                                    .lineLimit(2)
                                                    .truncationMode(.tail)
                                                    .fixedSize(horizontal: false, vertical: true)
                                                
                                                Text("Rp\(i.productPrice)").font(.system(size: 14)).bold().padding(.top, 1).frame(maxWidth: .infinity, alignment: .leading)
                                                
                                                HStack {
                                                    Image(uiImage: UIImage.personSmall)
                                                        .renderingMode(isDark ? .template : .original)
                                                        .foregroundColor(isDark ? .white : nil)
                                                    Text("\(i.store)").font(.system(size: 10))
                                                }.frame(maxWidth: .infinity, alignment: .leading)
                                                
                                                HStack {
                                                    Image(uiImage: UIImage.star)
                                                        .renderingMode(isDark ? .template : .original)
                                                        .foregroundColor(isDark ? .white : nil)
                                                    Text("\(i.productRating)").font(.system(size: 10))
                                                    Divider().padding(.vertical, 4)
                                                    Text(isEN ? "Sold \(i.sale)" :"Terjual \(i.sale)").font(.system(size: 10))
                                                }.frame(maxWidth: .infinity, maxHeight: 20 ,alignment: .leading)
                                                
                                            }.frame(maxWidth: .infinity, alignment: .leading).padding(.vertical, 4)
                                        }
                                        .frame(maxWidth: .infinity, alignment: .leading)
                                        .background(isDark ? .black :Color.white)
                                        .cornerRadius(8)
                                        .padding(.top, 12)
                                        .padding(.horizontal, 20)
                                        .shadow(color: .gray, radius: 2, x: 0, y: 2)
                                        .onTapGesture {
                                            print("product detail \(i.productName)")
                                            chosenProduct = i
                                            goToDetailProduct = true
                                        }
                                        
                                        if (i == pagingVM.product.last) {
                                            let _ = pagingVM.loadMoreContent(currentItem: i, search: search, brand: brand, lowest: lowest, highest: highest, sort: sort)
                                            
                                            if pagingVM.isLoadingPaging {
                                                CircularLoadingView().padding()
                                            }
                                        }
                                    }
                                }
                            }
                        } else {
                            ScrollView(.vertical) {
                                PullToRefreshView {
                                    getProductsWithFilter()
                                }
                                LazyVGrid(columns: columns, spacing: 5) {
                                    ForEach(pagingVM.product, id: \.self) { i in
                                        VStack {
                                            let image = i.image
                                            ImageLoader(contentMode: .constant("fill"),urlString: image).frame(maxWidth: .infinity, maxHeight: 80).padding(.top, 50)
                                            
                                            VStack {
                                                Text("\(i.productName)").font(.system(size: 14)).padding(.top, 40).frame(maxWidth: .infinity, alignment: .leading)
                                                    .lineLimit(2)
                                                    .truncationMode(.tail)
                                                    .fixedSize(horizontal: false, vertical: true)
                                                
                                                Text("Rp\(i.productPrice)").font(.system(size: 14)).bold().padding(.top, 1).frame(maxWidth: .infinity, alignment: .leading)
                                                
                                                HStack {
                                                    Image(uiImage: UIImage.personSmall)
                                                        .renderingMode(isDark ? .template : .original)
                                                        .foregroundColor(isDark ? .white : nil)
                                                    Text("\(i.store)").font(.system(size: 10))
                                                }.frame(maxWidth: .infinity, alignment: .leading)
                                                
                                                HStack {
                                                    Image(uiImage: UIImage.star)
                                                        .renderingMode(isDark ? .template : .original)
                                                        .foregroundColor(isDark ? .white : nil)
                                                    Text("\(i.productRating)").font(.system(size: 10))
                                                    Divider().padding(.vertical, 4)
                                                    Text(isEN ? "Sold \(i.sale)" :"Terjual \(i.sale)").font(.system(size: 10))
                                                }.frame(maxWidth: .infinity, maxHeight: 20 ,alignment: .leading)
                                                
                                            }.frame(maxWidth: .infinity, alignment: .leading).padding(8)
                                        }
                                        .frame(maxWidth: .infinity, alignment: .leading)
                                        .background(isDark ? .black :Color.white)
                                        .cornerRadius(8)
                                        .padding(2)
                                        .shadow(color: .gray, radius: 2, x: 0, y: 2)
                                        .onTapGesture {
                                            print("product detail \(i.productName)")
                                            chosenProduct = i
                                            goToDetailProduct = true
                                        }
                                        
                                        if (i == pagingVM.product.last) {
                                            
                                            let _ = pagingVM.loadMoreContent(currentItem: i, search: search, brand: brand, lowest: lowest, highest: highest, sort: sort)
                                            
                                            if pagingVM.isLoadingPaging {
                                                CircularLoadingView().padding()
                                            }
                                        }
                                    }
                                }
                            }.padding(.top, 8).padding(.horizontal, 8)
                        }
                    }
                    
                } else {
                    
                    let _ = Log.d("store masuk loading")
                    
                    if isGrid {
                        HStack {
                            Rectangle().frame(width: 80, height : 25).foregroundColor(.gray).shimmer().background(Color.gray).cornerRadius(4).foregroundColor(.gray).frame(maxWidth: .infinity, alignment: .leading)
                            Rectangle().frame(width: 25, height : 25).background(Color.gray).cornerRadius(4).foregroundColor(.gray).shimmer()
                        }.padding(.horizontal, 20).padding(.top, 8)
                        
                        LazyVGrid(columns: columns, spacing: 5) {
                            ForEach(0..<2) { i in
                                VStack {
                                    Rectangle().frame(width: .infinity, height: 180).shimmer().background(Color.gray).cornerRadius(8).foregroundColor(.gray)
                                    
                                    Rectangle().frame(maxWidth: .infinity, maxHeight: 10).shimmer().foregroundColor(.gray).padding(.horizontal, 4)
                                    Rectangle().frame(maxWidth: .infinity, maxHeight: 10).shimmer().foregroundColor(.gray).padding(.horizontal, 4)
                                    Rectangle().frame(maxWidth: 60, maxHeight: 10).padding(.top, 8).shimmer().foregroundColor(.gray).frame(maxWidth: .infinity, alignment: .leading).padding(.horizontal, 4)
                                    Rectangle().frame(maxWidth: 60, maxHeight: 10).shimmer().foregroundColor(.gray).padding(.bottom, 8).frame(maxWidth: .infinity, alignment: .leading).padding(.horizontal, 4)
                                    
                                }
                                .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .leading)
                                .background(Color.white)
                                .cornerRadius(8)
                                .padding(2)
                                .shadow(color: .gray, radius: 2, x: 0, y: 2)
                            }
                        }.padding(.horizontal, 20).padding(.top, 8)
                        
                    } else {
                        HStack {
                            Rectangle().frame(width: 80, height : 25).foregroundColor(.gray).shimmer().background(Color.gray).cornerRadius(4).foregroundColor(.gray).frame(maxWidth: .infinity, alignment: .leading)
                            Rectangle().frame(width: 25, height : 25).background(Color.gray).cornerRadius(4).foregroundColor(.gray).shimmer()
                        }.padding(.horizontal, 20).padding(.top, 8)
                        
                        LazyVStack {
                            ForEach(0..<4) { index in
                                HStack {
                                    Rectangle().frame(width: 80, height: 80).shimmer().background(Color.gray).cornerRadius(8).padding(8).foregroundColor(.gray)
                                    
                                    VStack {
                                        Rectangle().frame(maxWidth: .infinity, maxHeight: 10).shimmer().foregroundColor(.gray)
                                        Rectangle().frame(maxWidth: .infinity, maxHeight: 10).shimmer().foregroundColor(.gray)
                                        Rectangle().frame(maxWidth: 60, maxHeight: 10).padding(.top, 8).shimmer().foregroundColor(.gray).frame(maxWidth: .infinity, alignment: .leading)
                                        Rectangle().frame(maxWidth: 60, maxHeight: 10).shimmer().foregroundColor(.gray).padding(.bottom, 8).frame(maxWidth: .infinity, alignment: .leading)
                                    }.padding(.trailing, 16).frame(maxWidth: .infinity, alignment: .leading)
                                }
                                .frame(maxWidth: .infinity, alignment: .leading)
                                .background(Color.white)
                                .cornerRadius(8)
                                .padding(.top, 12)
                                .padding(.horizontal, 20)
                                .shadow(color: .gray, radius: 2, x: 0, y: 2)
                            }
                        }
                    }
                }
                
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top).navigationBarBackButtonHidden().padding(.top, 16)
        }
    }
    
    private func getProductsWithFilter() {
        pagingVM.isLoading = true
        
        var lowest: Int? = nil
        var highest: Int? = nil
        var search: String? = nil
        
        if searchedText != "" {
            search = searchedText
        }
        
        if bottomSheetVM.hargaTerendah != nil {
            lowest = Int(bottomSheetVM.hargaTerendah!)
        }
        
        if bottomSheetVM.hargaTertinggi != nil {
            highest = Int(bottomSheetVM.hargaTertinggi!)
        }
        
        pagingVM.product = []
        pagingVM.getProduct(
            search: search, brand: bottomSheetVM.selectedCategoryChip, lowest: lowest, highest: highest, sort: bottomSheetVM.selectedSortChip, page: 1
        )
    }
}

#Preview {
    StoreScreen(showSearchDialog: .constant(false), showExpiredAlert: .constant(false), alertExpiredMessage: .constant(""), searchedText: .constant(""), showBottomSheet: .constant(false), filterProducts: .constant(false) ,bottomSheetVM: BottomSheetViewModel(), goToDetailProduct: .constant(false), chosenProduct: .constant(Product(productId : "", productName : "", productPrice : 0, image : "", brand : "", store : "", sale : 0, productRating: 0.0)))
}

struct ShimmerView: View {
    
    @AppStorage("isDark") private var isDark: Bool = false
    @AppStorage("isEN") private var isEN: Bool = false
    
    @State private var startPoint: UnitPoint = .leading
    @State private var endPoint: UnitPoint = .trailing

    var body: some View {
        LinearGradient(
            gradient: Gradient(colors: isDark ? [Color.black.opacity(0.1), Color.black.opacity(0.3), Color.black.opacity(0.5)] : [Color.white.opacity(0.1), Color.white.opacity(0.3), Color.white.opacity(0.5)]),
            startPoint: startPoint,
            endPoint: endPoint
            
        )
        .blendMode(.screen)
        .onAppear {
            withAnimation(
                Animation.linear(duration: 1.0).repeatForever(autoreverses: false)
            )
            {
                self.startPoint = .trailing
                self.endPoint = .trailing
            }
        }
    }
}

struct ShimmerModifier: ViewModifier {
    func body(content: Content) -> some View {
        content
            .overlay(ShimmerView().mask(content))
    }
}

extension View {
    func shimmer() -> some View {
        self.modifier(ShimmerModifier())
    }
}

import Foundation
import SwiftUI

struct LoadingPagingView: View {
    
    @AppStorage("isDark") private var isDark: Bool = false
    @AppStorage("isEN") private var isEN: Bool = false
    
    var body: some View {
        
        ZStack {
            Rectangle().fill(isDark ? .black :Color.white)

            ProgressView()

        }
        .ignoresSafeArea(.all)
        .frame(
            width: .infinity,
            height: .infinity,
            alignment: .center
        )
    }
}


