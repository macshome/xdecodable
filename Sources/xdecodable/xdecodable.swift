import Foundation

/// Represents an Xcode project file structure decoded from a `project.pbxproj` file.
///
/// This is the root object that contains all project metadata including targets, build phases,
/// file references, and build configurations.
struct XcodeProject: Decodable {
    /// The archive version of the project file format
    let archiveVersion: String

    /// The object version indicating the Xcode compatibility level
    let objectVersion: String

    /// The unique identifier of the root `PBXProject` object
    let rootObject: String

    /// Dictionary mapping unique object IDs to their corresponding project objects
    let objects: [String: ProjectObject]
}

/// Represents any type of object that can appear in an Xcode project file.
///
/// Xcode project files contain heterogeneous collections of objects identified by their `isa` type.
/// This enum discriminates between different object types and provides type-safe access to their data.
enum ProjectObject: Decodable {
    /// A group container for organizing files and other groups in the project navigator
    case group(PBXGroup)
    /// A reference to a file in the project
    case fileReference(PBXFileReference)
    /// A file included in a build phase
    case buildFile(PBXBuildFile)
    /// A native build target (e.g., app, framework, test bundle)
    case nativeTarget(PBXNativeTarget)
    /// An aggregate target that runs build phases but doesn't produce a binary output
    case aggregateTarget(PBXAggregateTarget)
    /// The root project object containing project-wide settings
    case project(PBXProject)
    /// A list of build configurations (Debug, Release, etc.)
    case configurationList(XCConfigurationList)
    /// A single build configuration with its settings
    case buildConfiguration(XCBuildConfiguration)
    /// A generic build phase (sources, frameworks, resources, headers)
    case buildPhase(PBXBuildPhase)
    /// A reference to a remote Swift package repository
    case remotePackageReference(XCRemoteSwiftPackageReference)
    /// A dependency on a Swift package product
    case packageProductDependency(XCSwiftPackageProductDependency)
    /// An unknown or unsupported object type with raw data preserved
    case unknown([String: AnyCodable])
    /// A proxy for items in other projects or targets
    case containerItemProxy(PBXContainerItemProxy)
    /// A dependency relationship between targets
    case targetDependency(PBXTargetDependency)
    /// A build phase that copies files to a specific location in the bundle
    case copyFilesBuildPhase(PBXCopyFilesBuildPhase)
    /// A build phase that runs a shell script during the build
    case shellScriptBuildPhase(PBXShellScriptBuildPhase)
    /// A group of localized file variants
    case variantGroup(PBXVariantGroup)
    /// A file system synchronized root group (Xcode 16+)
    case fileSystemSynchronizedRootGroup(PBXFileSystemSynchronizedRootGroup)
    /// A legacy external build system target
    case legacyTarget(PBXLegacyTarget)
    /// A custom build rule for processing specific file types
    case buildRule(PBXBuildRule)
    /// A proxy reference to a product from another project
    case referenceProxy(PBXReferenceProxy)

    enum CodingKeys: String, CodingKey {
        case isa
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        let isa = try container.decode(String.self, forKey: .isa)

        let singleValueContainer = try decoder.singleValueContainer()

