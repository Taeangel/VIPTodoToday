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
import Combine
import CombineCocoa

protocol MainDisplayLogic: AnyObject
{
  func displayTodoList(viewModel: MainScene.FetchTodoList.ViewModel)
  func displayAddTodo(viewModle: MainScene.FetchTodoList.ViewModel)
  func displayedDeleteTodo(viewModel: MainScene.DeleteTodo.ViewModel)
  func displayedModifyTodo(viewModel: MainScene.ModifyTodo.ViewModel)
}

class MainViewController: UIViewController, MainDisplayLogic, Alertable
{
  
  var interactor: MainBusinessLogic?
  var router: (NSObjectProtocol & MainRoutingLogic & MainDataPassing)?
  
  // MARK: - IBoutlets
  
  // MARK: - Properties
  typealias Displayedtodo = MainScene.FetchTodoList.ViewModel.DisplayedTodo
  let refreshControl: UIRefreshControl = UIRefreshControl()
  var sections: [String] = []
  var page = 1
  var cancellables = Set<AnyCancellable>()
  @Published var todoList: [String: [Displayedtodo]] = [:]
  @Published private var isloading: Bool = false
  @Published private var fetchingMore = true

  //바텀 인디케이터
  lazy var bottomIndicator: UIActivityIndicatorView = {
    var indicator = UIActivityIndicatorView(style: .medium)
    indicator.color = UIColor.systemGray3
    indicator.startAnimating()
    indicator.frame = CGRect(x: 0, y: 0, width: myTableView.bounds.width, height: 50)
    return  indicator
  }()
  
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
  
  private func configureView() {
    self.view.backgroundColor = UIColor.theme.backgroundColor
    self.searchBar.clipsToBounds = true
    self.searchBar.layer.cornerRadius = 15
    self.searchBar.layer.borderWidth = 1
    self.searchBar.layer.borderColor = UIColor.theme.boardColor?.cgColor
    self.searchBar.addleftimage(image: UIImage.theme.magnifyingglass?.withTintColor(.gray) ?? UIImage())
    
    addButton.setImage(UIImage.theme.largePlusButton, for: .normal)
  }
  
