//
//  MainViewController.swift
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

protocol MainDisplayLogic: AnyObject
{
  func displayTodoList(viewModel: MainScene.FetchTodoList.ViewModel)
}

class MainViewController: UIViewController, MainDisplayLogic
{
  var interactor: MainBusinessLogic?
  var router: (NSObjectProtocol & MainRoutingLogic & MainDataPassing)?
  
  // MARK: - IBoutlets
  
  // MARK: - Properties
  typealias Displayedtodo = MainScene.FetchTodoList.ViewModel.DisplayedTodo
  
  var sections: [String] = []
  var sectionsNumber: [String] = []
  var todoList: [Displayedtodo] = []
  var sectionInfo: [Int] = []
  
  // MARK: Object lifecycle
  override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: Bundle?)
  {
    super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
    setup()
  }
  
  required init?(coder aDecoder: NSCoder)
  {
    super.init(coder: aDecoder)
    setup()
  }
  
  // MARK: Setup
  
  private func setup()
  {
    let viewController = self
    let interactor = MainInteractor()
    let presenter = MainPresenter()
    let router = MainRouter()
    
    viewController.interactor = interactor
    viewController.router = router
    interactor.presenter = presenter
    presenter.viewController = viewController
    router.viewController = viewController
    router.dataStore = interactor
  }
  
  // MARK: Routing
  
  override func prepare(for segue: UIStoryboardSegue, sender: Any?)
  {
    
    if let scene = segue.identifier {
      let selector = NSSelectorFromString("routeTo\(scene)WithSegue:")
      if let router = router, router.responds(to: selector) {
        router.perform(selector, with: segue)
      }
    }
  }
  
  // MARK: View lifecycle
  
  override func viewDidLoad()
  {
    super.viewDidLoad()
    configureTableView()
    fetchTodoList()
    resizeButton()
    
    NotificationCenter.default.addObserver(
      self,
      selector: #selector(self.didDismissDetailNotification(_:)),
      name: NSNotification.Name("ModalDismissNC"),
      object: nil
    )
  }
  
  @objc func didDismissDetailNotification(_ notification: Notification) {
    let fetchRequest = MainScene.FetchTodoList.Request()
    Task {
      try await self.interactor?.fetchTodoList(request: fetchRequest)
    }
  }
  
  // MARK: Do something
  
  @IBOutlet weak var myTableView: UITableView!
  @IBOutlet weak var addButton: UIButton!
  
  private func resizeButton() {
    let largeConfig = UIImage.SymbolConfiguration(pointSize: 30, weight: .bold, scale: .large)
    
    let largeBoldDoc = UIImage(systemName: "plus.circle.fill", withConfiguration: largeConfig)
    
    addButton.setImage(largeBoldDoc, for: .normal)
  }
  
  //뷰에서 인터렉터한테 시키는 곳
  func fetchTodoList()
  {
    let request = MainScene.FetchTodoList.Request()
    Task {
      try await interactor?.fetchTodoList(request: request)
    }
  }
  
  func deleteTodo(id: Int) {
    let deleteRequest = MainScene.DeleteTodo.Request(id: id)
    let fetchRequest = MainScene.FetchTodoList.Request()
    
    Task {
      try await interactor?.deleteTodo(request: deleteRequest)
      try await interactor?.fetchTodoList(request: fetchRequest)
    }
  }
  
  //프리젠터에서 뷰로 화면에 그리는 것
  func displayTodoList(viewModel: MainScene.FetchTodoList.ViewModel) {
    
    self.todoList = viewModel.displayedTodoList
    
    sections = todoList
      .map { $0.createdDate }
      .removeDuplicates()
    
    sectionsNumber = todoList
      .map { $0.createdDate }
    
    sectionInfo = sections.map { standard in
      sectionsNumber.filter { target in
        standard == target
      }.count
    }
    
    DispatchQueue.main.async {
      self.myTableView.reloadData()
    }
  }
}

extension MainViewController: UITableViewDelegate
{
  private func configureTableView()
  {
    let myTableViewCellNib = UINib(nibName: String(describing: MyTableViewCell.self), bundle: nil)
    
    self.myTableView.register(myTableViewCellNib, forCellReuseIdentifier: "MyTableViewCell")
    
    self.myTableView.rowHeight = UITableView.automaticDimension
    self.myTableView.estimatedRowHeight = 120
    
    self.myTableView.delegate = self
    self.myTableView.dataSource = self
  }
  
  func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
    
    let delete = UIContextualAction(style: .destructive, title: "Delete") { [weak self] (_, _, _) in
      guard let section = indexPath.first else { return }
      let row = indexPath.row
      let id: Int
      
      if section == 0 {
        id = self?.todoList[row].id ?? 0
      } else {
        var startIndex = 0
        
        for i in 0...indexPath.section - 1 {
          startIndex += self?.sectionInfo[i] ?? 0
        }
        id = self?.todoList[startIndex + row].id ?? 0
      }
      self?.deleteTodo(id: id)
    }
    
    return UISwipeActionsConfiguration(actions: [delete])
  }
}

extension MainViewController: UITableViewDataSource
{
  
  func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
    router?.routeToDetail()
  }
  
  func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
    return sections[section]
  }
  
  func numberOfSections(in tableView: UITableView) -> Int {
    return sections.count
  }
  
  func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    return sectionsNumber.filter { $0 == sections[section] }.count
  }
  
  func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
    guard let cell = myTableView.dequeueReusableCell(withIdentifier: "MyTableViewCell", for: indexPath) as? MyTableViewCell else {
      return UITableViewCell()
    }
    
    if indexPath.section == 0 {
      
      cell.configureCell(todo: todoList[indexPath.row])
      return cell
    } else {
      var startIndex = 0
      
      for i in 0...indexPath.section - 1 {
        startIndex += sectionInfo[i]
      }
      
      cell.configureCell(todo: todoList[startIndex + indexPath.row])
      return cell
    }
  }
}
