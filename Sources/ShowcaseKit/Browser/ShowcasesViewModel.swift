//
//  ShowcaseViewModel.swift
//  ShowcaseKit-iOS
//
//  Created by Jérôme Alves on 09/09/2019.
//  Copyright © 2019 Heetch. All rights reserved.
//

import Foundation
import UIKit

public final class ShowcasesViewModel {

    public typealias Section = (name: String?, items: [Item])
    public enum Item: Comparable {
        case folder(named: String, content: [ShowcaseDescription])
        case showcase(ShowcaseDescription)
        public static func < (lhs: ShowcasesViewModel.Item, rhs: ShowcasesViewModel.Item) -> Bool {
            switch (lhs, rhs) {
            case let (.folder(lhs, _), .folder(rhs, _)):
                return lhs < rhs
            case let (.showcase(lhs), .showcase(rhs)):
                return lhs.title < rhs.title
            case (.folder, .showcase):
                return true
            case (.showcase, .folder):
                return false
            }
        }
        public static func == (lhs: ShowcasesViewModel.Item, rhs: ShowcasesViewModel.Item) -> Bool {
            switch (lhs, rhs) {
            case let (.folder(lhsName, lhsContent), .folder(rhsName, rhsContent)):
                return lhsName == rhsName && lhsContent.elementsEqual(rhsContent, by: ==)
            case let (.showcase(lhs), .showcase(rhs)):
                return lhs == rhs
            case (.folder, .showcase):
                return false
            case (.showcase, .folder):
                return false
            }
        }
    }

    public init(showcases: [ShowcaseDescription] = .all) {
        self.showcases = showcases
        defaultSections = makeSections(showcases: showcases)
    }

    private let showcases: [ShowcaseDescription]

    public var onDataUpdate: (() -> Void)?

    private let defaultSections: [Section]

    public var searchQuery: String? {
        didSet {
            updateSearchResults()
            ShowcasesSettings.shared.searchQuery = searchQuery
        }
    }

    private var searchResults: [ShowcaseDescription: SearchResult] = [:]

    public var uniqueShowcase: ShowcaseDescription? {
        if let showcase = showcases.first(where: { $0.className == searchQuery }) {
            return showcase
        }
        return searchResults.keys.count == 1
            ? searchResults.keys.first
            : nil
    }

    private var searchResultSections: [Section]? = nil {
        didSet { onDataUpdate?() }
    }

    public var sections: [Section] {
        if let searchResultSections = searchResultSections {
            return searchResultSections
        }
        return defaultSections
    }

    public func section(at index: Int) -> Section {
        return sections[index]
    }

    public func item(at indexPath: IndexPath) -> Item {
        return sections[indexPath.section].items[indexPath.row]
    }

    private func updateSearchResults() {
        guard let query = searchQuery, query.isEmpty == false else {
            searchResults = [:]
            searchResultSections = nil
            return
        }

        let pattern = query
            .split(separator: " ")
            .map { "(\($0))" }
            .joined(separator: ".*")
            .enclosed(prefix: ".*", suffix: ".*")

        guard let regex = try? NSRegularExpression(pattern: pattern, options: .caseInsensitive) else {
            searchResults = [:]
            searchResultSections = nil
            return
        }

        let result = showcases
            .map { showcase -> SearchResult in
                SearchResult(showcase: showcase, regex: regex)
            }
            .filter { $0.isMatching }

        let showcaseResults = result.filter { $0.isMatchingTitle }.sorted()
        let sectionResults = result.filter { $0.isMatchingTitle == false }.sorted()

        searchResults = Dictionary(uniqueKeysWithValues: result.map { ($0.showcase, $0) })
        searchResultSections = [
            showcaseResults.isEmpty ? nil as Section? : (
                name:  "Showcases",
                items: showcaseResults.map { .showcase($0.showcase) }
            ),
            sectionResults.isEmpty ? nil as Section? : (
                name: "Sections",
                items: sectionResults.map { .showcase($0.showcase) }
            ),
            ].compactMap { $0 }
    }

    public func attributedTitle(for item: Item) -> NSAttributedString {
        switch item {
        case .folder(let name, _):
            return NSAttributedString(string: name)
        case .showcase(let showcase):
            return attributedText(for: showcase.title, ranges: searchResults[showcase]?.ranges.title ?? [])
        }
    }