  private func configureTableView()
  {
    let myTableViewCellNib = UINib(nibName: String(describing: MyTableViewCell.self), bundle: nil)
    self.myTableView.register(myTableViewCellNib, forCellReuseIdentifier: "MyTableViewCell")
    self.myTableView.rowHeight = UITableView.automaticDimension
    self.myTableView.estimatedRowHeight = 120
    self.myTableView.delegate = self
    self.myTableView.dataSource = self
    refreshControl.addTarget(self, action: #selector(self.refreshFunction), for: .valueChanged)
    self.myTableView.refreshControl = refreshControl
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
    configureView()
    addSubscription()
  }
  
  // MARK: - @IBOutlets
  
  @IBOutlet weak var myTableView: UITableView!
  @IBOutlet weak var addButton: UIButton!
  @IBOutlet weak var searchBar: UITextField!
  
  // MARK: - addSubscriptionn
  
  private func addSubscription() {
        
    $isloading.sink { [weak self] in
      guard let self = self else { return }
      self.myTableView.tableFooterView = $0 ? self.bottomIndicator : nil
    }
    .store(in: &cancellables)
    
    searchBar.textPublisher()
      .delay(for: 1, scheduler: DispatchQueue.main)
      .sink { [weak self] in
        guard let self = self else { return }
        self.page = 1
        self.searchTodos($0)
      }
      .store(in: &cancellables)
    
    myTableView.reachedBottomPublisher().combineLatest(searchBar.textPublisher)
      .delay(for: 0.5, scheduler: DispatchQueue.main)
      .sink {[weak self] in
        guard let self = self else { return }
        if self.fetchingMore {
          self.searchTodos($1 ?? "")
        }
      }
      .store(in: &cancellables)
    
    myTableView.willDisplayHeaderViewPublisher.sink { headerView, sesction in
        let header = headerView as? UITableViewHeaderFooterView
        header?.textLabel?.textColor = .black
      }
      .store(in: &cancellables)
    
    myTableView.didSelectRowPublisher
      .sink { [weak self] indexPath in
        guard let self = self else { return }
        let date = self.sections[indexPath.section]
        guard let todos = self.todoList[date] else { return  }
        self.router?.routeToDetail(todoId: todos[indexPath.row].id)
      }
      .store(in: &cancellables)
  }
  
  // MARK: 인터랙터에게 보내는 메서드
  
  private func searchTodos(_ todo: String) {
    if todo == "" {
      fetchTodoList()
    } else {
      searchTodoList(quary: todo)
    }
  }
  
  func fetchTodoList() {
    self.isloading = true
    self.fetchingMore = false
    let request = MainScene.FetchTodoList.Request(page: page)
    interactor?.fetchTodoList(request: request)
  }
  
  func searchTodoList(quary: String) {
    self.isloading = true
    self.fetchingMore = false
    let request = MainScene.FetchSearchTodoList.Request(quary: quary, page: page)
    interactor?.fetchTodoList(request: request)
  }
  
  func deleteTodo(id: Int) {
    let deleteRequest = MainScene.DeleteTodo.Request(id: id)
    interactor?.deleteTodo(request: deleteRequest)
  }
  
  func modifyTodo(id: Int, title: String, isDone: Bool) {
    
    let request = MainScene.ModifyTodo.Request(id: id, title: title, isDone: isDone)
    interactor?.modifyTodo(request: request)
  }
  
  @IBAction func presentModal(_ sender: Any) {
    router?.presentModalAdd()
  }
  
  // MARK: - 프리젠터에서 뷰로 보내진
  
  func displayTodoList(viewModel: MainScene.FetchTodoList.ViewModel) {
    
    guard let error = viewModel.error else {
      // 에러 없음
      self.page = viewModel.page ?? 1
      self.todoList = viewModel.displayedTodoList
      self.sections = viewModel.sections
      
      DispatchQueue.main.async { [weak self] in
        self?.myTableView.reloadData()
        self?.fetchingMore = viewModel.isFetch ?? true
        self?.isloading = false
      }
      return
    }
    // 에러 있음
    
    DispatchQueue.main.async { [weak self] in
      self?.showErrorAlertWithConfirmButton(error.errorDescription ?? "")
    }
  }
  
  func displayAddTodo(viewModle: MainScene.FetchTodoList.ViewModel) {
    
    self.todoList = viewModle.displayedTodoList
    self.sections = viewModle.sections
    
    DispatchQueue.main.async { [weak self] in
      self?.myTableView.reloadData()
    }
  }
  
  func displayedDeleteTodo(viewModel: MainScene.DeleteTodo.ViewModel) {
    guard let error = viewModel.error else {
      
      guard let indexPath = viewModel.indexPath,
            let sectionIndex = viewModel.indexPath?.section,
            let rowIndex = viewModel.indexPath?.row  else {
        return
      }
      
      let section = sections[sectionIndex]
      self.todoList[section]?.remove(at: rowIndex)
      
      DispatchQueue.main.async { [weak self] in
        
        self?.myTableView.deleteRows(at: [indexPath], with: .automatic)
        
      }
      return
    }
    
    DispatchQueue.main.async { [weak self] in
      self?.showErrorAlertWithConfirmButton(error.errorDescription ?? "")
    }
  }
  
  func displayedModifyTodo(viewModel: MainScene.ModifyTodo.ViewModel) {
    guard let error = viewModel.error else {
      
      guard let indexPath = viewModel.indexPath,
            let sectionIndex = viewModel.indexPath?.section,
            let rowIndex = viewModel.indexPath?.row else {
        return
      }
      
      self.todoList[sections[sectionIndex]]?[rowIndex] = MainViewController.Displayedtodo(
        id: viewModel.disPlayTodo?.id ?? 0,
        title: viewModel.disPlayTodo?.title ?? "",
        isDone: viewModel.disPlayTodo?.isDone ?? false,
        updatedTime: viewModel.disPlayTodo?.updatedTime ?? "",
        updatedDate: viewModel.disPlayTodo?.updatedDate ?? ""
      )
      
      DispatchQueue.main.async { [weak self] in
        self?.myTableView.reloadRows(at: [indexPath], with: .automatic)
      }
      return
    }
    
    DispatchQueue.main.async { [weak self] in
      self?.showErrorAlertWithConfirmButton(error.errorDescription ?? "")
    }
  }
}

// MARK: - TableView

extension MainViewController: UITableViewDelegate
{
  @objc func refreshFunction() {
    self.page = 1
    searchTodos(self.searchBar.text ?? "")
    
    refreshControl.endRefreshing()
  }
  
  func tableView(_ tableView: UITableView, editingStyleForRowAt indexPath: IndexPath) -> UITableViewCell.EditingStyle {
    return .delete
  }
  
  func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
    if editingStyle == .delete {
      let data = self.sections[indexPath.section]
      guard let todos = self.todoList[data] else { return }
      
      self.deleteTodo(id: todos[indexPath.row].id)
    }
  }
}

extension MainViewController: UITableViewDataSource
{
  func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
    return sections[section]
  }
  
  func numberOfSections(in tableView: UITableView) -> Int {
    return sections.count
  }
  
  func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    guard let sectionsCount = todoList[sections[section]]?.count else {
      return 0
    }
    return sectionsCount
  }
  
  func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
    
    guard let cell = myTableView.dequeueReusableCell(withIdentifier: "MyTableViewCell", for: indexPath) as? MyTableViewCell else {
      return UITableViewCell()
    }
    
    let date = sections[indexPath.section]
    guard let todos = todoList[date] else { return cell }
    cell.configureCell(todo: todos[indexPath.row])
    
    cell.onEditAction = { [weak self] clickedTodo in
      let idDone = !clickedTodo.isDone
      self?.modifyTodo(id: clickedTodo.id, title: clickedTodo.title, isDone: idDone)
    }
    return cell
  }
}
