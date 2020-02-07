//
//  Note.swift
//  SwiftBeginner-L2
//
//  Created by Andrey Stecenko on 7/29/19.
//  Copyright © 2019 Andrii Stetsenko. All rights reserved.
//

import Foundation

public struct Note: JSONDecodable {

    public let text: String
    public let identifier: String
    public let userID: String
    public let lastModified: Date

    public init(text: String, identifier: String, userID: String) {
        self.text = text
        self.identifier = identifier
        self.userID = userID
        self.lastModified = Date()
    }

    public init?(JSON: Any) {
        guard let JSON = JSON as? [String: AnyObject] else { return nil }

        guard let idn = JSON["_id"] as? String else { return nil }
        guard let text = JSON["_source"]?["notetext"] as? String else { return nil }
        guard let userID = JSON["_source"]?["userID"] as? String else { return nil }

        self.text = text
        self.identifier = idn
        self.userID = userID
        
        // сдесь нам нужно проверить если ключ пришел вместе с JSON то нам нужно его сохранить
        if let modified = JSON["_source"]?["lastModified"] as? String,
            let dateInterval = Double(modified) {
            self.lastModified = Date(timeIntervalSince1970: dateInterval)
        } else {
            self.lastModified = Date()
        }
    }
    
    static func == (left: Note, right: Note) -> Bool {
        return left.identifier == right.identifier
    }
    
}

public struct Notes: JSONDecodable {
    let notes: [Note]

    public init(notes: [Note]) {
        self.notes = notes
    }

    init?(JSON: Any) {
        guard let JSON = JSON as? [String: AnyObject] else { return nil }
        // print("JSON to parse = \(JSON)")

        guard let hits = JSON["hits"]?["hits"] as? [AnyObject] else { return nil }

        var buffer = [Note]()

        for hitData in hits {
            // print("print \(hitData)")

            if let hit = Note(JSON: hitData) {
                buffer.append(hit)
            }
        }
        
        self.notes = buffer
    }
    
}
