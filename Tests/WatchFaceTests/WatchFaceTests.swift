//
//  WatchFaceTests.swift
//  Watchface
//
//  Created by Keith on 7/29/24.
//

import Watchface
import XCTest

@available(macOS 15.0, iOS 16.0, *)
final class WatchFaceTests: XCTestCase {
    override func setUpWithError() throws {
        print("\n")
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }

    override func tearDownWithError() throws {
        print("\n")
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }

    func testExample() async throws {
        let imageURLs = Bundle.module.urls(forResourcesWithExtension: "jpg", subdirectory: nil) ?? []
        let plistOfURL: [URL: Data] = try imageURLs.reduce(into: [:]) { result, url in
            let plistURL = url.deletingPathExtension().appendingPathExtension("plist")
            let data = try Data(contentsOf: plistURL)
            result[url] = data
        }

        let photoWF = try await PhotosWatchface(plistOfURL: plistOfURL)
        let resultURL = try photoWF.generateURL()

        print(resultURL.absoluteString)
    }
}
