#!/bin/bash

current_dir=`pwd`

# for all supported CocoaPods versions
cocoapods_versions=( "0.33.1" )
for cocoapods_version in ${cocoapods_versions[@]} ; do

  echo "- cocoapods ${cocoapods_version}"

  # for all test directories
  test_dirs=( "plain" )
  for test_dir in ${test_dirs[@]} ; do
    echo "  - ${test_dir}"
    cd "${current_dir}/${test_dir}"
    ./test.sh ${cocoapods_version}
  done

done

echo "ok"
