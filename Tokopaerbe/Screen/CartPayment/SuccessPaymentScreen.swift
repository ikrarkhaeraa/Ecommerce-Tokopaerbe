//
//  SuccessPaymentScreen.swift
//  Tokopaerbe
//
//  Created by Ikrar Khaera Arfat on 02/08/24.
//

import SwiftUI
import UserNotifications
import CoreData

struct SuccessPaymentScreen: View {
    
    @AppStorage("isDark") private var isDark: Bool = false
    @AppStorage("isEN") private var isEN: Bool = false
    
    @Environment(\.managedObjectContext) var viewContext
    @FetchRequest(sortDescriptors: []) private var carts: FetchedResults<CartEntity>
    
    @State private var reviewText: String = ""
    @Binding var fulfillmentResponse: FulfillmentResponse?
    @State var isStarFilled: Bool = false
    @State var starFilledArray: [Bool] = [false, false, false, false, false]
    @State var goToHomeScreen: Bool = false
    @State var isLoading: Bool = false
    @State var totalRating: Int = 0
    
    @State var isExpired: Bool = false
    @State var showExpiredAlert: Bool = false
    @State var alertExpiredMessage: String = ""
    @State var showErrorAlert: Bool = false
    @State var errorMessageAlert: String = ""
    
    var body: some View {
        
        VStack {
            HStack {
                Text("Status").frame(maxWidth: .infinity, alignment: .center).font(.system(size: 22))
            }.frame(maxWidth: .infinity, alignment: .center)
            
            Divider()
            
            VStack {
                
                ZStack {
                    
                    ZStack {
                        VStack {
                            Text(isEN ? "Payment Success" :"Pembayaran Berhasil").font(.system(size: 24)).fontWeight(.semibold).foregroundColor(isDark ? .white :Color(hex: "#6750A4")).padding(.top, 60)
                            
                            HStack{
                                ForEach(0...4, id: \.self) { i in
                                    ratingStarView(isFilled: $starFilledArray[i], starFilledArray: $starFilledArray, totalRating: $totalRating, iteration: i)
                                }
                            }.frame(maxWidth: .infinity, alignment: .center).padding(.top, 8)
                            
                            Text(isEN ? "Give a review" :"Beri ulasan").font(.system(size: 14)).fontWeight(.medium).foregroundColor(isDark ? .white :Color(hex: "#49454F")).frame(maxWidth: .infinity, alignment: .leading).padding(.horizontal).padding(.top, 32)
                            
                            TextEditor(text: $reviewText)
                                .frame(height: 100)
                                .padding(.all, 4)
                                .background(RoundedRectangle(cornerRadius: 8).stroke(isDark ? .white :Color.black, lineWidth: 2))
                                .cornerRadius(10)
                                .padding()
                                .font(.system(size: 16))
                                .autocapitalization(.none)

                            
                        }.frame(maxWidth: .infinity)
                            .background(isDark ? .black :Color.white)
                            .cornerRadius(8)
                            .padding(.top, 24)
                            .padding(.horizontal, 20)
                            .shadow(color: .gray, radius: 2, x: 0, y: 2)
                    }.frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top).padding(.top)
                    
                    ZStack {
                        Circle().fill(Color(hex: "#EADDFF")).frame(maxWidth: 64, maxHeight: 64)
                        Image(uiImage: .check)
                    }.frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
                        .padding(.top)
                }
                
                VStack {
                    Text(isEN ? "Product Detail" :"Detail Produk").font(.system(size: 14)).fontWeight(.medium).foregroundColor(isDark ? .white :Color(hex: "#49454F")).frame(maxWidth: .infinity, alignment: .leading)
                    
                    HStack {
                        Text(isEN ? "Transaction ID" :"ID Transaksi").font(.system(size: 12)).foregroundColor(isDark ? .white :Color(hex: "#49454F")).frame(maxWidth: .infinity, alignment: .leading)
                        
                        Text("\(fulfillmentResponse!.invoiceId)").font(.system(size: 12)).fontWeight(.medium)
                    }.padding(.top)
                    
                    HStack {
                        Text("Status").font(.system(size: 12)).foregroundColor(isDark ? .white :Color(hex: "#49454F")).frame(maxWidth: .infinity, alignment: .leading)
                        
                        Text("\(fulfillmentResponse!.status)").font(.system(size: 12)).fontWeight(.medium)
                    }.padding(.top, 4)
                    
                    HStack {
                        Text(isEN ? "Date" :"Tanggal").font(.system(size: 12)).foregroundColor(isDark ? .white :Color(hex: "#49454F")).frame(maxWidth: .infinity, alignment: .leading)
                        
                        Text("\(fulfillmentResponse!.date)").font(.system(size: 12)).fontWeight(.medium)
                    }.padding(.top, 4)
                    
                    HStack {
                        Text(isEN ? "Time" :"Waktu").font(.system(size: 12)).foregroundColor(isDark ? .white :Color(hex: "#49454F")).frame(maxWidth: .infinity, alignment: .leading)
                        
                        Text("\(fulfillmentResponse!.time)").font(.system(size: 12)).fontWeight(.medium)
                    }.padding(.top, 4)
                    
                    HStack {
                        Text(isEN ? "Payment Method" :"Metode Pembayaran").font(.system(size: 12)).foregroundColor(isDark ? .white :Color(hex: "#49454F")).frame(maxWidth: .infinity, alignment: .leading)
                        
                        Text("\(fulfillmentResponse!.payment)").font(.system(size: 12)).fontWeight(.medium)
                    }.padding(.top, 4)
                    
                    HStack {
                        Text(isEN ? "Total Payment" :"Total Pembayaran").font(.system(size: 12)).foregroundColor(isDark ? .white :Color(hex: "#49454F")).frame(maxWidth: .infinity, alignment: .leading)
                        
                        Text("\(fulfillmentResponse!.total)").font(.system(size: 12)).fontWeight(.medium)
                    }.padding(.top, 4)
                    
                }.frame(maxWidth:.infinity, maxHeight: .infinity, alignment: .topLeading).padding()
                
            
            }.frame(maxWidth: .infinity, maxHeight: .infinity)
            
            Divider()
            
            if isLoading {
                CircularLoadingView()
            } else {
                Button(action: {
                    postRating(fulfillmentResponse: fulfillmentResponse!)
                    isLoading = true
                }, label: {
                    Text(isEN ? "Done" :"Selesai")
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color(hex: "#6750A4"))
                        .cornerRadius(25)
                }).padding()
            }
            
            
            NavigationLink(destination: MainScreen(page: 0), isActive: $goToHomeScreen) {
                EmptyView()
            }
            
