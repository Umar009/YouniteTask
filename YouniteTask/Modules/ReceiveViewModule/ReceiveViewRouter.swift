//
//  ReceiveViewRouter.swift
//  YouniteTask
//
//  Created by The Mac Store on 19/06/2022.
//

import Foundation
import UIKit

protocol ReceiveViewRouterProtocol: AnyObject {
}

class ReceiveViewRouter: NSObject {

    weak var presenter: ReceiveViewPresenterProtocol?

    static func setupModule() -> ReceiveViewController {
        let controller = ReceiveViewController()
        let router = ReceiveViewRouter()
        let presenter = ReceiveViewPresenter( router: router, view: controller)

        controller.presenter = presenter
        router.presenter = presenter
        return controller
    }
}

extension ReceiveViewRouter: ReceiveViewRouterProtocol {
}
