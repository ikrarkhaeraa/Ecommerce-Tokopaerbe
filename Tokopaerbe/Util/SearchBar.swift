import SwiftUI

struct SearchBar: View {
    
    @Binding var text: String
    @Binding var temp: String
    @Binding var temp2: String
    @State private var isEditing = false
    
    var body: some View {
        HStack {
            
            HStack {
                Image(uiImage: UIImage.searchIcon)
                TextField("Search ...", text: $text)
                
                if text != "" {
                    Image(uiImage: UIImage.iconClose).onTapGesture {
                        isEditing = false
                        text = ""
                        temp = ""
                        temp2 = ""
                        
                    }.padding(.trailing, 10)
                        .transition(.move(edge: .trailing))
                        .animation(.default)
                }
                
            }.padding(20)
                .background(RoundedRectangle(cornerRadius:8).stroke(Color.black,lineWidth:2))
                .cornerRadius(8)
                .padding(.horizontal, 10)
                .onTapGesture {
                    self.isEditing = true
                }
        }
    }
}
