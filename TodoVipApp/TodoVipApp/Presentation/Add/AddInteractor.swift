//
//  AddInteractor.swift
//  TodoVipApp
//
//  Created by song on 2023/04/03.
//  Copyright (c) 2023 ___ORGANIZATIONNAME___. All rights reserved.
//
//  This file was generated by the Clean Swift Xcode Templates so
//  you can apply clean architecture to your iOS and Mac projects,
//  see http://clean-swift.com
//

import UIKit

protocol AddBusinessLogic
{
  func postTodo(request: Add.PostTodo.Request)
}

protocol AddDataStore
{
}

class AddInteractor: AddBusinessLogic, AddDataStore
{
  var presenter: AddPresentationLogic?
  var worker: AddWorker?
  
  // MARK: Do something
  
  func postTodo(request: Add.PostTodo.Request)
  {
    worker = AddWorker()
    Task {
      do {
        let todoEntityData = try await self.worker?.postTodo(todo: request.todo)
        NotificationCenter.default.post(name: NSNotification.Name("addTodo"), object: todoEntityData?.todoEntity)
        
        let response = Add.PostTodo.Response(title: todoEntityData?.todoEntity?.title)
        presenter?.cleanAddView(response: response)
      } catch {
        let response = Add.PostTodo.Response(error: error)
        presenter?.cleanAddView(response: response)
      }
    }
  }
}
