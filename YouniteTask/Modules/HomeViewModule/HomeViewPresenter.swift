//
//  HomeViewPresenter.swift
//  YouniteTask
//
//  Created by The Mac Store on 19/06/2022.
//

import Foundation

protocol HomeViewPresenterProtocol: AnyObject {
    func sendData(ipAddress : String,port : String,data : Data?)
}

class HomeViewPresenter {

    unowned var view: HomeViewControllerProtocol
    let router: HomeViewRouterProtocol?
    let webSocket = SwiftWebSocketClient.shared

    init(router: HomeViewRouterProtocol, view: HomeViewControllerProtocol) {
        self.view = view
        self.router = router
    }
}

extension HomeViewPresenter: HomeViewPresenterProtocol {
    
    func RecursiveFunctionToSendImage(index : Int,chunks : [Data])
    {
        let data = ImageDataResponse(index: index, length: chunks.count, base64: chunks[index].base64EncodedString())
        
        self.webSocket.webSocket?.send(.data(try! JSONEncoder().encode(data))) { error in
            if let error = error {
                self.view.showMessage(message: error.localizedDescription)
                print("Error when sending a message \(error.localizedDescription)")
                return
            }
            print("done")
            if index < (chunks.count - 1)
            {
                print(chunks[index])
                DispatchQueue.main.async {
                    self.RecursiveFunctionToSendImage(index: index + 1, chunks: chunks)
                }
                return
            }
            self.view.showMessage(message: "Completed")
            self.webSocket.closeSocket()
            
        }
    }
    func sendData(ipAddress : String,port : String,data : Data?)
    {
        self.view.showMessage(message: "Please Wait Connecting to IpAddress")
        self.webSocket.connectToSocket(ipAddress: ipAddress, port: port)
        { state in
            if state == .connected{
                if let imageData = data
                {
                    self.view.showMessage(message: "Sending Image. Please wait")
                    self.RecursiveFunctionToSendImage(index: 0, chunks: imageData.getChunks())
                }
            }
            else{
                self.view.showMessage(message: "unable to connect to ipaddress please try again")
            }
        }
    }
}
