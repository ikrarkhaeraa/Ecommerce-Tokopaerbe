import SwiftUI

struct ContentView: View {
    
    private var numberOfImages = 3
    
    @State private var currentIndex = 0
    
    private let onboardImage = [UIImage(named: "onboard1"), UIImage(named: "onboard2"), UIImage(named: "onboard3")]
    
    var body: some View {
        
        VStack {
            //            ZStack(alignment: .bottom, content: {
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
                // Button action here
            }, label: {
                Text("Gabung Sekarang")
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity) // Make button take maximum width available
                    .padding()
                    .background(Color(hex: "#6750A4"))
                    .cornerRadius(25) // Set corner radius
            })
            .padding(20)
            
//            VStack {
                HStack(spacing: 10) {
                    Spacer()
                    Text("Lewati").foregroundColor(Color(hex: "#6750A4")).fontWeight(.medium)
                    Spacer()
                    
                    Spacer()
                    HStack(spacing: 15) {
                        ForEach(0...numberOfImages-1, id: \.self) { i in
                            if i == currentIndex {
                                Circle().foregroundColor(Color(hex: "#6750A4")).frame(width: 10,height: 10)
                            } else {
                                Circle().foregroundColor(.black).frame(width: 10, height: 10)
                            }
                        }
                    }
                    Spacer()
                    
                    if currentIndex != 0 {
                        Spacer()
                    } else {
                        Text("Sebelumnya").foregroundColor(Color(hex: "#6750A4")).fontWeight(.medium)
                        Spacer()
                    }
                    
                }
                //            })
//            }
        }
    }
        
        struct ContentView_Previews: PreviewProvider {
            static var previews: some View {
                ContentView()
            }
        }
        
    }
