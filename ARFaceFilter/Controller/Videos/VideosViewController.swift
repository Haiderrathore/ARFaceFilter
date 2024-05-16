
import UIKit
import AVFoundation
import AVKit

class VideosViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {

    @IBOutlet weak var tableView: UITableView!
    
    private let persistanceStore = PersistanceStore()
    private var videos: [Video] = []
    var player: AVPlayer?
    var playerViewController: AVPlayerViewController?

    override func viewDidLoad() {
        super.viewDidLoad()

        self.title = "Videos"
        tableView.register(VideoTableViewCell.self, forCellReuseIdentifier: "cell")
        loadVideos()
    }

    // MARK: - UITableViewDataSource
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return videos.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath) as! VideoTableViewCell
        let video = videos[indexPath.row]
        cell.configure(title: video.id ?? "")
        return cell
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if let videoURL = URL(string:videos[indexPath.row].localUrl ?? "") {
            // Create AVPlayer instance
            player = AVPlayer(url: videoURL)
            
            // Create AVPlayerViewController instance
            playerViewController = AVPlayerViewController()
            playerViewController?.player = player

            // Present the player view controller
            if let playerViewController = playerViewController {
                present(playerViewController, animated: true) {
                    // Start playing the video when the player view controller is presented
                    self.player?.play()
                }
            }
        }
    }

    private func loadVideos() {
        self.videos = persistanceStore.loadVideos()
    }
}
