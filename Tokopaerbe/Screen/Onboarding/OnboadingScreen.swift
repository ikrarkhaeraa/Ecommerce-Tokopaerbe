import SwiftUI

struct OnboardingScreen: View {
    
    private var numberOfImages = 3
    
    @State private var currentIndex = 0
    
    private let onboardImage = [UIImage(named: "onboard1"), UIImage(named: "onboard2"), UIImage(named: "onboard3")]
    
    @State private var goToLogin: Bool = false
    @State private var goToRegister: Bool = false
    
    var body: some View {
        
//        NavigationView {
            
            VStack {
                GeometryReader { proxy in
                    TabView(selection: $currentIndex) {
                        ForEach(0..<numberOfImages, id: \.self) { num in
                            Image(uiImage: onboardImage[num]!)
                                .resizable()
                                .scaledToFit()
                        }
                    }
                    .tabViewStyle(PageTabViewStyle())
                    .frame(width: proxy.size.width, height: proxy.size.height)
                }
                
                
                Button(action: {
                    Log.d("button gabung sekarang")
                    UserDefaults.standard.set(true, forKey: "isAlreadyOnboarding")
                    goToRegister = true
                }, label: {
                    Text("Gabung Sekarang")
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity) // Make button take maximum width available
                        .padding()
                        .background(Color(hex: "#6750A4"))
                        .cornerRadius(25)
                }).padding(20)
                
               
                HStack(spacing: 10) {
                    Spacer()

                    Text("Lewati").foregroundColor(Color(hex: "#6750A4")).fontWeight(.medium).onTapGesture {
                        let _ = Log.d("button lewati")
                        let _ = UserDefaults.standard.set(true, forKey: "isAlreadyOnboarding")
                        let _ = Log.d("cek : \(UserDefaults.standard.bool(forKey: "isAlreadyOnboarding"))")
                        goToLogin = true
                    }
                
                
                    Spacer()
                    
                    Spacer()
                    HStack(spacing: 15) {
                        ForEach(0...numberOfImages-1, id: \.self) { i in
                            if i == currentIndex {
                                Circle().foregroundColor(Color(hex: "#6750A4")).frame(width: 10,height: 10)
                            } else {
                                Circle().foregroundColor(Color(hex: "#CAC4D0")).frame(width: 10, height: 10)
                            }
                        }
                    }
                    Spacer()
                    
                    if currentIndex == 2 {
                        Text("Selanjutnya").foregroundColor(Color(hex:"#6750A4")).fontWeight(.medium).hidden()
                        Spacer()
                    } else {
                        Text("Selanjutnya").foregroundColor(Color(hex:"#6750A4")).fontWeight(.medium).onTapGesture {
                            Log.d("button selanjutnya")
                            currentIndex += 1
                        }
                        Spacer()
                    }
                    
                }
                
                NavigationLink(destination: LoginScreen(), isActive: $goToLogin) {
                    EmptyView()
                } 
                
                NavigationLink(destination: RegisterScreen(), isActive: $goToRegister) {
                    EmptyView()
                }
                
            }.navigationBarBackButtonHidden()
    }
    
    struct ContentView_Previews: PreviewProvider {
        static var previews: some View {
            OnboardingScreen()
        }
    }
    
}
