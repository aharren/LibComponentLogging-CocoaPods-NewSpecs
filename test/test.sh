#!/bin/bash

current_dir=`pwd`

# for all supported CocoaPods versions
cocoapods_versions=( "0.33.1" )
for cocoapods_version in ${cocoapods_versions[@]} ; do

  echo "- cocoapods ${cocoapods_version}"

  # for all scenarios
  scenario_dirs=( "spec_lint" "plain_LogFile" )
  for scenario_dir in ${scenario_dirs[@]} ; do
    echo "  - ${scenario_dir}"
    cd "${current_dir}/scenarios/${scenario_dir}"
    ./test.sh ${cocoapods_version}
  done

done

echo "ok"