        switch isa {
        case "PBXGroup":
            self = .group(try singleValueContainer.decode(PBXGroup.self))
        case "PBXFileReference":
            self = .fileReference(try singleValueContainer.decode(PBXFileReference.self))
        case "PBXBuildFile":
            self = .buildFile(try singleValueContainer.decode(PBXBuildFile.self))
        case "PBXNativeTarget":
            self = .nativeTarget(try singleValueContainer.decode(PBXNativeTarget.self))
        case "PBXAggregateTarget":
            self = .aggregateTarget(try singleValueContainer.decode(PBXAggregateTarget.self))
        case "PBXProject":
            self = .project(try singleValueContainer.decode(PBXProject.self))
        case "XCConfigurationList":
            self = .configurationList(try singleValueContainer.decode(XCConfigurationList.self))
        case "XCBuildConfiguration":
            self = .buildConfiguration(try singleValueContainer.decode(XCBuildConfiguration.self))
        case "PBXSourcesBuildPhase", "PBXFrameworksBuildPhase", "PBXResourcesBuildPhase", "PBXHeadersBuildPhase":
            self = .buildPhase(try singleValueContainer.decode(PBXBuildPhase.self))
        case "XCRemoteSwiftPackageReference":
            self = .remotePackageReference(try singleValueContainer.decode(XCRemoteSwiftPackageReference.self))
        case "XCSwiftPackageProductDependency":
            self = .packageProductDependency(try singleValueContainer.decode(XCSwiftPackageProductDependency.self))
        case "PBXContainerItemProxy":
            self = .containerItemProxy(try singleValueContainer.decode(PBXContainerItemProxy.self))
        case "PBXTargetDependency":
            self = .targetDependency(try singleValueContainer.decode(PBXTargetDependency.self))
        case "PBXCopyFilesBuildPhase":
            self = .copyFilesBuildPhase(try singleValueContainer.decode(PBXCopyFilesBuildPhase.self))
        case "PBXShellScriptBuildPhase":
            self = .shellScriptBuildPhase(try singleValueContainer.decode(PBXShellScriptBuildPhase.self))
        case "PBXVariantGroup":
            self = .variantGroup(try singleValueContainer.decode(PBXVariantGroup.self))
        case "PBXFileSystemSynchronizedRootGroup":
            self = .fileSystemSynchronizedRootGroup(
                try singleValueContainer.decode(PBXFileSystemSynchronizedRootGroup.self)
            )
        case "PBXLegacyTarget":
            self = .legacyTarget(try singleValueContainer.decode(PBXLegacyTarget.self))
        case "PBXBuildRule":
            self = .buildRule(try singleValueContainer.decode(PBXBuildRule.self))
        case "PBXReferenceProxy":
            self = .referenceProxy(try singleValueContainer.decode(PBXReferenceProxy.self))
        default:
            self = .unknown(try singleValueContainer.decode([String: AnyCodable].self))
        }
    }
}

/// Represents a proxy for accessing items from other projects or containers.
///
/// Used when a target depends on a product from another project or when referencing
/// items across project boundaries.
struct PBXContainerItemProxy: Decodable {
    /// Object type identifier (always "PBXContainerItemProxy")
    let isa: String
    /// ID of the container (project) being referenced
    let containerPortal: String
    /// Type of proxy (1 = target reference, 2 = file reference)
    let proxyType: String
    /// Global ID of the remote object in the referenced container
    let remoteGlobalIDString: String
    /// Human-readable name of the remote item
    let remoteInfo: String
}

/// Represents a dependency on another target.
///
/// Defines the relationship when one target must be built before another target can be built.
struct PBXTargetDependency: Decodable {
    /// Object type identifier (always "PBXTargetDependency")
    let isa: String
    /// ID of the target this depends on (for same-project dependencies)
    let target: String?
    /// ID of the proxy for cross-project dependencies
    let targetProxy: String?
    /// ID of the Swift package product dependency
    let productRef: String?
}

/// Represents a build phase that copies files to a specific destination in the bundle.
///
/// Used to copy resources, frameworks, or other files to designated locations during the build process.
struct PBXCopyFilesBuildPhase: Decodable {
    /// Object type identifier (always "PBXCopyFilesBuildPhase")
    let isa: String
    /// Bitmask for when this phase runs (optional in some Xcode versions)
    let buildActionMask: String?
    /// Destination path for copied files (relative to destination subfolder)
    let dstPath: String?
    /// Destination subfolder specification (numeric code indicating location)
    let dstSubfolderSpec: String
    /// Array of file IDs to copy
    let files: [String]
    /// Whether to run only for deployment postprocessing (optional in some Xcode versions)
    let runOnlyForDeploymentPostprocessing: String?
    /// Display name of this build phase (optional)
    let name: String?
}

/// Represents a build phase that executes a shell script during the build.
///
/// Commonly used for running code generation tools, linters, or custom build steps.
/// The script can have input and output file dependencies for proper incremental builds.
struct PBXShellScriptBuildPhase: Decodable {
    /// Object type identifier (always "PBXShellScriptBuildPhase")
    let isa: String
    /// Bitmask for when this phase runs (optional in some Xcode versions)
    let buildActionMask: String?
    /// Array of file IDs processed by this phase (optional for script-only phases)
    let files: [String]?
    /// Paths to `.xcfilelist` files listing input files
    let inputFileListPaths: [String]?
    /// Individual input file paths
    let inputPaths: [String]?
    /// Display name of this build phase (optional)
    let name: String?
    /// Paths to `.xcfilelist` files listing output files
    let outputFileListPaths: [String]?
    /// Individual output file paths
    let outputPaths: [String]?
    /// Whether to run only for deployment postprocessing (optional in some Xcode versions)
    let runOnlyForDeploymentPostprocessing: String?
    /// Path to the shell interpreter (e.g., `/bin/sh`)
    let shellPath: String
    /// The script to execute (can be a single string or array of strings)
    let shellScript: AnyCodable
    /// Whether to show environment variables in the build log (`0` or `1`)
    let showEnvVarsInLog: String?
}

