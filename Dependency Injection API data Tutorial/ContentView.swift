//
//  ContentView.swift
//  Dependency Injection API data Tutorial
//
//  Created by jim on 4/25/23.
//
//  API data is often fetched using
//  the Singleton design pattern.  There is
//  a better way using Dependency Injection.
//  Why?  Singletons have three flaws
//    1) its a global, instance accessed from any class.
//       collision on different threads can be an issue.
//    2) initiated and configured only once
//    3) we cant swap out services

//  Dependency Injection can fix





import SwiftUI
import Combine


  // 3) the data
struct PostsModel: Identifiable, Codable {
  // from url website
  /*
   {
   "userId": 1,
   "id": 1,
   "title": " bunch of words go here ",
   "body": " "more words go here"
   }
   
   */
  
  let userId: Int
  let id: Int
  let title: String
  let body: String
  
}

// 5
// fetches data

class ProductionDataService {
  
  // using a singleton
  static let instance = ProductionDataService()  // Singleton
  
  //  ( explicitly unwrapping an optional is not recommended for production )
  let url: URL = URL(string: "https://jsonplaceholder.typicode.com/posts")!
  

  
  // get data returns AnyPublisher with a result with an array of PostsModel and Error
  func getData() -> AnyPublisher<[PostsModel], Error> {
    
    // fetch data with combine
    URLSession.shared.dataTaskPublisher(for: url)
    
    // map the data and decode data to post model
      .map({ $0.data })
      .decode(type: [PostsModel].self, decoder: JSONDecoder())
      .receive(on:DispatchQueue.main)
      .eraseToAnyPublisher()
    
    
  }
  
}


  // 1)
 class DependencyInjectionViewModel: ObservableObject {
  
   // 4
   @Published var dataArray: [PostsModel] = []
   var cancellables = Set<AnyCancellable>()
   
   init() {
     
     loadPosts()
     
   }
   private func loadPosts() {
     
     // using singleton to get data, then sink it
     ProductionDataService.instance.getData()
       .sink { _ in
         
       } receiveValue: { [weak self] returnedPosts in
         self?.dataArray = returnedPosts
      }
       .store(in: &cancellables)
     
   }
}




struct ContentView: View {
  
  // 2
  @StateObject private var vm = DependencyInjectionViewModel()
  
  
  
    var body: some View {
      ScrollView {
        VStack {
          ForEach( vm.dataArray) { post in
            Text(post.title)
          }
        }
        
      }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
