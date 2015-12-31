![Build Status](https://travis-ci.org/orta/cocoapods-keys.svg)

A key value store for enviroment and application keys.

Its good security practice to keep production keys out of developer hands. CocoaPods-keys makes it easy to have per-user config settings stored securely in the developer's keychain, and not in the application source. It is a plugin that once installed will run on every `pod install` or `pod update`.

## Requirements

Requires CocoaPods 0.36

## Installation

    $ gem install cocoapods-keys

## How it works

Key names are stored in `~/.cocoapods/keys/` and key values in the OS X keychain. When you run `pod install` or `pod update`, an Objective-C class is created with scrambled versions of the keys, making it difficult to just [dump](https://github.com/stefanesser/dumpdecrypted) the contents of the decrypted binary and extract the keys. At runtime, the keys are unscrambled for use in your app.

The generated Objective-C classes are stored in the `Pods/CocoaPodsKeys` directory, so if you're checking in your [Pods folder](http://guides.cocoapods.org/using/using-cocoapods.html#should-i-ignore-the-pods-directory-in-source-control), just add `Pods/CocoaPodsKeys` to your `.gitignore` file. CocoaPods-Keys supports integration in Swift or Objective-C projects.

## Usage

Using the new Plugin API in CocoaPods we can automate a lot of the fiddly bits away. You define what keys you want inside your [Podfile](https://github.com/artsy/eidolon/blob/0a9f5947914eb637fd4abf364fa3532b56da3c52/Podfile#L6-L21) and Keys will detect what keys are not yet set. If you need to specify a different project name from the target name, use the key `:target` to specify it.

```
plugin 'cocoapods-keys', {
  :project => "Eidolon",
  :keys => [
    "ArtsyAPIClientSecret",
    "ArtsyAPIClientKey",
    "HockeyProductionSecret",
    "HockeyBetaSecret",
    "MixpanelProductionAPIClientKey",
    ...
  ]}
```

Then running `pod install` will prompt for the keys not yet set and you can ensure everyone has the same setup.


## Alternative Usage

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

After the next `pod install` or `pod update` keys will add a new `Keys` pod to your Pods project, supporting both static libraries and frameworks. *Note* you have to include `plugin 'cocoapods-keys'` in the Podfile for Keys to register that it should work. This provides an API to your keys from Cocoa code. For example the application code above would look like:

``` objc

#import "ORAppDelegate.h"
#import <Keys/MyApplicationKeys.h>
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

Some documentation is also available to [use cocoapods-keys in Swift projects](SWIFT_PROJECTS.md).

#### Other commands

CocoaPods-keys has 3 other commands:

 * `pod keys get [key] [optional project]`
   Which will output the value of the key to STDOUT, useful for scripting.

 * `pod keys rm [key] [optional project]`
   Will remove a key from a project.  

   If Wildcards are included, it will remove the keys matching the pattern. E.g.: `pod keys rm "G*og*"` will remove *all* the keys that begin with 'G', have 'og' in the middle and end with anything.  
	To nuke all the keys, run either `pod keys rm "*"` or `pod keys rm --all`

 * `pod keys generate [optional project]`
   Will generate the obfuscated Objective-C keys class (mainly used internally).

#### Continuous Integration

It's rarely a good idea to mess around with the keychain in your CI, so keys will look for an environment var with the same string before looking in the keychain. Also you could create a `.env` file in your project folder.

#### Security

Key security is difficult. Right now even the biggest apps get their keys [leaked](https://threatpost.com/twitter-oauth-api-keys-leaked-030713/77597). This is neatly summed up by John Adams of the Twitter Security Team on [Quora](http://www.quora.com/Twitter-1/How-were-the-Twitter-iPhone-and-Android-OAuth-keys-leaked).

> Putting this in the context of, "should you be storing keys in software", is more appropriate. Many companies do this. It's never a good idea.

> When developers do that, other developers can use debuggers and string searching commands to extract those keys from the running application. There are numerous talks on how to do that, but leave that as an exercise to the reader to find those talks.

> Many people believe that obfuscating these keys in code will help. It usually won't because you can just run a debugger and find the fully functional keys.

So in summary, the ideal way to store keys is to not store keys. In reality though most Apps embed keys, and this does that and adds some rudimentary obfuscation to the keys. A well motivated app cracker could probably extract this within a few minutes however.

#### Thanks

This was built with a lot of help from [@segiddins](https://github.com/segiddins) and [@ashfurrow](http://github.com/ashfurrow).
