//
//  Swift+Extensions.swift
//  ShowcaseKit-iOS
//
//  Created by Jérôme Alves on 09/09/2019.
//  Copyright © 2019 Heetch. All rights reserved.
//

import Foundation
import UIKit

extension String {

    internal func enclosed(prefix: String, suffix: String) -> String {
        return prefix + self + suffix
    }

    private func index(at offset: Int) -> String.Index {
        return index(startIndex, offsetBy: offset)
    }

    internal func splitOnCamelCase() -> [Substring] {
        let middleIndexes = zip(
            enumerated(),
            enumerated().dropFirst()
            )
            .filter(
                characterSetDidChange(.uppercaseLetters) ||
                    characterSetDidChange(CharacterSet.lowercaseLetters.union(.uppercaseLetters).inverted)
            )
            .map { _, r in
                index(at: r.offset)
            }

        let indexes = [startIndex] + middleIndexes + [endIndex]

        return zip(indexes, indexes.dropFirst())
            .map { start, end in
                self[start...index(end, offsetBy: -1)]
        }
    }

    internal func splittingOnCamelCase(separator: String = " ") -> String {
        return splitOnCamelCase()
            .joined(separator: separator)
            .capitalized
    }

    internal func dropPrefix(_ prefix: String) -> String {
        if hasPrefix(prefix) {
            return String(dropFirst(prefix.count))
        }
        return self
    }

    internal func dropPrefixes(_ prefixes: String...) -> String {
        return dropPrefixes(prefixes)
    }

    internal func dropPrefixes(_ prefixes: [String]) -> String {
        var result = self
        for prefix in prefixes {
            result = result.dropPrefix(prefix)
        }
        return result
    }

    internal func image(fontSize: CGFloat = 20) -> UIImage {
        return image(font: .systemFont(ofSize: fontSize))
    }

    internal func image(font: UIFont) -> UIImage {
        let string = self as NSString
        let attributes = [NSAttributedString.Key.font: font]
        let size = string.size(withAttributes: attributes)
        let rect = CGRect(origin: .zero, size: size)

        UIGraphicsBeginImageContextWithOptions(size, false, 0)
        defer { UIGraphicsEndImageContext() }

        string.draw(in: rect, withAttributes: attributes)

        return UIGraphicsGetImageFromCurrentImageContext()!
    }

}

private typealias EnumeratedCharacterComparator = ((offset: Int, element: Character), (offset: Int, element: Character)) -> Bool
private func characterSetDidChange(_ characterSet: CharacterSet) -> EnumeratedCharacterComparator {
    return { l, r in
        l.element.isIn(characterSet) == false && r.element.isIn(characterSet) == true
    }
}

private func || (lhs: @escaping EnumeratedCharacterComparator, rhs: @escaping EnumeratedCharacterComparator) -> EnumeratedCharacterComparator {
    return { l, r in
        lhs(l, r) || rhs(l, r)
    }
}

extension Character {

    fileprivate var unicodeScalar: Unicode.Scalar? {
        return Unicode.Scalar(String(self).unicodeScalars.map { $0.value }.reduce(0, +))
    }

    fileprivate func isIn(_ characterSet: CharacterSet) -> Bool {
        return unicodeScalar.map(characterSet.contains) ?? false
    }
}

extension CharacterSet {
    fileprivate func contains(_ character: Character) -> Bool {
        guard let unicodeScalar = character.unicodeScalar else {
            return false
        }
        return contains(unicodeScalar)
    }
}

extension RangeReplaceableCollection {
    internal func appending(_ elements: Element...) -> Self {
        return appending(contentsOf: elements)
    }

    internal func appending<S>(contentsOf sequence: S) -> Self where S: Sequence, S.Element == Self.Element {
        var copy = self
        copy.append(contentsOf: sequence)
        return copy
    }

    internal func appending(to elements: Element...) -> Self {
        return appending(toContentsOf: elements)
    }

    internal func appending<S>(toContentsOf sequence: S) -> Self where S: Sequence, S.Element == Self.Element {
        var copy = self
        for element in sequence.reversed() {
            copy.insert(element, at: startIndex)
        }
        return copy
    }
}
