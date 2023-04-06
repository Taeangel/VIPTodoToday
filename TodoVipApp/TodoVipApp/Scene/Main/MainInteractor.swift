//
//  MainInteractor.swift
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

protocol MainBusinessLogic
{
  func fetchTodoList(request: MainScene.FetchTodoList.Request)
  func deleteTodo(request: MainScene.DeleteTodo.Request)
  func fetchSearchTodoList(request: MainScene.FetchSearchTodoList.Request)
  func checkTodo(request: MainScene.CheckBoxTodo.Request)

}

protocol MainDataStore
{
  var todoList: [TodoEntity] { get set }
}

class MainInteractor: MainBusinessLogic, MainDataStore
{

  var todoList: [TodoEntity] = []
  var presenter: MainPresentationLogic?
  var worker: MainWorker?
  
  // MARK: 뷰에서 인터렉터한테 시키는 메서드
  
  func fetchTodoList(request: MainScene.FetchTodoList.Request)  {
    worker = MainWorker()
    Task{
      do {
        guard let todoList = try await worker?.fetchTodoList(page: request.page, perPage: request.perPage) else { return }

        if request.page == 1 {
          self.todoList = todoList
        } else {
          self.todoList += todoList
        }
        
        let response = MainScene.FetchTodoList.Response(todoList: self.todoList, page: request.page)
        presenter?.presentTodoList(response: response)
      } catch {
        let response = MainScene.FetchTodoList.Response(error: error as? NetworkError, page: request.page)
        presenter?.presentTodoList(response: response)
      }
    }
  }
  
  func deleteTodo(request: MainScene.DeleteTodo.Request)  {
    worker = MainWorker()
    Task {
      do {
        try await worker?.deleteTodo(id: request.id)
        let response = MainScene.DeleteTodo.Response(page: request.page)
        presenter?.updatePage(response: response)
      } catch {
        let response = MainScene.DeleteTodo.Response(error: error as? NetworkError, page: request.page)
        presenter?.updatePage(response: response)
      }
    }
  }
  
  func fetchSearchTodoList(request: MainScene.FetchSearchTodoList.Request) {
    worker = MainWorker()
    Task {
      do {
        let todoList = try await worker?.fetchSearchTodoList(page: request.page, perPage: request.perPage, query: request.quary)
        let response = MainScene.FetchSearchTodoList.Response(todoList: todoList, page: request.page)
        presenter?.presentTodoList(response: response)
      } catch {
        let response = MainScene.FetchSearchTodoList.Response(error: error as? NetworkError, page: request.page)
        presenter?.presentTodoList(response: response)
      }
    }
  }
  
  func checkTodo(request: MainScene.CheckBoxTodo.Request) {
    worker = MainWorker()
    Task {
      do {
       try await worker?.checkisDone(id:request.id ,title: request.title , isDone: request.isDone)
        let response = MainScene.CheckBoxTodo.Response(page: request.page)
        presenter?.updatePage(response: response)
      } catch {
        let response = MainScene.CheckBoxTodo.Response(error: error as? NetworkError, page: request.page)
        presenter?.updatePage(response: response)
      }
    }
  }
}
