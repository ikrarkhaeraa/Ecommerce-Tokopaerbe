import SwiftUI
import UIKit



struct ProfileScreen: View {
    
    @Binding var isNewAccount: Bool
    
    var body: some View {
        
        let isRegistered = UserDefaults.standard.bool(forKey: "isRegistered")
        let username = UserDefaults.standard.string(forKey: "username") ?? ""
        
        let _ = Log.d("cek isRegistered : \(isRegistered)")
        let _ = Log.d("cek Username : \(username)")
        
        if isRegistered == false {
            LoginScreen()
        } else if isNewAccount == true || username.isEmpty || username == "" {
            ProfileActivitiy()
        } else {
            MainScreen(page: 0)
        }
    }
}


struct ProfileActivitiy: View {
    
    @AppStorage("isDark") private var isDark: Bool = false
    @AppStorage("isEN") private var isEN: Bool = false
    
    @State private var name: String = ""
    @State var alertMessage: String = ""
    @State var isLoading: Bool = false
    @State var showAlert: Bool = false
    @State private var dismissOnTapOutside: Bool = true
    @State private var isPresented: Bool = false
    @State private var selectedImage: UIImage?
    @State var navigateToHome: Bool = false
    @State var isExpired: Bool = false
    @State var isNotRegistered = false
    
    @State var showExpiredAlert: Bool = false
    @State var alertExpiredMessage: String = ""
    
