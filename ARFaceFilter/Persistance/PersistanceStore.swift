//
//  PersistanceStore.swift
//  TargetofsAssessment
//
//  Created by Zohaib Afzal on 24/04/2024.
//

import Foundation

import CoreData

protocol PersistanceStoreProtocol {
    func saveArticles(articles: [Article])
    func saveImage(id: String, url: String)
    func loadArticles() -> [Article]?
    func loadImage(with Id: String) -> String?
}

struct PersistanceStore: PersistanceStoreProtocol {
    
    let context = PersistentStorage.shared.context
    
    // MARK: - PersistanceStoreProtocol
    
    func saveArticles(articles: [Article]) {
        // performBackgroundTask will ensure a designated queu for context since coredata
        // is not thread safe. This ensure core data concurrency
        
        clearDB { success in
            guard success else { return }
            
            PersistentStorage.shared.persistentContainer.performBackgroundTask { privateManagedContext in
                for article in articles {
                    let articleData = ArticleEntity(context: privateManagedContext)
                    articleData.id = Int64(article.id ?? 0)
                    articleData.url = article.url
                    articleData.updatedDate = article.updatedDate
                    articleData.title = article.title
                    articleData.abstract = article.abstract
                    articleData.mediaUrl = article.media?.first?.mediaMetaData?.last?.url
                    
                    if privateManagedContext.hasChanges {
                        do {
                            try privateManagedContext.save()
                        } catch let error as NSError {
                            print("Error in saving data in local db: \(error.localizedDescription)")
                        }
                    }
                }
            }
        }
    }

    func saveImage(id: String, url: String) {
        // performBackgroundTask will ensure a designated queu for context since coredata
        // is not thread safe. This ensure core data concurrency

        PersistentStorage.shared.persistentContainer.performBackgroundTask { privateManagedContext in
            let imageEntity = ImageEntity(context: privateManagedContext)
            imageEntity.id = id
            imageEntity.localUrl = url
            
            if privateManagedContext.hasChanges {
                try? privateManagedContext.save()
            }
        }
    }
    
    func loadImage(with id: String) -> String? {
        var imageUrl: String?
        // performAndWait would ensure the thread for the context since we can call loadPhotos from any thread
        // this ensure concurrency and thread safety of the context on main thread
        
        context.performAndWait {
            let res = PersistentStorage.shared.fetchRecord(managedObject: ImageEntity.self, withId: id)
            if let image = res {
                imageUrl = image.convertToImage()
            }
        }
        return imageUrl
    }
    
    func loadArticles() -> [Article]? {
        var articlesData: [Article]? = nil
        // performAndWait would ensure the thread for the context since we can call loadPhotos from any thread
        // this ensure concurrency and thread safety of the context on main thread
        context.performAndWait {
            let result = PersistentStorage.shared.fetchManagedObject(managedObject: ArticleEntity.self)
            articlesData = result?.map({ article in
                article.convertToArticle()
            })
        }
        return articlesData
    }

    private func clearDB(completion: @escaping (Bool) -> ()) {
        let deleteArticleRequest = NSBatchDeleteRequest(fetchRequest: NSFetchRequest<NSFetchRequestResult>(entityName: "ArticleEntity"))
        let deleteImagesRequest = NSBatchDeleteRequest(fetchRequest: NSFetchRequest<NSFetchRequestResult>(entityName: "ImageEntity"))
        do {
            try context.execute(deleteArticleRequest)
            try context.execute(deleteImagesRequest)
            completion(true)
        }
        catch {
            print(error)
            completion(false)
        }
    }
}
