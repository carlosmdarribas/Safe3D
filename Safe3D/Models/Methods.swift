//
//  Methods.swift
//  Safe3D
//
//  Created by Carlos Martin de Arribas on 28/11/2020.
//

import Foundation

enum Method: String, Codable {
    case change_property = "change_property"
    case change_model = "change_model"
    case addedToBC = "addedToBC"
}

class MessageMethod: Codable {
    let method: Method
}

class BCMethod: Codable {
    let txid: String
}
