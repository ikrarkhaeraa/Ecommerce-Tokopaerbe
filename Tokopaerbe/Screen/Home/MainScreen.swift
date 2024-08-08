//
//  HomeScreen.swift
//  Tokopaerbe
//
//  Created by Ikrar Khaera Arfat on 01/06/24.
//

import SwiftUI
import WrappingHStack



struct MainScreen: View {
    
    @AppStorage("username") private var username: String = ""
    @State private var isNewAccount: Bool = false
    @State var page: Int
    
    var body: some View {
        
        let _ = Log.d("cek username : \(username)")
        
        if username == "" || username.isEmpty {
            let _ = Log.d("cek username : \(username)")
            ProfileScreen(isNewAccount: $isNewAccount)
        } else {
            MainActivity(page: $page)
        }
    }
    
}

struct MainActivity: View {
    private let bottomNavIcon = [UIImage.home, UIImage.store, UIImage.favoriteFull, UIImage.listAlt]
    private let bottomNavTitle = ["Beranda", "Toko", "Favorit", "Transaksi"]
    private let bottomNavTitleEN = ["Home", "Store", "Favorite", "Transaction"]
    
    @AppStorage("username") private var username: String = ""
    @AppStorage("isDark") private var isDark: Bool = false
    @AppStorage("isEN") private var isEN: Bool = false
    
    @FetchRequest(sortDescriptors: []) private var carts: FetchedResults<CartEntity>
    @FetchRequest(sortDescriptors: []) private var favorites: FetchedResults<FavoriteEntity>
    @FetchRequest(
        entity: EntityNotif.entity(),
        sortDescriptors: [],
        predicate: NSPredicate(format: "isRead == false")
    ) var notifications: FetchedResults<EntityNotif>
    
    @Binding var page: Int
    @State private var temp = ""
    @State private var temp2 = ""
    @State var isLogout: Bool = false
    @State var searchLoading: Bool = false
    @State var searchedText: String = ""
    @State var choosenSearchText: String = ""
    @State var showExpiredAlert: Bool = false
    @State var alertExpiredMessage: String = ""
    @State var showSearchDialog: Bool = false
    @State var showBottomSheet: Bool = false
    @State var hargaTerendah: String = ""
    @State var hargaTertinggi: String = ""
    @State var bottomSheetReset: Bool = false
    @State var filterProducts: Bool = false
    @State var selectedSortChip: Int = -1
    @State var selectedCategoryChip: Int = -1
    
    @State var goToDetailProduct: Bool = false
    @State var chosenProduct: Product = Product(productId : "", productName : "", productPrice : 0, image : "", brand : "", store : "", sale : 0, productRating: 0.0)
    @State var goToCartScreen: Bool = false
    @State var goToNotifScreen: Bool = false

