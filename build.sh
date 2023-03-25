#!/bin/bash
cd "$(dirname "$0")"

set -e

# Valheim configuration
appid=892970
depotid=892971
buildid=10699914
version="0.214.2"

# Unity configuration
unityversion="2020.3.33f1"
unityhash="915a7af8b0d5"
variant="macos_x64_nondevelopment_mono"

confirm() {
  read -r -p "${1:-Are you sure?} [y/N] " response
  case "$response" in
    [yY][eE][sS]|[yY])
      true
      ;;
    *)
      false
      ;;
  esac
}

verify() {
  local hash
  hash=$(md5 -q "$1")
  if [ "$hash" != "$2" ]; then
    echo "The file '$1' may be corrupted: md5 hash $hash != $2 (expected)"
    if ! confirm "Do you still want to continue? (not recommended)"; then
      exit 1
    fi
  fi
}

cd vendor

if [ ! -d "depots/$depotid/$buildid" ]; then
  if confirm "Download Valheim v$version (~1.5GB) from Steam?"; then

    if [ ! -d "depotdownloader-2.4.7" ]; then
      if confirm "Download (~2MB) and unzip DepotDownloader to download Valheim from Steam?"; then
        curl -L https://github.com/SteamRE/DepotDownloader/releases/download/DepotDownloader_2.4.7/depotdownloader-2.4.7.zip -o depotdownloader-2.4.7.zip
        verify depotdownloader-2.4.7.zip acee4d813db4e6908b75d348767cf01e
        unzip depotdownloader-2.4.7.zip -d depotdownloader-2.4.7
      fi

      if [ ! -d "depotdownloader-2.4.7" ]; then
        echo "DepotDownloader not found, exiting.."
        exit 1
      fi
    fi

    echo -n "Steam username: "
    read -r username
    dotnet depotdownloader-2.4.7/DepotDownloader.dll -app $appid -os linux -username "$username"
  fi

  if [ ! -d "depots/$depotid" ]; then
    echo "Valheim data not found, exiting.."
    exit 1
  fi
fi

if [ ! -d "Unity-$unityversion" ]; then
  if confirm "Download Unity v$unityversion data files (~3.5GB)?"; then
    curl -L https://download.unity3d.com/download_unity/$unityhash/MacEditorInstaller/Unity.pkg -o Unity-$unityversion.pkg
    pkgutil --expand-full Unity-$unityversion.pkg Unity-$unityversion
  fi

  if [ ! -d "Unity-$unityversion" ]; then
    echo "Unity package $unityversion not found, exiting.."
    exit 1
  fi
fi

if [ ! -d "Steamworks.NET-Standalone_14.0.0" ]; then
  if confirm "Download Steamworks.NET (~2.5MB) from GitHub?"; then
    curl -L https://github.com/rlabrecque/Steamworks.NET/releases/download/14.0.0/Steamworks.NET-Standalone_14.0.0.zip -o Steamworks.NET-Standalone_14.0.0.zip
    verify Steamworks.NET-Standalone_14.0.0.zip 889417c79b52e7a33e67807aac21337c
    unzip Steamworks.NET-Standalone_14.0.0.zip -d Steamworks.NET-Standalone_14.0.0
  fi

  if [ ! -d "Steamworks.NET-Standalone_14.0.0" ]; then
    echo "Steamworks.NET not found, exiting.."
    exit 1
  fi
fi

if [ ! -d "PlayFabParty-for-macOS_v1.7.16" ]; then
  if confirm "Download PlayFabParty (~100MB) from GitHub?"; then
    curl -L https://github.com/PlayFab/PlayFabParty/releases/download/v1.7.16/PlayFabParty-for-macOS.zip -o PlayFabParty-for-macOS_v1.7.16.zip
    verify PlayFabParty-for-macOS_v1.7.16.zip 95cd6814893d57abd63c19fb668d304c
    unzip PlayFabParty-for-macOS_v1.7.16.zip -d PlayFabParty-for-macOS_v1.7.16
  fi

  if [ ! -d "PlayFabParty-for-macOS_v1.7.16" ]; then
    echo "PlayFabParty not found, exiting.."
    exit 1
  fi
fi

cd ..

rm -rf build/*
cp -r skeleton/* build/

prefix="build/Valheim.app/Contents"
unityprefix="vendor/Unity-$unityversion/Unity.pkg.tmp/Payload/Unity/Unity.app/Contents/PlaybackEngines/MacStandaloneSupport"

cat skeleton/Valheim.app/Contents/Info.plist \
	| sed "s|\$appid|$appid|g" \
	| sed "s|\$unityhash|$unityhash|g" \
	| sed "s|\$unityversion|$unityversion|g" \
	| sed "s|\$version|$version|g" \
	> $prefix/Info.plist

cp $unityprefix/Variations/$variant/UnityPlayer.app/Contents/Frameworks/* $prefix/Frameworks/
cp $unityprefix/Variations/$variant/UnityPlayer.app/Contents/MacOS/UnityPlayer $prefix/MacOS/Valheim
cp -r $unityprefix/Source/Player/MacPlayer/MacPlayerEntryPoint/Resources/MainMenu.nib $prefix/Resources/
cp -r $unityprefix/MonoBleedingEdge $prefix/MonoBleedingEdge

cp -r vendor/depots/$depotid/$buildid/valheim_Data $prefix/Resources/Data

cp -r $prefix/Resources/Data/Resources/* $prefix/Resources/
rm $prefix/Resources/UnityPlayer.png

cp vendor/depots/$depotid/$buildid/valheim_Data/Plugins/Steamworks.NET.txt $prefix/PlugIns/
cp -r vendor/Steamworks.NET-Standalone_14.0.0/OSX-Linux-x64/steam_api.bundle $prefix/Plugins/

cp -r vendor/PlayFabParty-for-macOS_v1.7.16/PlayFabParty-for-macOS/PlayFabPartyMacOS.bundle $prefix/Plugins/party.bundle

rm -rf $prefix/Resources/Data/Plugins
rm -rf $prefix/Resources/Data/MonoBleedingEdge
