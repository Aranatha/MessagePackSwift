MessagePack.swift
=================

[![CI Status](https://img.shields.io/travis/a2/MessagePack.swift.svg?style=flat)](https://travis-ci.org/a2/MessagePack.swift)

A fast, zero-dependency MessagePack implementation written in Swift 4. Supports Apple platforms and Linux.

## Installation

### SPM (Swift Package Manager)

You can easily integrate MessagePack.swift in your app with SPM. Just add MessagePack.swift as a dependency:

```swift
import PackageDescription

let package = Package(
    name: "MyAwesomeApp",
    dependencies: [
        .Package(url: "https://github.com/rustle/MessagePack.swift.git", 
                 majorVersion: 4),
    ]
)
```

## Version

- Versions 4.x support Swift 5.
- Versions 3.x support Swift 4.
- Support for Swift 3 was dropped after [2.1.1](https://github.com/a2/MessagePack.swift/releases/tag/2.1.1).
- Support for Swift 2 was dropped after [1.2.0](https://github.com/a2/MessagePack.swift/releases/tag/1.2.0).

## Authors

Alexsander Akers, me@a2.io
Swift 5 Updates: Doug Russell doug@getitdownonpaper.com

## License

MessagePack.swift is available under the MIT license. See the LICENSE file for more info.
