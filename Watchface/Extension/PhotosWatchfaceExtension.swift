//
//  PhotosWatchfaceExtension.swift
//  Watchface
//
//  Created by Keith on 7/29/24.
//

import Foundation
import Zip

@available(macOS 15.0, iOS 16.0, *)
public extension PhotosWatchface {
    static let encoder = JSONEncoder()
    static let plistDecoder = PropertyListDecoder()

    init(plistOfURL: [URL: Data]) async throws {
        let plists = try plistOfURL.values.map {
            try Self.plistDecoder.decode(Watchface.Resources.PhotosV1.Item.self, from: $0)
        }

        let files: [String: Data] = try await withThrowingTaskGroup(of: (String, Data).self) { group in
            for (url, name) in zip(plistOfURL.keys, plists.map(\.imageURL)) {
                group.addTask {
                    let data = try await URLSession.shared.data(from: url).0
                    return (name, data)
                }
            }

            return try await group.reduce(into: [:]) { $0[$1.0] = $1.1 }
        }

        let resources: Watchface.Resources = .init(images: .photos(.init(imageList: plists)), files: files)
        self.init(
            position: .top,
            snapshot: .init(),
            no_borders_snapshot: .init(),
            resources: resources
        )
    }

//    init(plists: [Data]) throws {
//        let items = plists.compactMap {
//            try? Self.plistDecoder.decode(Watchface.Resources.PhotosV1.Item.self, from: $0)
//        }
//        let files: [String: Data] = items.reduce(into: [:]) { result, item in
//            let name = String(item.imageURL.prefix(while: { $0 != "." }))
//            guard
//                let image = UIImage(named: name)
//            else { return }
//            result[item.imageURL] = image.jpegData(compressionQuality: 1)
//        }
//        let resources: Watchface.Resources = .init(images: .photos(.init(imageList: items)), files: files)
//        self.init(
//            position: .top,
//            snapshot: .init(),
//            no_borders_snapshot: .init(),
//            resources: resources
//        )
//    }
    
    func generateURL(rootURL: URL = .cachesDirectory.appending(path: "watchface")) throws -> URL {
        let manager = FileManager.default
        
        if manager.fileExists(atPath: rootURL.path()) {
            try manager.removeItem(at: rootURL)
        }
        try manager.createDirectory(at: rootURL, withIntermediateDirectories: true)
        
        let fileURL = rootURL.appending(path: "newFile")
        let wrapper = try FileWrapper(watchface: .init(photosWatchface: self))
        try wrapper.write(to: fileURL, originalContentsURL: nil)
        let contents = try manager.contentsOfDirectory(at: fileURL, includingPropertiesForKeys: nil)
        
        let watchfaceURL = rootURL.appending(path: "new.watchface")
        try Zip.zipFiles(paths: contents, zipFilePath: watchfaceURL, password: nil, progress: nil)
        
        return watchfaceURL
    }
}
