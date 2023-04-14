//
//  DetailViewController.swift
//  TodoVipApp
//
//  Created by song on 2023/04/02.
//  Copyright (c) 2023 ___ORGANIZATIONNAME___. All rights reserved.
//
//  This file was generated by the Clean Swift Xcode Templates so
//  you can apply clean architecture to your iOS and Mac projects,
//  see http://clean-swift.com
//

import UIKit

protocol DetailDisplayLogic: AnyObject
{
  func displaySomething(viewModel: Detail.PresentTodo.ViewModel)
  func displayModifyResult(viewModel: Detail.ModifyTodo.ViewModel)
}

class DetailViewController: UIViewController, DetailDisplayLogic, Alertable
{
  
  var interactor: DetailBusinessLogic?
  var router: (NSObjectProtocol & DetailRoutingLogic & DetailDataPassing)?
  
  // MARK: - properties
  var id: Int = 0
  
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
    let interactor = DetailInteractor()
    let presenter = DetailPresenter()
    let router = DetailRouter()
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
  
  override func viewWillDisappear(_ animated: Bool) {
    super.viewWillDisappear(animated)
    NotificationCenter.default.post(name: NSNotification.Name("ModalDismissNC"), object: nil, userInfo: nil)
  }
  
  override func viewDidLoad()
  {
    super.viewDidLoad()
    presentTodo()
  }
  
  // MARK: - @IBOutlets
  
  @IBOutlet weak var doWorkTextField: UITextField!
  @IBOutlet weak var finishSwitch: UISwitch!
  
  // MARK: 인터렉터한테 시키는 메서드
  
  func presentTodo()
  {
    let request = Detail.PresentTodo.Request()
    interactor?.fetchTodo(request: request)
  }
  
  @IBAction func modifyButtonDidTap(_ sender: Any) {
    
    let request = Detail.ModifyTodo.Request(
      id: self.id,
      title: doWorkTextField.text ?? "",
      isDone: finishSwitch.isOn)
    interactor?.modifyTodo(request: request)
  }

  // MARK: - 프리젠터에게 받는 메서드
  
  func displaySomething(viewModel: Detail.PresentTodo.ViewModel)
  {
    guard let error = viewModel.error else {
      //에러 없음
      DispatchQueue.main.async {
        self.doWorkTextField.text = viewModel.displayedTodo.title
        self.finishSwitch.isOn = viewModel.displayedTodo.isDone
        self.id = viewModel.displayedTodo.id
      }
      return
    }
    //에러 있음
    DispatchQueue.main.async {
      self.showErrorAlertWithConfirmButton(error.errorDescription ?? "")
    }
  }
  
  func displayModifyResult(viewModel: Detail.ModifyTodo.ViewModel) {
    guard let error = viewModel.error else {
      
      DispatchQueue.main.async {
        self.showSuccessAlertWithConfirmButton("\(viewModel.title ?? "") \(viewModel.isDone ?? false)로 변경했습니다!") {
          self.router?.dismiss()
        }
      }
      return
    }
    
    DispatchQueue.main.async {
      self.showErrorAlertWithConfirmButton(error.errorDescription ?? "")
    }
  }
}