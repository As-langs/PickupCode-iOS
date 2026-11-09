import os, glob, plistlib

proj_dir = '/Users/zouh/.gemini/antigravity/scratch/PickupCode-iOS'

def make_id(name):
    import hashlib
    return hashlib.md5(name.encode()).hexdigest()[:24].upper()

swift_files = [
    ('PickupCodeApp.swift', 'App/PickupCodeApp.swift', 'sourcecode.swift'),
    ('Models.swift', 'Core/Models.swift', 'sourcecode.swift'),
    ('ThemeManager.swift', 'Core/ThemeManager.swift', 'sourcecode.swift'),
    ('JumpManager.swift', 'Core/JumpManager.swift', 'sourcecode.swift'),
    ('ContentView.swift', 'Views/ContentView.swift', 'sourcecode.swift'),
    ('EntryCardView.swift', 'Views/EntryCardView.swift', 'sourcecode.swift'),
    ('SettingsView.swift', 'Views/SettingsView.swift', 'sourcecode.swift'),
    ('ToastView.swift', 'Views/ToastView.swift', 'sourcecode.swift'),
    ('PlatformIconView.swift', 'Views/PlatformIconView.swift', 'sourcecode.swift'),
]

png_files = sorted(glob.glob(f'{proj_dir}/PickupCode/Resources/Images/*.png'))
resource_files = [
    ('Info.plist', 'Resources/Info.plist', 'text.plist.xml', False)
]
for p in png_files:
    fname = os.path.basename(p)
    resource_files.append((fname, f'Resources/Images/{fname}', 'image.png', True))

objects = {}

# File references & Build files
app_prod_id = make_id('prod_pickupcode_app')
objects[app_prod_id] = {
    'isa': 'PBXFileReference',
    'explicitFileType': 'wrapper.application',
    'includeInIndex': 0,
    'path': 'PickupCode.app',
    'sourceTree': 'BUILT_PRODUCTS_DIR'
}

sources_build_file_ids = []
resources_build_file_ids = []

swift_file_refs = {}
for name, path, ftype in swift_files:
    fid = make_id('file_' + name)
    bid = make_id('build_' + name)
    swift_file_refs[name] = fid
    objects[fid] = {
        'isa': 'PBXFileReference',
        'lastKnownFileType': ftype,
        'path': name,
        'sourceTree': '<group>'
    }
    objects[bid] = {
        'isa': 'PBXBuildFile',
        'fileRef': fid
    }
    sources_build_file_ids.append(bid)

img_file_refs = {}
for name, path, ftype, in_bundle in resource_files:
    fid = make_id('file_' + name)
    img_file_refs[name] = fid
    objects[fid] = {
        'isa': 'PBXFileReference',
        'lastKnownFileType': ftype,
        'path': name,
        'sourceTree': '<group>'
    }
    if in_bundle:
        bid = make_id('build_' + name)
        objects[bid] = {
            'isa': 'PBXBuildFile',
            'fileRef': fid
        }
        resources_build_file_ids.append(bid)

# Build phases
sources_phase_id = make_id('sources_phase')
objects[sources_phase_id] = {
    'isa': 'PBXSourcesBuildPhase',
    'buildActionMask': 2147483647,
    'files': sources_build_file_ids,
    'runOnlyForDeploymentPostprocessing': 0
}

resources_phase_id = make_id('resources_phase')
objects[resources_phase_id] = {
    'isa': 'PBXResourcesBuildPhase',
    'buildActionMask': 2147483647,
    'files': resources_build_file_ids,
    'runOnlyForDeploymentPostprocessing': 0
}

frameworks_phase_id = make_id('frameworks_phase')
objects[frameworks_phase_id] = {
    'isa': 'PBXFrameworksBuildPhase',
    'buildActionMask': 2147483647,
    'files': [],
    'runOnlyForDeploymentPostprocessing': 0
}

# Groups
app_group_id = make_id('group_app')
objects[app_group_id] = {
    'isa': 'PBXGroup',
    'children': [swift_file_refs['PickupCodeApp.swift']],
    'path': 'App',
    'sourceTree': '<group>'
}

core_group_id = make_id('group_core')
objects[core_group_id] = {
    'isa': 'PBXGroup',
    'children': [
        swift_file_refs['Models.swift'],
        swift_file_refs['ThemeManager.swift'],
        swift_file_refs['JumpManager.swift'],
    ],
    'path': 'Core',
    'sourceTree': '<group>'
}

