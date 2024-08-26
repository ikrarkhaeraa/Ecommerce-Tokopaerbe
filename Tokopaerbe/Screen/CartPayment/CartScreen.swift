//
//  CartScreen.swift
//  Tokopaerbe
//
//  Created by Ikrar Khaera Arfat on 26/07/24.
//

import SwiftUI
import CoreData

struct CartScreen: View {
    
    @AppStorage("isDark") private var isDark: Bool = false
    @AppStorage("isEN") private var isEN: Bool = false
    
    @Environment(\.presentationMode) var presentationMode
    
    @FetchRequest(sortDescriptors: []) private var carts: FetchedResults<CartEntity>
    @Environment(\.managedObjectContext) var viewContext
    
    @State var isCheckedAll: Bool = false
    @State var isShowAppBarChild: Bool = false
    @State var goToCheckout: Bool = false
    
    var totalPrice: Int {  carts.filter { $0.productChecked }
        .reduce(0) { $0 + ($1.productQuantity * $1.productPrice) }}
    
    var body: some View {
        VStack {
            HStack {
                Image(uiImage: .arrowleft)
                    .renderingMode(isDark ? .template : .original)
                    .foregroundColor(isDark ? .white : nil)
                    .padding()
                    .onTapGesture {
                    self.presentationMode.wrappedValue.dismiss()
                }
                
                Text(isEN ? "Cart" :"Keranjang").frame(maxWidth: .infinity, alignment: .leading).font(.system(size: 22))
                
            }.frame(maxWidth: .infinity, alignment: .leading)
            
            Divider()
            
            if isShowAppBarChild {
                HStack {
                    CheckBoxAllView(checked: $isCheckedAll, carts: carts)
                    Text(isEN ? "Choose All" :"Pilih Semua").font(.system(size: 14)).foregroundColor(isDark ? .white :Color(hex: "#49454F")).frame(maxWidth: .infinity, alignment: .leading).padding(.leading, 4)
                    
                    if carts.contains(where: {$0.productChecked == true}) {
                        Text(isEN ? "Delete" :"Hapus").font(.system(size: 14)).bold().foregroundColor(Color(hex: "#6750A4")).onTapGesture {
                            deleteCartItem()
                        }
                    }
                    
                }.frame(maxWidth: .infinity, alignment: .leading).padding()
                
                Divider()
            }
            
            if carts.isEmpty {
                VStack {
                    Image(uiImage: UIImage.errorState)
                    Text("Empty").font(.system(size: 32)).bold().padding(.bottom, 2)
                    Text("Your requested data is unavailable").font(.system(size: 16)).foregroundColor(isDark ? .white :Color(hex: "#1D1B20"))
                }.frame(maxWidth: .infinity ,maxHeight: .infinity, alignment: .center).onAppear {
                    isShowAppBarChild = false
                }
            } else {
                
                ScrollView {
                    ForEach(carts.indices, id: \.self) { i in
                        
                        HStack {

                            CheckBoxItemView(iteration: i, carts: carts, isCheckedAll: $isCheckedAll)
                            
                            ImageLoader(contentMode: .constant("fit"), urlString: carts[i].productImage!).frame(maxWidth: 80, maxHeight: 80).background(RoundedRectangle(cornerRadius: 8).foregroundColor(.white))
                            
                            VStack {
                                Text("\(carts[i].productName!)").font(.system(size: 14)).bold().foregroundColor(isDark ? .white :Color(hex: "#49454F"))
                                    .lineLimit(1)
                                    .truncationMode(.tail)
                                    .fixedSize(horizontal: false, vertical: true)
                                    .frame(maxWidth: .infinity, alignment: .leading)
                                
                                Text("\(carts[i].productVariant!)").font(.system(size: 10)).foregroundColor(isDark ? .white :Color(hex: "#49454F"))
                                    .frame(maxWidth: .infinity, alignment: .leading)
                                
                                Text("Stok \(carts[i].productStock)").font(.system(size: 10)).foregroundColor(isDark ? .white :Color(hex: "#49454F"))
                                    .frame(maxWidth: .infinity, alignment: .leading)
                                
                                HStack {
                                    Text("Stok \(carts[i].productPrice)").font(.system(size: 14)).bold().foregroundColor(isDark ? .white :Color(hex: "#49454F"))
                                        .frame(maxWidth: .infinity, alignment: .leading).padding(.top, 8)
                                    
                                    Image(uiImage: .delete20PxBlack).padding(.top, 4).onTapGesture {
                                        deleteCartItemById(id: carts[i].productId!, variant: carts[i].productVariant!)
                                    }
                                    
                                    ToggleQuantity(iteration: i, carts: carts, viewContext: viewContext, deleteCartItemById: deleteCartItemById(id:variant:)).padding(.top, 4)
                                    
                                }.frame(maxWidth: .infinity)
                                
                                
                            }.padding(.horizontal, 2).frame(maxWidth: .infinity, alignment: .leading)
                            
                        }.padding()
                        
                        Divider()
                    }
                }.onAppear {
                    isShowAppBarChild = true
                }
                
                Divider()
                
                HStack {
                    VStack {
                        Text(isEN ? "Total Payment" :"Total Bayar").font(.system(size: 12)).foregroundColor(isDark ? .white :Color(hex: "#49454F")).frame(maxWidth: .infinity, alignment: .leading)
                        
                        Text("Rp\(totalPrice)").font(.system(size: 16)).bold().foregroundColor(isDark ? .white :Color(hex: "#49454F")).padding(.top, 2).frame(maxWidth: .infinity, alignment: .leading)
                    }.frame(maxWidth: .infinity, alignment: .leading)
                    
                    
                    if carts.contains(where: {$0.productChecked}) {
                        Button(action: {
                            goToCheckout = true
                        }, label: {
                            Text(isEN ? "Buy" :"Beli")
                                .font(.system(size: 14))
                                .foregroundColor(.white)
                                .padding()
                                .padding(.horizontal, 12)
                                .background(Color(hex: "#6750A4"))
                                .cornerRadius(25)
                        })
                    } else {
                        Button(action: {
                            goToCheckout = true
                        }, label: {
                            Text("Beli")
                                .font(.system(size: 14))
                                .foregroundColor(.white)
                                .padding()
                                .padding(.horizontal, 12)
                                .background(Color(hex: "#CAC4D0"))
                                .cornerRadius(25)
                        }).disabled(true)
                    }
                
                }.frame(maxWidth: .infinity).padding()
            }
            
            NavigationLink(destination: CheckoutScreen(), isActive: $goToCheckout) {
                EmptyView()
            }
            
        }.navigationBarBackButtonHidden().frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
    }

    
    struct ToggleQuantity: View {
        
