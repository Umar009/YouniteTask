//
//  HomeViewRouter.swift
//  YouniteTask
//
//  Created by The Mac Store on 19/06/2022.
//

import Foundation
import UIKit

protocol HomeViewRouterProtocol: AnyObject {
}

class HomeViewRouter: NSObject {

    weak var presenter: HomeViewPresenterProtocol?

    static func setupModule() -> HomeViewController {
        let controller = HomeViewController()
        let router = HomeViewRouter()
        let presenter = HomeViewPresenter( router: router, view: controller)

        controller.presenter = presenter
        router.presenter = presenter
        return controller
    }
}

extension HomeViewRouter: HomeViewRouterProtocol {
}
