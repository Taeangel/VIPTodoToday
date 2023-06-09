////
////  MainWorkerTests.swift
////  TodoVipApp
////
////  Created by song on 2023/04/11.
////  Copyright (c) 2023 ___ORGANIZATIONNAME___. All rights reserved.
////
////  This file was generated by the Clean Swift Xcode Templates so
////  you can apply clean architecture to your iOS and Mac projects,
////  see http://clean-swift.com
////
//
//@testable import TodoVipApp
//import XCTest
//
//class MainWorkerTests: XCTestCase
//{
//  // MARK: Subject under test
//
//  var sut: MainWorker!
//
//  // MARK: Test lifecycle
//
//  override func setUp()
//  {
//    super.setUp()
//    setupMainWorker()
//  }
//
//  override func tearDown()
//  {
//    super.tearDown()
//  }
//
//  // MARK: Test setup
//
//  func setupMainWorker()
//  {
//    sut = MainWorker(reauestable: URLSession.shared)
//  }
//
//  // MARK: Test doubles
//
//  // MARK: Tests
//
//  func test_fetchTodoList() async
//  {
//    // Given
//    let page = 1
//    let perPage = 10
//    Task {
//      do {
//        // When
//        let todoList = try await sut.fetchTodoList(page: page, perPage: perPage)
//
//        // Then
//        XCTAssertEqual(todoList?.message, "성공")
//      }
//    }
//  }
//
//  func test_fetchSearchTodoList() async
//  {
//    // Given
//    let page = 1
//    let perPage = 10
//    let query = "a"
//    Task {
//
//      do {
//        // When
//
//        let todoList = try await sut.fetchSearchTodoList(page: page, perPage: perPage, query: query)
//        // Then
//
//        XCTAssertEqual(todoList?.message, "성공")
//      }
//    }
//  }
//
//  func test_deleteTodo() async
//  {
//    // Given
//    let id = 3091
//    Task {
//
//      do {
//        // When
//        let todoListData = try await sut.deleteTodo(id: id)
//
//        // Then
//
//        XCTAssertEqual(todoListData.message, "성공")
//      }
//    }
//  }
//
//  func test_modifyTodo() async
//  {
//    // Given
//    let id = 3091
//    let title = "이걸로"
//    let isDone = false
//    Task {
//
//      do {
//        // When
//        let todoListData = try await sut.modifyTodo(id: id, title: title, isDone: isDone)
//
//        // Then
//
//        XCTAssertEqual(todoListData.message, "성공")
//      }
//    }
//  }
//}
