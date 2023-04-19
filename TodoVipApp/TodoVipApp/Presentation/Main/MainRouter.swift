//
//  MainRouter.swift
//  TodoVipApp
//
//  Created by song on 2023/03/24.
//  Copyright (c) 2023 ___ORGANIZATIONNAME___. All rights reserved.
//
//  This file was generated by the Clean Swift Xcode Templates so
//  you can apply clean architecture to your iOS and Mac projects,
//  see http://clean-swift.com
//

import UIKit

protocol MainRoutingLogic: AnyObject
{
  func routeToDetail(todoId: Int)
  func presentModalAdd()
}

protocol MainDataPassing
{
  var dataStore: MainDataStore? { get }
}

class MainRouter: NSObject, MainRoutingLogic, MainDataPassing
{
  weak var viewController: MainViewController?
  var dataStore: MainDataStore?
  
  // MARK: Routing
  
  func routeToDetail(todoId: Int)
  {
    
    let storyboard = UIStoryboard(name: "Main", bundle: nil)
    let destinationVC = storyboard.instantiateViewController(withIdentifier: "DetailViewController") as! DetailViewController
    var destinationDS = destinationVC.router!.dataStore!
    passDataToDatail(source: dataStore!, destination: &destinationDS, todoId: todoId)
    navigateToSomewhere(source: viewController!, destination: destinationVC)
  }
  
  func presentModalAdd() {
    let storyboard = UIStoryboard(name: "Main", bundle: nil)
    let destinationVC = storyboard.instantiateViewController(withIdentifier: "AddViewController") as! AddViewController
    navigateToAdd(source: viewController!, destination: destinationVC)
  }
}

// MARK: - ToAddView

extension MainRouter {
  
  // MARK: - Navigation
  func navigateToAdd(source: MainViewController, destination: AddViewController) {
    source.show(destination, sender: nil)
  }
  
  // MARK: - Passing data
  
  func passDataToAdd(source: MainViewController, destination: inout AddViewController) {
    
  }
}

// MARK: - ToModifyView
extension MainRouter {
  //   MARK: Navigation
  
  func navigateToSomewhere(source: MainViewController, destination: DetailViewController)
  {
    source.show(destination, sender: nil)
  }
  
  //   MARK: Passing data
  
  func passDataToDatail(source: MainDataStore, destination: inout DetailDataStore, todoId: Int)
  {
    destination.todoId = todoId

  }
}
