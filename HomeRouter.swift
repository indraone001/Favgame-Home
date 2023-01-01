//
//  HomeRouter.swift
//  Favgame
//
//  Created by deri indrawan on 31/12/22.
//

import Foundation
import Favgame-Core

public class HomeRouter {
  let container: Container = {
    let container = Injection().container
    
    container.register(HomeViewController.self) { resolver in
      let controller = HomeViewController()
      controller.getListGameUseCase = resolver.resolve(GetListGameUseCase.self)
      return controller
    }
    return container
  }()
}
