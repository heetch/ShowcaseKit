//
//  ShowcaseDescription.swift
//  ShowcaseKit-iOS
//
//  Created by Jérôme Alves on 09/09/2019.
//  Copyright © 2019 Heetch. All rights reserved.
//

import Foundation

/**
 A value type describing a Showcase properties based on the given `Showcasable` properties
 */
public struct ShowcaseDescription: Hashable, Equatable, CaseIterable {

    public static var allCases: [ShowcaseDescription] = .all

    public static func == (lhs: ShowcaseDescription, rhs: ShowcaseDescription) -> Bool {
        return lhs.title == rhs.title && lhs.className == rhs.className && lhs.path == rhs.path
    }

    public func hash(into hasher: inout Hasher) {
        hasher.combine(title)
        hasher.combine(className)
        hasher.combine(path.fullPathDescription)
    }

    public let title: String
    public let path: ShowcasePath
    public let className: String
    public let classType: Showcase.Type
    public let presentationMode: ShowcasePresentationMode

    public func pushPath() -> ShowcaseDescription {
        return ShowcaseDescription(
            title: title,
            path: path.push(),
            className: className,
            classType: classType,
            presentationMode: presentationMode
        )
    }

    public func popPath() -> ShowcaseDescription {
        return ShowcaseDescription(
            title: title,
            path: path.pop(),
            className: className,
            classType: classType,
            presentationMode: presentationMode
        )
    }

    public func disambiguate(count: Int) -> ShowcaseDescription {
        return ShowcaseDescription(
            title: title + " (\(count))",
            path: path,
            className: className,
            classType: classType,
            presentationMode: presentationMode
        )
    }
}

extension ShowcaseDescription {
    public init(class showcaseClass: Showcase.Type) {
        title = showcaseClass.title
        path = showcaseClass.path
        className = String(describing: showcaseClass).replacingOccurrences(of: ".Type", with: "")
        classType = showcaseClass
        presentationMode = showcaseClass.presentationMode
    }
}


