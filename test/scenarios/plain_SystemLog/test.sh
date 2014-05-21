#!/bin/bash

cocoapods_version=$1
cocoapods_selection="_${cocoapods_version}_"

source ../../testbase/testbase.sh ${cocoapods_version}

# create Podfile
cat >Podfile <<END
platform :ios, 7
pod 'LibComponentLogging-SystemLog'
pod 'LibComponentLogging-qlog'
END

# pod install
step "pod install"
pod ${cocoapods_selection} install --no-repo-update > pod_out.log 2> pod_err.log
assert_success
assert_file_contains pod_out.log "Installing LibComponentLogging-Core (1.3.3)"
assert_file_contains pod_out.log "Installing LibComponentLogging-SystemLog (1.2.2)"
assert_file_contains pod_out.log "Installing LibComponentLogging-qlog (1.1.1)"

# create lcl config files
step "create lcl config files"
cat <<END > lcl_config_components.h
_lcl_component(MyComponent, "MyComponent", "MyComponent")
END
cat <<END > lcl_config_logger.h
#import "LCLSystemLog.h"
END
cat <<END > lcl_config_extensions.h
#import "qlog.h"
END
cp Pods/LibComponentLogging-SystemLog/LCLSystemLogConfig.template.h LCLSystemLogConfig.h
sed s/\<UniquePrefix\>/TEST/g LCLSystemLogConfig.h > LCLSystemLogConfig.h.bak
mv LCLSystemLogConfig.h.bak LCLSystemLogConfig.h

# create main.m
step "create main.m"
cat > Project/main.m <<END
#import <UIKit/UIKit.h>

#import "PAppDelegate.h"
#import "lcl.h"

int main(int argc, char *argv[])
{
    lcl_configure_by_component(lcl_cMyComponent, lcl_vInfo);

    lcl_log(lcl_cMyComponent, lcl_vInfo, @"Test");

    qlinfo_c(lcl_cMyComponent, @"Test");

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
assert_file_contains pod_out.log "Using LibComponentLogging-SystemLog (1.2.2)"
assert_file_contains pod_out.log "Using LibComponentLogging-qlog (1.1.1)"

# build
step "build"
xcodebuild -workspace 'Project.xcworkspace' -scheme 'Project' -configuration "iPhone Simulator" > build.log
assert_success

# pod install
step "pod install"
pod ${cocoapods_selection} install --no-repo-update > pod_out.log 2> pod_err.log
assert_success
assert_file_contains pod_out.log "Using LibComponentLogging-Core (1.3.3)"
assert_file_contains pod_out.log "Using LibComponentLogging-SystemLog (1.2.2)"
assert_file_contains pod_out.log "Using LibComponentLogging-qlog (1.1.1)"

# build
step "build"
xcodebuild -workspace 'Project.xcworkspace' -scheme 'Project' -configuration "iPhone Simulator" > build.log
assert_success
