# xdecodable

A Swift package for decoding and parsing Xcode project files (`project.pbxproj`).

## Overview

`xdecodable` provides type-safe Swift structures for decoding Xcode project files. It parses the property list format used by Xcode and converts it into strongly-typed Swift objects, making it easy to programmatically analyze and work with Xcode projects.

## Features

- **Complete Xcode Project Support**: Decodes all major Xcode project object types
- **Type-Safe API**: Strongly-typed Swift enums and structs for all project components
- **Modern Swift**: Built with Swift 6.2 and uses modern Swift concurrency patterns
- **Comprehensive Object Coverage**: Supports targets, build phases, configurations, file references, and Swift packages
- **Error Diagnostics**: Detailed error messages with coding paths for debugging decode failures

## Supported Object Types

### Project Structure
- `XcodeProject` - Root project structure
- `PBXProject` - Main project object
- `PBXGroup` - File organization groups
- `PBXFileReference` - File references
- `PBXVariantGroup` - Localized file variants

### Targets
- `PBXNativeTarget` - Native build targets (apps, frameworks, libraries)
- `PBXAggregateTarget` - Aggregate targets for grouping build phases
- `PBXLegacyTarget` - External build system targets

### Build Phases
- `PBXBuildPhase` - Generic build phases (sources, frameworks, resources, headers)
- `PBXShellScriptBuildPhase` - Shell script execution phases
- `PBXCopyFilesBuildPhase` - File copying phases
- `PBXBuildRule` - Custom build rules

### Build Configuration
- `XCConfigurationList` - Configuration lists
- `XCBuildConfiguration` - Individual build configurations

### Dependencies & Packages
- `XCRemoteSwiftPackageReference` - Swift package references
- `XCSwiftPackageProductDependency` - Swift package product dependencies
- `PBXTargetDependency` - Target dependencies
- `PBXContainerItemProxy` - Cross-project references
- `PBXReferenceProxy` - External product references

### Modern Xcode Features
- `PBXFileSystemSynchronizedRootGroup` - File system synchronized groups (Xcode 16+)

## Installation

Add this package to your `Package.swift`:

```swift
.package(url: "https://github.com/yourusername/xdecodable.git", from: "1.0.0")
```

Or in Xcode: File → Add Packages → Enter the repository URL

## Usage

### Basic Project Decoding

```swift
import Foundation
import xdecodable

// Load and decode an Xcode project
let projectURL = URL(fileURLWithPath: "/path/to/MyProject.xcodeproj/project.pbxproj")
let data = try Data(contentsOf: projectURL)

let decoder = PropertyListDecoder()
let project = try decoder.decode(XcodeProject.self, from: data)

// Access project information
print("Archive Version: \(project.archiveVersion)")
print("Object Version: \(project.objectVersion)")
print("Total Objects: \(project.objects.count)")

// Iterate through project objects
for (id, object) in project.objects {
    switch object {
    case .nativeTarget(let target):
        print("Target: \(target.name)")
    case .project(let proj):
        print("Targets in project: \(proj.targets.count)")
    case .group(let group):
        print("Group: \(group.name ?? "unnamed")")
    case .unknown(let dict):
        print("Unknown object: \(id)")
    default:
        break
    }
}
```

### Analyzing Build Configurations

```swift
// Find the root project object
if case .project(let rootProject) = project.objects[project.rootObject] {
    print("Project has \(rootProject.targets.count) targets")
    
    // Iterate through targets
    for targetID in rootProject.targets {
        if case .nativeTarget(let target) = project.objects[targetID] {
            print("\nTarget: \(target.name)")
            print("  Build Phases: \(target.buildPhases.count)")
            print("  Dependencies: \(target.dependencies?.count ?? 0)")
            print("  Product Type: \(target.productType ?? "unknown")")
        }
    }
}
```

### Finding Swift Package Dependencies

```swift
var swiftPackages: [String: XCRemoteSwiftPackageReference] = [:]

for (id, object) in project.objects {
    if case .remotePackageReference(let package) = object {
        swiftPackages[id] = package
        print("Package: \(package.repositoryURL)")
        print("Requirement: \(package.requirement.kind)")
    }
}
```

## Requirements

- Swift 6.2 or later
- macOS 12.0 or later (for development)
- iOS 13.0 or later (for runtime use)

## Testing

The package includes comprehensive tests that validate decoding against real Xcode projects:

```bash
swift test
```

Test projects are located in `Tests/xdecodableTests/TestProjects/` and include:
- HelloCpp - C++ project example
- ExternalBuildTool - Legacy build system example
- Security - Complex framework project
- Xcode 16.3 projects - Latest Xcode compatibility

These files range randomly from Xcode 3.9-16.3 version formatting. New project files can be added and will automaticly be tested.

## Error Handling

The decoder provides detailed error information for debugging:

```swift
do {
    let project = try decoder.decode(XcodeProject.self, from: data)
} catch let DecodingError.keyNotFound(key, context) {
    print("Missing key: \(key.stringValue)")
    print("Coding path: \(context.codingPath)")
} catch let DecodingError.typeMismatch(type, context) {
    print("Type mismatch: expected \(type)")
    print("Coding path: \(context.codingPath)")
} catch {
    print("Decoding failed: \(error)")
}
```

## Architecture

The library uses a discriminated union (`ProjectObject` enum) to handle the heterogeneous object types in Xcode projects. The `isa` field in each object determines its concrete type:

```swift
enum ProjectObject: Decodable {
    case group(PBXGroup)
    case fileReference(PBXFileReference)
    case nativeTarget(PBXNativeTarget)
    // ... more cases
    case unknown([String: AnyCodable])
}
```

The `AnyCodable` type wraps values that can be of any type (strings, numbers, arrays, dictionaries) and is used for:
- Build settings (which vary by key)
- Shell script content (can be string or array)
- Other heterogeneous data

## Limitations

- Xcode project files are assumed to be in property list format
- The `AnyCodable` type loses type information; values are decoded as generic `Any`
- Build settings are not deeply typed; accessing them requires manual type casting

## Contributing

Contributions are welcome! Please feel free to submit a Pull Request.

## License

MIT License - see LICENSE file for details

## Related Resources

- [Xcode Build System Documentation](https://developer.apple.com/documentation/xcode)
- [Property List Format](https://developer.apple.com/library/archive/documentation/Cocoa/Conceptual/PropertyLists/)
- [Xcodeproj Ruby Gem](https://github.com/CocoaPods/Xcodeproj) - Similar functionality in Ruby

## Acknowledgments

This package was built to understand and work with the Xcode project format in a type-safe Swift manner. It successfully decodes complex real-world Xcode projects including C++, legacy build systems, and modern Swift Package Manager integrations.
