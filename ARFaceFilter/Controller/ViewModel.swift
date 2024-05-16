
import Foundation

class ViewModel: NSObject {
    
    private let persistanceStore = PersistanceStore()

    func saveVideoUrlInCoreData(id: String, url: String) {
        persistanceStore.saveVideo(id: id, url: url)
    }
}
