//
//  SwiftWebSocketServer.swift
//  YouniteTask
//
//  Created by The Mac Store on 19/06/2022.
//
import Network
import Foundation
import UIKit


class SwiftWebSocketServer {
    var listener: NWListener
    var connectedClients: [NWConnection] = []
    
    init(port: UInt16) {
        
        let parameters = NWParameters(tls: nil)
        parameters.allowLocalEndpointReuse = true
        parameters.includePeerToPeer = true
        
        let wsOptions = NWProtocolWebSocket.Options()
        wsOptions.autoReplyPing = true
        
        parameters.defaultProtocolStack.applicationProtocols.insert(wsOptions, at: 0)
        
        do {
            if let port = NWEndpoint.Port(rawValue: port) {
                listener = try NWListener(using: parameters, on: port)
            } else {
                fatalError("Unable to start WebSocket server on port \(port)")
            }
        } catch {
            fatalError(error.localizedDescription)
        }
    }
    func stopServer()
    {
        let serverQueue = DispatchQueue(label: "ServerQueue")
//        listener.start(queue: serverQueue)
        listener.cancel()
    }
    func startServer(completion: @escaping (ServerResponse) -> Void) {
            let serverQueue = DispatchQueue(label: "ServerQueue")
            
            listener.newConnectionHandler = { newConnection in
                print("New connection connecting")
                
                func receive() {
                    newConnection.receiveMessage { (data, context, isComplete, error) in
                        if let data = data, let _ = context {
                            let imageData = try? JSONDecoder().decode(ImageDataResponse.self, from: data)
                            let response = ServerResponse(responseType: .data, data: imageData)
                            completion(response)
                            receive()
                        }
                    }
                }
                receive()
                
                newConnection.stateUpdateHandler = { state in
                    switch state {
                    case .ready:
                        print("Client ready")
                        try! self.sendMessageToClient(data: JSONEncoder().encode("Client Connected"), client: newConnection)
                    case .failed(let error):
                        print("Client connection failed \(error.localizedDescription)")
                    case .waiting(let error):
                        print("Waiting for long time \(error.localizedDescription)")
                    default:
                        break
                    }
                }

                newConnection.start(queue: serverQueue)
            }
            
            listener.stateUpdateHandler = { state in
                print(state)
                switch state {
                case .ready:
                    let connectionType = ServerConnectionResponse(connectionType: .sucess, message: "Server Ready")
                    completion(ServerResponse(responseType: .connection, data: connectionType))
                    print("Server Ready")
                case .failed(let error):
                    let connectionType = ServerConnectionResponse(connectionType: .failed, message: "Server Failed with  \(error.localizedDescription)")
                    completion(ServerResponse(responseType: .connection, data: connectionType ))
//                    print("Server failed with \(error.localizedDescription)")
                default:
                    let connectionType = ServerConnectionResponse(connectionType: .failed, message: "Error connecting server please try again")
                    completion(ServerResponse(responseType: .connection, data:connectionType ))
//                    let response = ServerResponse(type: 1, data: imageData)
                    break
                }
            }
            
            listener.start(queue: serverQueue)
        }
        
        func sendMessageToClient(data: Data, client: NWConnection) throws {
            let metadata = NWProtocolWebSocket.Metadata(opcode: .binary)
            let context = NWConnection.ContentContext(identifier: "context", metadata: [metadata])

            client.send(content: data, contentContext: context, isComplete: true, completion: .contentProcessed({ error in
                if let error = error {
                    print(error.localizedDescription)
                } else {
                }
            }))
        }
}
struct ImageDataResponse: Encodable,Decodable {
    let index: Int
    let length : Int
    let base64: String
}
struct ServerConnectionResponse {
    let connectionType: ConnectionType
    let message : String
}


struct ServerResponse {
    let responseType : ResponseType
    let data : Any
}
struct SocketQuoteResponse: Encodable,Decodable {
    let t: String
    let body: QuoteResponseBody
}

struct QuoteResponseBody: Encodable,Decodable {
    let securityId: String
    let currentPrice: String
}

struct ConnectionAck: Encodable,Decodable {
    let t: String
    let connectionId: Int
}

enum ResponseType: Int {
    case connection = 0
    case data =  1
}

enum ConnectionType: Int {
    case sucess = 0
    case failed =  1
}
