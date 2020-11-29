//
//  ViewController+Starscream.swift
//  Safe3D
//
//  Created by Carlos Martin de Arribas on 28/11/2020.
//

import Foundation
import Starscream
import UIKit

extension ViewController: WebSocketDelegate {
    func websocketDidConnect(socket: WebSocketClient) {
        print("conectado a ws")
    }
    
    func websocketDidDisconnect(socket: WebSocketClient, error: Error?) {
        print("desconectado de WS")
    }
    
    func websocketDidReceiveMessage(socket: WebSocketClient, text: String) {
        print("Nuevo mensaje de WS  \(text)")
        guard let data = text.data(using: .utf8) else {
            print("Dtos incorrectos")
            return
        }
        
        do {
            let method = try JSONDecoder().decode(MessageMethod.self, from: data)
            
            switch method.method {
            case .change_model:
                print("Se ha cambiado el modelo")
                
            case .change_property:
                let change = try JSONDecoder().decode(Change.self, from: data)
                self.changes.append(change)
                
                currentColor = UIColor(initHex: change.valueChanged) ?? .darkGray
                self.tbleViewParts.reloadData()
                
            case .addedToBC:
                let bcid = try JSONDecoder().decode(BCMethod.self, from: data)

                self.changes.filter({$0.bcid == nil}).first?.bcid = bcid
                self.tbleViewParts.reloadData()
                print("Aádir a BC")
            }
        } catch {
            print("Error al parsear: \(error.localizedDescription)")
        }
    }
    
    func websocketDidReceiveData(socket: WebSocketClient, data: Data) {
        
    }
    
    
}
