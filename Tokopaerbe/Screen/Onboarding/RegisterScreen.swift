//
//  RegisterScreen.swift
//  Tokopaerbe
//
//  Created by Ikrar Khaera Arfat on 01/06/24.
//

import SwiftUI

struct RegisterScreen: View {
    
    @AppStorage("isDark") private var isDark: Bool = false
    @AppStorage("isEN") private var isEN: Bool = false
    
    @State private var email: String = ""
    @State private var password: String = ""
    @State private var TFborderColorEmail: Color = Color(hex: "#49454F")
    @State private var TFborderColorPass: Color = Color(hex: "#49454F")
    @State private var TitleTFEmail: Color = Color(hex: "#6750A4")
    @State private var TitleTFPass: Color = Color(hex: "#6750A4")
    @State private var emailHelperString: String = "Contoh : test@gmail.com"
    @State private var passHelperString: String = "Minimal 8 karakter"
    @State private var emailHelperColorText: Color = Color(hex: "#49454F")
    @State private var passHelperColorText: Color = Color(hex: "#49454F")
    
    @State var navigateToProfile: Bool = false
    @State var goToLogin: Bool = false
    @State var showAlert: Bool = false
    @State var isLoading: Bool = false
    @State var isNewAccount: Bool = true
    
    @State var alertMessage: String = ""
    
