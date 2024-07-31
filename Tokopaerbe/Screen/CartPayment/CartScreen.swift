//
//  CartScreen.swift
//  Tokopaerbe
//
//  Created by Ikrar Khaera Arfat on 26/07/24.
//

import SwiftUI
import CoreData

struct CartScreen: View {
    
    @Environment(\.presentationMode) var presentationMode
    
    @FetchRequest(sortDescriptors: []) private var carts: FetchedResults<CartEntity>
    @Environment(\.managedObjectContext) var viewContext
    
    @State var isCheckedAll: Bool = false
    @State var isShowAppBarChild: Bool = false
    
    var body: some View {
        VStack {
            HStack {
                Image(uiImage: .arrowleft).padding().onTapGesture {
                    self.presentationMode.wrappedValue.dismiss()
                }
                
                Text("Checkout").frame(maxWidth: .infinity, alignment: .leading).font(.system(size: 22))
                
            }.frame(maxWidth: .infinity, alignment: .leading).onAppear {
                if !carts.isEmpty {
                    isShowAppBarChild = true
                } else {
                    isShowAppBarChild = false
                }
            }
            Divider()
            
            if isShowAppBarChild {
                HStack {
                    CheckBoxAllView(checked: $isCheckedAll, carts: carts)
                    Text("Pilih Semua").font(.system(size: 14)).foregroundColor(Color(hex: "#49454F")).frame(maxWidth: .infinity, alignment: .leading).padding(.leading, 4)
                    Text("Hapus").font(.system(size: 14)).bold().foregroundColor(Color(hex: "#6750A4")).onTapGesture {
                        deleteCartItem()
                    }
                }.frame(maxWidth: .infinity, alignment: .leading).padding()
                
                Divider()
            }
            
            ForEach(carts.indices, id: \.self) { i in
                
                HStack {

                    CheckBoxItemView(iteration: i, carts: carts, isCheckedAll: $isCheckedAll)
                    
                    ImageLoader(contentMode: .constant("fit"), urlString: carts[i].productImage!).frame(maxWidth: 80, maxHeight: 80).background(RoundedRectangle(cornerRadius: 8).foregroundColor(.white))
                    
                    VStack {
                        Text("\(carts[i].productName!)").font(.system(size: 14)).bold().foregroundColor(Color(hex: "#49454F"))
                            .lineLimit(1)
                            .truncationMode(.tail)
                            .fixedSize(horizontal: false, vertical: true)
                            .frame(maxWidth: .infinity, alignment: .leading)
                        
                        Text("\(carts[i].productVariant!)").font(.system(size: 10)).foregroundColor(Color(hex: "#49454F"))
                            .frame(maxWidth: .infinity, alignment: .leading)
                        
                        Text("Stok \(carts[i].productStock)").font(.system(size: 10)).foregroundColor(Color(hex: "#49454F"))
                            .frame(maxWidth: .infinity, alignment: .leading)
                        
                        HStack {
                            Text("Stok \(carts[i].productPrice)").font(.system(size: 14)).bold().foregroundColor(Color(hex: "#49454F"))
                                .frame(maxWidth: .infinity, alignment: .leading).padding(.top, 8)
                            
                            Image(uiImage: .delete20PxBlack).padding(.top, 4).onTapGesture {
                                deleteCartItemById(id: carts[i].productId!, variant: carts[i].productVariant!)
                            }
                            
                            ToggleQuantity(iteration: i, carts: carts).padding(.top, 4)
                            
                        }.frame(maxWidth: .infinity)
                        
                        
                    }.padding(.horizontal, 2).frame(maxWidth: .infinity, alignment: .leading)
                    
                }.padding()
                
                Divider()
            }
            
        }.navigationBarBackButtonHidden().frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
    }
    
    struct ToggleQuantity: View {
        
        var iteration: Int
        var carts: FetchedResults<CartEntity>
        
        var body: some View {
            HStack {
                HStack {
                    Text("-").foregroundColor(Color(hex: "#1D1B20")).padding(.bottom, 2).padding(.leading, 8)
                    Text("\(carts[iteration].productQuantity)").bold().foregroundColor(Color(hex: "#1D1B20")).font(.system(size: 14)).padding(.horizontal, 8)
                    Text("+").foregroundColor(Color(hex: "#1D1B20")).padding(.bottom, 2).padding(.trailing, 8)
                }
            }.background(RoundedRectangle(cornerRadius: 100).stroke(lineWidth: 1).foregroundColor(Color(hex: "#79747E")))
        }
    }
    
    private func deleteCartItemById(id: String, variant: String) {
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
