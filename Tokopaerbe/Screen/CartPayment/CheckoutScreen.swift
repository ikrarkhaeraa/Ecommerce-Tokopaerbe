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
    @Environment(\.managedObjectContext) var viewContext
    @State var isChoosePaymentMethod: Bool = false
    @State private var appBarViewSize: CGSize = .zero
    @State private var scrollViewSize: CGSize = .zero
    @State private var pembayaranView: CGSize = .zero
    @State private var totalBayarView: CGSize = .zero
    @State private var goToPayment: Bool = false
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
                .frame(maxHeight: calculateScrollViewHeight(proxy: proxy))

                
                VStack {
                    Rectangle().foregroundColor(Color(hex: "#D9D9D9")).frame(maxWidth: .infinity, maxHeight: 4)
                    
                    Text("Pembayaran").font(.system(size: 16)).fontWeight(.medium).foregroundColor(Color(hex: "#49454F")).frame(maxWidth: .infinity, alignment: .leading).padding()
                    
                    HStack {
                        HStack {
                            Image(uiImage: .addCard)
                            Text("Pilih Pembayaran").font(.system(size: 14)).foregroundColor(Color(hex: "#49454F")).frame(maxWidth: .infinity, alignment: .leading).padding(.leading, 4)
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
                            
                            Text("Rp\(totalPrice)").font(.system(size: 16)).bold().foregroundColor(Color(hex: "#49454F")).padding(.top, 2).frame(maxWidth: .infinity, alignment: .leading)
                        }.frame(maxWidth: .infinity, alignment: .leading)
                        
                        if isChoosePaymentMethod {
                            Button(action: {
                                
                            }, label: {
                                Text("Bayar")
                                    .font(.system(size: 14))
                                    .foregroundColor(.white)
                                    .padding()
                                    .padding(.horizontal, 12)
                                    .background(Color(hex: "#6750A4"))
                                    .cornerRadius(25)
                            })
                        } else {
                            Button(action: {
                                
                            }, label: {
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
                
                NavigationLink(destination: PaymentScreen(), isActive: $goToPayment) {
                    EmptyView()
                }
                
            }.navigationBarBackButtonHidden()
        }
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

    
    struct ToggleQuantity: View {
        
        var iteration: Int
        var checkoutCarts: FetchedResults<CartEntity>
        var viewContext: NSManagedObjectContext
        var deleteCartItemById: (String, String) -> Void
        
        var body: some View {
            HStack {
                HStack {
                    Text("-").foregroundColor(Color(hex: "#1D1B20")).padding(.bottom, 2).padding(.leading, 8).onTapGesture {
                        if checkoutCarts[iteration].productQuantity == 1 {
                            deleteCartItemById(checkoutCarts[iteration].productId!, checkoutCarts[iteration].productVariant!)
                        } else {
                            do {
                                checkoutCarts[iteration].productQuantity -= 1
                                try viewContext.save()
                                print("decrease cart item quantituy")
                            } catch {
                                print("failed to decrease cart item quantity")
                            }
                        }
                    }
                    Text("\(checkoutCarts[iteration].productQuantity)").bold().foregroundColor(Color(hex: "#1D1B20")).font(.system(size: 14)).padding(.horizontal, 8)
                    Text("+").foregroundColor(Color(hex: "#1D1B20")).padding(.bottom, 2).padding(.trailing, 8).onTapGesture {
                        if checkoutCarts[iteration].productQuantity < checkoutCarts[iteration].productStock {
                            do {
                                checkoutCarts[iteration].productQuantity += 1
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
            

        } catch {
            let nsError = error as NSError
            print("Unresolved error \(nsError), \(nsError.userInfo)")
        }
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
