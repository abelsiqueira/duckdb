#!/bin/bash

rm -rf build
cmake -B build \
	-DCMAKE_BUILD_TYPE=Release \
	-DCMAKE_TOOLCHAIN_FILE=mingw-w64-x86_64.cmake \
	-DBUILD_EXTENSIONS='autocomplete;icu;parquet;json;fts;tpcds;tpch' \
	-DENABLE_EXTENSION_AUTOLOADING=1 \
	-DENABLE_EXTENSION_AUTOINSTALL=1 \
	-DBUILD_UNITTESTS=FALSE \
	-DBUILD_SHELL=TRUE \
	-DDUCKDB_EXPLICIT_PLATFORM=x86_64-w64-mingw32-cxx11 .
cmake --build build

[[ $? -ne 0 ]] &&
	{
		echo "build failed, cannot test"
		exit 125
	}

if [[ -f build/src/libduckdb.dll ]]; then
	winedump -j export build/src/libduckdb.dll | grep -q duckdb_vector_size
	if [[ $? -eq 0 ]]; then
		exit 0
	else
		exit 1
	fi
else
	echo "cannot find DLL, cannot test"
	exit 125
fi
