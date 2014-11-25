#!/bin/bash

description="Core, LogFile, qlog, lcl_configure pod"

cocoapods_version=$1
cocoapods_selection="_${cocoapods_version}_"

source ../../testbase/testbase.sh ${cocoapods_version} "${description}"

# create Podfile
cat >Podfile <<END
platform :ios, 7
pod 'LibComponentLogging-Core', '= 1.1.6'
pod 'LibComponentLogging-LogFile', '= 1.1.5'
pod 'LibComponentLogging-qlog', '= 1.0.3'
pod 'LibComponentLogging-pods'
END

# pod install
step "pod install"
pod ${cocoapods_selection} install --no-repo-update > pod_out.log 2> pod_err.log
assert_success
assert_file_contains pod_out.log "Installing LibComponentLogging-Core (1.1.6)"
assert_file_contains pod_out.log "Installing LibComponentLogging-LogFile (1.1.5)"
assert_file_contains pod_out.log "Installing LibComponentLogging-qlog (1.0.3)"
assert_file_contains pod_out.log "Installing LibComponentLogging-pods (0.0.2)"

# run lcl_configure pod
step "run lcl_configure pod"
assert_file_not_exists "lcl_config_components.h"
assert_file_not_exists "lcl_config_logger.h"
assert_file_not_exists "lcl_config_extensions.h"
assert_file_not_exists "LCLLogFileConfig.h"
${LCL_CONFIGURE} pod > configure_out.log 2> configure_err.log
assert_file_contains configure_out.log "Creating configuration file 'lcl_config_components.h'"
assert_file_contains configure_out.log "Creating configuration file 'lcl_config_logger.h'"
assert_file_contains configure_out.log "Creating configuration file 'lcl_config_extensions.h'"
assert_file_contains configure_out.log "Using LibComponentLogging-Core (core)"
assert_file_contains configure_out.log "Using LibComponentLogging-LogFile (LogFile logger)"
assert_file_contains configure_out.log "Creating configuration file 'LCLLogFileConfig.h' from template 'Pods/LibComponentLogging-LogFile/LCLLogFileConfig.template.h'"
assert_file_contains configure_out.log "[!] Configuration file 'LCLLogFileConfig.h' needs to be adapted before compiling your project, e.g. adapt '<UniquePrefix>'"
assert_file_contains configure_out.log "Using LibComponentLogging-qlog (qlog extension)"
assert_file_exists "lcl_config_components.h"
assert_file_exists "lcl_config_logger.h"
assert_file_exists "lcl_config_extensions.h"
assert_file_exists "LCLLogFileConfig.h"
assert_file_contains lcl_config_logger.h "#include \"LCLLogFile.h\""
assert_file_contains lcl_config_extensions.h "#include \"qlog.h\""

# add log component
cat <<END >> lcl_config_components.h
_lcl_component(MyComponent, "MyComponent", "MyComponent")
END

# adapt logger config file
sed s/\<UniquePrefix\>/TEST/g LCLLogFileConfig.h > LCLLogFileConfig.h.bak
mv LCLLogFileConfig.h.bak LCLLogFileConfig.h

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
assert_file_contains pod_out.log "Using LibComponentLogging-Core (1.1.6)"
assert_file_contains pod_out.log "Using LibComponentLogging-LogFile (1.1.5)"
assert_file_contains pod_out.log "Using LibComponentLogging-qlog (1.0.3)"
assert_file_contains pod_out.log "Using LibComponentLogging-pods (0.0.2)"

# run lcl_configure pod
step "run lcl_configure pod"
assert_file_exists "lcl_config_components.h"
assert_file_exists "lcl_config_logger.h"
assert_file_exists "lcl_config_extensions.h"
assert_file_exists "LCLLogFileConfig.h"
${LCL_CONFIGURE} pod > configure_out.log 2> configure_err.log
assert_file_not_contains configure_out.log "Creating configuration file 'lcl_config_components.h'"
assert_file_not_contains configure_out.log "Creating configuration file 'lcl_config_logger.h'"
assert_file_not_contains configure_out.log "Creating configuration file 'lcl_config_extensions.h'"
assert_file_contains configure_out.log "Using LibComponentLogging-Core (core)"
assert_file_contains configure_out.log "Using LibComponentLogging-LogFile (LogFile logger)"
assert_file_not_contains configure_out.log "LCLLogFileConfig.h"
assert_file_contains configure_out.log "Using LibComponentLogging-qlog (qlog extension)"
assert_file_exists "lcl_config_components.h"
assert_file_exists "lcl_config_logger.h"
assert_file_exists "lcl_config_extensions.h"
assert_file_exists "LCLLogFileConfig.h"

# build
step "build"
xcodebuild -workspace 'Project.xcworkspace' -scheme 'Project' -configuration "iPhone Simulator" > build.log
assert_success

# pod install
step "pod install"
pod ${cocoapods_selection} install --no-repo-update > pod_out.log 2> pod_err.log
assert_success
assert_file_contains pod_out.log "Using LibComponentLogging-Core (1.1.6)"
assert_file_contains pod_out.log "Using LibComponentLogging-LogFile (1.1.5)"
assert_file_contains pod_out.log "Using LibComponentLogging-qlog (1.0.3)"
assert_file_contains pod_out.log "Using LibComponentLogging-pods (0.0.2)"

# build
step "build"
xcodebuild -workspace 'Project.xcworkspace' -scheme 'Project' -configuration "iPhone Simulator" > build.log
assert_success
