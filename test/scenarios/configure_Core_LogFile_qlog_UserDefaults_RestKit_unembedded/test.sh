#!/bin/bash

description="Core, LogFile, qlog, UserDefaults, RestKit un-embedded, lcl_configure pod"

cocoapods_version=$1
cocoapods_selection="_${cocoapods_version}_"

source ../../testbase/testbase.sh ${cocoapods_version} "${description}"

# create Podfile
cat >Podfile <<END
platform :ios, 7
pod 'LibComponentLogging-LogFile'
pod 'LibComponentLogging-qlog'
pod 'LibComponentLogging-UserDefaults'
pod 'LibComponentLogging-pods'
pod 'RestKit', '>= 0.20.0'
END

# pod install
step "pod install"
pod ${cocoapods_selection} install --no-repo-update > pod_out.log 2> pod_err.log
assert_success
assert_file_contains pod_out.log "Installing LibComponentLogging-Core (1.3.3)"
assert_file_contains pod_out.log "Installing LibComponentLogging-LogFile (1.2.2)"
assert_file_contains pod_out.log "Installing LibComponentLogging-UserDefaults (1.0.3)"
assert_file_contains pod_out.log "Installing LibComponentLogging-pods (0.0.1)"
assert_file_contains pod_out.log "Installing RestKit"

# run lcl_configure pod
step "run lcl_configure pod"
assert_file_not_exists "lcl_config_components.h"
assert_file_not_exists "lcl_config_logger.h"
assert_file_not_exists "lcl_config_extensions.h"
assert_file_not_exists "LCLLogFileConfig.h"
Pods/LibComponentLogging-pods/configure/lcl_configure pod > configure_out.log 2> configure_err.log
assert_file_contains configure_out.log "Creating configuration file 'lcl_config_components.h'"
assert_file_contains configure_out.log "Creating configuration file 'lcl_config_logger.h'"
assert_file_contains configure_out.log "Creating configuration file 'lcl_config_extensions.h'"
assert_file_contains configure_out.log "Using LibComponentLogging-Core (core)"
assert_file_contains configure_out.log "Using LibComponentLogging-LogFile (LogFile logger)"
assert_file_contains configure_out.log "Creating configuration file 'LCLLogFileConfig.h' from template 'Pods/LibComponentLogging-LogFile/LCLLogFileConfig.template.h'"
assert_file_contains configure_out.log "[!] Configuration file 'LCLLogFileConfig.h' needs to be adapted before compiling your project, e.g. adapt '<UniquePrefix>'"
assert_file_contains configure_out.log "Using LibComponentLogging-UserDefaults (UserDefaults extension)"
assert_file_contains configure_out.log "Creating configuration file 'LCLUserDefaultsConfig.h' from template 'Pods/LibComponentLogging-UserDefaults/LCLUserDefaultsConfig.template.h'"
assert_file_contains configure_out.log "[!] Configuration file 'LCLUserDefaultsConfig.h' needs to be adapted before compiling your project, e.g. adapt '<UniquePrefix>'"
assert_file_contains configure_out.log "Using RestKit (un-embedded RestKit/RK)"
assert_file_contains configure_out.log "Creating configuration file '${cocoapods_path_pod_buildheaders}/RestKit/lcl_config_components.h'"
assert_file_contains configure_out.log "Creating configuration file '${cocoapods_path_pod_buildheaders}/RestKit/lcl_config_logger.h'"
assert_file_contains configure_out.log "Creating configuration file '${cocoapods_path_pod_buildheaders}/RestKit/lcl_config_extensions.h'"
assert_file_contains configure_out.log "Creating configuration file '${cocoapods_path_pod_buildheaders}/RestKit/LCLLogFileConfig.h'"
assert_file_contains configure_out.log "Creating configuration file '${cocoapods_path_pod_buildheaders}/RestKit/LCLUserDefaultsConfig.h'"
assert_file_contains configure_out.log "Rewriting file 'Pods/RestKit/Vendor/LibComponentLogging/Core/lcl_RK.h'"
assert_file_contains configure_out.log "Rewriting file 'Pods/RestKit/Vendor/LibComponentLogging/Core/lcl_RK.m'"
assert_file_exists "lcl_config_components.h"
assert_file_exists "lcl_config_logger.h"
assert_file_exists "lcl_config_extensions.h"
assert_file_exists "LCLLogFileConfig.h"
assert_file_exists "LCLUserDefaultsConfig.h"
assert_file_contains lcl_config_logger.h "#include \"LCLLogFile.h\""
assert_file_contains lcl_config_extensions.h "#include \"qlog.h\""
assert_file_contains lcl_config_extensions.h "#include \"LCLUserDefaults.h\""
assert_file_contains lcl_config_components.h "#include \"Pods/RestKit/Code/Support/lcl_config_components_RK.h\""

