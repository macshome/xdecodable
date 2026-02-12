import Foundation
import Testing

@testable import xdecodable

/// Tests that Xcode projects can be successfully decoded from their project.pbxproj files.
///
/// This test is parameterized to run against all available test projects in the TestProjects bundle.
/// It verifies that the xdecodable decoder can parse real Xcode project files and extract all object types.
/// The test runs serially to ensure proper output formatting.
///
/// - Parameter project: URL pointing to an `.xcodeproj` directory to decode
@Test("Decodes Xcode Projects", .serialized, arguments: try TestResources.projects)
func decode(project: URL) async throws {
    try testProjectDecoding(project)
}

/// Helper struct for loading test project resources from the bundle.
///
/// Provides a convenient interface for discovering and accessing Xcode project files
/// bundled with the test target.
struct TestResources {
    /// Returns an array of URLs for all `.xcodeproj` bundles in the TestProjects directory.
    /// To add a new test project, just drop the project file in the TestProjects directory.
    ///
    /// Loads all Xcode project directories from the test bundle's TestProjects subdirectory.
    /// This property is used as the argument source for parameterized tests.
    ///
    /// - Returns: Array of file URLs pointing to `.xcodeproj` directories
    /// - Throws: `NSError` if the TestProjects directory cannot be found in the bundle
    static var projects: [URL] {
        get throws {
            guard
                let resourcesURL = Bundle.module.resourceURL?
                    .appending(path: "TestProjects", directoryHint: .isDirectory)
            else {
                throw NSError(
                    domain: "Tests",
                    code: 1,
                    userInfo: [NSLocalizedDescriptionKey: "Failed to load test project URL"]
                )
            }

            return try FileManager.default.contentsOfDirectory(
                at: resourcesURL,
                includingPropertiesForKeys: nil
            ).filter { $0.pathExtension == "xcodeproj" }
        }
    }
}

/// Loads a test resource file from the TestProjects directory bundle.
///
/// Helper function to locate resource files by name and extension within the bundled TestProjects directory.
/// Used for finding individual project files or resources needed during tests.
///
/// - Parameters:
///   - name: The name of the resource file (without extension)
///   - ext: The file extension (e.g., "xcodeproj", "pbxproj")
/// - Returns: A URL pointing to the resource file
/// - Throws: `NSError` if the resource cannot be found in the bundle
func resourceURL(_ name: String, ext: String) throws -> URL {
    guard let url = Bundle.module.url(forResource: name, withExtension: ext, subdirectory: "TestProjects") else {
        throw NSError(
            domain: "Tests",
            code: 1,
            userInfo: [NSLocalizedDescriptionKey: "Missing resource \(name).\(ext)"]
        )
    }
    return url
}

