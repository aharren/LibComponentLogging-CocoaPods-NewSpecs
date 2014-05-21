#!/bin/bash

cocoapods_version=$1
cocoapods_selection="_${cocoapods_version}_"

source ../../testbase/testbase.sh ${cocoapods_version}

# lint the specs
step "pod spec lint"
pod "_${cocoapods_version}_" spec lint ~/.cocoapods/repos/a_lcl --quick > pod_lint_out.log 2> pod_lint_err.log
assert_file_contains pod_lint_out.log "All the specs passed validation"
