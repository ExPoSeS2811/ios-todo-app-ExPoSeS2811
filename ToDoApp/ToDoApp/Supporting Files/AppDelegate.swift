//
//  AppDelegate.swift
//  ToDoApp
//
//  Created by Gleb Rasskazov on 16.06.2023.
//

import UIKit

@main
class AppDelegate: UIResponder, UIApplicationDelegate {
    var window: UIWindow?
    private let fileCache = FileCache()

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        window = UIWindow(frame: UIScreen.main.bounds)
        if let window = window {
            let navigationController = UINavigationController()
            let homeViewModel = HomeViewModel(fileCache: fileCache)
            navigationController.viewControllers = [HomeViewController(viewModel: homeViewModel)]
            window.rootViewController = navigationController
            window.makeKeyAndVisible()
        }

        return true
    }
}
