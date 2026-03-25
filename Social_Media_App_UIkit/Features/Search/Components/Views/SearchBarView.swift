//
//  SearchBarView.swift
//  Social_Media_App_UIkit
//
//  Created by aplle on 12/27/25.
//

import SwiftUI


struct CustomSearchBar: View {
    @Binding var searchText:String
   
    var foregroundColor:Color
    var search:()->Void
    
    @State var timer: Timer?
    var body: some View {
        HStack(){
            Image(systemName: "magnifyingglass")
                
                .foregroundColor(searchText.isEmpty ?.secondary: foregroundColor)
                
            TextField("Search Friends...",text: $searchText)
                .onSubmit {
                    search()
                }
                .foregroundColor(.primary)
                .overlay(alignment: .trailing) {
                    Image(systemName: "xmark.circle.fill")
                        .padding()
                        .offset(x:20)
                        .foregroundStyle(foregroundColor)
                        .opacity(!searchText.isEmpty ? 1.0: 0.0)
                        .allowsHitTesting(!searchText.isEmpty )
                        .contentShape(Rectangle())
                        .onTapGesture {
                            searchText = ""
                        }
                }
        }
        .padding()
        .padding(.horizontal,10)
        .background(Color.init(uiColor: .systemBackground))
        .clipShape(Capsule(style: .continuous))
        .overlay(content: {
            Capsule(style: .continuous)
             
                .strokeBorder(style:.init(lineWidth: 0.5))
                .foregroundStyle(.secondary)
        })
       
        .shadow(color:.gray.opacity(0.5),radius: 5)
        .padding(.horizontal,20)
        .padding(.vertical,2)
        .onChange(of: searchText) {
            timer?.invalidate()

            // Start a new timer
            timer = Timer.scheduledTimer(withTimeInterval: 0.3, repeats: false) { _ in
              search()
                print("Search")
            }
        }
      
    }
}

#Preview {
    CustomSearchBar(searchText: .constant("sdsdsdsd"), foregroundColor: Color(uiColor: UIColor.electricPurple)) {
        
    }
}