    @StateObject private var searchVM = SearchViewModel()
    @StateObject private var bottomSheetVM = BottomSheetViewModel()

    
    var body: some View {
        
        ZStack {
            
            VStack {
                
                HStack {
                    Image(uiImage: UIImage(named: "icon_person")!)
                        .renderingMode(isDark ? .template : .original)
                        .foregroundColor(isDark ? .white : nil)
                        .padding(.leading, 20)
                    Text(isEN ? "Hello, \(username)" : "Halo, \(username)").font(.system(size: 22)).frame(maxWidth: /*@START_MENU_TOKEN@*/.infinity/*@END_MENU_TOKEN@*/, alignment: .leading).padding(.leading, 10)
                    
                    HStack {
                        Image(uiImage: UIImage.notifications)
                            .renderingMode(isDark ? .template : .original)
                            .foregroundColor(isDark ? .white : nil)
                            .padding(.trailing, 14)
                            .onTapGesture {
                            goToNotifScreen = true
                        }.overlay(NotificationCountView(value: .constant(notifications.count)))
                        
                        Image(uiImage: UIImage.shoppingCart)
                            .renderingMode(isDark ? .template : .original)
                            .foregroundColor(isDark ? .white : nil)
                            .padding(.trailing, 14).onTapGesture {
                            goToCartScreen = true
                        }.overlay(NotificationCountView(value: .constant(carts.count)))
                        
                        Image(uiImage: UIImage.menu)
                            .renderingMode(isDark ? .template : .original)
                            .foregroundColor(isDark ? .white : nil)
                    }.padding(.trailing, 20)
                    
                }.frame(maxWidth: .infinity, alignment: .leading).padding(.vertical, 12)
                Divider()
                
                ZStack {
                    if page == 0 {
                        HomeScreen(isLogout: $isLogout)
                    } else if page == 1 {
                        StoreScreen(showSearchDialog: $showSearchDialog, showExpiredAlert: $showExpiredAlert, alertExpiredMessage: $alertExpiredMessage, searchedText: $searchedText, showBottomSheet: $showBottomSheet, filterProducts: $filterProducts, bottomSheetVM: bottomSheetVM, goToDetailProduct: $goToDetailProduct, chosenProduct: $chosenProduct)
                    } else if page == 2 {
                        FavoriteScreen()
                    } else if page == 3 {
                        TransactionScreen()
                    }
                }
                
                Divider()
                HStack {
                    ForEach(0..<bottomNavIcon.count, id: \.self) { num in
                        VStack {
                            ZStack {
                                if (page == num) {
                                    Image(uiImage: UIImage.iconContainer)
                                        .renderingMode(isDark ? .template : .original)
                                        .foregroundColor(isDark ? Color(hex: "#6750A4") : nil)
                                }
                                
                                ZStack {
                                    Image(uiImage: bottomNavIcon[num])
                                        .renderingMode(isDark ? .template : .original)
                                        .foregroundColor(isDark ? .white : nil)
                                        .onTapGesture {
                                        print("page : \(page) \n num : \(num)")
                                        page = num
                                    }.overlay(num == 2 ? NotificationCountView(value: .constant(favorites.count)) : nil)
                                }.frame(maxWidth: .infinity)
                                
                            }
                            
                            if (page == num) {
                                Text(isEN ? "\(bottomNavTitleEN[num])" : "\(bottomNavTitle[num])").font(.system(size: 14)).bold().onTapGesture {
                                    print("page : \(page) \n num : \(num)")
                                    page = num
                                }
                            } else {
                                Text(isEN ? "\(bottomNavTitleEN[num])" : "\(bottomNavTitle[num])").font(.system(size: 14)).onTapGesture {
                                    print("page : \(page) \n num : \(num)")
                                    page = num
                                }
                            }
                        }
                        
                    }.padding(.top, 12)
                }
                
            }
                .navigationBarBackButtonHidden()
                .alert(isPresented: $showExpiredAlert, content: {
                Alert(
                    title: Text("Error"),
                    message: Text(alertExpiredMessage),
                    dismissButton: .default(Text("OK"), action: {
                        isLogout = true
                    })
                )
            })
        
            if showSearchDialog {
                
                VStack {
                    Image(uiImage: UIImage.arrowleft)
                        .renderingMode(isDark ? .template : .original)
                        .foregroundColor(isDark ? .white : nil)
                        .frame(maxWidth: .infinity, alignment: .leading).padding(8).padding(.leading, 8).onTapGesture {
                        choosenSearchText = searchVM.searchText
                        showSearchDialog = false
                    }.onAppear {
                        searchVM.product = []
                    }
                    
                    SearchBar(text: $choosenSearchText, temp: $temp, temp2: $temp2)
                        .onReceive(choosenSearchText.publisher.last(), perform: { _ in
                            if temp != choosenSearchText {
                                temp = choosenSearchText
                                
                                DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
                                    if choosenSearchText != "" {
                                        searchVM.isLoading = true
                                        DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
                                            if temp2 != choosenSearchText {
                                                temp2 = choosenSearchText
                                                Log.d("cekSearchText : \(choosenSearchText)")
                                                searchVM.searchProduct(query: choosenSearchText)
                                            }
                                        }
                                    }
                                }
                            }
                    })
                    
                    if searchVM.isLoading {
                        CircularLoadingView().frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .center)
                    } else {
                        VStack {
                            ForEach(searchVM.product, id: \.self) { i in
                                HStack {
                                    Image(uiImage: UIImage.searchIcon).renderingMode(isDark ? .template : .original)
                                        .foregroundColor(isDark ? .white : nil)
                                        .padding(4)
                                    Text("\(i)").frame(maxWidth: .infinity, alignment: .leading).padding(4)
                                    Image(uiImage: UIImage.arrowRight)
                                        .renderingMode(isDark ? .template : .original)
                                        .foregroundColor(isDark ? .white : nil)
                                        .padding(4)
                                }.padding(8).onTapGesture {
                                    let _ = Log.d("cek klik text : \(i)")
                                    choosenSearchText = i
                                    searchedText = i
                                    searchVM.searchText = searchedText
                                    showSearchDialog = false
                                }
                            }
                        }.frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
                    }
                    
                    Button(action: {
                        searchedText = choosenSearchText
                        showSearchDialog = false
                    }, label: {
                        Text("Search").foregroundColor(.white)
                    }).frame(maxWidth: .infinity, maxHeight: 40).background(RoundedRectangle(cornerRadius: 100).fill(Color(hex: "#6750A4"))).padding(16)
                    
                }.frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top).background(isDark ? .black : Color.white)
            }
            
            if showBottomSheet {
                ZStack(alignment: .bottom) {
                    ZStack {
                        Color.gray.opacity(0.5)
                    }.onTapGesture {
                        
                        if !bottomSheetReset {
                            for i in bottomSheetVM.chipSortArrayTemp.indices {
                                if bottomSheetVM.chipSortArrayTemp[i].isSelected == nil {
                                    if isEN {
                                        bottomSheetVM.chipSortArrayEN[i].isSelected = false
                                    } else {
                                        bottomSheetVM.chipSortArray[i].isSelected = false
                                    }
                                }
                            }
                            
                            for i in bottomSheetVM.chipCategoryArrayTemp.indices {
                                if bottomSheetVM.chipCategoryArrayTemp[i].isSelected == nil {
                                    bottomSheetVM.chipCategoryArray[i].isSelected = false
                                }
                            }
                            
                            if bottomSheetVM.hargaTerendahTemp == nil {
                                bottomSheetVM.hargaTerendah = ""
                                hargaTerendah = bottomSheetVM.hargaTerendah!
                            }
                            
                            if bottomSheetVM.hargaTertinggiTemp == nil {
                                bottomSheetVM.hargaTertinggi = ""
                                hargaTertinggi = bottomSheetVM.hargaTertinggi!
                            }
                            
                        } else {
                            for i in bottomSheetVM.chipSortArrayTemp.indices {
                                if bottomSheetVM.chipSortArrayTemp[i].isSelected == nil {
                                    if isEN {
                                        bottomSheetVM.chipSortArrayEN[i].isSelected = false
                                    } else {
                                        bottomSheetVM.chipSortArray[i].isSelected = false
                                    }
                                } else {
                                    if isEN {
                                        bottomSheetVM.chipSortArrayEN[i].isSelected = bottomSheetVM.chipSortArrayTemp[i].isSelected
                                    } else {
                                        bottomSheetVM.chipSortArray[i].isSelected = bottomSheetVM.chipSortArrayTemp[i].isSelected
                                    }
                                }
                            }
                            
                            for i in bottomSheetVM.chipCategoryArrayTemp.indices {
                                if bottomSheetVM.chipCategoryArrayTemp[i].isSelected == nil {
                                    bottomSheetVM.chipCategoryArray[i].isSelected = false
                                } else {
                                    bottomSheetVM.chipCategoryArray[i].isSelected = bottomSheetVM.chipCategoryArrayTemp[i].isSelected
                                }
                            }
                            
                            if bottomSheetVM.hargaTerendahTemp == nil || bottomSheetVM.hargaTerendahTemp == "" {
                                bottomSheetVM.hargaTerendah = ""
                                hargaTerendah = bottomSheetVM.hargaTerendah!
                            } else {
                                bottomSheetVM.hargaTerendah = bottomSheetVM.hargaTerendahTemp
                                hargaTerendah = bottomSheetVM.hargaTerendah!
                            }
                            
                            if bottomSheetVM.hargaTertinggiTemp == nil || bottomSheetVM.hargaTertinggiTemp == "" {
                                bottomSheetVM.hargaTertinggi = ""
                                hargaTertinggi = bottomSheetVM.hargaTertinggi!
                            } else {
                                bottomSheetVM.hargaTertinggi = bottomSheetVM.hargaTertinggiTemp
                                hargaTertinggi = bottomSheetVM.hargaTertinggi!
                            }
                            
                        }
                        
                        
                        bottomSheetReset = false
                        showBottomSheet = false
                    }
                    
                    VStack {
                        
                        Rectangle()
                            .frame(maxWidth: 32, maxHeight: 5)
                            .background(RoundedRectangle(cornerRadius:100).fill(Color(hex: "#79747E")))
                            .opacity(0.1)
                            .padding(.top, 8)
                        
                        HStack {
                            Text("Filter").font(.system(size: 20)).bold().frame(maxWidth: .infinity, alignment: .leading).foregroundColor(isDark ? .white : .black)
                            Text("Reset").font(.system(size: 16)).foregroundColor(Color(hex: "#6750A4")).bold().onTapGesture {
                                
                                for i in bottomSheetVM.chipSortArray.indices {
                                    if isEN {
                                        bottomSheetVM.chipSortArrayEN[i].isSelected = false
                                    } else {
                                        bottomSheetVM.chipSortArray[i].isSelected = false
                                    }
                                }
                                
                                for i in bottomSheetVM.chipCategoryArray.indices {
                                    bottomSheetVM.chipCategoryArray[i].isSelected = false
                                }
                                
                                hargaTerendah = ""
                                hargaTertinggi = ""
                                
                                bottomSheetReset = true
                                
                            }
                        }.padding(.horizontal, 12)
                        
                        
                        VStack {
                            Text(isEN ? "Sort" :"Urutkan").font(.system(size: 16)).bold().foregroundColor(isDark ? .white : .black).frame(maxWidth: .infinity, alignment: .leading).padding(.top, 8).padding(.bottom, -8)
                            
                            HStack {
                                WrappedLayout(chip: isEN ? $bottomSheetVM.chipSortArrayEN :$bottomSheetVM.chipSortArray, bottomSheetVM: bottomSheetVM, chipType: .constant("sort"))
                            }.frame(maxWidth: .infinity, maxHeight: 87)
                            
                            
                            Text(isEN ? "Category" :"Kategori").font(.system(size: 16)).bold().foregroundColor(isDark ? .white : .black).frame(maxWidth: .infinity, alignment: .leading).padding(.top, 8)
                            
                            HStack {
                                ForEach($bottomSheetVM.chipCategoryArray) { data in
                                    ChipView(titleKey: data.titleKey,
                                             isSelected: data.isSelected, bottomSheetVM: bottomSheetVM, chipType: .constant("category"))
                                }
                            }.frame(maxWidth: .infinity, alignment: .leading)
                            
                            Text(isEN ? "Price" :"Harga").font(.system(size: 16)).bold().foregroundColor(isDark ? .white : .black).frame(maxWidth: .infinity, alignment: .leading).padding(.top, 8)
                            
                            HStack {
                                ZStack(alignment: .leading) {
                                    TextField(isEN ? "Lowest Price" :"Harga terendah", text: $hargaTerendah)
                                        .padding(18)
                                        .background(RoundedRectangle(cornerRadius:8).stroke(isDark ? .white :Color(hex: "#79747E"),lineWidth:2))
                                        .cornerRadius(10)
                                        .font(.system(size: 14))
                                        .autocapitalization(.none)
                                }
                                
                                ZStack(alignment: .leading) {
                                    TextField(isEN ? "Highest Price" :"Harga tertinggi", text: $hargaTertinggi)
                                        .padding(18)
                                        .background(RoundedRectangle(cornerRadius:8).stroke(isDark ? .white :Color(hex: "#79747E"),lineWidth:2))
                                        .cornerRadius(10)
                                        .font(.system(size: 14))
                                        .autocapitalization(.none)
                                }
                            }
                            
                            Button(action: {
                                
                                for i in bottomSheetVM.chipSortArray.indices {
                                    if isEN {
                                        bottomSheetVM.chipSortArrayTemp[i].isSelected = bottomSheetVM.chipSortArrayEN[i].isSelected
                                    } else {
                                        bottomSheetVM.chipSortArrayTemp[i].isSelected = bottomSheetVM.chipSortArray[i].isSelected
                                    }
                                }
                                
                                for i in bottomSheetVM.chipCategoryArray.indices {
                                    bottomSheetVM.chipCategoryArrayTemp[i].isSelected = bottomSheetVM.chipCategoryArray[i].isSelected
                                }
                                
                                bottomSheetVM.hargaTerendah = hargaTerendah
                                bottomSheetVM.hargaTertinggi = hargaTertinggi
                                bottomSheetVM.hargaTerendahTemp = bottomSheetVM.hargaTerendah
                                bottomSheetVM.hargaTertinggiTemp = bottomSheetVM.hargaTertinggi
                                
                                
                                for i in bottomSheetVM.chipSortArray.indices {
                                    if isEN {
                                        if bottomSheetVM.chipSortArrayEN[i].isSelected == true {
                                            bottomSheetVM.selectedSortChip = bottomSheetVM.chipSortArrayEN[i].titleKey
                                        } else {
                                            if bottomSheetReset == true {
                                                bottomSheetVM.selectedSortChip = nil
                                            }
                                        }
                                    } else {
                                        if bottomSheetVM.chipSortArray[i].isSelected == true {
                                            bottomSheetVM.selectedSortChip = bottomSheetVM.chipSortArray[i].titleKey
                                        } else {
                                            if bottomSheetReset == true {
                                                bottomSheetVM.selectedSortChip = nil
                                            }
                                        }
                                    }
                                }
                                
                                for i in bottomSheetVM.chipCategoryArray.indices {
                                    if bottomSheetVM.chipCategoryArray[i].isSelected == true {
                                        bottomSheetVM.selectedCategoryChip = bottomSheetVM.chipCategoryArray[i].titleKey
                                    } else {
                                        if bottomSheetReset == true {
                                            bottomSheetVM.selectedCategoryChip = nil
                                        }
                                    }
                                }
                                
                                bottomSheetReset = false
                                showBottomSheet = false
                                filterProducts = true
                                
                            }, label: {
                                Text(isEN ? "Show Products" :"Tampilkan Produk").foregroundColor(.white).bold().frame(maxWidth: .infinity)
                            }).padding().background( RoundedRectangle(cornerRadius: 100).fill(Color(hex: "#6750A4"))).frame(maxWidth: .infinity).padding(.vertical, 8).padding(.horizontal, 12).padding(.bottom, 16)
                            
                        }.padding(.horizontal, 12)
                    }.background(RoundedRectangle(cornerRadius:24).fill(isDark ? .black :Color.white))
                }
                .frame(maxWidth: .infinity, alignment: .bottom)
                .ignoresSafeArea()
                .animation(.easeInOut)
            }
            
            if isLogout {
                NavigationLink(destination: LoginScreen(), isActive: $isLogout) {
                    EmptyView()
                }
            }
        
            if goToDetailProduct {
                let _ = Log.d("\(chosenProduct)")
                NavigationLink(destination: ProductDetailScreen(product: chosenProduct), isActive: $goToDetailProduct) {
                    EmptyView()
                }
            }
            
            if goToCartScreen {
                NavigationLink(destination: CartScreen(), isActive: $goToCartScreen) {
                    EmptyView()
                }
            }
            
            NavigationLink(destination: NotificationScreen(), isActive: $goToNotifScreen) {
                EmptyView()
            }
            
        }
    
    }
}

