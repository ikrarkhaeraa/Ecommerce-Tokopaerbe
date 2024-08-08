//
//  FavoriteScreen.swift
//  Tokopaerbe
//
//  Created by Ikrar Khaera Arfat on 11/06/24.
//

import SwiftUI
import CoreData
import AlertToast

struct FavoriteScreen: View {
    
    @AppStorage("isDark") private var isDark: Bool = false
    @AppStorage("isEN") private var isEN: Bool = false
    
    // MARK: Core Data
    @FetchRequest(sortDescriptors: []) private var favorites: FetchedResults<FavoriteEntity>
    @FetchRequest(sortDescriptors: []) private var carts: FetchedResults<CartEntity>
    @Environment(\.managedObjectContext) var viewContext
    
    @State var isGrid: Bool = UserDefaults.standard.bool(forKey: "isGridFav")
    @State var showToastSuccess: Bool = false
    @State var showToastFailed: Bool = false

    private let adaptiveColumn = [
            GridItem(.adaptive(minimum: 150))
        ]
    
    let columns: [GridItem] = Array(repeating: .init(.flexible()), count: 2)
    
    var body: some View {
        if !favorites.isEmpty {
            VStack {
                HStack {
                    Text(isEN ? "\(favorites.count) items" :"\(favorites.count) barang").foregroundColor(isDark ? .white :Color(hex: "#49454F")).font(.system(size: 16)).frame(maxWidth: .infinity, alignment: .leading)
                    
                    HStack {
                        Divider().padding(.vertical, 6).foregroundColor(isDark ? .white : .black)
                    }
                    
                    if isGrid {
                        Image(uiImage: .gridView)
                            .renderingMode(isDark ? .template : .original)
                            .foregroundColor(isDark ? .white : nil)
                            .onTapGesture {
                            isGrid = false
                            UserDefaults.standard.setValue(false, forKey: "isGridFav")
                        }
                    } else {
                        Image(uiImage: .formatListBulleted)
                            .renderingMode(isDark ? .template : .original)
                            .foregroundColor(isDark ? .white : nil)
                            .onTapGesture {
                            isGrid = true
                            UserDefaults.standard.setValue(true, forKey: "isGridFav")
                        }
                    }
                    
                    
                }.frame(maxWidth: .infinity, maxHeight: 40, alignment: .leading).padding(.horizontal, 10)
                
                ScrollView(.vertical) {
                    
                    if !isGrid {
                        VStack {
                            ForEach(favorites.indices, id: \.self) { i in
                                VStack {
                                    HStack {
                                        ImageLoader(contentMode: .constant("fill"), urlString: favorites[i].productImage!).frame(width: 80, height: 80)
                                        
                                        VStack {
                                            Text("\(favorites[i].productName!)").font(.system(size: 14)).padding(.top, 8).frame(maxWidth: .infinity, alignment: .leading).padding(.trailing)
                                                .lineLimit(2)
                                                .truncationMode(.tail)
                                                .fixedSize(horizontal: false, vertical: true)
                                            
                                            Text("Rp\(favorites[i].productPrice)").font(.system(size: 14)).bold().padding(.top, 1).frame(maxWidth: .infinity, alignment: .leading)
                                            
                                            HStack {
                                                Image(uiImage: UIImage.personSmall)
                                                    .renderingMode(isDark ? .template : .original)
                                                    .foregroundColor(isDark ? .white : nil)
                                                Text("\(favorites[i].productStore!)").font(.system(size: 10))
                                            }.frame(maxWidth: .infinity, alignment: .leading)
                                            
                                            HStack {
                                                Image(uiImage: UIImage.star)
                                                    .renderingMode(isDark ? .template : .original)
                                                    .foregroundColor(isDark ? .white : nil)
                                                Text("\(Float16(favorites[i].productRating))").font(.system(size: 10))
                                                Divider().padding(.vertical, 4)
                                                Text(isEN ? "Sold \(favorites[i].productSale)" : "Terjual \(favorites[i].productSale)").font(.system(size: 10))
                                            }.frame(maxWidth: .infinity, maxHeight: 20 ,alignment: .leading)
                                            
                                        }.frame(maxWidth: .infinity, alignment: .leading).padding(.vertical, 4)
                                    }
                                    
                                    HStack {
                                        Button(action: {
                                            deleteProduct(withId: favorites[i].productId!)
                                               }) {
                                                   Image(uiImage: .delete24Px)
                                                       .resizable()
                                                       .scaledToFit()
                                                       .frame(maxWidth: 24, maxHeight: 24)
//                                                       .renderingMode(isDark ? .template : .original)
//                                                       .foregroundColor(isDark ? .white : nil)
                                                       .padding(.all, 4)
                                                       .background(RoundedRectangle(cornerRadius: 8)
                                                        .stroke(isDark ? .white :Color(hex: "#79747E"), lineWidth: 1))
                                               }
                                        
                                        Button(action: {
                                            handleAddToCart(id: favorites[i].productId!, name: favorites[i].productName!, image: favorites[i].productImage!, price: favorites[i].productPrice, variant: favorites[i].productVariant!, stock: favorites[i].productStock)
                                               }) {
                                                   Text(isEN ? "+ Cart" :"+ Keranjang")
                                                       .frame(maxWidth: .infinity)
                                                       .padding(.vertical, 8)
                                                       .foregroundColor(isDark ? .white :Color(hex: "#6750A4"))
                                                       .font(.system(size: 12))
                                                       .background(RoundedRectangle(cornerRadius: 100)
                                                        .stroke(isDark ? .white :Color(hex: "#79747E"), lineWidth: 1))
                                               }.frame(maxWidth: .infinity).padding(.leading, 4)
                                    }.frame(maxWidth: .infinity, alignment: .leading).padding(.bottom, 16).padding(.horizontal, 16)
                                }
                                .frame(maxWidth: .infinity, alignment: .leading)
                                .background(isDark ? .black :Color.white)
                                .cornerRadius(8)
                                .padding(.vertical, 8)
                                .padding(.horizontal, 10)
                                .shadow(color: .gray, radius: 2, x: 0, y: 2)
                            }
                            
                        }
                    } else {
                        LazyVGrid(columns: columns, spacing: 5) {
                            ForEach(favorites.indices, id: \.self) { i in
                                VStack {
                                    ImageLoader(contentMode: .constant("fill"),urlString: favorites[i].productImage!).frame(maxWidth: .infinity, maxHeight: 80).padding(.top, 50)
                                    
                                    VStack {
                                        Text("\(favorites[i].productName!)").font(.system(size: 14)).padding(.top, 40).frame(maxWidth: .infinity, alignment: .leading)
                                            .lineLimit(2)
                                            .truncationMode(.tail)
                                            .fixedSize(horizontal: false, vertical: true)
                                        
                                        Text("Rp\(favorites[i].productPrice)").font(.system(size: 14)).bold().padding(.top, 1).frame(maxWidth: .infinity, alignment: .leading)
                                        
                                        HStack {
                                            Image(uiImage: UIImage.personSmall)
                                                .renderingMode(isDark ? .template : .original)
                                                .foregroundColor(isDark ? .white : nil)
                                            Text("\(favorites[i].productStore!)").font(.system(size: 10))
                                        }.frame(maxWidth: .infinity, alignment: .leading)
                                        
                                        HStack {
                                            Image(uiImage: UIImage.star)
                                                .renderingMode(isDark ? .template : .original)
                                                .foregroundColor(isDark ? .white : nil)
                                            Text("\(Float16(favorites[i].productRating))").font(.system(size: 10))
                                            Divider().padding(.vertical, 4)
                                            Text(isEN ? "Sold \(favorites[i].productSale)" :"Terjual \(favorites[i].productSale)").font(.system(size: 10))
                                        }.frame(maxWidth: .infinity, maxHeight: 20 ,alignment: .leading)
                                        
                                    }.frame(maxWidth: .infinity, alignment: .leading).padding(8)
                                    
                                    HStack {
                                        Button(action: {
                                            deleteProduct(withId: favorites[i].productId!)
                                               }) {
                                                   Image(uiImage: .delete24Px)
                                                       .resizable()
                                                       .scaledToFit()
//                                                       .renderingMode(isDark ? .template : .original)
//                                                       .foregroundColor(isDark ? .white : nil)
                                                       .frame(maxWidth: 24, maxHeight: 24)
                                                       .padding(.all, 4)
                                                       .background(RoundedRectangle(cornerRadius: 8)
                                                        .stroke(isDark ? .white :Color(hex: "#79747E"), lineWidth: 1))
                                               }
                                        
                                        Button(action: {
                                            handleAddToCart(id: favorites[i].productId!, name: favorites[i].productName!, image: favorites[i].productImage!, price: favorites[i].productPrice, variant: favorites[i].productVariant!, stock: favorites[i].productStock)
                                               }) {
                                                   Text(isEN ? "+ Cart" :"+ Keranjang")
                                                       .frame(maxWidth: .infinity)
                                                       .padding(.vertical, 8)
                                                       .foregroundColor(isDark ? .white :Color(hex: "#6750A4"))
                                                       .font(.system(size: 12))
                                                       .background(RoundedRectangle(cornerRadius: 100)
                                                        .stroke(isDark ? .white :Color(hex: "#79747E"), lineWidth: 1))
                                               }.frame(maxWidth: .infinity).padding(.leading, 4)
                                    }.frame(maxWidth: .infinity, alignment: .leading).padding(.bottom, 16).padding(.horizontal, 16)
                                }
                                .frame(maxWidth: .infinity, alignment: .leading)
                                .background(isDark ? .black :Color.white)
                                .cornerRadius(8)
                                .padding(2)
                                .shadow(color: .gray, radius: 2, x: 0, y: 2)
                            }
                        }
                    }
                
                }.padding(.horizontal, 8).navigationBarBackButtonHidden()
            }.toast(isPresenting: $showToastSuccess) {
                AlertToast(type: .complete(.green), subTitle: "Berhasil menambahkan produk ke keranjang")
            }
            .toast(isPresenting: $showToastFailed) {
                AlertToast(type: .error(.red), subTitle: "Stok barang tidak mencukupi")
            }
            
        } else {
            VStack {
                Image(uiImage: .errorState)
                Text("Empty").bold().padding().font(.system(size: 32)).foregroundColor(isDark ? .white :Color(hex: "#1D1B20"))
                Text("Your requested data is unavailable").font(.system(size: 16)).foregroundColor(isDark ? .white :Color(hex: "#1D1B20"))
            }.frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .center)
        }
    }
    
    private func handleAddToCart(id: String, name: String ,image: String ,price: Int, variant: String, stock: Int) {
        
        print(id)
        if let existingCartItem = carts.first(where: { $0.productId == id && $0.productVariant == variant }) {
                
                if (existingCartItem.productQuantity < stock) {
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
                addToCart(id: id,
                          name: name,
                          image: image,
                          price: price,
                          variant: variant,
                          stock: stock,
                          quantity: 1)
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
    
    private func deleteProduct(withId productId: String) {
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

#Preview {
    FavoriteScreen()
}
