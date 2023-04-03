//
//  MainModels.swift
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

enum MainScene
{
  // MARK: Use cases
  
  enum FetchSearchTodoList
  {
    struct Request // 뷰가 인터렉터한테 요청하는 데이터
    {
      var quary: String
      var page: Int = 1
      var perPage: Int = 10
    }
    struct Response: TodoListProtocol //워커에서 들어온 데이터 - 날것의 데이터
    {
      var todoList: [TodoEntity] = []
    }
    struct ViewModel // 프리젠터가 뷰에 전달하는 데이터
    {
      struct DisplayedTodo: Hashable {
        let id: Int
        let title: String
        let isDone: Bool
        let createdTime: String
        let createdDate: String
      }
      
      var displayedTodoList: [DisplayedTodo]
    
    }
  }
  
  enum DeleteTodo
  {
    struct Request // 뷰가 인터렉터한테 요청하는 데이터
    {
      var id: Int
    }
    struct Response //워커에서 들어온 데이터 - 날것의 데이터
    {
    }
    struct ViewModel // 프리젠터가 뷰에 전달하는 데이터
    {
    }
  }
  
  enum FetchTodoList
  {
    struct Request // 뷰가 인터렉터한테 요청하는 데이터
    {
      var page: Int = 1
      var perPage: Int = 10
    }
    struct Response: TodoListProtocol //워커에서 들어온 데이터 - 날것의 데이터
    {
      var todoList: [TodoEntity] = []
    }
    struct ViewModel // 프리젠터가 뷰에 전달하는 데이터
    {
      struct DisplayedTodo: Hashable {
        let id: Int
        let title: String
        let isDone: Bool
        let createdTime: String
        let createdDate: String
      }
      
      var displayedTodoList: [DisplayedTodo]
    }
  }
}

protocol TodoListProtocol {
  var todoList: [TodoEntity] { get set }
}
