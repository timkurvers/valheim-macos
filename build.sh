#!/bin/bash
# shellcheck disable=SC2002

cd "$(dirname "$0")"

set -e

# Valheim configuration
appid=892970
depotid=892971

# Stable (public)
branch="public"
buildid=12959248
manifestid=7697447462593569757
version="0.217.38"
depotdownloaderversion="2.5.0"
depotdownloaderarch="arm64"
depotdownloaderhash="e46b90b6a838e055c21856931e21f096"
unityversion="2022.3.12f1"
unityhash="4fe6e059c7ef"
variant="macos_x64_player_nondevelopment_mono"
steamworksversion="20.2.0"
steamworkshash="6c8e7f5101176ed13d32cf704a4febe6"
playfabpartyversion="1.7.16"
playfabpartyasset="PlayFabParty-for-macOS.zip"
playfabpartyhash="95cd6814893d57abd63c19fb668d304c"
outdir="build"

# Intel (x86_64) support
if [ "$(arch)" = "i386" ]; then
  depotdownloaderarch="x64"
  depotdownloaderhash="c9862fc3a73960a60130551fa4141b82"
fi

# Beta (public-test)
if [[ " $* " =~ " --beta " ]]; then
  branch="public-test"
  buildid=13711282
  unset manifestid
  version="0.217.43"
  unityversion="2022.3.17f1"
  unityhash="4fc78088f837"
  playfabpartyversion="1.8.0"
  playfabpartyasset="PlayFabPartyMac.framework-for-macOS-Release.zip"
  playfabpartyhash="93c4967e7dc74b281ca7614b96c941a9"
  outdir="build-beta"
fi

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
  if confirm "Download Valheim $version (~1.5GB) from Steam?"; then

    if [ ! -d "depotdownloader-$depotdownloaderversion-$depotdownloaderarch" ]; then
      if confirm "Download (~80MB) and unzip DepotDownloader ($depotdownloaderarch) to download Valheim from Steam?"; then
        curl -L https://github.com/SteamRE/DepotDownloader/releases/download/DepotDownloader_$depotdownloaderversion/depotdownloader-macos-$depotdownloaderarch.zip -o depotdownloader-$depotdownloaderversion-macos-$depotdownloaderarch.zip
        verify depotdownloader-$depotdownloaderversion-macos-$depotdownloaderarch.zip $depotdownloaderhash
        unzip depotdownloader-$depotdownloaderversion-macos-$depotdownloaderarch.zip -d depotdownloader-$depotdownloaderversion-$depotdownloaderarch
      fi

      if [ ! -d "depotdownloader-$depotdownloaderversion-$depotdownloaderarch" ]; then
        echo "DepotDownloader not found, exiting.."
        exit 1
      fi
    fi

    xattr -c depotdownloader-$depotdownloaderversion-$depotdownloaderarch/DepotDownloader
    chmod u+x depotdownloader-$depotdownloaderversion-$depotdownloaderarch/DepotDownloader

    echo -n "Steam username: "
    read -r username
    ./depotdownloader-$depotdownloaderversion-$depotdownloaderarch/DepotDownloader -app $appid -depot $depotid -manifest $manifestid -beta $branch -os linux -username "$username"
  fi

  if [ ! -d "depots/$depotid/$buildid/valheim_Data" ]; then
    echo "Valheim data for build $buildid not found, exiting.."
    echo "(the build script may need to be updated if a patch was recently released)"
    exit 1
  fi
fi

if [ ! -d "Unity-$unityversion" ]; then
  if confirm "Download Unity v$unityversion data files (~3.5GB)?"; then
    curl -L https://download.unity3d.com/download_unity/$unityhash/MacEditorInstaller/Unity.pkg -o Unity-$unityversion.pkg
    echo "(unpacking Unity.pkg, this may take a while...)"
    pkgutil --expand-full Unity-$unityversion.pkg Unity-$unityversion
  fi

  if [ ! -d "Unity-$unityversion" ]; then
    echo "Unity package $unityversion not found, exiting.."
    exit 1
  fi
fi

