//
//  ReceiveViewPresenter.swift
//  YouniteTask
//
//  Created by The Mac Store on 19/06/2022.
//

import Foundation

protocol ReceiveViewPresenterProtocol: AnyObject {
    func startServer()
    func stopServer()
    
    
}

class ReceiveViewPresenter {

    unowned var view: ReceiveViewControllerProtocol
    let router: ReceiveViewRouterProtocol?
    var server  = SwiftWebSocketServer(port: 8080)
    
    init(router: ReceiveViewRouterProtocol, view: ReceiveViewControllerProtocol) {
        self.view = view
        self.router = router
    }
}

extension ReceiveViewPresenter: ReceiveViewPresenterProtocol {
    
    func stopServer()
    {
        server.stopServer()
    }
    func startServer() {
        server.startServer{ response in
            if response.responseType == .data
            {
                
                if let imageData = response.data as? ImageDataResponse {
                    self.view.receiveImagePackage(imageData: imageData)
                }
            }
            else
            {
                if let response = response.data as? ServerConnectionResponse
                {
                    self.view.connectionCallBack(response: response)
                }
            }

        }
    }
    
}
