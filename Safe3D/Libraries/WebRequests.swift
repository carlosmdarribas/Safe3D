//
//  WebRequests.swift
//  Safe3D
//
//  Created by Carlos Martin de Arribas on 28/11/2020.
//

import Foundation
import Alamofire

class WebRequests {
    static var bcIP:String = "http://172.16.0.54:8000"
    
    static func getChangesHistoric(completionHandler:@escaping (_ historic: [Change]) -> (), errorHandler:@escaping (_ error: String) -> ()) {
        let url = bcIP + "/get_all_changes"
        
        AF.request(url).responseString { (response) in
            switch response.result {
            case let .success(value):
                print(value)
                
                let results = matches(for: "\\((.*?)\\)", in: value.replacingOccurrences(of: "[", with: "").replacingOccurrences(of: "]", with: ""))
                print(results)
                
                var changes = [Change]()
                for result in results { changes.append(Change(withRawString: result)) }
                
                completionHandler(changes)
            case let .failure(error):
                print(error)
                errorHandler(error.localizedDescription)
            }
        }
    }
    
    static func matches(for regex: String, in text: String) -> [String] {
        do {
            let regex = try NSRegularExpression(pattern: regex)
            let results = regex.matches(in: text,
                                        range: NSRange(text.startIndex..., in: text))
            return results.map {
                String(text[Range($0.range, in: text)!])
            }
        } catch let error {
            print("invalid regex: \(error.localizedDescription)")
            return []
        }
    }
}
