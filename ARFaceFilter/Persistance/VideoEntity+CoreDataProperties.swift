
import Foundation
import CoreData


extension VideoEntity {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<VideoEntity> {
        return NSFetchRequest<VideoEntity>(entityName: "VideoEntity")
    }

    @NSManaged public var id: String?
    @NSManaged public var localUrl: String?
}

extension VideoEntity : Identifiable {
    func convertToVideo() -> Video {
        return Video(id: id, localUrl: localUrl)
    }
}


class Video {
    var id: String?
    var localUrl: String?
    
    init(id: String? = nil, localUrl: String? = nil) {
        self.id = id
        self.localUrl = localUrl
    }
}