    var body: some View {
        ZStack {
            VStack {
                Text("Profile")
                
                Divider()
                
                ZStack(alignment: .center) {
                    if let image = selectedImage {
                        GeometryReader { geometry in
                            let size = min(geometry.size.width, geometry.size.height)
                            ZStack(alignment: .topTrailing) {
                                Circle()
                                    .fill(Color.clear)
                                    .frame(width: size, height: size)
                                Image(uiImage : image)
                                    .resizable()
                                    .scaledToFill()
                                    .frame(width: size, height: size)
                                    .clipShape(Circle()).onAppear {
                                        Log.d("cekImage : \(selectedImage!)")
                                    }
                                Image(uiImage: UIImage(named: "close")!).scaledToFit().padding(.all,8).onTapGesture {
                                    selectedImage = nil
                                }
                            }
                        }
                            .frame(maxWidth: .infinity, maxHeight: .infinity)
                    } else {
                        Circle().fill(Color(hex: "#6750A4"))
                        Image(uiImage: UIImage(named: "person1.5x")!).scaledToFit()
                    }
                }
                .scaledToFit()
                .padding(.top, 24)
                .padding(.horizontal, 120)
                .onTapGesture {
                    print("cekKlik")
                    isPresented = true
                }
                
                
                ZStack(alignment: .leading) {
                    TextField(isEN ? "Input your name" :"Masukkan Nama Anda", text: $name)
                        .padding(24)
                        .background(RoundedRectangle(cornerRadius: 8).stroke(isDark ? .white :Color.black, lineWidth: 2))
                        .cornerRadius(10)
                        .padding()
                        .font(.system(size: 16))
                        .autocapitalization(.none)
                    
                    Rectangle().fill(isDark ? .black :Color.white).overlay(
                        Text(isEN ? "Name" : "Nama")
                            .font(.system(size: 16))
                            .foregroundColor(isDark ? .white :Color(hex: "#6750A4"))
                            .background(isDark ? .black :Color.white)
                    ).frame(width: 50, height: 16)
                        .padding(.bottom, 70)
                        .padding(.leading, 40)
                }.padding(.top, 4)
                
                
                if name.isEmpty {
                    Button(action: {}) {
                        Text(isEN ? "Done" :"Selesai")
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(Color(hex: "#CAC4D0"))
                            .cornerRadius(25)
                    }
                    .alert(isPresented: $showAlert) {
                        Alert(
                            title: Text("Error"),
                            message: Text(alertMessage),
                            primaryButton: .default(Text("OK")),
                            secondaryButton: .cancel()
                        )
                    }
                    .padding()
                    .padding(.top, -10)
                    .disabled(/*@START_MENU_TOKEN@*/true/*@END_MENU_TOKEN@*/)
                    
                } else {
                    Button(action: {
                        isLoading = true
                        
                        let token = UserDefaults.standard.string(forKey: "bearerToken")
                        let username = name
                        var profileRequest = ProfileBody(userName: "", userImage: "")

                        if selectedImage != nil {
                            profileRequest = ProfileBody(userName: username, userImage: "\(selectedImage!)")
                        } else {
                            profileRequest = ProfileBody(userName: username, userImage: nil)
                        }
                        
                        hitApi(requestBody: profileRequest, urlApi: Url.Endpoints.profile, methodApi: "POST", token: token!, type: "profile") { (success: Bool, responseObject: GeneralResponse<ProfileResponse>?) in
                            if success, let responseBackend = responseObject {
                                
                                if responseObject?.code == 200 {
                                    UserDefaults.standard.setValue(responseBackend.data?.userName, forKey: "username")
                                    
                                    DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
                                
                                        
                                        isLoading = false
                                        navigateToHome = true
                                    }
                                    
                                } else if responseObject?.code == 401 {
                                    alertExpiredMessage = responseObject!.message
                                    showExpiredAlert = true
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
                        Text(isEN ? "Done" :"Selesai")
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(Color(hex: "#6750A4"))
                            .cornerRadius(25)
                    }
                    .alert(isPresented: $showAlert) {
                        Alert(
                            title: Text("Error"),
                            message: Text(alertMessage),
                            primaryButton: .default(Text("OK")),
                            secondaryButton: .cancel()
                        )
                    }
                    .padding()
                    .padding(.top, -10)
                }

            
                
                VStack {
                    Group {
                        Text(isEN ? "By entering here, you agree " : "Dengan masuk disini, kamu menyetujui ").font(.system(size: 12)).foregroundColor(isDark ? .white : Color(hex: "#49454F")) +
                        Text(isEN ? "Terms $ Condition " : "Syarat & Ketentuan ").font(.system(size: 12)).foregroundColor(Color(hex: "#6750A4")) +
                        Text(isEN ? "and " : "serta ").font(.system(size: 12)).foregroundColor(isDark ? .white : Color(hex: "#49454F")) +
                        Text(isEN ? "Privacy Policy " : "Kebijakan Privasi ").font(.system(size: 12)).foregroundColor(Color(hex: "#6750A4")) +
                        Text("TokoPhincon.").font(.system(size: 12)).foregroundColor(isDark ? .white : Color(hex: "#49454F"))
                    }
                    .multilineTextAlignment(.center)
                }.padding(.horizontal, 20)
                
            }
            .frame(maxHeight: .infinity, alignment: .top)
            .padding(.top, 10)
            
            if isPresented {
                PopupView(isPresented: $isPresented, dismissOnTapOutside: $dismissOnTapOutside, selectedImage: $selectedImage)
            }
            
            if isLoading {
                LoadingView()
            }
            
            
            
            if isExpired {
                NavigationLink(destination: LoginScreen(), isActive: $isExpired) {
                    EmptyView()
                }
            }
            
            NavigationLink(destination: MainScreen(page: 0), isActive: $navigateToHome) {
                EmptyView()
            }
            
        }
        .navigationBarBackButtonHidden()
        .alert(isPresented: $showExpiredAlert, content: {
        Alert(
            title: Text("Error"),
            message: Text(alertExpiredMessage),
            dismissButton: .default(Text("OK"), action: {
                isExpired = true
            })
        )
    })
    }
}


struct PopupView: View {
    
    @AppStorage("isDark") private var isDark: Bool = false
    @AppStorage("isEN") private var isEN: Bool = false
    
    @Binding var isPresented: Bool
    @Binding var dismissOnTapOutside: Bool
    @Binding var selectedImage: UIImage?
    @State private var showCamera: Bool = false
    @State private var showImagePicker: Bool = false
    
    var body: some View {
        ZStack {
            Rectangle()
                .fill(Color.gray.opacity(0.7))
                .onTapGesture {
                    if dismissOnTapOutside {
                        withAnimation {
                            isPresented = false
                        }
                    }
                }

            VStack(alignment: .leading) {
                VStack(alignment: .leading) {
                    Text(isEN ? "Choose Image" :"Pilih Gambar").fontWeight(.bold).font(.system(size: 24.0)).padding(.vertical, 8)
                    Text(isEN ? "Camera" :"Kamera").padding(.top, 24).onTapGesture {
                        showCamera = true
                        Log.d("Show Camera = \(showCamera)")
                    }
                    Text(isEN ? "Gallery" :"Galeri").padding(.vertical, 16).onTapGesture {
                        showImagePicker = true
                        Log.d("Show Gallery = \(showImagePicker)")
                    }
                }.padding(.leading, 24)
                    .padding(.trailing, 200)
                    .padding(.vertical, 8)
            }
            .fixedSize()
            .background(Color.white)
            .cornerRadius(12)
            
            if showCamera || showImagePicker {
                ImagePicker(isPresented: $showCamera, isPresentedGallery: $showImagePicker, selectedImage: $selectedImage, isParentPresented: $isPresented)
            }
        }
        .ignoresSafeArea(.all)
        .frame(
            width: .infinity,
            height: .infinity,
            alignment: .center
        )
    }
}

struct ImagePicker: UIViewControllerRepresentable {
    @Binding var isPresented: Bool
    @Binding var isPresentedGallery: Bool
    @Binding var selectedImage: UIImage?
    @Binding var isParentPresented: Bool

    func makeUIViewController(context: Context) -> UIImagePickerController {
        let imagePicker = UIImagePickerController()
        if isPresented {
            imagePicker.sourceType = .camera
        } else if isPresentedGallery {
            imagePicker.sourceType = .photoLibrary
        }
        imagePicker.allowsEditing = true
        imagePicker.delegate = context.coordinator
        return imagePicker
    }

    func updateUIViewController(_ uiViewController: UIImagePickerController, context: Context) {}

    func makeCoordinator() -> Coordinator {
        return Coordinator(self)
    }

    class Coordinator: NSObject, UINavigationControllerDelegate, UIImagePickerControllerDelegate {
        var parent: ImagePicker

        init(_ parent: ImagePicker) {
            self.parent = parent
        }

        func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
            if let selectedImage = info[.originalImage] as? UIImage {
                self.parent.selectedImage = selectedImage
            }
            picker.dismiss(animated: true) {
                self.parent.isPresented = false
                self.parent.isPresentedGallery = false
                self.parent.isParentPresented = false
            }
        }

        func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
            picker.dismiss(animated: true) {
                self.parent.isPresented = false
                self.parent.isPresentedGallery = false
                self.parent.isParentPresented = false
            }
        }
    }
}

#Preview {
    ProfileActivitiy()
}
