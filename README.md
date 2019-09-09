# ShowcaseKit

![pod](https://img.shields.io/cocoapods/v/ShowcaseKit.svg)

## What's a Showcase?

> noun: a place for presenting something favourably to general attention

It's a way to embed easily some view controllers in your application in order to _showcase_ what you've done.

You can showcase simple views with dummy data as well as you can showcase complete flows. It's all up to you.

The general idea is to be able to _showcase_ something your working on before you finish the whole feature, that way you can still merge it in your mainline branch - that's what we call real Continuous Integration.

## Requirements
- iOS 8.0+
- Xcode 9.0+
- Swift 4.1+

## Installation

### CocoaPods

Add the following to your `Podfile`:

`pod "ShowcaseKit"`



### Swift Package Manager

`https://github.com/heetch/ShowcaseKit` using Xcode 11 SPM integration


## Usage

### Creating a new Showcase

All you have to do is to create a new class conforming to `Showcase`.
The only required implementation is `makeViewController()`.

```swift
final class MyAwesomeFeatureShowcase : Showcase {

    func makeViewController() {
    
        // Setup any kind of view controller here and return it
        
    }
}
```


### Showcase Browser

**ShowcaseKit** comes with a handy ready-to-use showcase browser allowing you to easily order your showcase. You can present this browser as a modal in a single line:

```swift
ShowcasesViewController.present(over: self)
```

Or you can simply init it to embed it the way you want (in an exisitng navigation controller, or a tab bar controller):
```swift
let browser = ShowcasesViewController(showcases: .all)
```

:warning: The only requirement is that `ShowcasesViewController` must be in a `UINavigationController` at some point, because it needs to `push` some other controllers

### Optional Overrides

You can override 3 defaults showcase properties.

#### Title
```swift
static var title: String { get }
```
By default, the title is inferred from the Showcase class name by the `Showcase` suffix and turning the camel case string into a capitalized string.
```swift
MyAwesomeFeatureShowcase → My Awesome Feature
```

But you con override this in your showcase to give a custom name.
```swift
final class MyAwesomeFeatureShowcase : Showcase {

    static let title = "My Awesome Feature (empty state)"
    
    func makeViewController() {...}
}
```

#### Path
```swift
static var path: ShowcasePath { get }
```
By default, showcases are all added the root of the browser, in an unnamed section. But you can customize that with the following code.
```swift
static let path = ShowcasePath.root
    .underSection(named: "Sign Up")
    .inFolder(named: "Onboarding")
```
Here, to access the showcase we'll have to go the the `Sign Up` table view section, and open the `Onboarding` folder.

#### Presentation Mode
```swift
static var presentationMode: ShowcasePresentationMode { get }
```
By default, showcase are pushed to the current navigation controller. But sometimes you need to control presentation and dismiss. So you can change the `presentationMode` to `.modal`. But you will have to handle the dismiss of your showcase.

## License

This framework is provided under the MIT license.