/// Represents a group containing localized variants of a file.
///
/// Used for localizable resources where different versions exist for different languages or regions.
/// For example, a `Localizable.strings` file with English, Spanish, and French variants.
struct PBXVariantGroup: Decodable {
    /// Object type identifier (always "PBXVariantGroup")
    let isa: String
    /// Array of child file reference IDs representing different localizations
    let children: [String]
    /// Display name of the variant group (typically the base resource name)
    let name: String
    /// Source tree location type (e.g., `<group>`, `SOURCE_ROOT`)
    let sourceTree: String
}

/// Represents a file system synchronized root group (Xcode 16+).
///
/// Introduced in Xcode 16, this type of group automatically synchronizes with a directory
/// on disk, automatically including new files without manual project updates.
struct PBXFileSystemSynchronizedRootGroup: Decodable {
    /// Object type identifier (always "PBXFileSystemSynchronizedRootGroup")
    let isa: String
    /// File system path to synchronize
    let path: String?
    /// Source tree location type (e.g., `<group>`, `SOURCE_ROOT`)
    let sourceTree: String?
    /// Array of exception rule IDs for files/folders to exclude
    let exceptions: [String]?
    /// Explicit file type mappings for overriding auto-detection
    let explicitFileTypes: [String: AnyCodable]?
    /// Explicitly specified folder paths within the synchronized directory
    let explicitFolders: [String]?
}

/// Represents a group container for organizing project files in the project navigator.
///
/// Groups can contain files, other groups, or a mix of both, forming a hierarchical structure.
/// The group's appearance in Xcode doesn't necessarily match the file system structure.
struct PBXGroup: Decodable {
    /// Object type identifier (always "PBXGroup")
    let isa: String
    /// Array of child object IDs (files or subgroups)
    let children: [String]?
    /// Display name of the group in the project navigator
    let name: String?
    /// File system path of the group (relative to source tree)
    let path: String?
    /// Source tree location type (e.g., `<group>`, `SOURCE_ROOT`, `BUILT_PRODUCTS_DIR`)
    let sourceTree: String?
}

/// Represents a reference to a file in the project.
///
/// File references point to actual files on disk and specify their type and location.
/// They can represent source files, resources, frameworks, or any other file type.
struct PBXFileReference: Decodable {
    /// Object type identifier (always "PBXFileReference")
    let isa: String
    /// Last known file type identifier (e.g., `sourcecode.swift`, `text.plist.xml`)
    let lastKnownFileType: String?
    /// File system path to the file
    let path: String?
    /// Source tree location type (e.g., `<group>`, `SOURCE_ROOT`, `BUILT_PRODUCTS_DIR`)
    let sourceTree: String?
    /// Explicitly set file type identifier (overrides automatic detection)
    let explicitFileType: String?
    /// Whether to include in the index for search (`0` or `1`)
    let includeInIndex: String?
}

/// Represents a file included in a build phase.
///
/// Links a file reference or package product to a specific build phase (e.g., compile, link, copy).
struct PBXBuildFile: Decodable {
    /// Object type identifier (always "PBXBuildFile")
    let isa: String
    /// ID of the file reference being built
    let fileRef: String?
    /// ID of the package product reference (for Swift package dependencies)
    let productRef: String?
}

/// Represents a native build target that produces a binary output.
///
/// Native targets can produce applications, frameworks, libraries, test bundles, or other binary products.
/// Each target has its own build configurations, phases, and dependencies.
struct PBXNativeTarget: Decodable {
    /// Object type identifier (always "PBXNativeTarget")
    let isa: String
    /// Display name of the target shown in Xcode
    let name: String
    /// ID of the configuration list containing Debug, Release, etc.
    let buildConfigurationList: String
    /// Array of build phase IDs (compile sources, link frameworks, copy resources, etc.)
    let buildPhases: [String]
    /// Array of target dependency IDs this target depends on
    let dependencies: [String]?
    /// Array of Swift package product dependency IDs
    let packageProductDependencies: [String]?
    /// Product name (may differ from target name)
    let productName: String?
    /// ID of the file reference for the built product
    let productReference: String?
    /// Product type identifier (e.g., `com.apple.product-type.application`)
    let productType: String?
}