            NavigationLink(destination: LoginScreen(), isActive: $isExpired) {
                EmptyView()
            }
        
            
        }.navigationBarBackButtonHidden()
            .onAppear {
                
                //delete product bought
                deleteProduct()
                
                //add notif
                makingNotification()
                //save notif to local database
                saveNotif(id: fulfillmentResponse!.invoiceId, date: fulfillmentResponse!.date, time: fulfillmentResponse!.time)
                
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
    
    private func deleteProduct() {
        
            let fetchRequest: NSFetchRequest<CartEntity> = CartEntity.fetchRequest()
            fetchRequest.predicate = NSPredicate(format: "productChecked == true")

            do {
                let products = try viewContext.fetch(fetchRequest)
                let _ = Log.d("delete product: \(products)")
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

            } catch {
                let nsError = error as NSError
                print("Unresolved error \(nsError), \(nsError.userInfo)")
            }
        }
    
    func makingNotification() {
        let content = UNMutableNotificationContent()
        content.title = isEN ? "Transaction Success" :"Transaksi Berhasil"
        content.subtitle = isEN ? "Your transaction with ID \(fulfillmentResponse!.invoiceId) is being process by the seller, please kindly wait for the next update. While waiting, you can looking for another items." :"Transaksi anda dengan ID \(fulfillmentResponse!.invoiceId) sedang di proses oleh penjual, mohon ditunggu untuk update selanjutnya di aplikasi. Sambil menunggu, anda bisa cari barang lain terlebih dahulu"
        content.sound = UNNotificationSound.default
        
        
        // show this notification five seconds from now
        let trigger = UNTimeIntervalNotificationTrigger(timeInterval: 0.5, repeats: false)
        
        
        // choose a random identifier
        let request = UNNotificationRequest(identifier: UUID().uuidString, content: content, trigger: trigger)
        
        // add our notification request
        UNUserNotificationCenter.current().add(request)
    }
    
    func saveNotif(id: String, date: String, time: String) {
        let notif = EntityNotif(context: viewContext)
        notif.productId = id
        notif.date = date
        notif.time = time
        notif.isRead = false
        
        do {
            try viewContext.save()
            print("notif saved!")
        } catch {
            print("whoops \\(error.localizedDescription)")
        }
    }

    
    private func postRating(fulfillmentResponse: FulfillmentResponse) {

        let request = RatingBody(invoiceId: fulfillmentResponse.invoiceId, rating: totalRating, review: reviewText)
        
        hitApi(requestBody: request, urlApi: Url.Endpoints.rating, methodApi: "POST", token: UserDefaults().string(forKey: "bearerToken")!, type: "rating", completion: { (success: Bool, responseObject: GeneralResponse<RatingResponse>?) in
            if success, let responseBackend = responseObject {
                
                if responseObject?.code == 200 {
                    isLoading = false
                    goToHomeScreen = true
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
    SuccessPaymentScreen(fulfillmentResponse: .constant(FulfillmentResponse(invoiceId: "", status: true, date: "", time: "", payment: "", total: 0)))
}

struct ratingStarView: View {
    
    @Binding var isFilled: Bool
    @Binding var starFilledArray: [Bool]
    @Binding var totalRating: Int
    var iteration: Int
    
    var body: some View {
        Image(systemName: "star.fill").font(.system(size: 30)).foregroundColor(isFilled ? Color.yellow : Color(hex: "#49454F")).onTapGesture {
            
            for i in 0...4 {
                if i == iteration {
                    isFilled = true
                    for i in 0...iteration {
                        starFilledArray[i] = true
                    }
                    if i < 4 {
                        for i in iteration+1...4 {
                            starFilledArray[i] = false
                        }
                    }
                }
            }
            
            for i in 0...4 {
                if starFilledArray[i] == true {
                    totalRating += 1
                }
            }
        }
    }
}
