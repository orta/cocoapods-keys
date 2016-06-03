## Master

## 1.7.0

* Fixes undefined method '*' for nil:NilClass issue on first run [rpassis]

## 1.6.1

* Uses CocoaPods 0.37's pre-install plugins hooks, this fixes issues with migrations to 1.0 [orta]

## 1.6.0

* Adds `export` command to export keys in consumable way [ashfurrow]

## 1.5.2

* Don't ask for input in CI [x2on]
* Fix for first run crash [segiddins]

## 1.5.1

* Support .env files [x2on]

## 1.5.0

* Minor error handling improvements [orta]
* Don't create a shared scheme for Keys [orta]

## 1.4.0

* Adds support for ENV VAR based keys, this makes CI much easier to work with [alloy, orta]

## 1.3.2

* Use relative paths for generated Podspec [segiddins]

## 1.3.1

* Fix for accidental `ui puts` crash [eliesoueidy]

## 1.3.0

* Support for not including keys in Podfile [ashfurrow]

## 1.2.0

* Support for correctly scoping Keys to a target [orta]
* Support CocoaPods 0.37+ via CocoaPods development Pods [orta]

## 1.1.0

* Don't integrate in a project unless keys is declared in the `plugin` [orta]

## 1.0.2

* Support both :key and "key" in user settings [alloy]
* Use ERB templates for the .m & .h [lyricsboy]
* Frameworks support [ashfurrow]
