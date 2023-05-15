//
//  Dependency_Injection_API_data_TutorialApp.swift
//  Dependency Injection API data Tutorial
//
//  Created by jim on 4/25/23.
//

import SwiftUI

@main
struct Dependency_Injection_API_data_TutorialApp: App {
  
 //  let dataService:ProductionDataService = ProductionDataService()
 //   or simplified:
  
 //   let dataService = ProductionDataService(url: URL(string: "https://jsonplaceholder.typicode.com/posts")!)
  
 // default test data
 // let dataService: DataServiceProtocol = MockDataService(data: nil)
 
  
 //  production data
 // let dataService:DataServiceProtocol = ProductionDataService(url: URL(string: "https://jsonplaceholder.typicode.com/posts")!)
  
  
  //  custome test data
    let dataService = MockDataService(data: [
        PostsModel(userId: 1234, id: 1234, title:"test", body: "test"),
        PostsModel(userId: 1235, id: 1234, title: "test1", body: "test1")] )
  
    var body: some Scene {
        WindowGroup {
            ContentView(dataService: dataService )
        }
    }
}
