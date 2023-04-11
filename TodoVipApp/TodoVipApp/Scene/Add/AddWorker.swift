//
//  AddWorker.swift
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

class AddWorker: TodoWorkerUsecase {
  var apiManager: TodoApiManager
  
  init(apiManager: TodoApiManager = TodoApiManager(session: URLSession.shared)) {
    self.apiManager = apiManager
  }
  
  func postTodo(todo: TodoPostDTO) async throws -> TodoEntity {
    try await todoUsecase.postTodo(todo:todo)
  }
}