    var body: some View {
        
        ZStack {
            
            VStack {
                Text(isEN ? "Register" :"Daftar").font(.system(size: 24))
                
                Divider()
                
                VStack(alignment: .leading) {
                    VStack(alignment: .leading) {
                        
                        Text("Email")
                            .font(.system(size: 16))
                            .foregroundColor(isDark ? .white :TitleTFEmail)
                            .background(isDark ? .black : Color.white)
                        
                        TextField(isEN ? "Input your email" : "Masukkan Email Anda", text: $email)
                            .padding(.all, 24)
                            .background(RoundedRectangle(cornerRadius:8).stroke(isDark ? .white :TFborderColorEmail,lineWidth:2))
                            .cornerRadius(10)
                            .font(.system(size: 16))
                            .autocapitalization(.none)
                            .onReceive(email.publisher.collect()) { _ in
                                if email.isEmpty {
                                    TFborderColorEmail = isDark ? .white : Color(hex: "#49454F")
                                    TitleTFEmail =  isDark ? .white : Color(hex: "#6750A4")
                                    emailHelperString = isEN ? "Example : test@gmail.com" : "Contoh : test@gmail.com"
                                    emailHelperColorText = isDark ? .white : Color(hex: "#49454F")
                                } else if !isValidEmail(email: email) {
                                    TFborderColorEmail = Color.red
                                    TitleTFEmail = Color.red
                                    emailHelperString = isEN ? "Email is not valid" : "Email tidak valid"
                                    emailHelperColorText = Color.red
                                } else {
                                    TFborderColorEmail = Color(hex: "#49454F")
                                    TitleTFEmail =  isDark ? .white : Color(hex: "#6750A4")
                                    emailHelperString = isEN ? "Example : test@gmail.com" : "Contoh : test@gmail.com"
                                    emailHelperColorText = isDark ? .white : Color(hex: "#49454F")
                                }
                            }
                        
                        Text(emailHelperString).font(.system(size: 14)).foregroundColor(emailHelperColorText).padding(.top, 8)
                        
                    }.padding()
                    
                    VStack(alignment: .leading) {
                        
                        Text("Password")
                            .font(.system(size: 16))
                            .foregroundColor(isDark ? .white :TitleTFEmail)
                            .background(isDark ? .black : Color.white)
                        
                        SecureField(isEN ? "Input your password" :"Masukkan Password Anda", text: $password)
                            .padding(.all, 24)
                            .background(RoundedRectangle(cornerRadius:8).stroke(isDark ? .white :TFborderColorPass,lineWidth:2))
                            .cornerRadius(10)
                            .font(.system(size: 16))
                            .autocapitalization(.none)
                            .onReceive(password.publisher.collect()) {_ in
                                if password.isEmpty {
                                    TFborderColorPass = isDark ? .white : Color(hex: "#49454F")
                                    TitleTFPass = isDark ? .white : Color(hex: "#6750A4")
                                    passHelperString = isEN ? "At least 8 characters" : "Minimal 8 karakter"
                                    passHelperColorText = isDark ? .white : Color(hex: "#49454F")
                                } else if password.count < 8 {
                                    TFborderColorPass = Color.red
                                    TitleTFPass = Color.red
                                    passHelperString = isEN ? "Password is not valid (At least 8 characters)" : "Password Tidak valid (Minimal 8 karakter)"
                                    passHelperColorText = Color.red
                                } else {
                                    TFborderColorPass = isDark ? .white : Color(hex: "#49454F")
                                    TitleTFPass = isDark ? .white : Color(hex: "#6750A4")
                                    passHelperString = isEN ? "At least 8 character" : "Minimal 8 karakter"
                                    passHelperColorText = isDark ? .white : Color(hex: "#49454F")
                                }
                            }
                        
                        Text(passHelperString).font(.system(size: 14)).foregroundColor(passHelperColorText).padding(.top, 8)
                        
                    }.padding().padding(.top, -16)
            
                }
                
                if TFborderColorPass == Color.red || TFborderColorEmail == Color.red || email.isEmpty || password.isEmpty {
                    
                    Button(action: /*@START_MENU_TOKEN@*/{}/*@END_MENU_TOKEN@*/, label: {
                        Text(isEN ? "Register" :"Daftar")
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(Color(hex: "#CAC4D0"))
                            .cornerRadius(25) // Set corner radius
                            .disabled(/*@START_MENU_TOKEN@*/true/*@END_MENU_TOKEN@*/)
                    }).padding().padding(.top, -10).disabled(true)
                    
                } else {
                    
                    Button(action: {
                        
                        isLoading = true
                        
                        let registerData = RegisterBody(email: email, password: password, firebaseToken: "")
                        
                        hitApi(requestBody: registerData, urlApi: Url.Endpoints.register, methodApi: "POST", token: "", type: "register") { (success: Bool, responseObject: GeneralResponse<RegisterResponse>?) in
                            if success, let responseBackend = responseObject {
                                
                                if responseObject?.code == 200 {
                                    UserDefaults.standard.setValue(responseBackend.data?.accessToken, forKey: "bearerToken")
                                    UserDefaults.standard.setValue(responseBackend.data?.refreshToken, forKey: "refreshToken")
                                    UserDefaults.standard.setValue(responseBackend.data?.expiresAt, forKey: "expiresAt")
                                    
                                    UserDefaults.standard.setValue(true, forKey: "isRegistered")
                                    Log.d("\(UserDefaults.standard.bool(forKey: "isRegistered"))")
                                    
                                    isLoading = false
                                    navigateToProfile = true
                                } else {
                                    isLoading = false
                                    showAlert = true
                                    alertMessage = responseObject!.message
                                }
                                
                            } else {
                                isLoading = false
                                showAlert = true
                                alertMessage = isEN ? "Server cannot handle your request" :"Server tidak dapat melayani permintaan anda"
                            }
                        }
                        
                    }) {
                        
                        Text(isEN ? "Register" :"Daftar")
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(Color(hex: "#6750A4"))
                            .cornerRadius(25)
                        
                    }.alert(isPresented: $showAlert, content: {
                        Alert(
                            title: Text("Error"),
                            message: Text(alertMessage),
                            primaryButton: .default(Text("OK")),
                            secondaryButton: .cancel()
                        )
                    })
                    .padding()
                    .padding(.top, -10)
                }
    
                
                ZStack {
                    Divider()
                    Rectangle().fill(isDark ? .black :Color.white).overlay(
                        Text(isEN ? "or login with" :"atau masuk dengan")
                            .font(.system(size: 16))
                            .foregroundColor(isDark ? .white :Color(hex: "#6750A4"))
                            .background(isDark ? .black :Color.white)
                    ).frame(width: 180, height: 16)
                }.padding(.horizontal, 20).padding(.bottom)
                
                Button(action: {
                    goToLogin = true
                }, label: {
                    Text(isEN ? "Login" :"Masuk")
                        .foregroundColor(isDark ? .white :Color(hex: "#6750A4"))
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(RoundedRectangle(cornerRadius:25).stroke(Color.gray,lineWidth:2))
                        .cornerRadius(25) // Set corner radius
                }).padding(.horizontal, 20)

                VStack {
                    Group {
                        Text(isEN ? "By entering here, you agree " : "Dengan masuk disini, kamu menyetujui ").font(.system(size: 12)).foregroundColor(isDark ? .white : Color(hex: "#49454F")) +
                        Text(isEN ? "Terms $ Condition " : "Syarat & Ketentuan ").font(.system(size: 12)).foregroundColor(Color(hex: "#6750A4")) +
                        Text(isEN ? "and " : "serta ").font(.system(size: 12)).foregroundColor(isDark ? .white : Color(hex: "#49454F")) +
                        Text(isEN ? "Privacy Policy " : "Kebijakan Privasi ").font(.system(size: 12)).foregroundColor(Color(hex: "#6750A4")) +
                        Text("TokoPhincon.").font(.system(size: 12)).foregroundColor(isDark ? .white : Color(hex: "#49454F"))
                    }
                    .multilineTextAlignment(.center)
                }.padding(.horizontal, 20).padding(.top)
                
            }.frame(maxHeight: .infinity, alignment: .top).padding(.top, 10).navigationBarBackButtonHidden()
            
            if isLoading {
                LoadingView()
            }
            
            NavigationLink(destination: ProfileScreen(isNewAccount: $isNewAccount), isActive: $navigateToProfile) {
                EmptyView()
            }
            
            NavigationLink(destination: LoginScreen(), isActive: $goToLogin) {
                EmptyView()
            }
            
        }
    }
    
}

#Preview {
    RegisterScreen()
}
