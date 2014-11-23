#!/bin/bash

description="Core, SystemLog, qlog, UserDefaults, lcl_configure pod"

cocoapods_version=$1
cocoapods_selection="_${cocoapods_version}_"

source ../../testbase/testbase.sh ${cocoapods_version} "${description}"

# create Podfile
cat >Podfile <<END
platform :ios, 7
pod 'LibComponentLogging-Core'
pod 'LibComponentLogging-SystemLog'
pod 'LibComponentLogging-qlog'
pod 'LibComponentLogging-UserDefaults'
pod 'LibComponentLogging-pods'
END

# pod install
step "pod install"
pod ${cocoapods_selection} install --no-repo-update > pod_out.log 2> pod_err.log
assert_success
assert_file_contains pod_out.log "Installing LibComponentLogging-Core (1.3.3)"
assert_file_contains pod_out.log "Installing LibComponentLogging-SystemLog (1.2.2)"
assert_file_contains pod_out.log "Installing LibComponentLogging-qlog (1.1.1)"
assert_file_contains pod_out.log "Installing LibComponentLogging-UserDefaults (1.0.3)"
assert_file_contains pod_out.log "Installing LibComponentLogging-pods (0.0.1)"

# run lcl_configure pod
step "run lcl_configure pod"
assert_file_not_exists "lcl_config_components.h"
assert_file_not_exists "lcl_config_logger.h"
assert_file_not_exists "lcl_config_extensions.h"
assert_file_not_exists "LCLSystemLogConfig.h"
assert_file_not_exists "LCLUserDefaultsConfig.h"
${LCL_CONFIGURE} pod > configure_out.log 2> configure_err.log
assert_file_contains configure_out.log "Creating configuration file 'lcl_config_components.h'"
assert_file_contains configure_out.log "Creating configuration file 'lcl_config_logger.h'"
assert_file_contains configure_out.log "Creating configuration file 'lcl_config_extensions.h'"
assert_file_contains configure_out.log "Using LibComponentLogging-Core (core)"
assert_file_contains configure_out.log "Using LibComponentLogging-SystemLog (SystemLog logger)"
assert_file_contains configure_out.log "Creating configuration file 'LCLSystemLogConfig.h' from template 'Pods/LibComponentLogging-SystemLog/LCLSystemLogConfig.template.h'"
assert_file_contains configure_out.log "[!] Configuration file 'LCLSystemLogConfig.h' needs to be adapted before compiling your project, e.g. adapt '<UniquePrefix>'"
assert_file_contains configure_out.log "Using LibComponentLogging-qlog (qlog extension)"
assert_file_contains configure_out.log "Using LibComponentLogging-UserDefaults (UserDefaults extension)"
assert_file_contains configure_out.log "Creating configuration file 'LCLUserDefaultsConfig.h' from template 'Pods/LibComponentLogging-UserDefaults/LCLUserDefaultsConfig.template.h'"
assert_file_contains configure_out.log "[!] Configuration file 'LCLUserDefaultsConfig.h' needs to be adapted before compiling your project, e.g. adapt '<UniquePrefix>'"
assert_file_exists "lcl_config_components.h"
assert_file_exists "lcl_config_logger.h"
assert_file_exists "lcl_config_extensions.h"
assert_file_exists "LCLSystemLogConfig.h"
assert_file_exists "LCLUserDefaultsConfig.h"
assert_file_contains lcl_config_logger.h "#include \"LCLSystemLog.h\""
assert_file_contains lcl_config_extensions.h "#include \"qlog.h\""
assert_file_contains lcl_config_extensions.h "#include \"LCLUserDefaults.h\""

# add log component
cat <<END >> lcl_config_components.h
_lcl_component(MyComponent, "MyComponent", "MyComponent")
END

# adapt logger config file
sed s/\<UniquePrefix\>/TEST/g LCLSystemLogConfig.h > LCLSystemLogConfig.h.bak
mv LCLSystemLogConfig.h.bak LCLSystemLogConfig.h

# adapt UserDefaults config file
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
assert_file_contains pod_out.log "Using LibComponentLogging-SystemLog (1.2.2)"
assert_file_contains pod_out.log "Using LibComponentLogging-qlog (1.1.1)"
assert_file_contains pod_out.log "Using LibComponentLogging-UserDefaults (1.0.3)"
assert_file_contains pod_out.log "Using LibComponentLogging-pods (0.0.1)"

# run lcl_configure pod
step "run lcl_configure pod"
assert_file_exists "lcl_config_components.h"
assert_file_exists "lcl_config_logger.h"
assert_file_exists "lcl_config_extensions.h"
assert_file_exists "LCLSystemLogConfig.h"
assert_file_exists "LCLUserDefaultsConfig.h"
${LCL_CONFIGURE} pod > configure_out.log 2> configure_err.log
assert_file_not_contains configure_out.log "Creating configuration file 'lcl_config_components.h'"
assert_file_not_contains configure_out.log "Creating configuration file 'lcl_config_logger.h'"
assert_file_not_contains configure_out.log "Creating configuration file 'lcl_config_extensions.h'"
assert_file_contains configure_out.log "Using LibComponentLogging-Core (core)"
assert_file_contains configure_out.log "Using LibComponentLogging-SystemLog (SystemLog logger)"
assert_file_not_contains configure_out.log "LCLSystemLogConfig.h"
assert_file_contains configure_out.log "Using LibComponentLogging-qlog (qlog extension)"
assert_file_contains configure_out.log "Using LibComponentLogging-UserDefaults (UserDefaults extension)"
assert_file_not_contains configure_out.log "LCLUserDefaultsConfig.h"
assert_file_exists "lcl_config_components.h"
assert_file_exists "lcl_config_logger.h"
assert_file_exists "lcl_config_extensions.h"
assert_file_exists "LCLSystemLogConfig.h"
assert_file_exists "LCLUserDefaultsConfig.h"
assert_file_contains lcl_config_logger.h "#include \"LCLSystemLog.h\""
assert_file_contains lcl_config_extensions.h "#include \"qlog.h\""
assert_file_contains lcl_config_extensions.h "#include \"LCLUserDefaults.h\""

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
assert_file_contains pod_out.log "Using LibComponentLogging-UserDefaults (1.0.3)"
assert_file_contains pod_out.log "Using LibComponentLogging-pods (0.0.1)"

# build
step "build"
xcodebuild -workspace 'Project.xcworkspace' -scheme 'Project' -configuration "iPhone Simulator" > build.log
assert_success
