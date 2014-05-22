#!/bin/bash

description="UserDefaults extension, plain pod install"

cocoapods_version=$1
cocoapods_selection="_${cocoapods_version}_"

source ../../testbase/testbase.sh ${cocoapods_version} "${description}"

# create Podfile
cat >Podfile <<END
platform :ios, 7
pod 'LibComponentLogging-UserDefaults'
END

# pod install
step "pod install"
pod ${cocoapods_selection} install --no-repo-update > pod_out.log 2> pod_err.log
assert_success
assert_file_contains pod_out.log "Installing LibComponentLogging-Core (1.3.3)"
assert_file_contains pod_out.log "Installing LibComponentLogging-UserDefaults (1.0.3)"

# create lcl config files
step "create lcl config files"
cat <<END > lcl_config_components.h
_lcl_component(MyComponent, "MyComponent", "MyComponent")
END
cat <<END > lcl_config_logger.h
END
cat <<END > lcl_config_extensions.h
#import "LCLUserDefaults.h"
END
cp Pods/LibComponentLogging-UserDefaults/LCLUserDefaultsConfig.template.h LCLUserDefaultsConfig.h
sed s/\<UniquePrefix\>/TEST/g LCLUserDefaultsConfig.h > LCLUserDefaultsConfig.h.bak
mv LCLUserDefaultsConfig.h.bak LCLUserDefaultsConfig.h

# create main.m
step "create main.m"
cat > Project/main.m <<END
#import <UIKit/UIKit.h>

#import "PAppDelegate.h"
#import "lcl.h"

int main(int argc, char *argv[])
{

    [LCLUserDefaults restoreLogLevelSettingsFromStandardUserDefaults];

    lcl_configure_by_component(lcl_cMyComponent, lcl_vInfo);

    lcl_log(lcl_cMyComponent, lcl_vInfo, @"Test");

    @autoreleasepool {
        return UIApplicationMain(argc, argv, nil, NSStringFromClass([PAppDelegate class]));
    }
}
END

# build
step "build"
xcodebuild -workspace 'Project.xcworkspace' -scheme 'Project' -configuration "iPhone Simulator" > build.log
assert_success

# pod update
step "pod update"
pod ${cocoapods_selection} update --no-repo-update > pod_out.log 2> pod_err.log
assert_success
assert_file_contains pod_out.log "Using LibComponentLogging-Core (1.3.3)"
assert_file_contains pod_out.log "Using LibComponentLogging-UserDefaults (1.0.3)"

# build
step "build"
xcodebuild -workspace 'Project.xcworkspace' -scheme 'Project' -configuration "iPhone Simulator" > build.log
assert_success

# pod install
step "pod install"
pod ${cocoapods_selection} install --no-repo-update > pod_out.log 2> pod_err.log
assert_success
assert_file_contains pod_out.log "Using LibComponentLogging-Core (1.3.3)"
assert_file_contains pod_out.log "Using LibComponentLogging-UserDefaults (1.0.3)"

# build
step "build"
xcodebuild -workspace 'Project.xcworkspace' -scheme 'Project' -configuration "iPhone Simulator" > build.log
assert_success
