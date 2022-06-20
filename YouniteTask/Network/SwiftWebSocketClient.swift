//
//  SwiftWebSocketClient.swift
//  YouniteTask
//
//  Created by The Mac Store on 19/06/2022.
//
import Foundation

final class SwiftWebSocketClient: NSObject {
        
    static let shared = SwiftWebSocketClient()
    var webSocket: URLSessionWebSocketTask?
    
    var opened = false
    
    var connectionId = -1
    
    private override init() {
        // no-op
    }
    func connectToSocket(ipAddress : String,port : String,completion: @escaping (MessageType) -> Void)
    {
        if !opened {
            openWebSocket(ipAddress: ipAddress, port: port)
        }
        else{
            completion(.connected)
        }
        
        guard let webSocket = webSocket else {
            completion(.failed)
            return
        }
        webSocket.receive(completionHandler: { [weak self] result in
            
            guard let _ = self else { return }
            
            switch result {
            case .failure(let error):
                self?.closeSocket()
                completion(.failed)
                print("nil \(error.localizedDescription)")
            case .success(let webSocketTaskMessage):
                completion(.connected)
                print("success")
            }
        })
    }


    private func openWebSocket(ipAddress : String,port : String) {
        let address = "ws://\(ipAddress):\(port)"
        print(address)
        if let url = URL(string: address) {
            let request = URLRequest(url: url)
            let session = URLSession(configuration: .default, delegate: self, delegateQueue: nil)
            let webSocket = session.webSocketTask(with: request)
            self.webSocket = webSocket
            self.opened = true
            self.webSocket?.resume()
        } else {
            webSocket = nil
        }
    }
    
    func closeSocket() {
        webSocket?.cancel(with: .goingAway, reason: nil)
        opened = false
        webSocket = nil
    }
}

extension SwiftWebSocketClient: URLSessionWebSocketDelegate {
    func urlSession(_ session: URLSession, webSocketTask: URLSessionWebSocketTask, didOpenWithProtocol protocol: String?) {
        opened = true
    }

    
    func urlSession(_ session: URLSession, webSocketTask: URLSessionWebSocketTask, didCloseWith closeCode: URLSessionWebSocketTask.CloseCode, reason: Data?) {
        self.webSocket = nil
        self.opened = false
    }
}


struct GenericSocketResponse: Decodable {
    let t: String
}

enum MessageType: String {
    case connected = "connect"
    case failed =  "failed"
}
