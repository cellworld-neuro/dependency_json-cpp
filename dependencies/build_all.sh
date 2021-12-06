#!/bin/bash

function build_dependency(){
    DEPENDENCY_NAME=$1
    echo "Building dependency: $DEPENDENCY_NAME"
    if [[ "$*1" == *"-d"*  ]]
    then
      BUILD_TYPE="Debug"
      FOLDER="cmake-build-debug"
    else
      BUILD_TYPE="Release"
      FOLDER="cmake-build-release"
    fi

    TESTS="-DDISABLE_TESTING=YES"

    if [[ "$*1" == *"-t"*  ]]
    then
      TESTS=""
    fi

    cd "$DEPENDENCY_NAME"

    if [ -f "CMakeLists.txt" ]
    then
      if [ -d "./cmake-build-release" ]
      then
        if [[ "$*1" == *"-c"*  ]]
        then
          rm $FOLDER -r
        fi
      fi
      mkdir $FOLDER -p


      cd $FOLDER
      CXX=g++-10 CC=gcc-10 cmake .. -DCMAKE_BUILD_TYPE=$BUILDTYPE $TESTS

      if [[ "$*1" == *"-i"*  ]]
      then
        make -j install
      else
        make -j
      fi
    else
      echo "No cmake project file (CMakeLists.txt) found at $DEPENDENCY_NAME"
    fi
}

#install_dependency date $@

for f in *; do
    if [ -d "$f" ]; then
        build_dependency $f $@
    fi
done
