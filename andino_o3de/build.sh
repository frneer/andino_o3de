#!/bin/bash

PROJECT_PATH=$(dirname $(realpath $0))

echo "Registering project at ${PROJECT_PATH}"
/opt/O3DE/${O3DE_VERSION}/scripts/o3de.sh register --project-path ${PROJECT_PATH}

echo "Configuring project at ${PROJECT_PATH}"
cmake -B build/linux -S . -G "Ninja Multi-Config"

echo "Building project at ${PROJECT_PATH}"
cmake --build build/linux --target andino_o3de.GameLauncher Editor --config profile -j 8

echo "Running project at ${PROJECT_PATH}"
/opt/O3DE/${O3DE_VERSION}/bin/Linux/profile/Default/Editor --project-path ${PROJECT_PATH}
