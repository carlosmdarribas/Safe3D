//
//  ViewController.swift
//  ARDemoiOS
//
//  Created by Mishra, Neeraj Kumar (US - Bengaluru) on 05/07/19.
//  Copyright © 2019 Mishra, Neeraj Kumar (US - Bengaluru). All rights reserved.
//

import UIKit
import Starscream
import ARKit

class ViewController: UIViewController, ARSCNViewDelegate {
    @IBOutlet weak var sceneView: ARSCNView!
    var trackerNode: SCNNode?
    var foundSurface = false
    var tracking = true
    var car: SCNNode!
    var carSubNodes = [CarPart]()
    var socket: WebSocket!

    @IBOutlet weak var tbleViewColor: UITableView!
    @IBOutlet weak var tbleViewParts: UITableView!
    // Lifecycle method of the view
    
    let color = [UIColor.blue, UIColor.red, UIColor.black, UIColor.magenta, UIColor.cyan, UIColor.green]
    var changes = [Change]()
    
    var selectedPart = 0
    
    var currentColor: UIColor = .blue {
        didSet {
            changeBodyColor(to: currentColor)
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        sceneView.delegate = self
        
        // Show statistics such as fps and timing information
        sceneView.showsStatistics = true
        
        // Create a new scene
        let scene = SCNScene(named: "art.scnassets/car.scn")!

        // Set the scene to the view
        sceneView.scene = scene
        
        // Adding lighting to the scene
        sceneView.autoenablesDefaultLighting = true
        sceneView.automaticallyUpdatesLighting = true

        
        self.connectToWS()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        // Create a session configuration
        let configuration = ARWorldTrackingConfiguration()
        
        // Run the view's session
        sceneView.session.run(configuration)
        
        tbleViewColor.isHidden = true
        tbleViewParts.isHidden = true
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        // Pause the view's session
        sceneView.session.pause()
    }
    
    func connectToWS() {
        var request = URLRequest(url: URL(string: "http://172.16.0.54:8080")!)
        request.timeoutInterval = 5
        socket = WebSocket(request: request)
        socket.delegate = self
        socket.connect()
    }
    
    // Adding sub node and setting default color
    func getAllSubNodes(){
        // Adding Values to the arry which we have declared
        for item in car.childNodes {
            carSubNodes.append(CarPart.getNodeObj(item: item))
        }
        changeBodyColor(to: .blue)
        changeRimColor(to: .black)
        changeGlassColor(to: .red)
    }
    
    // Taking for the horizontal plane
    func renderer(_ renderer: SCNSceneRenderer, updateAtTime time: TimeInterval) {
        
        // Code for getting the Plane in the scene
        DispatchQueue.main.async {
            guard self.tracking else { return }
            let hitTest = self.sceneView.hitTest(CGPoint(x: self.view.frame.midX, y: self.view.frame.midY), types: .featurePoint)
            guard let result = hitTest.first else { return }
            let translation = SCNMatrix4(result.worldTransform)
            let position = SCNVector3Make(translation.m41, translation.m42, translation.m43)
            if self.trackerNode == nil {
                let plane = SCNPlane(width: 0.15, height: 0.15)
                plane.firstMaterial?.diffuse.contents = UIImage(named: "tracker.png")
                plane.firstMaterial?.isDoubleSided = true
                self.trackerNode = SCNNode(geometry: plane)
                self.trackerNode?.eulerAngles.x = -.pi * 0.5
                self.sceneView.scene.rootNode.addChildNode(self.trackerNode!)
                self.foundSurface = true
            }
            self.trackerNode?.position = position
        }
    }
    
    // Place the car on the view
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        print("Plane tapped by the user")
        if tracking {
            //Set up the scene
            guard foundSurface else { return }
            let trackingPosition = trackerNode!.position
            trackerNode?.removeFromParentNode()
            car = sceneView.scene.rootNode.childNode(withName: "car", recursively: false) ?? sceneView.scene.rootNode.childNode(withName: "ship", recursively: true)!
            car.position = trackingPosition
            car.isHidden = false
            tracking = false
            getAllSubNodes()
            
            // Configuring View
            tbleViewColor.isHidden = false
            tbleViewParts.isHidden = false
            
            tbleViewParts.dataSource = self
            tbleViewColor.dataSource = self
            tbleViewColor.delegate = self
            tbleViewParts.delegate = self
            
            tbleViewParts.reloadData()
            tbleViewColor.reloadData()
        } else {
            //Handle all other taps
        }
    }
    
