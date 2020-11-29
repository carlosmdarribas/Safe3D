//
//  ViewController+UITableView.swift
//  Safe3D
//
//  Created by Carlos Martin de Arribas on 28/11/2020.
//

import Foundation
import UIKit

extension ViewController: UITableViewDelegate, UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return tableView == tbleViewParts ? changes.count : color.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let reuseParts = "cellPart"
        let reuseColor = "cellColor"
        
        let cell: UITableViewCell!
        
        if tableView == tbleViewColor {
            cell = tableView.dequeueReusableCell(withIdentifier: reuseColor)
            cell.backgroundColor = .clear
            
            if let circleView = cell.contentView.viewWithTag(100) {
                circleView.backgroundColor = color[indexPath.row]
            }
        } else {
            cell = tableView.dequeueReusableCell(withIdentifier: reuseParts)
            let change = changes[indexPath.row]
            
            cell.textLabel?.text = "Cambio \((change.propertyChanges == 0) ? "textura" : "color") a \(change.valueChanged)"
            cell.detailTextLabel?.text = (change.bcid == nil) ? "Pendiente..." : change.bcid!.txid
            
            cell.backgroundColor = (change.bcid == nil) ? .systemRed : .clear
        }
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if tableView == tbleViewColor {
            currentColor = color[indexPath.row]
            socket.write(string: "{\"method\":\"change_property\",\"type\":1,\"value\":\"#\(currentColor.toHex() ?? "")\",\"username\":\"carlos\"}")
        } else {
            
            guard let bcid = changes[indexPath.row].bcid,
                  let url = URL(string: "https://rinkeby.etherscan.io/tx/\(bcid.txid)") else { return }
            UIApplication.shared.open(url)
        }
    }
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if tableView == tbleViewColor {
            return 100
        } else {
            return 50
        }
    }
}

