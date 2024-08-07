//
//  RegisterScreen.swift
//  Tokopaerbe
//
//  Created by Ikrar Khaera Arfat on 01/06/24.
//

import SwiftUI
import LocalAuthentication


struct LoginScreen: View {
    
    var body: some View {
        let isAlreadyOnboarding = UserDefaults.standard.bool(forKey: "isAlreadyOnboarding")
        
        let _ = Log.d("cekState : \(isAlreadyOnboarding)")
        
        if isAlreadyOnboarding == false {
            OnboardingScreen()
        } else {
            LoginActivity()
        }
    }
}

struct LoginActivity: View {
    
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
    
    @State var isNewAccount: Bool = false
    @State var navigateToProfile: Bool = false
    @State var goToRegister: Bool = false
    @State var showAlert: Bool = false
    @State var isLoading: Bool = false
    @State var isNotOnboardingYet = false
    @State var alertMessage: String = ""
    
    @State var keyboardHeight: CGFloat = 0
    

    var body: some View {

            ZStack {
                
                VStack {
                    Text(isEN ? "Login" : "Masuk").font(.system(size: 24))
                    
                    Divider()
                    
                    VStack(alignment: .leading) {
                        VStack(alignment: .leading) {
                            
                            Text("Email")
                                .font(.system(size: 16))
                                .foregroundColor(isDark ? .white : TitleTFEmail)
                                .background(isDark ? Color.black :Color.white)
                            
                            TextField(isEN ? "Input your Email" : "Masukkan Email Anda", text: $email)
                                .padding(.all, 24)
                                .background(RoundedRectangle(cornerRadius:8).stroke(isDark ? .white :TFborderColorEmail,lineWidth:2))
                                .cornerRadius(10)
    //                            .padding()
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
                                .foregroundColor(isDark ? .white : TitleTFPass)
                                .background(isDark ? .black : Color.white)
                            
                            SecureField(isEN ? "Input your password" : "Masukkan Password Anda", text: $password)
                                .padding(.all, 24)
                                .background(RoundedRectangle(cornerRadius:8).stroke(TFborderColorPass,lineWidth:2))
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
                            Text(isEN ? "Login" : "Masuk")
                                .foregroundColor(.white)
                                .frame(maxWidth: .infinity) // Make button take maximum width available
                                .padding()
                                .background(Color(hex: "#CAC4D0"))
                                .cornerRadius(25) // Set corner radius
                                .disabled(/*@START_MENU_TOKEN@*/true/*@END_MENU_TOKEN@*/)
                        }).padding().padding(.top, -10).disabled(true)
               
                    } else {
                        
                        Button(action: {
                            
                            isLoading = true
                            
                            let loginData = LoginBody(email: email, password: password, firebaseToken: "")
                            
                            hitApi(requestBody: loginData, urlApi: Url.Endpoints.login, methodApi: "POST", token: "", type: "login") { (success: Bool, responseObject: GeneralResponse<LoginResponse>?) in
                                if success, let responseBackend = responseObject {
                                    
                                    if responseObject?.code == 200 {
                                        
                                        UserDefaults.standard.setValue(responseBackend.data?.accessToken, forKey: "bearerToken")
                                        UserDefaults.standard.setValue(responseBackend.data?.refreshToken, forKey: "refreshToken")
                                        UserDefaults.standard.setValue(responseBackend.data?.expiresAt, forKey: "expiresAt")
                                        
                                        UserDefaults.standard.setValue(true, forKey: "isRegistered")
                                        UserDefaults.standard.setValue(responseBackend.data?.userName, forKey: "username")
                                        
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
                                    alertMessage = isEN ? "Server cannot handle your request" : "Server tidak dapat melayani permintaan anda"
                                }
                            }
                                            
                            
                        }) {
                            
                            Text(isEN ? "Login" : "Masuk")
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
                                secondaryButton: .cancel(Text("Cancel"))
                            )
                        })
                        .padding()
                        .padding(.top, -10)
                    }
                    
                    ZStack {
                        Divider()
                        Rectangle().fill(isDark ? .black : Color.white).overlay(
                            Text(isEN ? "or register with" :"atau daftar dengan")
                                .font(.system(size: 16))
                                .foregroundColor(isDark ? .white : Color(hex: "#6750A4"))
                                .background(isDark ? .black : Color.white)
                        ).frame(width: 180, height: 16)
                    }.padding(.horizontal, 20).onTapGesture {
                        faceIdAuthentication()
                    }
                    
                    Button(action: {
                        goToRegister = true
                    }, label: {
                        Text(isEN ? "Register" :"Daftar")
                            .foregroundColor(isDark ? .white : Color(hex: "#6750A4"))
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(RoundedRectangle(cornerRadius:25).stroke(Color.gray,lineWidth:2))
                            .cornerRadius(25) // Set corner radius
                    }).padding()
                    

                    VStack {
                        Group {
                            Text(isEN ? "By entering here, you agree " : "Dengan masuk disini, kamu menyetujui ").font(.system(size: 12)).foregroundColor(isDark ? .white : Color(hex: "#49454F")) +
                            Text(isEN ? "Terms $ Condition " : "Syarat & Ketentuan ").font(.system(size: 12)).foregroundColor(Color(hex: "#6750A4")) +
                            Text(isEN ? "and " : "serta ").font(.system(size: 12)).foregroundColor(isDark ? .white : Color(hex: "#49454F")) +
                            Text(isEN ? "Privacy Policy " : "Kebijakan Privasi ").font(.system(size: 12)).foregroundColor(Color(hex: "#6750A4")) +
                            Text("TokoPhincon.").font(.system(size: 12)).foregroundColor(isDark ? .white : Color(hex: "#49454F"))
                        }
                        .multilineTextAlignment(.center)
                        
//                            TextField("Masukkan Email Anda", text: $email)
//                                .padding(.all, 24)
//                                .background(RoundedRectangle(cornerRadius:8).stroke(TFborderColorEmail,lineWidth:2))
//                                .cornerRadius(10)
//        //                            .padding()
//                                .font(.system(size: 16))
//                                .autocapitalization(.none)
//    
//                            TextField("Masukkan Email Anda", text: $email)
//                                .padding(.all, 24)
//                                .background(RoundedRectangle(cornerRadius:8).stroke(TFborderColorEmail,lineWidth:2))
//                                .cornerRadius(10)
//        //                            .padding()
//                                .font(.system(size: 16))
//                                .autocapitalization(.none)


                        
                    }.padding(.horizontal, 20)
                    
                }.frame(maxHeight: .infinity, alignment: .top).padding(.top, 10).navigationBarBackButtonHidden()
                
