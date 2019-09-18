#!/bin/bash
set -x

#3rd party
cmake_build_type=RELEASE
LEVELDB_VER=1.22
THRIFT_VER=0.12.0
JSON_VER=3.5.0
SPDLOG_VER=1.3.1

sudo yum install -y cppcheck bison libcurl-devel; yum clean all
sudo pip install gcovr

#cmake
cd /tmp/
wget https://github.com/Kitware/CMake/releases/download/v3.15.3/cmake-3.15.3-Linux-x86_64.tar.gz
tar xzvf cmake*.tar.gz
sudo rpm -e cmake
sudo ln -s $(pwd)/cmake-3.15.3-Linux-x86_64/bin/cmake /usr/bin/cmake

#leveldb
cd /tmp
curl -o leveldb.zip https://codeload.github.com/google/leveldb/zip/$LEVELDB_VER
unzip leveldb.zip
rm leveldb.zip
mv leveldb-$LEVELDB_VER leveldb
mkdir leveldb/_build
cd leveldb/_build;cmake .. -DCMAKE_BUILD_TYPE=$cmake_build_type -DCMAKE_POSITION_INDEPENDENT_CODE=ON; make -j 10; sudo make install

#json
cd /tmp
curl -o json.zip https://codeload.github.com/nlohmann/json/zip/v$JSON_VER
unzip json.zip
rm json.zip
mv json-$JSON_VER json
cd json;mkdir _build
cd _build/;cmake .. -DCMAKE_BUILD_TYPE=$cmake_build_type -DJSON_BuildTests=OFF;make -j 10;sudo make install

#spdlog
cd /tmp
curl -o spdlog.zip https://codeload.github.com/gabime/spdlog/zip/v$SPDLOG_VER
unzip spdlog.zip
rm spdlog.zip
mv spdlog-$SPDLOG_VER spdlog
cd spdlog;mkdir _build
cd _build/;cmake .. -DCMAKE_BUILD_TYPE=$cmake_build_type -DSPDLOG_BUILD_EXAMPLES=OFF -DSPDLOG_BUILD_BENCH=OFF -DSPDLOG_BUILD_TESTS=OFF; make -j 10; sudo make install

#thrift
cd /tmp
curl -o thrift.zip https://codeload.github.com/apache/thrift/zip/v$THRIFT_VER
unzip thrift.zip
rm thrift.zip
mv thrift-$THRIFT_VER thrift
cd thrift;mkdir _build
cd _build/;cmake .. -DCMAKE_BUILD_TYPE=$cmake_build_type -DBUILD_PYTHON=OFF -DBUILD_JAVA=OFF -DBUILD_C_GLIB=OFF -DWITH_LIBEVENT=OFF -DWITH_ZLIB=OFF -DWITH_OPENSSL=OFF -DBUILD_TESTING=OFF -DCMAKE_POSITION_INDEPENDENT_CODE=ON;make -j 10;sudo make install

#verify/sonar
if [[ "${JOB_NAME}" == "vnfsdk-ves-agent-cmake-sonar" ]]; then
echo "sonar"
mkdir -p ${BUILD_DIR}
cppcheck --enable=all --inconclusive --xml --xml-version=2 --output-file=${BUILD_DIR}/cppcheck.xml .

cd ${BUILD_DIR}
cat >> sonar-project.properties <<EOF
sonar.cfamily.gcov.reportsPath=${BUILD_DIR}/coverage
sonar.cppcheck.reportPath=${BUILD_DIR}/cppcheck.xml
sonar.exclusions=**/gen-cpp/**/*,**/build/**/*
sonar.projectBaseDir=${WORKSPACE}/veslibrary/ves_cpplibrary
sonar.cfamily.threads=4
EOF

ls ${BUILD_DIR}/sonar-project.properties
cat ${BUILD_DIR}/sonar-project.properties

fi
