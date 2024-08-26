//
//  NotificationScreen.swift
//  Tokopaerbe
//
//  Created by Ikrar Khaera Arfat on 06/08/24.
//

import SwiftUI

struct NotificationScreen: View {
    
    @AppStorage("isDark") private var isDark: Bool = false
    @AppStorage("isEN") private var isEN: Bool = false
    
    @Environment(\.presentationMode) var presentationMode
    @FetchRequest(sortDescriptors: []) private var notifications: FetchedResults<EntityNotif>
    @Environment(\.managedObjectContext) var viewContext
    
    var body: some View {
            
            VStack {
                
                HStack {
                    Image(uiImage: .arrowleft)
                        .renderingMode(isDark ? .template : .original)
                        .foregroundColor(isDark ? .white : nil)
                        .padding().onTapGesture {
                        self.presentationMode.wrappedValue.dismiss()
                    }
                    
                    Text(isEN ? "Notifications" :"Notifikasi").frame(maxWidth: .infinity, alignment: .leading).font(.system(size: 22))
                    
                }.frame(maxWidth: .infinity, alignment: .leading)
                
                Divider()
                
                if !notifications.isEmpty {
                    ScrollView {
                        ForEach(notifications.indices, id: \.self) { i in
                            HStack {
                                
                                VStack {
                                    Image(uiImage: .imageThumbnail).frame(maxWidth: 40, maxHeight: 40)
                                }.frame(maxHeight: .infinity, alignment: .top).padding()
                               
                                
                                VStack {
                                    
                                    HStack {
                                        Text("Info").font(.system(size: 12)).foregroundColor(isDark ? .white :Color(hex: "#49454F")).frame(maxWidth: .infinity, alignment: .leading)
                                        
                                        Text("\(notifications[i].date!), \(notifications[i].time!)").font(.system(size: 12)).foregroundColor(isDark ? .white :Color(hex: "#49454F"))
                                    }.padding(.top).padding(.trailing)
                                    
                                    Text(isEN ? "Transaction Success" :"Tansaksi Berhasil").font(.system(size: 14))
                                        .foregroundColor(isDark ? .white :Color(hex: "#49454F"))
                                        .fontWeight(.bold)
                                        .frame(maxWidth: .infinity, alignment: .leading)
                                        .padding(.top, -2)
                                    
                                    Text(isEN ? "Your transaction with ID \(notifications[i].productId!) is being process by the seller, please kindly wait for the next update. While waiting, you can looking for another items." :"Transaksi anda dengan ID \(notifications[i].productId!) sedang di proses oleh penjual, mohon ditunggu untuk update selanjutnya di aplikasi. Sambil menunggu, anda bisa cari barang lain terlebih dahulu").font(.system(size: 12)).foregroundColor(isDark ? .white :Color(hex: "#49454F")).frame(maxWidth: .infinity, alignment: .leading).padding(.trailing).padding(.top, -2)
                                    
                                    Divider()
                                }.frame(maxWidth: .infinity, alignment: .leading)
                                
                            }
                            .background(notifications[i].isRead ? isDark ? .black :Color.white : isDark ? Color(hex: "#6750A4") :Color(hex: "#EADDFF"))
                            .padding(.bottom, -8)
                            .frame(maxWidth: .infinity)
                            .onTapGesture {
                                
                                notifications[i].isRead = true
                                do {
                                    try viewContext.save()
                                } catch {
                                    print("Failed to update isChecked")
                                }
                                
                            }
                        }
                    }.frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
                        .padding(.top, -8)
//                        .ignoresSafeArea()
                    
                } else {
                    VStack {
                        Image(uiImage: UIImage.errorState)
                        Text("Empty").font(.system(size: 32)).bold().padding(.bottom, 2)
                        Text("Your requested data is unavailable").font(.system(size: 16)).foregroundColor(isDark ? .white :Color(hex: "#1D1B20"))
                    }.frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .center)
                }
                
            }.frame(maxWidth: .infinity, maxHeight: .infinity).navigationBarBackButtonHidden()
    }
}

#Preview {
    NotificationScreen()
}
