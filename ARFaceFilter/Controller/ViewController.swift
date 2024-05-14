//
//  ViewController.swift
//  ARFaceFilter
//
//  Created by Haider Rathore on 13/05/2024.
//

import UIKit
import SceneKit
import ARKit

class ViewController: UIViewController, ARSCNViewDelegate, UICollectionViewDelegate, UICollectionViewDataSource {
    
    var filterImages:[String] = ["must1","must2","must3","must4"]
    var filterNames:[String] = ["Mustache1","Mustache2","Mustache3","Mustache4"]
    var selectedFilter  = ""
  
    
    @IBOutlet weak var filtersCollectionsView: UICollectionView!
    
    @IBOutlet var sceneView: ARSCNView!
    private var contentNode: SCNNode?
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
            
            let nibCell = UINib(nibName: "FilterCollectionViewCell", bundle: nil)
            filtersCollectionsView.register(nibCell, forCellWithReuseIdentifier: "cell")
            
        // Set the view's delegate
        sceneView.delegate = self
        // Show statistics such as fps and timing information
        sceneView.showsStatistics = true
        // Create a new scene
    }
        
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        // Create a session configuration
        resetTracking()
    }
    
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        // Pause the view's session
        sceneView.session.pause()
    }

    func renderer(_ renderer: SCNSceneRenderer, nodeFor anchor: ARAnchor) -> SCNNode? {
        
        guard let sceneView = renderer as? ARSCNView, anchor is ARFaceAnchor else { return nil }
        
        let faceGeometry = ARSCNFaceGeometry(device: sceneView.device!)!
        
        let material = faceGeometry.firstMaterial!
                
        material.diffuse.contents = UIImage(named: "art.scnassets/\(selectedFilter).png")
        
        material.lightingModel = .physicallyBased
        
        contentNode = SCNNode(geometry: faceGeometry)
        
        return contentNode
    }
    
    func renderer(_ renderer: SCNSceneRenderer, didUpdate node: SCNNode, for anchor: ARAnchor) {
        guard let faceGeometry = node.geometry as? ARSCNFaceGeometry,
                    let faceAnchor = anchor as? ARFaceAnchor
                    else { return }
                
            faceGeometry.update(from: faceAnchor.geometry)
    }
    
    private func resetTracking() {
            guard ARFaceTrackingConfiguration.isSupported else { return }
            let configuration = ARFaceTrackingConfiguration()
            configuration.maximumNumberOfTrackedFaces = ARFaceTrackingConfiguration.supportedNumberOfTrackedFaces
            configuration.isLightEstimationEnabled = true
            sceneView.session.run(configuration, options: [.resetTracking, .removeExistingAnchors])
    }

    private func displayErrorMessage(title: String, message: String) {
            let alertController = UIAlertController(title: title, message: message, preferredStyle: .alert)
            let restartAction = UIAlertAction(title: "Restart Session", style: .default) { _ in
                alertController.dismiss(animated: true, completion: nil)
                self.resetTracking()
            }
            alertController.addAction(restartAction)
            present(alertController, animated: true, completion: nil)
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return filterNames.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = filtersCollectionsView.dequeueReusableCell(withReuseIdentifier: "cell", for: indexPath) as! FilterCollectionViewCell
        
        cell.filterImage.image = UIImage(named: filterImages[indexPath.row])
        cell.filterName.text = filterNames[indexPath.row]
        return cell
        
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        selectedFilter = filterImages[indexPath.row]
        print("Selected: \(selectedFilter)")
        resetTracking()
    }
}