/// Represents an aggregate target that doesn't produce a binary output.
///
/// Aggregate targets are used to group build phases and dependencies without creating a product.
/// They're commonly used for running scripts, preprocessing, or coordinating other targets.
struct PBXAggregateTarget: Decodable {
    /// Object type identifier (always "PBXAggregateTarget")
    let isa: String
    /// Display name of the target shown in Xcode
    let name: String
    /// ID of the configuration list containing Debug, Release, etc.
    let buildConfigurationList: String
    /// Array of build phase IDs (typically shell script phases)
    let buildPhases: [String]
    /// Array of target dependency IDs this target depends on
    let dependencies: [String]?
    /// Product name (though no actual product is created)
    let productName: String?
}

/// Represents the root project object containing project-wide settings.
///
/// This is the main container for the entire Xcode project, holding references to all targets,
/// build configurations, file groups, and package dependencies.
struct PBXProject: Decodable {
    /// Object type identifier (always "PBXProject")
    let isa: String
    /// ID of the project's configuration list
    let buildConfigurationList: String
    /// Xcode compatibility version (optional in older projects)
    let compatibilityVersion: String?
    /// Development region/language (e.g., "en", "English")
    let developmentRegion: String
    /// ID of the main group containing project files
    let mainGroup: String
    /// ID of the group containing build products (optional in some projects)
    let productRefGroup: String?
    /// Array of target IDs in this project
    let targets: [String]
    /// Array of Swift package reference IDs (optional)
    let packageReferences: [String]?
    /// Project directory path
    let projectDirPath: String?
    /// Project root path
    let projectRoot: String?
}

/// Represents a list of build configurations for a project or target.
///
/// Configuration lists contain different build configurations (e.g., Debug, Release)
/// and specify which one is the default.
struct XCConfigurationList: Decodable {
    /// Object type identifier (always "XCConfigurationList")
    let isa: String
    /// Array of build configuration IDs
    let buildConfigurations: [String]
    /// Whether the default configuration is visible in the UI (optional in some Xcode versions)
    let defaultConfigurationIsVisible: String?
    /// Name of the default configuration (e.g., "Release")
    let defaultConfigurationName: String
}

/// Represents a single build configuration with its settings.
///
/// Build configurations define compiler flags, preprocessor macros, and other build settings
/// that vary between different build scenarios (e.g., Debug vs. Release).
struct XCBuildConfiguration: Decodable {
    /// Object type identifier (always "XCBuildConfiguration")
    let isa: String
    /// Configuration name (e.g., "Debug", "Release", "Staging")
    let name: String
    /// Dictionary of build settings (e.g., SWIFT_VERSION, PRODUCT_NAME)
    let buildSettings: [String: AnyCodable]
}

/// Represents a generic build phase (sources, frameworks, resources, headers).
///
/// Build phases define steps in the build process such as compiling source files,
/// linking frameworks, copying resources, or processing headers.
struct PBXBuildPhase: Decodable {
    /// Object type identifier (e.g., "PBXSourcesBuildPhase", "PBXFrameworksBuildPhase")
    let isa: String
    /// Bitmask for when this phase runs (optional in some Xcode versions)
    let buildActionMask: String?
    /// Array of build file IDs to process in this phase
    let files: [String]
    /// Whether to run only for deployment postprocessing (optional in some Xcode versions)
    let runOnlyForDeploymentPostprocessing: String?
}

/// Represents a reference to a remote Swift package repository.
///
/// Defines a Swift package dependency by specifying the repository URL and version requirements.
struct XCRemoteSwiftPackageReference: Decodable {
    /// Object type identifier (always "XCRemoteSwiftPackageReference")
    let isa: String
    /// URL of the package repository (e.g., GitHub URL)
    let repositoryURL: String
    /// Version requirement specification
    let requirement: PackageRequirement
}

