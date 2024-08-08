#!/bin/bash

set -e
echo "Running bundle install for build type: $BUILD_TYPE..."
NUM_JOBS=$(($(nproc) - 1))
if [[ "$BUILD_TYPE" == "development" ]]; then
  bundle install --jobs $NUM_JOBS --retry 5
else
  bundle config set deployment true
  bundle config set without 'development test'
  bundle install --jobs $NUM_JOBS --retry 5
fi
