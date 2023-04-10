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
  func checkTodo(request: MainScene.ModifyTodo.Request)
  
}

protocol MainDataStore
{
  var sections: [String] { get set }
  var todoList: [String: [TodoEntity]] { get set }
}

class MainInteractor: MainBusinessLogic, MainDataStore
{
  var sections: [String] = []
  var todoList: [String: [TodoEntity]] = [:]
  var presenter: MainPresentationLogic?
  var worker: MainWorker?
  
  // MARK: - NotificationCenter
  
  init() {
    NotificationCenter.default.addObserver(self, selector: #selector(addTodo), name: NSNotification.Name("addTodo"), object: nil)
    NotificationCenter.default.addObserver(self, selector: #selector(modifyTodo), name: NSNotification.Name("modifyTodo"), object: nil)
  }
  
  // MARK: 뷰에서 인터렉터한테 시키는 메서드
  
  @objc func addTodo() {
    print("addtodo")
  }
   
  @objc func modifyTodo(_ notification: Notification) {
    guard let todoEntity = notification.object as? TodoEntity else {
      return
    }
    
    let storedTodoEntity = self.todoList.flatMap { $1.filter { $0.id == todoEntity.id  } }.first
    let rows = self.todoList[storedTodoEntity?.updatedDate ?? ""]
    
    guard let sectionIndex = self.sections.firstIndex(of: storedTodoEntity?.updatedDate ?? ""),
          let rowIndex = rows?.firstIndex(where: { $0.id == storedTodoEntity?.id }) else {
      return
    }
    
    let indexPath = IndexPath(row: rowIndex, section: sectionIndex)
    self.todoList[sections[sectionIndex]]?[rowIndex] = todoEntity
    
    let response = MainScene.ModifyTodo.Response(indexPath: indexPath, todoEntity: todoEntity, page: 1)
    presenter?.presentCheckBoxTap(response: response)
    
  }
  
  func fetchTodoList(request: MainScene.FetchTodoList.Request)  {
    worker = MainWorker()
    Task{
      do {
        guard let todoList = try await self.worker?.fetchTodoList(page: request.page, perPage: request.perPage) else { return }
        
        let groupedTodoList = Dictionary(grouping: todoList) { $0.updatedDate }
        
        if request.page == 1 {
          self.todoList = groupedTodoList
        } else {
          self.todoList.merge(groupedTodoList) { todo, _ in
            todo
          }
        }
        
        self.todoList.keys.sorted().forEach { sections.append($0) }
        sections.reverse()
        
        let response = MainScene.FetchTodoList.Response(todoList: self.todoList, page: request.page)
        presenter?.presentTodoList(response: response)
      } catch {
        let response = MainScene.FetchTodoList.Response(error: error as? NetworkError, page: request.page)
        presenter?.presentTodoList(response: response)
      }
    }
  }
  
  func fetchSearchTodoList(request: MainScene.FetchSearchTodoList.Request) {
    worker = MainWorker()
    Task {
      do {
        guard let todoList = try await self.worker?.fetchSearchTodoList(page: request.page, perPage: request.perPage, query: request.quary) else {
          return
        }
        
        let groupedTodoList = Dictionary(grouping: todoList) { $0.updatedDate }
        self.todoList = groupedTodoList
        
        let response = MainScene.FetchSearchTodoList.Response(todoList: self.todoList, page: request.page)
        presenter?.presentTodoList(response: response)
      } catch {
        let response = MainScene.FetchSearchTodoList.Response(error: error, page: request.page)
        presenter?.presentTodoList(response: response)
      }
    }
  }
  
  func deleteTodo(request: MainScene.DeleteTodo.Request)  {
    worker = MainWorker()
    Task {
      do {
        let todoEntity = try await self.worker?.deleteTodo(id: request.id)
        let storedTodoEntity = self.todoList.flatMap { $1.filter { $0.id == todoEntity?.id  } }.first
        let rows = self.todoList[storedTodoEntity?.updatedDate ?? ""]
        
        guard let sectionIndex = self.sections.firstIndex(of: storedTodoEntity?.updatedDate ?? ""),
              let rowIndex = rows?.firstIndex(where: { $0.id == storedTodoEntity?.id }) else {
          return
        }
        let indexPath = IndexPath(row: rowIndex, section: sectionIndex)
        
        self.todoList[sections[sectionIndex]]?.remove(at: rowIndex)
        
        let response = MainScene.DeleteTodo.Response(indexPath: indexPath, page: request.page)
        presenter?.presentDeleteTodo(response: response)
        
      } catch {
        let response = MainScene.DeleteTodo.Response(error: error, page: request.page)
        presenter?.presentDeleteTodo(response: response)
      }
    }
  }
  
  func checkTodo(request: MainScene.ModifyTodo.Request) {
    worker = MainWorker()
    Task {
      do {
        
        let todoEntity = try await self.worker?.checkisDone(id: request.id, title: request.title, isDone: request.isDone)
        let storedTodoEntity = self.todoList.flatMap { $1.filter { $0.id == todoEntity?.id  } }.first
        let rows = self.todoList[storedTodoEntity?.updatedDate ?? ""]
        
        guard let sectionIndex = self.sections.firstIndex(of: storedTodoEntity?.updatedDate ?? "") else {
          return
        }
        
        guard let rowIndex = rows?.firstIndex(where: { $0.id == storedTodoEntity?.id }) else {
          return
        }
        
        let indexPath = IndexPath(row: rowIndex, section: sectionIndex)
        self.todoList[sections[sectionIndex]]?[rowIndex].isDone = request.isDone
        
        let response = MainScene.ModifyTodo.Response(indexPath: indexPath, todoEntity: todoEntity, page: request.page)
        presenter?.presentCheckBoxTap(response: response)
      } catch {
        let response = MainScene.ModifyTodo.Response(error: error, page: request.page)
        presenter?.presentCheckBoxTap(response: response)
      }
    }
  }
}
