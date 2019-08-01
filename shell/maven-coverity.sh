#!/bin/bash

# Copyright 2019 Samsung Electronics Co., Ltd.
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
# http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.

set -Eeuxo pipefail
PS4='+['$(readlink -f "$0")' ${FUNCNAME[0]%main}#$LINENO] '

echo '---> maven-coverity.sh'

SUBMISSION_ATTEMPTS=5
SUBMISSION_INITIAL_REST_INTERVAL=30 # seconds, will be doubled after each attempt

#-----------------------------------------------------------------------------
# Process parameters for JS/PHP/Ruby files analysis

FS_CAPTURE_SEARCH_PARAMS=''
if [ -n "${SEARCH_PATHS:=}" ]; then
  for SEARCH_PATH in ${SEARCH_PATHS}; do
    if [ -d "${SEARCH_PATH}" ]; then
      FS_CAPTURE_SEARCH_PARAMS="${FS_CAPTURE_SEARCH_PARAMS} --fs-capture-search '${SEARCH_PATH}'"
    else
      echo "'${SEARCH_PATH}' from \$SEARCH_PATHS is not an existing directory." >&2
      exit 1
    fi
  done
fi

for EXCLUDE_REGEX in ${SEARCH_EXCLUDE_REGEXS:=}; do
  FS_CAPTURE_SEARCH_PARAMS="${FS_CAPTURE_SEARCH_PARAMS} --fs-capture-search-exclude-regex '${EXCLUDE_REGEX}'"
done

#-----------------------------------------------------------------------------
# Check if we are allowed to submit results to Coverity Scan service
# and have not exceeded our upload quota limits
# See also: https://scan.coverity.com/faq#frequency

CURL_OUTPUT=$(
  curl \
    --verbose \
    --silent \
    --show-error \
    --fail \
    --form "project=${COVERITY_PROJECT_NAME}" \
    --form "token=${COVERITY_TOKEN}" \
    'https://scan.coverity.com/api/upload_permitted'
)

IS_COVERITY_UPLOAD_PERMITTED=$(
  echo "${CURL_OUTPUT}" \
  | jq '.upload_permitted'
)
if [ x"${IS_COVERITY_UPLOAD_PERMITTED}" != x'true' ]; then
  echo "Upload quota reached. Next upload permitted at "$(echo "${CURL_OUTPUT}" | jq '.next_upload_permitted_at') >&2
  exit 1
fi

#-----------------------------------------------------------------------------
# Get Coverity Scan build tool

curl \
  --verbose \
  --silent \
  --show-error \
  --fail \
  --form "project=${COVERITY_PROJECT_NAME}" \
  --form "token=${COVERITY_TOKEN}" \
  --output 'coverity_tool.tgz' \
  'https://scan.coverity.com/download/linux64'

curl \
  --verbose \
  --silent \
  --show-error \
  --fail \
  --form "project=${COVERITY_PROJECT_NAME}" \
  --form "token=${COVERITY_TOKEN}" \
  --form 'md5=1' \
  --output 'coverity_tool.md5' \
  'https://scan.coverity.com/download/linux64'

echo -n ' coverity_tool.tgz' >> 'coverity_tool.md5'
md5sum --check 'coverity_tool.md5'

tar \
  --extract \
  --gunzip \
  --file='coverity_tool.tgz'

COVERITY_BUILD_TOOL_DIRECTORY=$(
  head -1 <( \
    tar \
      --list \
      --gunzip \
      --file='coverity_tool.tgz'
  )
)
COVERITY_BINARY_DIRECTORY="${COVERITY_BUILD_TOOL_DIRECTORY}bin"
test -d "${COVERITY_BINARY_DIRECTORY}" \
  || exit 1
export PATH="${PATH}:${COVERITY_BINARY_DIRECTORY}"

rm 'coverity_tool.tgz'

#-----------------------------------------------------------------------------
# Build

export MAVEN_OPTS

eval cov-build \
  --dir 'cov-int' \
  ${FS_CAPTURE_SEARCH_PARAMS} \
  "${MVN}" clean install \
    --errors \
    --global-settings "${GLOBAL_SETTINGS_FILE}" \
    --settings "${SETTINGS_FILE}" \
    ${MAVEN_OPTIONS:=} \
    ${MAVEN_PARAMS:=}

cov-import-scm \
  --dir 'cov-int' \
  --scm 'git'

cov-manage-emit \
  --dir cov-int \
  list \
| grep \
  --invert-match \
  '^Translation unit:$' \
| sed \
  's!^[[:digit:]]\+ -> !!' \
> 'coverity-scan-analysed-files.log'

#-----------------------------------------------------------------------------
# Submit results to Coverity service

tar \
  --create \
  --gzip \
  --file='results.tgz' \
  'cov-int'

for (( ATTEMPT=1; ATTEMPT<=SUBMISSION_ATTEMPTS; ATTEMPT++ )); do
  CURL_OUTPUT=$(
    curl \
      --verbose \
      --silent \
      --show-error \
      --fail \
      --write-out '\n%{http_code}' \
      --form "project=${COVERITY_PROJECT_NAME}" \
      --form "email=${COVERITY_USER_EMAIL}" \
      --form "token=${COVERITY_TOKEN}" \
      --form 'file=@results.tgz' \
      --form "version=${GIT_COMMIT:0:7}" \
      --form "description=${GIT_BRANCH}" \
      'https://scan.coverity.com/builds'
  )
  HTTP_RESPONSE_CODE=$(echo -n "${CURL_OUTPUT}" | tail -1)
  test x"${HTTP_RESPONSE_CODE}" = x"200" \
    && break

  sleep "${SUBMISSION_REST_INTERVAL:-$SUBMISSION_INITIAL_REST_INTERVAL}"

  SUBMISSION_REST_INTERVAL=$(( ${SUBMISSION_REST_INTERVAL:-$SUBMISSION_INITIAL_REST_INTERVAL} * 2 ))
done

HTTP_RESPONSE=$(echo -n "${CURL_OUTPUT}" | head -n -1 | tr -d '\n')
if [ x"${HTTP_RESPONSE}" != x"Build successfully submitted." ]; then
  echo "Coverity Scan service responded with '${HTTP_RESPONSE}' while 'Build successfully submitted.' expected." >&2
  exit 1
fi

#-----------------------------------------------------------------------------

exit 0
