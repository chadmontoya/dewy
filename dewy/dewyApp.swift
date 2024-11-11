//
//  dewyApp.swift
//  dewy
//
//  Created by Chad Montoya on 11/11/24.
//

import SwiftUI

@main
struct dewyApp: App {
    let persistenceController = PersistenceController.shared

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environment(\.managedObjectContext, persistenceController.container.viewContext)
        }
    }
}
