#!/bin/bash

cocoapods_version=$1
current_dir=`pwd`

# assertions
assert_success() {
  rc=$?
  if [[ $rc != 0 ]] ; then
    echo "## assertion failed: expected success"
    exit
  fi
}

assert_file_contains() {
  file=$1
  what=$2
  fgrep -q "$what" "$file"
  rc=$?
  if [[ $rc != 0 ]] ; then
    echo "## assertion failed: expected file '$file' to contain '$what'"
    echo "## file '$file':"
    echo "<<<<"
    cat $file
    echo ">>>>"
    exit
  fi
}

assert_file_not_contains() {
  file=$1
  what=$2
  fgrep -q "$what" "$file"
  rc=$?
  if [[ $rc != 1 ]] ; then
    echo "## assertion failed: expected file '$file' to not contain '$what'"
    echo "## file '$file':"
    echo "<<<<"
    cat $file
    echo ">>>>"
    exit
  fi
}

# step marker
step() {
  echo "    - $1 "
}

# intialize
step "init"

# clean up and initialize
work_dir="work_${cocoapods_version}"
rm -rf "${work_dir}"
mkdir "${work_dir}"

# continue in the work directory
cd "${work_dir}"

# copy testbase resources
cp -r "../../../testbase/Project" .
cp -r "../../../testbase/Project.xcodeproj" .
cp -r "../../../testbase/ProjectTests" .

# set up CocoaPods
step "pod setup"
rm -rf ~/.cocoapods
pod "_${cocoapods_version}_" --version > pod_init_out.log 2> pod_init_err.log
assert_file_contains pod_init_out.log "${cocoapods_version}"
ln -s "${current_dir}/../../../specs/" ~/.cocoapods/repos/a_lcl
rm -rf ~/.cocoapods/repos/master/Specs/LibComponentLogging*
