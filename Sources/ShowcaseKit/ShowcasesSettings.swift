//
//  ShowcasesSettings.swift
//  ShowcaseKit-iOS
//
//  Created by Jérôme Alves on 09/09/2019.
//  Copyright © 2019 Heetch. All rights reserved.
//

import Foundation

public final class ShowcasesSettings {

    public static let shared = ShowcasesSettings()

    public var searchQuery: String? {
        get {
            return UserDefaults.standard.string(forKey: "showcases-search-query")
        }
        set {
            UserDefaults.standard.set(newValue, forKey: "showcases-search-query")
        }
    }

    public var automaticReadableTitleDropablePrefixes: [String] = [
        "NS", // Foundation
        "UI", // UIKit
        "CL", // CoreLocation
        "MK", // MapKit
        ]

    public var automaticReadableTitleTransform: (String) -> String = { title in
        return title
            .replacingOccurrences(of: "Showcase", with: "")
            .replacingOccurrences(of: ".Type", with: "")
            .dropPrefixes(
                ShowcasesSettings.shared.automaticReadableTitleDropablePrefixes
            )
            .splittingOnCamelCase()
    }
}
