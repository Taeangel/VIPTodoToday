//
//  MainPresenter.swift
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

protocol MainPresentationLogic
{
  func presentTodoList(response: TodoListProtocol)
  func presentDeleteTodo(response: MainScene.DeleteTodo.Response)
  func presentModifyTodo(response: MainScene.ModifyTodo.Response)
  func presesntAddTodo(response: MainScene.AddTodo.Response)
}

class MainPresenter: MainPresentationLogic
{
  
  
  weak var viewController: MainDisplayLogic?
  
  // MARK: Do something
  
  //인터렉터한테 받은 날것의 데이터를 받음
  
  func presentTodoList(response: TodoListProtocol) {
    typealias DisplayedTodoList = MainScene.FetchTodoList.ViewModel.DisplayedTodo
    
    var displayTodoList: [String: [DisplayedTodoList]] = [:]
    
  let responseTodoList = response.todoList
    
    var sections: [String] = []
    responseTodoList?.keys.sorted().forEach { sections.append($0) }
    sections.reverse()
    
    sections.forEach {
      let todoDate = responseTodoList?[$0]
      let todoAday = todoDate?.map{
        return DisplayedTodoList(
          id: $0.id ?? 0,
          title: $0.title ?? "",
          isDone: $0.isDone ?? false,
          updatedTime: $0.updatedTime,
          updatedDate: $0.updatedDate
        )
      }
      displayTodoList.updateValue(todoAday!, forKey: $0)
    }
        
    let viewModel = MainScene.FetchTodoList.ViewModel(
      error: response.error as? NetworkError,
      isFetch: response.isFetch,
      page: response.page + 1,
      displayedTodoList: displayTodoList,
      sections: sections
    )
    
    viewController?.displayTodoList(viewModel: viewModel)
  }
  
  func presentDeleteTodo(response: MainScene.DeleteTodo.Response) {
    let viewModel = MainScene.DeleteTodo.ViewModel(indexPath: response.indexPath, error: response.error as? NetworkError)
    viewController?.displayedDeleteTodo(viewModel: viewModel)
  }
  
  func presentModifyTodo(response: MainScene.ModifyTodo.Response) {
    typealias DisplayedTodo = MainScene.ModifyTodo.ViewModel.DisplayedTodo

    let displayTodo = DisplayedTodo(
      id: response.todoEntity?.id ?? 0,
      title: response.todoEntity?.title ?? "",
      isDone: response.todoEntity?.isDone ?? false,
      updatedTime: response.todoEntity?.updatedTime ?? "",
      updatedDate: response.todoEntity?.updatedDate ?? ""
    )
    
    let viewModel = MainScene.ModifyTodo.ViewModel(indexPath: response.indexPath, disPlayTodo: displayTodo, error: response.error as? NetworkError)
    
    viewController?.displayedModifyTodo(viewModel: viewModel)
  }
  
  func presesntAddTodo(response: MainScene.AddTodo.Response) {
    typealias DisplayedTodoList = MainScene.FetchTodoList.ViewModel.DisplayedTodo
    
    var displayTodoList: [String: [DisplayedTodoList]] = [:]
        
    var sections: [String] = []
    response.todoList?.keys.sorted().forEach { sections.append($0) }
    sections.reverse()
    
    sections.forEach {
      let todoDate = response.todoList?[$0]
      let todoAday = todoDate?.map{
        return DisplayedTodoList(
          id: $0.id ?? 0,
          title: $0.title ?? "",
          isDone: $0.isDone ?? false,
          updatedTime: $0.updatedTime,
          updatedDate: $0.updatedDate
        )
      }
      displayTodoList.updateValue(todoAday!, forKey: $0)
    }
        
    let viewModel = MainScene.FetchTodoList.ViewModel(displayedTodoList: displayTodoList, sections: sections)
    viewController?.displayAddTodo(viewModle: viewModel)
  }
}