                if isLoading {
                    LoadingView()
                }
                
                NavigationLink(destination: ProfileScreen(isNewAccount: $isNewAccount), isActive: $navigateToProfile) {
                    EmptyView()
                }
                
                NavigationLink(destination: RegisterScreen(), isActive: $goToRegister) {
                    EmptyView()
                }
            
            }
//            .keyboardHeight($keyboardHeight)
//            .animation(.easeOut(duration: 0.16))
//            .offset(y: -keyboardHeight / 2)

    }
    
    
    func faceIdAuthentication(){
            let context = LAContext()
            var error: NSError?
            
            if context.canEvaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, error: &error){
                let reason = "Authenticate to access the app"
                context.evaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, localizedReason: reason){ success, authenticationError in
                    if success{
                        print("successed")
                    }else{
                        print("failed")
                    }
                }
            }else{
                // Device does not support Face ID or Touch ID
                print("Biometric authentication unavailable")
            }
        }
    
}

#Preview {
    LoginActivity()
}

struct KeyboardProvider: ViewModifier {
    
    var keyboardHeight: Binding<CGFloat>
    
    func body(content: Content) -> some View {
        content
            .onReceive(NotificationCenter.default.publisher(for: UIResponder.keyboardWillShowNotification),
                       perform: { notification in
                guard let userInfo = notification.userInfo,
                      let keyboardRect = userInfo[UIResponder.keyboardFrameEndUserInfoKey] as? CGRect else { return }
                                                            
                self.keyboardHeight.wrappedValue = keyboardRect.height
                
            }).onReceive(NotificationCenter.default.publisher(for: UIResponder.keyboardWillHideNotification),
                         perform: { _ in
                self.keyboardHeight.wrappedValue = 0
            })
    }
}


public extension View {
    func keyboardHeight(_ state: Binding<CGFloat>) -> some View {
        self.modifier(KeyboardProvider(keyboardHeight: state))
    }
}
