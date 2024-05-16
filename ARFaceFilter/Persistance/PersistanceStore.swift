
import Foundation
import CoreData

protocol PersistanceStoreProtocol {
    func saveVideo(id: String, url: String)
    func loadVideos() -> [Video]
}

struct PersistanceStore: PersistanceStoreProtocol {
    
    let context = PersistentStorage.shared.context
    
    // MARK: - PersistanceStoreProtocol

    func saveVideo(id: String, url: String) {
        // performBackgroundTask will ensure a designated queu for context since coredata
        // is not thread safe. This ensure core data concurrency

        PersistentStorage.shared.persistentContainer.performBackgroundTask { privateManagedContext in
            let imageEntity = VideoEntity(context: privateManagedContext)
            imageEntity.id = id
            imageEntity.localUrl = url
            
            if privateManagedContext.hasChanges {
                try? privateManagedContext.save()
            }
        }
    }
    
    func loadVideos() -> [Video] {
        var videos: [Video] = []
        // performAndWait would ensure the thread for the context since we can call loadPhotos from any thread
        // this ensure concurrency and thread safety of the context on main thread
        context.performAndWait {
            let result = PersistentStorage.shared.fetchManagedObject(managedObject: VideoEntity.self)
            videos = result?.map({ video in
                video.convertToVideo()
            }) ?? []
        }
        return videos
    }

    private func clearDB(completion: @escaping (Bool) -> ()) {
        let deleteImagesRequest = NSBatchDeleteRequest(fetchRequest: NSFetchRequest<NSFetchRequestResult>(entityName: "VideoEntity"))
        do {
            try context.execute(deleteImagesRequest)
            completion(true)
        }
        catch {
            print(error)
            completion(false)
        }
    }
}
