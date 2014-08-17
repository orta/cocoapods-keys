A key value store for enviroment and application keys.

Its good security practice to keep production keys out of developer hands. CocoaPods-keys makes it easy to have per-user config settings stored securely in the developer's keychain, and not in the application source. It is a plugin that once installed will run on every `pod install` or `pod update`.

## Requirements

Requires CocoaPods 0.34, which is currently unreleased.

## Installation

    $ gem install cocoapods-keys

## Usage

You can save keys on a per-project basis by running the command:

    $ pod keys set KEY VALUE

You can list all known keys by running:

    $ pod keys

For example:

``` sh
  $ cd MyApplication
  $ pod keys set "NetworkAPIToken" "AH2ZMiraGQbyUd9GkNTNfWEdxlwXcmHciEOH"
  Saved NetworkAPIToken to MyApplication.

  $ pod keys set "AnalyticsToken" "6TYKGVCn7sBSBFpwfSUCclzDoSBtEXw7"
  Saved AnalyticsToken to MyApplication.

  $ pod keys
  Keys for MyApplication
   ├  NetworkAPIToken - AH2ZMiraGQbyUd9GkNTNfWEdxlwXcmHciEOH
   └  AnalyticsToken - 6TYKGVCn7sBSBFpwfSUCclzDoSBtEXw7

  GIFs - /Users/orta/dev/mac/GIFs
   └ redditAPIToken & mixpanelAPIToken
```

After the next `pod install` or `pod update` keys will add a new Objective-C class to your Pods xcworkspace. This provides a _mostly secure*_ API to your keys from Cocoa code. For example the application code above would look like:

``` objc

#import "ORAppDelegate.h"
#import <CocoaPods-Keys/MyApplicationKeys.h>
#import <ARAnalytics/ARAnalytics.h>

@implementation ORAppDelegate

- (void)applicationDidFinishLaunching:(NSNotification *)aNotification
{
    MyApplicationKeys *keys = [[MyApplicationKeys alloc] init];
    [ARAnalytics setupWithAnalytics:@{
        ARGoogleAnalyticsID : keys.analyticsToken;
    }];
}

@end

```

* There's no perfect way to embed your keys in an application, as it has to be shipped somehow. This is a solid & peer reviewed method to save & access your keys.
