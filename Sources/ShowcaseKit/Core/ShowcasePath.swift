//
//  ShowcasePath.swift
//  ShowcaseKit-iOS
//
//  Created by Jérôme Alves on 09/09/2019.
//  Copyright © 2019 Heetch. All rights reserved.
//

import Foundation

public struct ShowcasePath: Equatable {

    public static let root = ShowcasePath(path: [], index: 0)
    private let path: [ShowcasePathComponent]
    private let index: Int

    private init(path: [ShowcasePathComponent], index: Int) {
        self.path = path
        self.index = index
    }

    private func appending(_ component: ShowcasePathComponent) -> ShowcasePath {
        return ShowcasePath(path: path.appending(component), index: index)
    }

    private func replacingLast(by component: ShowcasePathComponent) -> ShowcasePath {
        return ShowcasePath(path: Array(path.dropLast().appending(component)), index: index)
    }

    public func underSection(named sectionName: ShowcaseSectionName) -> ShowcasePath {
        return appending(.section(sectionName))
    }

    public func inFolder(named folderName: ShowcaseFolderName) -> ShowcasePath {
        guard let last = path.last else {
            return appending(.folder(folderName, underSection: nil))
        }
        switch last {
        case .folder:
            return appending(.folder(folderName, underSection: nil))
        case let .section(sectionName):
            return replacingLast(by: .folder(folderName, underSection: sectionName))
        }
    }

    internal func push() -> ShowcasePath {
        return ShowcasePath(path: path, index: min(index + 1, path.count))
    }

    internal func pop() -> ShowcasePath {
        return ShowcasePath(path: path, index: max(index - 1, 0))
    }

    internal func resolve() -> [ShowcasePathComponent] {
        return Array(path.dropFirst(index))
    }

    public var fullPathDescription: String? {
        let components = resolve()
        guard components.isEmpty == false else {
            return nil
        }
        return components
            .flatMap { [$0.sectionName?.rawValue, $0.folderName?.rawValue].compactMap { $0 } }
            .joined(separator: " → ")
    }
}

internal enum ShowcasePathComponent: Equatable {

    case section(ShowcaseSectionName)
    case folder(ShowcaseFolderName, underSection: ShowcaseSectionName?)

    var sectionName: ShowcaseSectionName? {
        switch self {
        case .section(let name):
            return name
        case .folder(_, let name):
            return name
        }
    }

    var folderName: ShowcaseFolderName? {
        switch self {
        case .section:
            return nil
        case .folder(let name, _):
            return name
        }
    }
}

public struct ShowcaseSectionName: RawRepresentable, ExpressibleByStringLiteral, Hashable {
    public let rawValue: String
    public init(rawValue: String) {
        self.rawValue = rawValue
    }
    public init(stringLiteral rawValue: String) {
        self.rawValue = rawValue
    }
}

public struct ShowcaseFolderName: RawRepresentable, ExpressibleByStringLiteral, Hashable {
    public let rawValue: String
    public init(rawValue: String) {
        self.rawValue = rawValue
    }
    public init(stringLiteral rawValue: String) {
        self.rawValue = rawValue
    }
}


