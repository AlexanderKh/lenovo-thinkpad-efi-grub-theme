#! /usr/bin/env bash

all_params=(
"1 l"
"1.5 l"
"2 l"
"1 d"
"1.5 d"
"2 d"
)

for params in "${all_params[@]}"
do
  ./build.sh $params
  echo "built $params"
done

# Remove all build folders, leave only .zip files
cd build
rm -R -- */