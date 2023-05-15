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
//    2) initiated and configured only once, cant be customized.
//    3) we cant swap out dependencies

//  Dependency Injection can fix the three problems above.





import SwiftUI
import Combine


  // 3) the data
struct PostsModel: Identifiable, Codable {
  // from url test data website,https://jsonplaceholder.typicode.com/posts data
  // has this json format
 
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

protocol DataServiceProtocol {
  // must have:
  func getData() -> AnyPublisher< [PostsModel], Error >
}

// 5
// fetch data from API

class ProductionDataService: DataServiceProtocol {
  
 /* // using a singleton
  static let instance = ProductionDataService()  // Singleton
 */
  
  
  
  //  ( explicitly unwrapping an optional is not recommended for production )
//  let url: URL = URL(string: "https://jsonplaceholder.typicode.com/posts")!

 // now, make url customizable
  let url: URL
  
  init(url: URL)  {
    self.url = url
  }
  

  
  // getData returns AnyPublisher with a result with an array of PostsModel and Error

  func getData() -> AnyPublisher< [PostsModel], Error > {
    
    // fetch data with combine
    URLSession.shared.dataTaskPublisher(for: url)
    
    // map the data and decode data to post model
      .map( { $0.data } )
      .decode(type: [PostsModel].self, decoder: JSONDecoder())
      .receive(on:DispatchQueue.main)
      .eraseToAnyPublisher()
    
    
  }
  
}




// for testing and developing we can add a test version of ProductionDataService.
// but rather than passing a productionDataService, we pass in a protocol,
class MockDataService: DataServiceProtocol {
  
// for test data
  let testData: [PostsModel]
  
  init(data: [PostsModel]?) {
   // note we use optional here so that we can test with nil data
    
    self.testData = data ?? [
      
      PostsModel(userId: 1, id: 1, title: "One", body: "one"),
      PostsModel(userId: 2, id: 2, title: "Two", body: "two"),
      PostsModel(userId: 3, id: 3, title: "Three", body: "three")
      
    ]
  }
  
  func getData() -> AnyPublisher< [PostsModel], Error > {
    
    // just is a single publisher with a single output
    
    Just(testData)           // Just will not throw an error so we use trymap to give it a possible error
    
      .tryMap({$0})           // gives the simulated error the data
      .eraseToAnyPublisher()  // publisher now has a possible Error even though none will exhist
    
  }
  
}




  // 1)
 class DependencyInjectionViewModel: ObservableObject {
  
   // 4
   @Published var dataArray: [PostsModel] = []
   var cancellables = Set<AnyCancellable>()
  
   let dataService: DataServiceProtocol
   
   
   // dependency injection
 //  let dataService: ProductionDataService
   
   // depedency injection, we init with dataService or any other service
   init( dataService:DataServiceProtocol  ) {
     
     self.dataService = dataService   // we now have access to the dataservice
     
     loadPosts()
     
   }
   
   private func loadPosts() {
    
     
     
     /*
     // if using singleton to get data, do this, then sink it
     ProductionDataService.instance.getData()
     */
     
     
     // if using dependency injection, do this:
     
     dataService.getData()
     
       .sink { _ in
         
       } receiveValue: { [weak self] returnedPosts in
         self?.dataArray = returnedPosts
      }
       .store(in: &cancellables)
     
   }
}



struct ContentView: View {
  
  // 2
  //@StateObject private var vm = DependencyInjectionViewModel()
  // with dependency injection...
  @StateObject private var vm: DependencyInjectionViewModel   // type rather than function
  
  init( dataService: DataServiceProtocol ) {
    
    _vm = StateObject(wrappedValue:DependencyInjectionViewModel(dataService: dataService))

  }
  
  
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

//  production data service
//  static let dataService = ProductionDataService(url: URL(string: "https://jsonplaceholder.typicode.com/posts")!)

//   default data
//    static let dataService = MockDataService(data: nil)

//   or specific test data
    static let dataService = MockDataService(data: [
      PostsModel(userId: 1234, id: 1234, title:"test", body: "test"),
      PostsModel(userId: 1235, id: 1234, title: "test1", body: "test1")] )
  
    static var previews: some View {
       ContentView(dataService: dataService)
    }
}