# add log component
cat <<END >> lcl_config_components.h
_lcl_component(MyComponent, "MyComponent", "MyComponent")
END

# adapt logger config file
sed s/\<UniquePrefix\>/TEST/g LCLLogFileConfig.h > LCLLogFileConfig.h.bak
mv LCLLogFileConfig.h.bak LCLLogFileConfig.h

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
    lcl_configure_by_component(lcl_cMyComponent, lcl_vInfo);
    lcl_configure_by_component(lcl_cRestKit, lcl_vInfo);

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
assert_file_contains pod_out.log "Using LibComponentLogging-LogFile (1.2.2)"
assert_file_contains pod_out.log "Using LibComponentLogging-qlog (1.1.1)"
assert_file_contains pod_out.log "Using LibComponentLogging-UserDefaults (1.0.3)"
assert_file_contains pod_out.log "Using LibComponentLogging-pods (0.0.1)"
assert_file_contains pod_out.log "Using RestKit"

# run lcl_configure pod
step "run lcl_configure pod"
assert_file_exists "lcl_config_components.h"
assert_file_exists "lcl_config_logger.h"
assert_file_exists "lcl_config_extensions.h"
assert_file_exists "LCLLogFileConfig.h"
assert_file_exists "LCLUserDefaultsConfig.h"
Pods/LibComponentLogging-pods/configure/lcl_configure pod > configure_out.log 2> configure_err.log
assert_file_not_contains configure_out.log "Creating configuration file 'lcl_config_components.h'"
assert_file_not_contains configure_out.log "Creating configuration file 'lcl_config_logger.h'"
assert_file_not_contains configure_out.log "Creating configuration file 'lcl_config_extensions.h'"
assert_file_contains configure_out.log "Using LibComponentLogging-Core (core)"
assert_file_contains configure_out.log "Using LibComponentLogging-LogFile (LogFile logger)"
assert_file_not_contains configure_out.log "'LCLLogFileConfig.h'"
assert_file_contains configure_out.log "Using LibComponentLogging-qlog (qlog extension)"
assert_file_contains configure_out.log "Using LibComponentLogging-UserDefaults (UserDefaults extension)"
assert_file_not_contains configure_out.log "'LCLUserDefaultsConfig.h'"
assert_file_contains configure_out.log "Using RestKit (un-embedded RestKit/RK)"
assert_file_contains configure_out.log "Creating configuration file '${cocoapods_path_pod_buildheaders}/RestKit/lcl_config_components.h'"
assert_file_contains configure_out.log "Creating configuration file '${cocoapods_path_pod_buildheaders}/RestKit/lcl_config_logger.h'"
assert_file_contains configure_out.log "Creating configuration file '${cocoapods_path_pod_buildheaders}/RestKit/lcl_config_extensions.h'"
assert_file_contains configure_out.log "Creating configuration file '${cocoapods_path_pod_buildheaders}/RestKit/LCLLogFileConfig.h'"
assert_file_contains configure_out.log "Creating configuration file '${cocoapods_path_pod_buildheaders}/RestKit/LCLUserDefaultsConfig.h'"
assert_file_not_contains configure_out.log "Rewriting file 'Pods/RestKit/Vendor/LibComponentLogging/Core/lcl_RK.h'"
assert_file_not_contains configure_out.log "Rewriting file 'Pods/RestKit/Vendor/LibComponentLogging/Core/lcl_RK.m'"
assert_file_exists "lcl_config_components.h"
assert_file_exists "lcl_config_logger.h"
assert_file_exists "lcl_config_extensions.h"
assert_file_exists "LCLLogFileConfig.h"
assert_file_exists "LCLUserDefaultsConfig.h"
assert_file_contains lcl_config_logger.h "#include \"LCLLogFile.h\""
assert_file_contains lcl_config_components.h "#include \"Pods/RestKit/Code/Support/lcl_config_components_RK.h\""
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
assert_file_contains pod_out.log "Using LibComponentLogging-LogFile (1.2.2)"
assert_file_contains pod_out.log "Using LibComponentLogging-qlog (1.1.1)"
assert_file_contains pod_out.log "Using LibComponentLogging-UserDefaults (1.0.3)"
assert_file_contains pod_out.log "Using LibComponentLogging-pods (0.0.1)"
assert_file_contains pod_out.log "Using RestKit"

# run lcl_configure pod
step "run lcl_configure pod"
Pods/LibComponentLogging-pods/configure/lcl_configure pod > configure_out.log 2> configure_err.log

# build
step "build"
xcodebuild -workspace 'Project.xcworkspace' -scheme 'Project' -configuration "iPhone Simulator" > build.log
assert_success
