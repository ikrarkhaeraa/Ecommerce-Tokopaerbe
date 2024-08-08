import SwiftUI

struct SearchBar: View {
    
    @Binding var text: String
    @Binding var temp: String
    @Binding var temp2: String
    @State private var isEditing = false
    
    @AppStorage("isDark") private var isDark: Bool = false
    @AppStorage("isEN") private var isEN: Bool = false
    
    var body: some View {
        HStack {
            
            HStack {
                Image(uiImage: UIImage.searchIcon)
                    .renderingMode(isDark ? .template : .original)
                    .foregroundColor(isDark ? .white : nil)
                TextField("Search ...", text: $text)
                
                if text != "" {
                    Image(uiImage: UIImage.iconClose)
                        .renderingMode(isDark ? .template : .original)
                        .foregroundColor(isDark ? .white : nil)
                        .onTapGesture {
                        isEditing = false
                        text = ""
                        temp = ""
                        temp2 = ""
                        
                    }.padding(.trailing, 10)
                        .transition(.move(edge: .trailing))
                        .animation(.default)
                }
                
            }.padding(20)
                .background(RoundedRectangle(cornerRadius:8).stroke(isDark ? .white :Color.black,lineWidth:2))
                .cornerRadius(8)
                .padding(.horizontal, 10)
                .onTapGesture {
                    self.isEditing = true
                }
        }
    }
}
