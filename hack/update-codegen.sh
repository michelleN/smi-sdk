#!/usr/bin/env bash

# Copyright 2017 The Kubernetes Authors.
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#     http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.

set -o errexit
set -o nounset
set -o pipefail

ROOT_PACKAGE="github.com/michelleN/smi-sdk"
ROOT_DIR="$(git rev-parse --show-toplevel)"


# get code-generator version from go.sum
CODEGEN_VERSION="v0.19.2" # Must match k8s.io/client-go version defined in go.mod
CODEGEN_PKG="$(echo `go env GOPATH`/pkg/mod/k8s.io/code-generator@${CODEGEN_VERSION})"

echo ">>> using codegen: ${CODEGEN_PKG}"
# ensure we can execute the codegen script
chmod +x ${CODEGEN_PKG}/generate-groups.sh

function generate_client() {
  CUSTOM_RESOURCE_NAME=$1
  CUSTOM_RESOURCE_VERSIONS=$2

   # code-generator makes assumptions about the project being located in `$GOPATH/src`.

  "${CODEGEN_PKG}"/generate-groups.sh all \
    "$ROOT_PACKAGE/generated/$CUSTOM_RESOURCE_NAME" \
    "$ROOT_PACKAGE/apis" \
    $CUSTOM_RESOURCE_NAME:$CUSTOM_RESOURCE_VERSIONS \
    --go-header-file "${ROOT_DIR}"/hack/boilerplate.go.txt \
    --output-base ../../../
}

echo "##### Generating split.smi-spec.io client ######"
generate_client "split" "v1alpha1"