struct ChipView: View {
    
    @AppStorage("isDark") private var isDark: Bool = false
    @AppStorage("isEN") private var isEN: Bool = false
    
    @Binding var titleKey: String
    @Binding var isSelected: Bool?
    @StateObject var bottomSheetVM: BottomSheetViewModel
    @Binding var chipType: String

    var body: some View {
        HStack() {
            Text("\(titleKey)").padding(4).font(.body).lineLimit(1)
        }
        .padding(.vertical, 4)
        .padding(.horizontal, 8)
        .foregroundColor(isSelected! ? .black : isDark ? .white :Color(hex: "#49454F"))
        .background(isSelected! ? Color(hex: "#E8DEF8") : isDark ? .black :Color.white)
        .cornerRadius(8)
        .overlay(
            RoundedRectangle(cornerRadius: 8)
                .stroke(isSelected! ? Color.clear : isDark ? .white :Color(hex: "#79747E"), lineWidth: 1.5)
            
        )
        .onTapGesture {
            
            if chipType == "sort" {
                for i in bottomSheetVM.chipSortArray.indices {
                    if isEN {
                        if bottomSheetVM.chipSortArrayEN[i].isSelected == true {
                            bottomSheetVM.chipSortArrayEN[i].isSelected?.toggle()
                        }
                    } else {
                        if bottomSheetVM.chipSortArray[i].isSelected == true {
                            bottomSheetVM.chipSortArray[i].isSelected?.toggle()
                        }
                    }
                }
            } else {
                for i in bottomSheetVM.chipCategoryArray.indices {
                    if bottomSheetVM.chipCategoryArray[i].isSelected == true {
                        bottomSheetVM.chipCategoryArray[i].isSelected?.toggle()
                    }
                }
            }
            
            isSelected!.toggle()
        }
    }
}