/// Represents version requirements for a Swift package.
///
/// Specifies how package versions are resolved (e.g., semantic versioning ranges, branches, or specific revisions).
struct PackageRequirement: Decodable {
    /// Requirement kind (e.g., "upToNextMajorVersion", "branch", "revision", "exact")
    let kind: String
    /// Minimum version for range-based requirements (e.g., "1.0.0")
    let minimumVersion: String?
    /// Maximum version for range-based requirements (e.g., "2.0.0")
    let maximumVersion: String?
    /// Branch name for branch-based requirements (e.g., "main", "develop")
    let branch: String?
    /// Commit revision for revision-based requirements (full commit SHA)
    let revision: String?
}

/// Represents a dependency on a Swift package product.
///
/// Links a target to a specific product (library or executable) from a Swift package.
struct XCSwiftPackageProductDependency: Decodable {
    /// Object type identifier (always "XCSwiftPackageProductDependency")
    let isa: String
    /// ID of the package reference this product comes from
    let package: String?
    /// Name of the package product (e.g., library name)
    let productName: String
}

/// Represents a legacy target using an external build system.
///
/// Legacy targets delegate building to an external tool (e.g., Make, CMake) instead of
/// using Xcode's native build system. Useful for integrating existing build processes.
struct PBXLegacyTarget: Decodable {
    /// Object type identifier (always "PBXLegacyTarget")
    let isa: String
    /// Arguments passed to the build tool
    let buildArgumentsString: String?
    /// ID of the configuration list for this target
    let buildConfigurationList: String?
    /// Array of build phase IDs
    let buildPhases: [String]?
    /// Path to the build tool executable
    let buildToolPath: String?
    /// Working directory for the build tool
    let buildWorkingDirectory: String?
    /// Array of target dependency IDs
    let dependencies: [String]?
    /// Display name of the target
    let name: String?
    /// Whether to pass build settings as environment variables (`0` or `1`)
    let passBuildSettingsInEnvironment: String?
    /// Product name
    let productName: String?
}

/// Represents a custom build rule for processing specific file types.
///
/// Build rules define how files of a particular type should be compiled or processed,
/// allowing custom transformations beyond Xcode's standard build system.
struct PBXBuildRule: Decodable {
    /// Object type identifier (always "PBXBuildRule")
    let isa: String
    /// Compiler specification identifier for this rule
    let compilerSpec: String?
    /// File type pattern this rule processes (e.g., UTI or file extension)
    let fileType: String?
    /// Input file path patterns
    let inputFiles: [String]?
    /// Whether the rule is user-editable (`0` or `1`)
    let isEditable: String?
    /// Output file path patterns
    let outputFiles: [String]?
    /// Compiler flags to apply to output files
    let outputFilesCompilerFlags: [String]?
    /// Rule pattern for generating output file names
    let outputFilesRule: String?
    /// Custom script for processing files
    let script: String?
    /// Script input file path patterns
    let scriptInputFiles: [String]?
    /// Script output file path patterns
    let scriptOutputFiles: [String]?
}

/// Represents a proxy reference to a product from another project.
///
/// Used when a project references build products from external projects without directly
/// embedding the external project files.
struct PBXReferenceProxy: Decodable {
    /// Object type identifier (always "PBXReferenceProxy")
    let isa: String
    /// File type of the referenced product
    let fileType: String?
    /// Path to the referenced product
    let path: String?
    /// ID of the remote reference
    let remoteRef: String?
    /// Source tree location type
    let sourceTree: String?
}

/// A type-erased wrapper for values that can be of any type.
///
/// Used for decoding heterogeneous data structures in project files where the exact type
/// isn't known at compile time. Supports primitives, arrays, and dictionaries.
struct AnyCodable: Decodable {
    /// The underlying value of any type
    let value: Any

    init(from decoder: Decoder) throws {
        let container = try decoder.singleValueContainer()

        if let bool = try? container.decode(Bool.self) {
            value = bool
        } else if let int = try? container.decode(Int.self) {
            value = int
        } else if let double = try? container.decode(Double.self) {
            value = double
        } else if let string = try? container.decode(String.self) {
            value = string
        } else if let array = try? container.decode([AnyCodable].self) {
            value = array.map { $0.value }
        } else if let dict = try? container.decode([String: AnyCodable].self) {
            value = dict.mapValues { $0.value }
        } else {
            throw DecodingError.dataCorruptedError(in: container, debugDescription: "Cannot decode value")
        }
    }
}
