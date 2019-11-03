//
//  ShowcaseDescription.swift
//  ShowcaseKit-iOS
//
//  Created by Jérôme Alves on 09/09/2019.
//  Copyright © 2019 Heetch. All rights reserved.
//

import Foundation
import UIKit

open class _ShowcaseBase: NSObject {
    public required override init() {
        super.init()
    }
}
/**
 A typealias combining `_ShowcaseIdentity` and `_ShowcaseRequirements`.
 Showcases implementations **must** add conformance to `Showcasable`
 and not to only `_ShowcaseIdentity` or `_ShowcaseRequirements`.

 Note: There's not a single `Showcasable` protocol because when annotated
 with `@objc`, it was not possible to provide a default implementation
 for `static var title: String` or reference Swift only types like `ShowcasePath`.
 */
public typealias Showcase = _ShowcaseBase & _ShowcaseIdentity & _ShowcaseRequirements

/**
 A protocol defining the showcase identity. Annotating it with `@objc` make it
 available to objective-c runtime and usable with `class_conformsToProtocol()`
 */
@objc public protocol _ShowcaseIdentity: AnyObject {
}

/**
 The actual protocol requiring some implementations for showcases
 */
public protocol _ShowcaseRequirements: AnyObject {

    /**
     The title of the Showcase. Automatically inferred from the class name, but can be overridden.
     */
    static var title: String { get }

    /**
     The path of the Showcase in the UINavigationController. Must be implemented.
     */
    static var path: ShowcasePath { get }

    /*
     Describe how the Showcase is shown in the UINavigationController.
     By default it is pushed, or presented if `viewController` is also an `UINavigationController`
     Can be overridden to present as modal, for example.
     
     - parameters:
     - viewController: The `UIViewController` created by the `makeViewController()` factory method.
     - navigationController: The `UINavigationController` in used to either push in, or present from the given `viewController`
     */
    static var presentationMode: ShowcasePresentationMode { get }

    /**
     Factory method that must be implemented to return the UIViewController to show in the `UINavigationController`
     */
    func makeViewController() -> UIViewController

}

public enum ShowcasePresentationMode {
    case automatic
    case modal
}

extension _ShowcaseRequirements {

    /**
     Default implementation.
     Automatically transform a type name into a readable title.
     Example:
     `DriverEngagementBarShowcase.Type` become `Driver Engagement Bar`
     */
    public static var title: String {
        return ShowcasesSettings.shared.automaticReadableTitleTransform(String(describing: type(of: self)))
    }

    /**
     Default implementation.
     */
    public static var path: ShowcasePath {
        return .root
    }

    /**
     Default implementation.
     `viewController` is pushed, or presented as a modal if it is also an `UINavigationController` instance.
     */
    public static var presentationMode: ShowcasePresentationMode {
        return .automatic
    }
}