/// Decodes and validates a single Xcode project file with detailed diagnostic output.
///
/// This function loads an Xcode project from disk, decodes it using the xdecodable decoder, and prints
/// comprehensive information about the project structure. It analyzes object types, counts them,
/// identifies any unknown object types, and provides details about the root project configuration.
///
/// The function performs the following validations:
/// - Loads the `project.pbxproj` plist file from the given `.xcodeproj` directory
/// - Decodes the entire project structure using PropertyListDecoder
/// - Categorizes and counts all object types found in the project
/// - Reports any unknown or unsupported object types (up to 10 examples)
/// - Displays project metadata (archive version, object version)
/// - Shows information about targets and Swift package dependencies
/// - Provides detailed error messages with decoding context on failure
///
/// - Parameter url: URL pointing to an `.xcodeproj` directory containing the `project.pbxproj` file
/// - Throws: `DecodingError` if the project.pbxproj file cannot be decoded. Specific error types include:
///   - `keyNotFound`: Required key is missing from the project structure
///   - `typeMismatch`: A value's type doesn't match the expected type
///   - `valueNotFound`: An expected value is nil or missing
///   - `dataCorrupted`: The plist data is malformed or corrupted
func testProjectDecoding(_ url: URL) throws {
    print("\n=== Testing \(url.lastPathComponent) ===")

    let projURL = url.appendingPathComponent("project.pbxproj")

    do {
        let data = try Data(contentsOf: projURL)
        let decoder = PropertyListDecoder()
        let project = try decoder.decode(XcodeProject.self, from: data)

        print("✓ Successfully decoded project")
        print("  Archive Version: \(project.archiveVersion)")
        print("  Object Version: \(project.objectVersion)")
        print("  Total Objects: \(project.objects.count)")

        var typeCounts: [String: Int] = [:]
        var unknownObjects: [String] = []

        for (key, object) in project.objects {
            let typeName: String
            switch object {
            case .group: typeName = "PBXGroup"
            case .fileReference: typeName = "PBXFileReference"
            case .buildFile: typeName = "PBXBuildFile"
            case .nativeTarget: typeName = "PBXNativeTarget"
            case .aggregateTarget: typeName = "PBXAggregateTarget"
            case .project: typeName = "PBXProject"
            case .configurationList: typeName = "XCConfigurationList"
            case .buildConfiguration: typeName = "XCBuildConfiguration"
            case .buildPhase: typeName = "PBXBuildPhase"
            case .remotePackageReference: typeName = "XCRemoteSwiftPackageReference"
            case .packageProductDependency: typeName = "XCSwiftPackageProductDependency"
            case .containerItemProxy: typeName = "PBXContainerItemProxy"
            case .targetDependency: typeName = "PBXTargetDependency"
            case .copyFilesBuildPhase: typeName = "PBXCopyFilesBuildPhase"
            case .shellScriptBuildPhase: typeName = "PBXShellScriptBuildPhase"
            case .variantGroup: typeName = "PBXVariantGroup"
            case .fileSystemSynchronizedRootGroup: typeName = "PBXFileSystemSynchronizedRootGroup"
            case .legacyTarget(_): typeName = "PBXLegacyTarget"
            case .buildRule(_): typeName = "PBXBuildRule"
            case .unknown(let dict):
                typeName = "Unknown"
                if let isa = dict["isa"]?.value as? String {
                    unknownObjects.append("\(key): \(isa)")
                }
            case .referenceProxy(_):
                typeName = "PBXReferenceProxy"
            }
            typeCounts[typeName, default: 0] += 1
        }

        print("\n  Object Type Summary:")
        for (type, count) in typeCounts.sorted(by: { $0.key < $1.key }) {
            print("    \(type): \(count)")
        }

        if !unknownObjects.isEmpty {
            print("\n  ⚠️  Unknown Objects Found:")
            for unknown in unknownObjects.prefix(10) {
                print("    \(unknown)")
            }
            if unknownObjects.count > 10 {
                print("    ... and \(unknownObjects.count - 10) more")
            }
        } else {
            print("\n  ✓ All objects decoded successfully")
        }

        if case .project(let proj) = project.objects[project.rootObject] ?? .unknown([:]) {
            print("\n  Root Project:")
            print("    Targets: \(proj.targets.count)")
            print("    Package References: \(proj.packageReferences?.count ?? 0)")
        }

        var packageCount = 0
        for (_, object) in project.objects {
            if case .remotePackageReference = object {
                packageCount += 1
            }
        }
        print("    Swift Packages: \(packageCount)")

    } catch let DecodingError.keyNotFound(key, context) {
        print("❌ Missing key: \(key.stringValue)")
        print("   Context: \(context.debugDescription)")
        print("   Coding path: \(context.codingPath.map { $0.stringValue }.joined(separator: " -> "))")
        throw DecodingError.keyNotFound(key, context)
    } catch let DecodingError.typeMismatch(type, context) {
        print("❌ Type mismatch for type: \(type)")
        print("   Context: \(context.debugDescription)")
        print("   Coding path: \(context.codingPath.map { $0.stringValue }.joined(separator: " -> "))")
        throw DecodingError.typeMismatch(type, context)
    } catch let DecodingError.valueNotFound(type, context) {
        print("❌ Value not found for type: \(type)")
        print("   Context: \(context.debugDescription)")
        print("   Coding path: \(context.codingPath.map { $0.stringValue }.joined(separator: " -> "))")
        throw DecodingError.valueNotFound(type, context)
    } catch let DecodingError.dataCorrupted(context) {
        print("❌ Data corrupted")
        print("   Context: \(context.debugDescription)")
        print("   Coding path: \(context.codingPath.map { $0.stringValue }.joined(separator: " -> "))")
        throw DecodingError.dataCorrupted(context)
    } catch {
        print("❌ Unknown error: \(error)")
        throw error
    }
}
