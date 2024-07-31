//
//  HomeScreen.swift
//  Tokopaerbe
//
//  Created by Ikrar Khaera Arfat on 11/06/24.
//

import SwiftUI

struct HomeScreen: View {
    
    @StateObject private var settings = AppSettings()
    
    @State private var isEN = false
    @State private var isDark = false
    
    @Binding var isLogout: Bool
    
    
    var body: some View {
        NavigationView {
            VStack {
                LottieView(animationFileName: "lottie", loopMode: .loop).padding(.leading, 100).padding(.top, -200)
                
                
                VStack {
                    
                    Button(action: {
                        Log.d("button keluar")
                        UserDefaults.standard.setValue(false, forKey: "isRegistered")
                        UserDefaults.standard.setValue(true, forKey: "isAlreadyOnboarding")
                        UserDefaults.standard.setValue("", forKey: "username")
                        
                        isLogout = true
                        
                    }, label: {
                        Text("Keluar")
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
                            Toggle("", isOn: $isEN).labelsHidden().onTapGesture {
                                if isEN == true {
                                    
                                } else {
                                    
                                }
                            }
                            Spacer().overlay(Text("EN"))
                            Spacer()
                            Spacer()
                        }
                        
                        HStack {
                            Spacer()
                            Spacer().overlay(Text("Terang"))
                            Toggle("", isOn: $isDark).labelsHidden()
                            Spacer().overlay(Text("Gelap"))
                            Spacer()
                        }.padding(.top, 16)
                    }.padding(.top, 28)
                }.padding(.top, -300)
            }
        }
    }
}

#Preview {
    HomeScreen(isLogout: .constant(false))
}