        @AppStorage("isDark") private var isDark: Bool = false
        @AppStorage("isEN") private var isEN: Bool = false
        
        var iteration: Int
        var carts: FetchedResults<CartEntity>
        var viewContext: NSManagedObjectContext
        var deleteCartItemById: (String, String) -> Void
        
        var body: some View {
            HStack {
                HStack {
                    Text("-").foregroundColor(isDark ? .white :Color(hex: "#1D1B20")).padding(.bottom, 2).padding(.leading, 8).onTapGesture {
                        if carts[iteration].productQuantity == 1 {
                            deleteCartItemById(carts[iteration].productId!, carts[iteration].productVariant!)
                        } else {
                            do {
                                carts[iteration].productQuantity -= 1
                                try viewContext.save()
                                print("decrease cart item quantituy")
                            } catch {
                                print("failed to decrease cart item quantity")
                            }
                        }
                    }
                    Text("\(carts[iteration].productQuantity)").bold().foregroundColor(isDark  ? .white :Color(hex: "#1D1B20")).font(.system(size: 14)).padding(.horizontal, 8)
                    Text("+").foregroundColor(isDark ? .white :Color(hex: "#1D1B20")).padding(.bottom, 2).padding(.trailing, 8).onTapGesture {
                        if carts[iteration].productQuantity < carts[iteration].productStock {
                            do {
                                carts[iteration].productQuantity += 1
                                try viewContext.save()
                                print("increase cart item quantituy")
                            } catch {
                                print("failed to increase cart item quantity")
                            }
                        } else {
                            print("stock is unavailable")
                        }
                    }
                }
            }.background(RoundedRectangle(cornerRadius: 100).stroke(lineWidth: 1).foregroundColor(Color(hex: "#79747E")))
        }
    }
    