views_group_id = make_id('group_views')
objects[views_group_id] = {
    'isa': 'PBXGroup',
    'children': [
        swift_file_refs['ContentView.swift'],
        swift_file_refs['EntryCardView.swift'],
        swift_file_refs['SettingsView.swift'],
        swift_file_refs['ToastView.swift'],
        swift_file_refs['PlatformIconView.swift'],
    ],
    'path': 'Views',
    'sourceTree': '<group>'
}

images_group_id = make_id('group_images')
objects[images_group_id] = {
    'isa': 'PBXGroup',
    'children': [img_file_refs[os.path.basename(p)] for p in png_files],
    'path': 'Images',
    'sourceTree': '<group>'
}

res_group_id = make_id('group_res')
objects[res_group_id] = {
    'isa': 'PBXGroup',
    'children': [images_group_id, img_file_refs['Info.plist']],
    'path': 'Resources',
    'sourceTree': '<group>'
}

pickupcode_group_id = make_id('group_pickupcode')
objects[pickupcode_group_id] = {
    'isa': 'PBXGroup',
    'children': [app_group_id, core_group_id, views_group_id, res_group_id],
    'path': 'PickupCode',
    'sourceTree': '<group>'
}

products_group_id = make_id('group_products')
objects[products_group_id] = {
    'isa': 'PBXGroup',
    'children': [app_prod_id],
    'name': 'Products',
    'sourceTree': '<group>'
}

main_group_id = make_id('main_group')
objects[main_group_id] = {
    'isa': 'PBXGroup',
    'children': [pickupcode_group_id, products_group_id],
    'sourceTree': '<group>'
}

# Configurations
proj_debug_cfg_id = make_id('proj_debug_cfg')
objects[proj_debug_cfg_id] = {
    'isa': 'XCBuildConfiguration',
    'buildSettings': {
        'ALWAYS_SEARCH_USER_PATHS': 'NO',
        'CLANG_ANALYZER_NONNULL': 'YES',
        'CLANG_CXX_LANGUAGE_STANDARD': 'gnu++20',
        'CLANG_ENABLE_MODULES': 'YES',
        'CLANG_ENABLE_OBJC_ARC': 'YES',
        'ENABLE_TESTABILITY': 'YES',
        'GCC_DYNAMIC_NO_PIC': 'NO',
        'GCC_OPTIMIZATION_LEVEL': '0',
        'GCC_PREPROCESSOR_DEFINITIONS': ['DEBUG=1', '$(inherited)'],
        'IPHONEOS_DEPLOYMENT_TARGET': '16.0',
        'MTL_ENABLE_DEBUG_INFO': 'INCLUDE_SOURCE',
        'ONLY_ACTIVE_ARCH': 'YES',
        'SDKROOT': 'iphoneos',
        'SWIFT_ACTIVE_COMPILATION_CONDITIONS': 'DEBUG',
        'SWIFT_OPTIMIZATION_LEVEL': '-Onone'
    },
    'name': 'Debug'
}

proj_release_cfg_id = make_id('proj_release_cfg')
objects[proj_release_cfg_id] = {
    'isa': 'XCBuildConfiguration',
    'buildSettings': {
        'ALWAYS_SEARCH_USER_PATHS': 'NO',
        'CLANG_ANALYZER_NONNULL': 'YES',
        'CLANG_CXX_LANGUAGE_STANDARD': 'gnu++20',
        'CLANG_ENABLE_MODULES': 'YES',
        'CLANG_ENABLE_OBJC_ARC': 'YES',
        'ENABLE_NS_ASSERTIONS': 'NO',
        'IPHONEOS_DEPLOYMENT_TARGET': '16.0',
        'MTL_ENABLE_DEBUG_INFO': 'NO',
        'SDKROOT': 'iphoneos',
        'SWIFT_COMPILATION_MODE': 'wholemodule',
        'SWIFT_OPTIMIZATION_LEVEL': '-O',
        'VALIDATE_PRODUCT': 'YES'
    },
    'name': 'Release'
}

