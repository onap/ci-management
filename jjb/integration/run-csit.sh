#!/bin/bash -x
#
# Copyright 2016-2017 Huawei Technologies Co., Ltd.
# Modification Copyright 2019 Samsung Electronics Co., Ltd.
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
#
# $1 project/functionality {TESTPLAN}
# $2 robot options         {TESTOPTIONS}

echo "---> run-csit.sh"

WORKDIR=$(mktemp -d --suffix=-robot-workdir)

# Exit if no arguments are provided and required variables not set
if [[ $# -eq 0 ]] && [[ -z "${TESTPLAN}" ]] && [[ -z "${TESTOPTIONS}" ]]; then
    echo
    echo "Usage: $0 plans/<project>/<functionality> [<robot-options>]"
    echo
    echo " <project>, <functionality>, <robot-options>:  "
    echo "  The same values as for the JJB job template:"
    echo '  {project}-csit-{functionality}'
    echo
    exit 1

elif [[ $# -ne 2 ]] && [[ -z "${TESTPLAN}" ]] && [[ -z "${TESTOPTIONS}" ]]; then
    echo
    echo "Script called without arguments, but the following variables"
    echo " must be set: {TESTPLAN} {TESTOPTIONS}"
    echo
    exit 1

elif [[ $# -eq 2 ]]; then
    export TESTPLAN=$1; export TESTOPTIONS=$2
fi

# Python version should match that used to setup
#  robot-framework in other jobs/stages
# Use pyenv for selecting the python version
if [[ -d "/opt/pyenv" ]]; then
    echo "Setup pyenv:"
    export PYENV_ROOT="/opt/pyenv"
    export PATH="$PYENV_ROOT/bin:$PATH"
    pyenv versions
    if command -v pyenv 1>/dev/null 2>&1; then
        eval "$(pyenv init - --no-rehash)"
        # Choose the latest numeric Python version from installed list
        version=$(pyenv versions --bare \
            | sed '/^[^0-9]/d' | sort -V | tail -n 1)
        pyenv local "${version}"
    fi
fi

#
# functions
#

# load the saved set options
function load_set {
    _setopts="$-"

    # bash shellopts
    for i in $(echo "$SHELLOPTS" | tr ':' ' ') ; do
        set +o "${i}"
    done
    for i in $(echo "$RUN_CSIT_SHELLOPTS" | tr ':' ' ') ; do
        set -o "${i}"
    done

    # other options
    for i in $(echo "$_setopts" | sed 's/./& /g') ; do
        set +"${i}"
    done
    set -"${RUN_CSIT_SAVE_SET}"
}

# set options for quick bailout when error
function harden_set {
    set -xeo pipefail
    set +u # enabled it would probably fail too many often
}

# relax set options so the sourced file will not fail
# the responsibility is shifted to the sourced file...
function relax_set {
    set +e
    set +o pipefail
}

# save current set options
function save_set {
    RUN_CSIT_SAVE_SET="$-"
    RUN_CSIT_SHELLOPTS="$SHELLOPTS"
}

# wrapper for sourcing a file
function source_safely {
    if [[ -z "$1" ]] && return 1; then
        relax_set
        # shellcheck disable=SC1090
        source "$1"
        load_set
    fi
}

function on_exit {
    rc=$?
    if [[ ${WORKSPACE} ]]; then
        if [[ ${WORKDIR} ]]; then
            rsync -av "$WORKDIR/" "$WORKSPACE/archives/$TESTPLAN"
        fi
        # Record list of active docker containers
        docker ps --format "{{.Image}}" > "$WORKSPACE/archives/$TESTPLAN/_docker-images.log"

        # show memory consumption after all docker instances initialized
        docker_stats | tee "$WORKSPACE/archives/$TESTPLAN/_sysinfo-2-after-robot.txt"
    fi
    # Run teardown script plan if it exists
    cd "${TESTPLANDIR}"
    TEARDOWN="${TESTPLANDIR}/teardown.sh"
    if [[ -f "${TEARDOWN}" ]]; then
        echo "Running teardown script ${TEARDOWN}"
        source_safely "${TEARDOWN}"
    fi
    exit $rc
}
# ensure that teardown and other finalizing steps are always executed
trap on_exit EXIT

function docker_stats {
    #General memory details
    echo "> top -bn1 | head -3"
    top -bn1 | head -3
    echo

    echo "> free -h"
    free -h
    echo

    #Memory details per Docker
    echo "> docker ps"
    docker ps
    echo

    echo "> docker stats --no-stream"
    docker stats --no-stream
    echo
}

#
# main
#

# set and save options for quick failure
harden_set && save_set

if [[ -z "${WORKSPACE}" ]]; then
    if (git rev-parse --show-toplevel > /dev/null 2>&1); then
        WORKSPACE=$(git rev-parse --show-toplevel)
        export WORKSPACE
    else
        WORKSPACE=$(pwd)
        export WORKSPACE
    fi
fi

if [[ ! -f "${WORKSPACE}/${TESTPLAN}/testplan.txt" ]]; then
    echo "testplan not found: ${WORKSPACE}/${TESTPLAN}/testplan.txt"
    exit 2
fi

rm -rf "$WORKSPACE/archives/$TESTPLAN"
mkdir -p "$WORKSPACE/archives/$TESTPLAN"

TESTPLANDIR="${WORKSPACE}/${TESTPLAN}"

# Run installation of required libraries
source_safely "${WORKSPACE}/prepare-csit.sh"

# Activate the virtualenv containing all the required libraries installed by prepare-csit.sh
source_safely "${ROBOT3_VENV}/bin/activate"

cd "${WORKDIR}"

# Add csit scripts to PATH
export PATH="${PATH}:${WORKSPACE}/docker/scripts:${WORKSPACE}/scripts:${ROBOT3_VENV}/bin"
export SCRIPTS="${WORKSPACE}/scripts"
export ROBOT_VARIABLES=

# Sign in to nexus3 docker repo
docker login -u docker -p docker nexus3.onap.org:10001

# Run setup script plan if it exists
cd "${TESTPLANDIR}"
SETUP="${TESTPLANDIR}/setup.sh"
if [ -f "${SETUP}" ]; then
    echo "Running setup script ${SETUP}"
    source_safely "${SETUP}"
fi

# show memory consumption after all docker instances initialized
docker_stats | tee "$WORKSPACE/archives/$TESTPLAN/_sysinfo-1-after-setup.txt"

# Run test plan
cd "$WORKDIR"
echo "Reading the testplan:"
grep -E -v '(^[[:space:]]*#|^[[:space:]]*$)' "${TESTPLANDIR}/testplan.txt" |\
    sed "s|^|${WORKSPACE}/tests/|" > testplan.txt
cat testplan.txt
SUITES=$( xargs -a testplan.txt )

echo ROBOT_VARIABLES="${ROBOT_VARIABLES}"
echo "Starting Robot test suites ${SUITES} ..."
relax_set

echo "Versioning information:"
python3 --version
pip freeze
python3 -m robot.run --version || :

python -m robot.run -N "${TESTPLAN}" -v WORKSPACE:/tmp "${ROBOT_VARIABLES}" "${TESTOPTIONS}" "${SUITES}"
RESULT=$?
load_set
echo "RESULT: $RESULT"
# Note that the final steps are done in on_exit function after this exit!
exit $RESULT
