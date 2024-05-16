
import UIKit
import SceneKit
import ARKit
import AVFoundation
import ARVideoKit

class ViewController: UIViewController, ARSCNViewDelegate, UICollectionViewDelegate, UICollectionViewDataSource {
    
    @IBOutlet weak var recordButton: UIButton!
    @IBOutlet weak var filtersCollectionsView: UICollectionView!
    @IBOutlet var sceneView: ARSCNView!

    private var filterImages: [String] = ["must1","must2","must3","must4"]
    private var filterNames: [String] = ["Mustache1","Mustache2","Mustache3","Mustache4"]
    private var selectedFilter  = ""
    private var recorder: RecordAR?
    private var contentNode: SCNNode?

    private var isRecording = false

    private let viewModel = ViewModel()

    private let configuration = ARFaceTrackingConfiguration()

    // MARK: - Life Cycle Methods

    override func viewDidLoad() {
        super.viewDidLoad()
        
        let nibCell = UINib(nibName: "FilterCollectionViewCell", bundle: nil)
        filtersCollectionsView.register(nibCell, forCellWithReuseIdentifier: "cell")

        self.title = "Home"
        let barButtonItem = UIBarButtonItem(barButtonSystemItem: .save, target: self, action: #selector(rightBarButtonItemTapped))
        navigationItem.rightBarButtonItem = barButtonItem

        sceneView.delegate = self
        sceneView.showsStatistics = true
        
        recorder = RecordAR(ARSceneKit: sceneView)
        
        configuration.maximumNumberOfTrackedFaces = ARFaceTrackingConfiguration.supportedNumberOfTrackedFaces
        configuration.isLightEstimationEnabled = true
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        // Create a session configuration
        resetTracking()
        let configuration = ARWorldTrackingConfiguration()
        recorder?.prepare(configuration)
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        // Pause the view's session
        sceneView.session.pause()
        recorder?.rest()
    }

    @IBAction func captureButton(_ sender: Any) {
        if isRecording {
            isRecording = false
            recordButton.setImage(UIImage(named: "start-recording"), for: .normal)
            recorder?.stop({[weak self] videoPath in
                self?.processVideo(videoPath: videoPath)
            })

        } else {
            recorder?.record()
            recordButton.setImage(UIImage(named: "stop-recording"), for: .normal)
            isRecording = true
        }
    }

    @objc func rightBarButtonItemTapped() {
        let videoListViewController = VideosViewController()
        self.navigationController?.pushViewController(videoListViewController, animated: true)
    }

    // MARK: - ARSCNViewDelegate
    
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

    // MARK: UICollectionViewDelegate

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

    // MARK: - Private Methods

    private func resetTracking() {
        guard ARFaceTrackingConfiguration.isSupported else { return }
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

    private func processVideo(videoPath: URL) {
        let name = "\(Date().timeIntervalSince1970)" + "_Video"
        if let fileUrl = self.storeVideoToFileManagerWith(fileName: name, tempURL: videoPath) {
            self.viewModel.saveVideoUrlInCoreData(id: name, url: "\(fileUrl)")
            DispatchQueue.main.async {
                let alert = UIAlertController(title: "Success", message: "Video Saved Successfully", preferredStyle: .alert)
                let action = UIAlertAction(title: "Done", style: .destructive)
                alert.addAction(action)
                self.present(alert, animated: true)
            }
        }
    }

    private func storeVideoToFileManagerWith(fileName: String, tempURL: URL) -> URL? {
        let fileURL = FileManager.getDocumentsDirectory().appendingPathComponent(fileName).appendingPathExtension("mp4")

        // Create the directory if it doesn't exist
        let directoryURL = fileURL.deletingLastPathComponent()
        if !FileManager.default.fileExists(atPath: fileURL.path) {
            do {
                try FileManager.default.createDirectory(at: directoryURL, withIntermediateDirectories: true, attributes: nil)
            } catch {
                print("Unable to create directory (\(error.localizedDescription))")
                return nil
            }
        }

        do {
            // Copy the video file from the temporary URL to the destination URL
            try FileManager.default.copyItem(at: tempURL, to: fileURL)
            return fileURL
        } catch {
            print("Unable to copy video file (\(error.localizedDescription))")
            return nil
        }
    }
}
