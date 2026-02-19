//
//  BearSongApp.swift
//  BearSong
//
//  SwiftUI app entry; Core Data and push notifications remain in AppDelegate.
//

import SwiftUI

@main
struct BearSongApp: App {
    @UIApplicationDelegateAdaptor(AppDelegate.self) var appDelegate

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environment(\.managedObjectContext, appDelegate.persistentContainer.viewContext)
        }
    }
}
