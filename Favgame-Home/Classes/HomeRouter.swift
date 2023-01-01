//
//  HomeRouter.swift
//  Favgame
//
//  Created by deri indrawan on 31/12/22.
//

import Foundation
import Favgame_Core
import Swinject

public class HomeRouter {
  public init() {}
  public let container: Container = {
    let container = Injection().container
    
    container.register(HomeViewController.self) { resolver in
      let controller = HomeViewController()
      controller.getListGameUseCase = resolver.resolve(GetListGameUseCase.self)
      return controller
    }
    return container
  }()
}
