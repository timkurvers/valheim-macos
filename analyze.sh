#!/usr/bin/env bash

# Usage: ./analyze.sh
#
# Analyzes all builds present in `vendor/depots` listing Unity Engine version and plugin hashes.
# Any unzipped Linux versions in `research/PlayFabParty` and `research/Steamworks.NET` are also analyzed.
#

shopt -s nullglob

for build in ./vendor/depots/892971/*; do
  echo "Valheim Build $(basename "$build")"

  echo "  Unity Engine: $(strings "$build"/valheim_Data/level0 | head -n 1)"
  echo "  Plugins:"

  for plugin in "$build"/valheim_Data/Plugins/*.so; do
    echo "    $(basename "$plugin"): $(md5 -q "$plugin")"
  done

  echo
done

if [ -d ./research/PlayFabParty ]; then
  echo '---'
  echo

  for version in ./research/PlayFabParty/*; do
    basename "$version"

    lib="$version/linux/x64/Release/libparty.so"
    echo "  $(basename "$lib"): $(md5 -q "$lib")"

    echo
  done
fi

if [ -d ./research/Steamworks.NET ]; then
  echo '---'
  echo

  for version in ./research/Steamworks.NET/*; do
    basename "$version"

    lib="$version/OSX-Linux-x64/libsteam_api.so"
    echo "  $(basename "$lib"): $(md5 -q "$lib")"

    echo
  done
fi