    public func deleteCartItemById(id: String, variant: String) {
        let fetchRequest: NSFetchRequest<CartEntity> = CartEntity.fetchRequest()
        // Predicate to search for both productId and productVariant
        let idPredicate = NSPredicate(format: "productId == %@", id)
        let variantPredicate = NSPredicate(format: "productVariant == %@", variant)
        fetchRequest.predicate = NSCompoundPredicate(andPredicateWithSubpredicates: [idPredicate, variantPredicate])

        do {
            let products = try viewContext.fetch(fetchRequest)
            let _ = Log.d("delete cart item: \(products)")
            guard !products.isEmpty else {
                print("No product found")
                return
            }

            for product in products {
                viewContext.delete(product)
            }

            // Save the context to persist the changes
            try viewContext.save()
            print("Product deleted successfully")
            if carts.isEmpty {
                isCheckedAll = false
                isShowAppBarChild = false
            }
            

        } catch {
            let nsError = error as NSError
            print("Unresolved error \(nsError), \(nsError.userInfo)")
        }
    }
    
    private func deleteCartItem() {
        let fetchRequest: NSFetchRequest<CartEntity> = CartEntity.fetchRequest()
        fetchRequest.predicate = NSPredicate(format: "productChecked == %d", true)

        do {
            let products = try viewContext.fetch(fetchRequest)
            let _ = Log.d("delete cart item: \(products)")
            guard !products.isEmpty else {
                print("No product found with checked true")
                return
            }

            for product in products {
                viewContext.delete(product)
            }

            // Save the context to persist the changes
            try viewContext.save()
            print("Product deleted successfully")
            isCheckedAll = false
            
            if carts.isEmpty {
                isShowAppBarChild = false
            }

        } catch {
            let nsError = error as NSError
            print("Unresolved error \(nsError), \(nsError.userInfo)")
        }
    }
 
    struct CheckBoxItemView: View {
        @Environment(\.managedObjectContext) var viewContext
        var iteration: Int
        var carts: FetchedResults<CartEntity>
        @Binding var isCheckedAll: Bool

        var body: some View {
            Image(systemName: carts[iteration].productChecked ? "checkmark.square.fill" : "square")
                .foregroundColor(carts[iteration].productChecked ? Color(hex: "#6750A4") : Color.secondary)
                .onTapGesture {
                    toggleItemCheckedState()
                    
                    // Update the isCheckedAll state based on the current state of all items
                    isCheckedAll = !carts.contains { !$0.productChecked }
                }
                .onAppear {
                
                    // Update the isCheckedAll state based on the current state of all items
                    isCheckedAll = !carts.contains { !$0.productChecked }
                }
        }
        
        private func toggleItemCheckedState() {
            do {
                self.carts[iteration].productChecked.toggle()
                try viewContext.save()
            } catch {
                print("Failed to update isChecked")
            }
            
        }
    }
    
    struct CheckBoxAllView: View {
        @Environment(\.managedObjectContext) var viewContext
        
        @Binding var checked: Bool
        var carts: FetchedResults<CartEntity>

        var body: some View {
            Image(systemName: checked ? "checkmark.square.fill" : "square")
                .foregroundColor(checked ? Color(hex: "#6750A4") : Color.secondary)
                .onTapGesture {
                    toggleAllChecked()
                }
        }
        
        private func toggleAllChecked() {
            checked.toggle()
            
            for cart in carts {
                cart.productChecked = checked
            }
            do {
                try viewContext.save()
            } catch {
                print("Failed to update isChecked")
            }
        }
    }
    
}

#Preview {
    CartScreen()
}
