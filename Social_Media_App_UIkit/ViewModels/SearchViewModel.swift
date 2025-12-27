//
//  SearchViewModel.swift
//  Social_Media_App_UIkit
//
//  Created by aplle on 12/27/25.
//

import Combine
import SwiftUI

class SearchViewModel:ObservableObject{
   @Published var query: String = ""
    @Published private(set) var results: [UserSummary] = []
   @Published private(set) var isLoading: Bool = false
   @Published private(set) var errorMessage: String?
    
    
    let searchService: SearchService
    private var cancellables = Set<AnyCancellable>()
        private var searchTask: Task<Void, Never>?

        private let limit = 10
    
    init(
           searchService: SearchService = .init(),
       ) {
      
           self.searchService = searchService
    }
    
    func search() async{
        guard !query.isEmpty else {
                    results = []
                    errorMessage = nil
                    isLoading = false
                    return
                }
        
        isLoading = true
              errorMessage = nil
        
        do {
                    let users = try await searchService.searchUsers(query: query, limit: limit)

print(users)
                    self.results = users
                    self.isLoading = false

                } catch {
                  
                    self.results = []
                    self.isLoading = false
                    self.errorMessage = error.localizedDescription
                }

    }
    func clean(){
        results = []
        errorMessage = nil
        isLoading = false
        query = ""
    }
}