#Preview {
    MainActivity(page: .constant(0))
}


struct WrappedLayout: View {
    @Binding var chip: [ChipModel]
    @StateObject var bottomSheetVM: BottomSheetViewModel
    @Binding var chipType: String

    var body: some View {
        GeometryReader { geometry in
            self.generateContent(in: geometry)
        }
    }

    private func generateContent(in g: GeometryProxy) -> some View {
        var width = CGFloat.zero
        var height = CGFloat.zero

        return ZStack(alignment: .topLeading) {
            ForEach(chip.indices, id: \.self) { index in
                ChipView(
                    titleKey: $chip[index].titleKey,
                    isSelected: $chip[index].isSelected,
                    bottomSheetVM: bottomSheetVM,
                    chipType: $chipType
                )
                .padding(.trailing, 8)
                .padding(.top, 8)
                .alignmentGuide(.leading, computeValue: { d in
                    if (abs(width - d.width) > g.size.width) {
                        width = 0
                        height -= d.height
                    }
                    let result = width
                    if index == chip.indices.last {
                        width = 0 // last item
                    } else {
                        width -= d.width
                    }
                    return result
                })
                .alignmentGuide(.top, computeValue: { d in
                    let result = height
                    if index == chip.indices.last {
                        height = 0// last item
                    }
                    return result
                })
            }
        }
    }
}
