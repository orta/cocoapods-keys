# Using Cocoapods-Keys in Swift projects

Once you've followed the setup instructions described in the [Usage](README.md#usage)
section of the README, you have two choices.

## Importing the framework

Use Swift's `import` statement. The name of the generated
module is `Keys`.

```swift
import Keys
```

## Usage

```swift
let keys = MyApplicationKeys()
ARAnalytics.setupWithAnalytics(keys.analyticsToken)
```