target_debug_cfg_id = make_id('target_debug_cfg')
objects[target_debug_cfg_id] = {
    'isa': 'XCBuildConfiguration',
    'buildSettings': {
        'CODE_SIGN_STYLE': 'Manual',
        'CODE_SIGN_IDENTITY': '',
        'CODE_SIGNING_REQUIRED': 'NO',
        'CODE_SIGNING_ALLOWED': 'NO',
        'CURRENT_PROJECT_VERSION': '1',
        'ENABLE_PREVIEWS': 'YES',
        'GENERATE_INFOPLIST_FILE': 'NO',
        'INFOPLIST_FILE': 'PickupCode/Resources/Info.plist',
        'IPHONEOS_DEPLOYMENT_TARGET': '16.0',
        'LD_RUNPATH_SEARCH_PATHS': ['$(inherited)', '@executable_path/Frameworks'],
        'MARKETING_VERSION': '1.0',
        'PRODUCT_BUNDLE_IDENTIFIER': 'com.takegai.fastcode',
        'PRODUCT_NAME': '$(TARGET_NAME)',
        'SWIFT_EMIT_LOC_STRINGS': 'YES',
        'SWIFT_VERSION': '5.0',
        'TARGETED_DEVICE_FAMILY': '1,2'
    },
    'name': 'Debug'
}

target_release_cfg_id = make_id('target_release_cfg')
objects[target_release_cfg_id] = {
    'isa': 'XCBuildConfiguration',
    'buildSettings': {
        'CODE_SIGN_STYLE': 'Manual',
        'CODE_SIGN_IDENTITY': '',
        'CODE_SIGNING_REQUIRED': 'NO',
        'CODE_SIGNING_ALLOWED': 'NO',
        'CURRENT_PROJECT_VERSION': '1',
        'ENABLE_PREVIEWS': 'YES',
        'GENERATE_INFOPLIST_FILE': 'NO',
        'INFOPLIST_FILE': 'PickupCode/Resources/Info.plist',
        'IPHONEOS_DEPLOYMENT_TARGET': '16.0',
        'LD_RUNPATH_SEARCH_PATHS': ['$(inherited)', '@executable_path/Frameworks'],
        'MARKETING_VERSION': '1.0',
        'PRODUCT_BUNDLE_IDENTIFIER': 'com.takegai.fastcode',
        'PRODUCT_NAME': '$(TARGET_NAME)',
        'SWIFT_EMIT_LOC_STRINGS': 'YES',
        'SWIFT_VERSION': '5.0',
        'TARGETED_DEVICE_FAMILY': '1,2'
    },
    'name': 'Release'
}

proj_cfg_list_id = make_id('proj_cfg_list')
objects[proj_cfg_list_id] = {
    'isa': 'XCConfigurationList',
    'buildConfigurations': [proj_debug_cfg_id, proj_release_cfg_id],
    'defaultConfigurationIsVisible': 0,
    'defaultConfigurationName': 'Release'
}

target_cfg_list_id = make_id('target_cfg_list')
objects[target_cfg_list_id] = {
    'isa': 'XCConfigurationList',
    'buildConfigurations': [target_debug_cfg_id, target_release_cfg_id],
    'defaultConfigurationIsVisible': 0,
    'defaultConfigurationName': 'Release'
}

app_target_id = make_id('target_pickupcode')
objects[app_target_id] = {
    'isa': 'PBXNativeTarget',
    'buildConfigurationList': target_cfg_list_id,
    'buildPhases': [sources_phase_id, frameworks_phase_id, resources_phase_id],
    'buildRules': [],
    'dependencies': [],
    'name': 'PickupCode',
    'productName': 'PickupCode',
    'productReference': app_prod_id,
    'productType': 'com.apple.product-type.application'
}

proj_id = make_id('project_root')
objects[proj_id] = {
    'isa': 'PBXProject',
    'attributes': {
        'BuildIndependentTargetsInParallel': 1,
        'LastUpgradeCheck': 1600,
        'TargetAttributes': {
            app_target_id: {'CreatedOnToolsVersion': '16.0'}
        }
    },
    'buildConfigurationList': proj_cfg_list_id,
    'compatibilityVersion': 'Xcode 14.0',
    'developmentRegion': 'zh_CN',
    'hasScannedForEncodings': 0,
    'knownRegions': ['en', 'Base', 'zh_CN'],
    'mainGroup': main_group_id,
    'productRefGroup': products_group_id,
    'projectDirPath': '',
    'projectRoot': '',
    'targets': [app_target_id]
}

root_plist = {
    'archiveVersion': '1',
    'classes': {},
    'objectVersion': '56',
    'objects': objects,
    'rootObject': proj_id
}

with open(f'{proj_dir}/PickupCode.xcodeproj/project.pbxproj', 'wb') as f:
    plistlib.dump(root_plist, f, fmt=plistlib.FMT_XML)

print('Updated project.pbxproj with PlatformIconView!')
