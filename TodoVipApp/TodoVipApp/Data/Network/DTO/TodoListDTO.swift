//
//  TodoListDTO.swift
//  TodoVipApp
//
//  Created by song on 2023/03/28.
//

import Foundation

// MARK: - Todo
struct TodoListDTO: Codable {
  let data: [TodoData]?
  let meta: Meta?
  let message: String?
}

// MARK: - Datum
struct TodoData: Codable {
  let id: Int?
  let title: String?
  let isDone: Bool?
  let updatedAt: String?
  
  enum CodingKeys: String, CodingKey {
    case id, title
    case isDone = "is_done"
    case updatedAt = "updated_at"
  }
}

// MARK: - Meta
struct Meta: Codable {
  let currentPage, from, lastPage, perPage: Int?
  let to, total: Int?
  
  enum CodingKeys: String, CodingKey {
    case currentPage = "current_page"
    case from
    case lastPage = "last_page"
    case perPage = "per_page"
    case to, total
  }
  
  var isfetch: Bool {
    var isfetch: Bool = true
  
    if self.lastPage == self.currentPage {
      isfetch = false
    }
    
    return isfetch
  }
  
}