    public func attributedSubtitle(for item: Item) -> NSAttributedString? {
        switch item {
        case .folder:
            return nil
        case .showcase(let showcase):
            if let result = searchResults[showcase], let path = showcase.path.fullPathDescription {
                if result.isMatchingTitle {
                    return NSAttributedString(string: path)
                } else {
                    return attributedText(for: path, ranges: result.ranges.path)
                }
            } else {
                return nil
            }
        }
    }

    public func image(for item: Item) -> UIImage? {
        switch item {
        case .folder:
            return "📂".image()
        case .showcase:
            return nil
        }
    }

    private func attributedText(for text: String, ranges: [NSRange]) -> NSAttributedString {
        guard ranges.isEmpty == false else {
            return NSAttributedString(string: text)
        }
        let attributedString = NSMutableAttributedString(string: text)
        for range in ranges {
            attributedString.addAttribute(
                .backgroundColor,
                value: UIColor.yellow,
                range: range
            )
        }
        return attributedString
    }

}

private func makeSections(showcases: [ShowcaseDescription]) -> [ShowcasesViewModel.Section] {
    return Dictionary
        .init(grouping: showcases, by: { $0.path.resolve().first?.sectionName?.rawValue })
        .mapValues(makeItems)
        .map { (name: $0, items: $1) }
        .sorted { lhs, rhs in
            switch (lhs.name, rhs.name) {
            case (nil, nil):
                assertionFailure("Shouldn't happen")
                return false
            case (nil, _):
                return false
            case (_, nil):
                return true
            case let (lhs?, rhs?):
                return lhs < rhs
            }
        }
}

private func makeItems(showcases: [ShowcaseDescription]) -> [ShowcasesViewModel.Item] {
    return Dictionary
        .init(grouping: showcases, by: { $0.path.resolve().first?.folderName })
        .flatMap { folderName, showcases -> [ShowcasesViewModel.Item] in
            if let folderName = folderName {
                return [.folder(named: folderName.rawValue, content: showcases.map { $0.pushPath() })]
            } else {
                return showcases.map { .showcase($0) }
            }
        }
        .sorted(by: <)
}

private struct SearchResult: Comparable {
    static func == (lhs: SearchResult, rhs: SearchResult) -> Bool {
        return lhs.showcase == rhs.showcase
    }

    let showcase: ShowcaseDescription
    let ranges: (title: [NSRange], path: [NSRange])

    init(showcase: ShowcaseDescription, regex: NSRegularExpression) {
        self.showcase = showcase
        self.ranges = (
            title: matches(in: showcase.title, for: regex),
            path: matches(in: showcase.path.fullPathDescription, for: regex)
        )
    }

    var isMatching: Bool {
        return isMatchingTitle || isMatchingPath
    }
    var isMatchingTitle: Bool {
        return ranges.title.isEmpty == false
    }
    var isMatchingPath: Bool {
        return ranges.path.isEmpty == false
    }

    static func < (lhs: SearchResult, rhs: SearchResult) -> Bool {
        // Matching title firsts
        if lhs.ranges.title.count > rhs.ranges.path.count {
            return true
        } else if lhs.ranges.path.count < rhs.ranges.title.count {
            return false
        }

        // Alphabetically (sections, then showcases)
        switch (lhs.showcase.path.resolve().first?.sectionName?.rawValue, rhs.showcase.path.resolve().first?.sectionName?.rawValue) {
        case (.none, .none):
            break
        case (.some, .none):
            return true
        case (.none, .some):
            return false
        case let (.some(_path), .some(path)):
            if _path == path {
                break
            }
            return _path < path
        }

        return lhs.showcase.title < rhs.showcase.title
    }
}

private func matches(in string: String?, for regex: NSRegularExpression) -> [NSRange] {
    guard let string = string else { return [] }
    return regex
        .matches(in: string, options: [], range: NSRange(location: 0, length: (string as NSString).length))
        .flatMap { result in
            (1..<result.numberOfRanges).map { i in
                result.range(at: i)
            }
        }
        .filter { $0.location != NSNotFound }
}

