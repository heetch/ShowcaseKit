//
//  Array+Showcase.swift
//  ShowcaseKit-iOS
//
//  Created by Jérôme Alves on 09/09/2019.
//  Copyright © 2019 Heetch. All rights reserved.
//

import Foundation

extension Array where Element == ShowcaseDescription {

    public static var all: [ShowcaseDescription] {

        let count = objc_getClassList(nil, 0)

        var classes = UnsafeMutablePointer<AnyClass>.allocate(capacity: Int(count))
        defer { classes.deallocate() }

        let buffer = AutoreleasingUnsafeMutablePointer<AnyClass>(classes)

        let classListCount = objc_getClassList(buffer, count)

        var showcases: [ShowcaseDescription] = []

        for i in 0..<Int(Swift.min(count, classListCount)) {
            let someclass: AnyClass = classes[i]
            if class_conformsToProtocol(someclass, _ShowcaseIdentity.self) {
                showcases.append(ShowcaseDescription(class: someclass as! Showcase.Type))
            }
        }

        return showcases
    }

    public static func inBundle(_ bundle: Bundle) -> [ShowcaseDescription] {
        return all.filter {
            Bundle(for: $0.classType) == bundle
        }
    }
}

