#!/bin/bash

current_dir=`pwd`

# for all supported CocoaPods versions
cocoapods_versions=(
  "0.33.1"
)
for cocoapods_version in ${cocoapods_versions[@]} ; do

  echo "- cocoapods ${cocoapods_version}"

  # for all scenarios
  scenario_dirs=(
    # pod spec lint for all pod specs
    "spec_lint"
    # core, plain pod install
    "plain_Core"
    # logging back-ends, plain pod install
    "plain_NSLog"
    "plain_LogFile"
    "plain_SystemLog"
    "plain_NSLogger"
    # extensions, plain pod install
    "plain_UserDefaults"
    "plain_qlog"
  )
  for scenario_dir in ${scenario_dirs[@]} ; do
    echo -ne "  - ${scenario_dir}"
    cd "${current_dir}/scenarios/${scenario_dir}"
    ./test.sh ${cocoapods_version}
  done

done

echo "ok"
