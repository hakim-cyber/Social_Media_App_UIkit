//
//  SearchProfileView.swift
//  Social_Media_App_UIkit
//
//  Created by aplle on 12/27/25.
//

import SwiftUI

struct SearchProfileView: View {
    @StateObject var vm: SearchViewModel
       @ObservedObject var router: SearchRouter


    @State private var presentError: Bool = false
    var body: some View {
        VStack(spacing: 20) {
            CustomSearchBar(searchText: $vm.query, foregroundColor: Color.init(uiColor: .electricPurple)) {
                Task{
                  await  self.vm.search()
                }
            }
           
          
            if vm.isLoading {
                ProgressView()
            }
            ScrollView{
                VStack(spacing: 15){
                    ForEach(vm.results, id: \.id) { user in
                        SearchProfileButton(user: user) {
                            router.openProfile?(user.id)
                        }
                    }
                    
                }
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity,alignment: .top)
        
        
        .onChange(of: vm.errorMessage, { oldValue, newValue in
            if newValue != nil{
                self.presentError = true
            }else{
                self.presentError = false
            }
        })
        .alert("There is something wrong", isPresented: $presentError) {
            Button("Ok"){
                
            }
        } message: {
            Text(vm.errorMessage ?? "Unknown Error")
        }
        
     
    }
        
}