if [ ! -d "Steamworks.NET-Standalone_$steamworksversion" ]; then
  if confirm "Download Steamworks.NET v$steamworksversion (~2.5MB) from GitHub?"; then
    curl -L https://github.com/rlabrecque/Steamworks.NET/releases/download/$steamworksversion/Steamworks.NET-Standalone_$steamworksversion.zip -o Steamworks.NET-Standalone_$steamworksversion.zip
    verify Steamworks.NET-Standalone_$steamworksversion.zip $steamworkshash
    unzip Steamworks.NET-Standalone_$steamworksversion.zip -d Steamworks.NET-Standalone_$steamworksversion
  fi

  if [ ! -d "Steamworks.NET-Standalone_$steamworksversion" ]; then
    echo "Steamworks.NET not found, exiting.."
    exit 1
  fi
fi

if [ ! -d "PlayFabParty-for-macOS_v$playfabpartyversion" ]; then
  if confirm "Download PlayFabParty v$playfabpartyversion (~100MB) from GitHub?"; then
    curl -L "https://github.com/PlayFab/PlayFabParty/releases/download/v$playfabpartyversion/$playfabpartyasset" -o "PlayFabParty-for-macOS_v$playfabpartyversion.zip"
    verify "PlayFabParty-for-macOS_v$playfabpartyversion.zip" $playfabpartyhash
    unzip "PlayFabParty-for-macOS_v$playfabpartyversion.zip" -d "PlayFabParty-for-macOS_v$playfabpartyversion"
  fi

  if [ ! -d "PlayFabParty-for-macOS_v$playfabpartyversion" ]; then
    echo "PlayFabParty not found, exiting.."
    exit 1
  fi
fi

cd ..

cd plugins

if [ ! -f "DiskSpacePlugin/build/DiskSpacePlugin.dylib" ]; then
  echo "Building DiskSpacePlugin for macOS..."
  cd DiskSpacePlugin
  make build
  cd ..
fi

cd ..

mkdir -p $outdir
rm -rf ${outdir:?}/*
cp -r skeleton/* $outdir/

prefix="$outdir/Valheim.app/Contents"
unityprefix="vendor/Unity-$unityversion/Unity.pkg.tmp/Payload/Unity/Unity.app/Contents/PlaybackEngines/MacStandaloneSupport"

cat skeleton/Valheim.app/Contents/Info.plist \
    | sed "s|\$appid|$appid|g" \
    | sed "s|\$unityhash|$unityhash|g" \
    | sed "s|\$unityversion|$unityversion|g" \
    | sed "s|\$unityyear|${unityversion:0:4}|g" \
    | sed "s|\$version|$version|g" \
    > $prefix/Info.plist

cp $unityprefix/Variations/$variant/UnityPlayer.app/Contents/Frameworks/* $prefix/Frameworks/
cp $unityprefix/Variations/$variant/UnityPlayer.app/Contents/MacOS/UnityPlayer $prefix/MacOS/Valheim
cp -r $unityprefix/Source/Player/MacPlayer/MacPlayerEntryPoint/Resources/MainMenu.nib $prefix/Resources/
cp -r $unityprefix/MonoBleedingEdge $prefix/MonoBleedingEdge

cp -r vendor/depots/$depotid/$buildid/valheim_Data $prefix/Resources/Data

cp -r $prefix/Resources/Data/Resources/* $prefix/Resources/
rm $prefix/Resources/UnityPlayer.png

cp plugins/DiskSpacePlugin/build/DiskSpacePlugin.dylib $prefix/PlugIns/
cp vendor/depots/$depotid/$buildid/valheim_Data/Plugins/Steamworks.NET.txt $prefix/PlugIns/
cp -r vendor/Steamworks.NET-Standalone_$steamworksversion/OSX-Linux-x64/steam_api.bundle $prefix/Plugins/

# Beta (public-test)
if [[ " $* " =~ " --beta " ]]; then
  # Note: this will hopefully become the default for future versions
  cp -r "vendor/PlayFabParty-for-macOS_v$playfabpartyversion/PlayFabPartyMacOS.bundle" $prefix/Plugins/party.bundle
else
  cp -r "vendor/PlayFabParty-for-macOS_v$playfabpartyversion/PlayFabParty-for-macOS/PlayFabPartyMacOS.bundle" $prefix/Plugins/party.bundle
fi

rm -rf $prefix/Resources/Data/Plugins
rm -rf $prefix/Resources/Data/MonoBleedingEdge

echo "Building Valheim $version complete: $outdir/Valheim.app"
