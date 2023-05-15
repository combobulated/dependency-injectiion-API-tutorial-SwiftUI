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
  
  let dataService = ProductionDataService(url: URL(string: "https://jsonplaceholder.typicode.com/posts")!)
  
    var body: some Scene {
        WindowGroup {
            ContentView(dataService: dataService )
        }
    }
}