    func changeColor(selectedColor: Int){
        switch selectedPart {
        case 0:
            changeBodyColor(to: color[selectedColor])
        case 1:
            changeGlassColor(to: color[selectedColor])
        case 2:
            changeRimColor(to: color[selectedColor])
        default:
            print("Interior not defined")
        }
    }

    
    // Delegate methods of ARSCNViewDelegate
    
    func session(_ session: ARSession, didFailWithError error: Error) {
        // Present an error message to the user
        
    }
    
    func sessionWasInterrupted(_ session: ARSession) {
        // Inform the user that the session has been interrupted, for example, by presenting an overlay
        
    }
    
    func sessionInterruptionEnded(_ session: ARSession) {
        // Reset tracking and/or remove existing anchors if consistent tracking is required
        
    }

}

// Method for changing the colors
extension ViewController {
    // Body Color
    func changeBodyColor(to color: UIColor) {
        // Setting the intial color
        let bodyPart = carSubNodes.filter{$0.type == PartType.body}
        for obj in bodyPart {
            obj.item.geometry = obj.item.geometry!.copy() as? SCNGeometry
            // Un-share the material, too
            obj.item.geometry?.firstMaterial = obj.item.geometry?.firstMaterial!.copy() as? SCNMaterial
            // Now, we can change node's material without changing parent and other childs:
            obj.item.geometry?.firstMaterial?.diffuse.contents = color
        }
    }
    
    // Rim Color
    func changeRimColor(to color: UIColor) {
        let rimPart = carSubNodes.filter{$0.type == PartType.rim}
        for obj in rimPart {
            obj.item.geometry = obj.item.geometry!.copy() as? SCNGeometry
            // Un-share the material, too
            obj.item.geometry?.firstMaterial = obj.item.geometry?.firstMaterial!.copy() as? SCNMaterial
            // Now, we can change node's material without changing parent and other childs:
            obj.item.geometry?.firstMaterial?.diffuse.contents = color
            
        }
    }
    
    // Glass color
    func changeGlassColor(to color: UIColor) {
        let glassPart = carSubNodes.filter{$0.type == PartType.glass}
        for obj in glassPart {
            obj.item.geometry = obj.item.geometry!.copy() as? SCNGeometry
            // Un-share the material, too
            obj.item.geometry?.firstMaterial = obj.item.geometry?.firstMaterial!.copy() as? SCNMaterial
            // Now, we can change node's material without changing parent and other childs:
            obj.item.geometry?.firstMaterial?.diffuse.contents = color
            obj.item.opacity = 0.2
        }
    }
}

extension UIColor {
    public convenience init?(initHex: String) {
        let r, g, b, a: CGFloat

        let hex = initHex + "FF"
        if hex.hasPrefix("#") {
            let start = hex.index(hex.startIndex, offsetBy: 1)
            let hexColor = String(hex[start...])

            if hexColor.count == 8 {
                let scanner = Scanner(string: hexColor)
                var hexNumber: UInt64 = 0

                if scanner.scanHexInt64(&hexNumber) {
                    r = CGFloat((hexNumber & 0xff000000) >> 24) / 255
                    g = CGFloat((hexNumber & 0x00ff0000) >> 16) / 255
                    b = CGFloat((hexNumber & 0x0000ff00) >> 8) / 255
                    a = CGFloat(hexNumber & 0x000000ff) / 255

                    self.init(red: r, green: g, blue: b, alpha: a)
                    return
                }
            }
        }

        return nil
    }
    
    var toHex: String? {
        return toHex()
    }

    // MARK: - From UIColor to String

    func toHex(alpha: Bool = false) -> String? {
        guard let components = cgColor.components, components.count >= 3 else {
            return nil
        }

        let r = Float(components[0])
        let g = Float(components[1])
        let b = Float(components[2])
        var a = Float(1.0)

        if components.count >= 4 {
            a = Float(components[3])
        }

        if alpha {
            return String(format: "%02lX%02lX%02lX%02lX", lroundf(r * 255), lroundf(g * 255), lroundf(b * 255), lroundf(a * 255))
        } else {
            return String(format: "%02lX%02lX%02lX", lroundf(r * 255), lroundf(g * 255), lroundf(b * 255))
        }
    }

}
