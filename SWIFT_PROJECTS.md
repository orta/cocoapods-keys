# Using Cocoapods-Keys in Swift projects

Once you've followed the setup instructions described in the [Usage](/orta/cocoapods-keys#usage)
section of the README, you have two choices.

## Using the bridge header

If you want to make your keys available to your whole project:

1. Make sure you have a [bridging header](https://developer.apple.com/library/prerelease/ios/documentation/Swift/Conceptual/BuildingCocoaApps/MixandMatch.html) already setup.
2. In the bridging header, import the generated key file:
```objectivec
#import <Keys/MyApplicationKeys.h>
```

## Importing the framework

If you've added the `use_frameworks!` and only want your Keys to be available in
specific files, simply use Swift's `import` statement. The name of the generated
module is `Keys`.

```swift
import Keys
```

## Usage

```swift
let keys = MyApplicationKeys()
ARAnalytics.setupWithAnalytics(keys.analyticsToken)
```
