import Foundation
import Testing

@testable import xdecodable

struct TestResources {
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

@Test("Decodes Xcode Projects", .serialized, arguments: try TestResources.projects)
func decode(project: URL) async throws {
    try testProjectDecoding(project)
}

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
        throw  DecodingError.valueNotFound(type, context)
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
