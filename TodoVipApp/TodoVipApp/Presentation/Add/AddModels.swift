//
//  AddModels.swift
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

enum Add
{
  // MARK: Use cases
  
  enum PostTodo
  {
    struct Request
    {
      var todo: TodoPostDTO
    }
    
    struct Response
    {
      var title: String?
      var error: Error?
      let cleanViewTitle: String = ""
      let isDone: Bool = false
    }
    
    struct ViewModel
    {
      var error: NetworkError?
      var titile: String?
      let cleanViewTitle: String = ""
      let cleanViewIsDone: Bool = false
    }
  }
}
