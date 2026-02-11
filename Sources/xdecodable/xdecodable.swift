import Foundation

struct XcodeProject: Decodable {
    let archiveVersion: String
    let objectVersion: String
    let rootObject: String
    let objects: [String: ProjectObject]
}

enum ProjectObject: Decodable {
    case group(PBXGroup)
    case fileReference(PBXFileReference)
    case buildFile(PBXBuildFile)
    case nativeTarget(PBXNativeTarget)
    case aggregateTarget(PBXAggregateTarget)
    case project(PBXProject)
    case configurationList(XCConfigurationList)
    case buildConfiguration(XCBuildConfiguration)
    case buildPhase(PBXBuildPhase)
    case remotePackageReference(XCRemoteSwiftPackageReference)
    case packageProductDependency(XCSwiftPackageProductDependency)
    case unknown([String: AnyCodable])
    case containerItemProxy(PBXContainerItemProxy)
    case targetDependency(PBXTargetDependency)
    case copyFilesBuildPhase(PBXCopyFilesBuildPhase)
    case shellScriptBuildPhase(PBXShellScriptBuildPhase)
    case variantGroup(PBXVariantGroup)
    case fileSystemSynchronizedRootGroup(PBXFileSystemSynchronizedRootGroup)
    case legacyTarget(PBXLegacyTarget)
    case buildRule(PBXBuildRule)
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

struct PBXContainerItemProxy: Decodable {
    let isa: String
    let containerPortal: String
    let proxyType: String
    let remoteGlobalIDString: String
    let remoteInfo: String
}

struct PBXTargetDependency: Decodable {
    let isa: String
    let target: String?
    let targetProxy: String?
    let productRef: String?
}

struct PBXCopyFilesBuildPhase: Decodable {
    let isa: String
    let buildActionMask: String?
    let dstPath: String?
    let dstSubfolderSpec: String
    let files: [String]
    let runOnlyForDeploymentPostprocessing: String?
    let name: String?
}

struct PBXShellScriptBuildPhase: Decodable {
    let isa: String
    let buildActionMask: String?
    let files: [String]?
    let inputFileListPaths: [String]?
    let inputPaths: [String]?
    let name: String?
    let outputFileListPaths: [String]?
    let outputPaths: [String]?
    let runOnlyForDeploymentPostprocessing: String?
    let shellPath: String
    let shellScript: AnyCodable
    let showEnvVarsInLog: String?
}

struct PBXVariantGroup: Decodable {
    let isa: String
    let children: [String]
    let name: String
    let sourceTree: String
}

struct PBXFileSystemSynchronizedRootGroup: Decodable {
    let isa: String
    let path: String?
    let sourceTree: String?
    let exceptions: [String]?
    let explicitFileTypes: [String: AnyCodable]?
    let explicitFolders: [String]?
}

struct PBXGroup: Decodable {
    let isa: String
    let children: [String]?
    let name: String?
    let path: String?
    let sourceTree: String?
}

struct PBXFileReference: Decodable {
    let isa: String
    let lastKnownFileType: String?
    let path: String?
    let sourceTree: String?
    let explicitFileType: String?
    let includeInIndex: String?
}

struct PBXBuildFile: Decodable {
    let isa: String
    let fileRef: String?
    let productRef: String?
}

struct PBXNativeTarget: Decodable {
    let isa: String
    let name: String
    let buildConfigurationList: String
    let buildPhases: [String]
    let dependencies: [String]?
    let packageProductDependencies: [String]?
    let productName: String?
    let productReference: String?
    let productType: String?
}

struct PBXAggregateTarget: Decodable {
    let isa: String
    let name: String
    let buildConfigurationList: String
    let buildPhases: [String]
    let dependencies: [String]?
    let productName: String?
}

struct PBXProject: Decodable {
    let isa: String
    let buildConfigurationList: String
    let compatibilityVersion: String?
    let developmentRegion: String
    let mainGroup: String
    let productRefGroup: String?
    let targets: [String]
    let packageReferences: [String]?
    let projectDirPath: String?
    let projectRoot: String?
}

struct XCConfigurationList: Decodable {
    let isa: String
    let buildConfigurations: [String]
    let defaultConfigurationIsVisible: String?
    let defaultConfigurationName: String
}

struct XCBuildConfiguration: Decodable {
    let isa: String
    let name: String
    let buildSettings: [String: AnyCodable]
}

struct PBXBuildPhase: Decodable {
    let isa: String
    let buildActionMask: String?
    let files: [String]
    let runOnlyForDeploymentPostprocessing: String?
}

struct XCRemoteSwiftPackageReference: Decodable {
    let isa: String
    let repositoryURL: String
    let requirement: PackageRequirement
}

struct PackageRequirement: Decodable {
    let kind: String
    let minimumVersion: String?
    let maximumVersion: String?
    let branch: String?
    let revision: String?
}

struct XCSwiftPackageProductDependency: Decodable {
    let isa: String
    let package: String?
    let productName: String
}

struct PBXLegacyTarget: Decodable {
    let isa: String
    let buildArgumentsString: String?
    let buildConfigurationList: String?
    let buildPhases: [String]?
    let buildToolPath: String?
    let buildWorkingDirectory: String?
    let dependencies: [String]?
    let name: String?
    let passBuildSettingsInEnvironment: String?
    let productName: String?
}

struct PBXBuildRule: Decodable {
    let isa: String
    let compilerSpec: String?
    let fileType: String?
    let inputFiles: [String]?
    let isEditable: String?
    let outputFiles: [String]?
    let outputFilesCompilerFlags: [String]?
    let outputFilesRule: String?
    let script: String?
    let scriptInputFiles: [String]?
    let scriptOutputFiles: [String]?
}

struct PBXReferenceProxy: Decodable {
    let isa: String
    let fileType: String?
    let path: String?
    let remoteRef: String?
    let sourceTree: String?
}

struct AnyCodable: Decodable {
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
