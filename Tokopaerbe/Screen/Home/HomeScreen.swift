//
//  HomeScreen.swift
//  Tokopaerbe
//
//  Created by Ikrar Khaera Arfat on 11/06/24.
//

import SwiftUI

struct HomeScreen: View {
    
    @StateObject private var settings = AppSettings()
    
    @AppStorage("isDark") private var isDark: Bool = false
    @AppStorage("isEN") private var isEN: Bool = false
    
    @Binding var isLogout: Bool
    
    
    var body: some View {
        NavigationView {
            GeometryReader { proxy in
                ZStack {
                    
                    LottieView(animationFileName: "lottie", loopMode: .loop).frame(maxWidth: .infinity).padding(.horizontal, 50).padding(.top, -200)
                    
                    VStack {
                        Button(action: {
                            UserDefaults.standard.setValue(false, forKey: "isRegistered")
                            UserDefaults.standard.setValue(true, forKey: "isAlreadyOnboarding")
                            UserDefaults.standard.setValue("", forKey: "username")
                            
                            isLogout = true
                            
                        }, label: {
                            Text(isEN ? "Logout" : "Keluar")
                                .foregroundColor(.white)
                                .padding(.horizontal, 16)
                                .padding()
                                .background(Color(hex: "#6750A4"))
                                .cornerRadius(25)
                        })
                        
                        VStack {
                            HStack {
                                Spacer()
                                Spacer()
                                Spacer().overlay(Text("ID"))
                                Toggle("", isOn: $isEN).labelsHidden()
                                Spacer().overlay(Text("EN"))
                                Spacer()
                                Spacer()
                            }
                            
                            HStack {
                                Spacer()
                                Spacer().overlay(Text(isEN ? "Light" :"Terang"))
                                Toggle("", isOn: $isDark).labelsHidden()
                                Spacer().overlay(Text(isEN ? "Dark" :"Gelap"))
                                Spacer()
                            }.padding(.top, 16)
                        }.padding(.top, 28)
                    }.padding(.bottom, -200)
                    
                    
                    if isDark {
                        let _ = UserDefaults().set(true, forKey: "isDark")
                        
                    } else {
                        let _ = UserDefaults().set(false, forKey: "isDark")
                    }
                    
                    if isEN {
                        let _ = UserDefaults().set(true, forKey: "isEN")
                        
                    } else {
                        let _ = UserDefaults().set(false, forKey: "isEN")
                    }
                    
                }.frame(maxWidth: .infinity, maxHeight: .infinity)
            }
        }
    }
}

#Preview {
    HomeScreen(isLogout: .constant(false))
}

