# Valheim macOS

[![Stable version](https://badgen.net/badge/Stable%20version/0.216.9/green)](https://valheim.com/news/patch-0-216-9)
[![Public Test version](https://badgen.net/badge/Public%20Test%20version/0.217.12/orange)](https://store.steampowered.com/news/app/892970/view/6395727041415668306)

## Background

A Steam leak in 2021 seemed to indicate that Iron Gate, developers of Valheim, were exploring macOS
support.

Unfortunately, that seems to be in limbo currently, as pointed out by moderator [Munin]:

> A little update: They [Iron Gate] still want do the Mac version. The question is just when. Currently, they focus
> on developing the Windows & Linux versions of the game (surprise, surprise - I know), and simply don't have time
> to work on supporting another OS.
>
> There's already a Valheim Mac Depot (last updated in April 2021), and it runs OK ("Okay") with Unity.

After reading an article on [porting Unity games to different platforms], I started experimenting with
building a custom Valheim build for macOS based on the Linux version: collecting the game data, fetching the
correct dependencies and stitching it all together.

Happy to report that it actually paid off 🥳

https://user-images.githubusercontent.com/378235/227661255-e07504da-6072-4e8c-b383-6d2df6b4e329.mp4

<sup>The footage above has `Bloom` and `SSAO` enabled for aesthetics; turn these off for increased performance.</sup>

## Performance

The build performs surprisingly well, given that Apple deprecated OpenGL four years ago (!).

In addition, running the game on Apple Silicon hardware requires using the Rosetta 2 translation layer, which may
incur an additional performance penalty.

Some statistics thanks to the kind community members of [r/macgaming]:

| Hardware         | Resolution    | Settings      | FPS      |
| ---------------- | ------------- | ------------- | -------- |
| M1 Max 14"       | 1440p         | Medium        | 50-60fps |
| M1 Max 14"       | 1080p         | Medium / High | 60fps    |
| M1 Pro 16"       | 1440p         | Low           | 60fps+   |
| M1 Pro 16"       | 1080p         | Low           | 100fps   |
| M1 Pro 14"       | 1440p         | Medium        | 45-60fps |
| M1 Air           | 900p          | Medium / High | 35-50fps |
| Intel 15" (2017) | 800p          | Low           | 30-40fps |

Here is to hoping that Iron Gate support macOS natively in the future with Apple Silicon and Metal support. 🍻

## Disclaimer

The build has been tested in both single / multiplayer and seems to function adequately without any negative
effects.

That said, there is an inherent risk to using custom game builds. In particular, Valheim interfaces with Steam,
Azure PlayFab cross-play services, and most likely Iron Gate's own services. These services could start treating
this custom build as problematic (or the build itself may behave incorrectly) and put your account, characters
etc. in jeopardy.

> __Warning__
> **Usage of this build script and the resulting macOS build is [at your own risk]. Official support channels
> will not be able to help you with any issues.**

## Building

### Prerequisites

- A Steam account that owns [Valheim].
- ~15GB free hard disk space. The majority of this space can be reclaimed once the build is complete.
- An internet connection to download the game data and dependencies.
- [Dotnet CLI]
  - Easiest to install via [Homebrew]: `brew install dotnet@7`.
  - Alternatively, install using the [official Dotnet installer].

### Initial build

These steps take between 15 to 30 minutes to complete, depending on network speed and computing power.

1. Clone this repository: `git clone https://github.com/timkurvers/valheim-macos`.

   > __Note__
   > Downloading the repository as a zip-file may cause [the build to be damaged] due to macOS quarantining
   > files that originate from the internet.

2. Navigate to the cloned repository in your terminal of choice.
3. Run `./build.sh` and follow the instructions.

   > __Note__
   > The script will ask for Steam credentials so that Valheim data can be acquired. As the original
   > macOS Steam client does not have access to Valheim, this is done automatically via [DepotDownloader].

   If you would rather use the Public Test build, run `./build.sh --beta` instead. Read the [official Public Test FAQ]
   to learn more.

4. Once the build script finishes, verify the presence of `Valheim.app` in the `build` folder.
5. If you are in dire need of disk space: the contents of the `vendor` folder can be safely deleted at this point.
   Those files are there to make future rebuilds faster, but are not necessary for the app to function once built.

## Running

1. Start Steam and log into an account that owns Valheim.
2. Launch `Valheim.app` from the `build` folder.

## Patching

Future Valheim patches will require updates to the build script and you may not be able to play with an outdated
build. Look at the top of this README to see what version of Valheim is currently supported.

> __Note__
> It may take a day or two before the script is updated to support a recently released patch.

To generate a new build:

1. Fetch the latest build script using `git pull`.
2. Optional: make a backup of the previous build by copying `Valheim.app` elsewhere.
3. Run `./build.sh` once more.

## Known issues

- Steam overlay is non-functional when launched directly from `Valheim.app`.
  - Press `F2` in-game to show Valheim's built-in FPS and network details panel.
  - Alternatively: add `Valheim.app` as a non-Steam game and launch via Steam.

- Generating and entering worlds may seem to infinitely hang before a loading screen is shown. Be patient.

- [Steam Cloud integration may misbehave]: characters or worlds not syncing across devices.

  This could be since Valheim changed cloud save mechanics in version 0.209.8 in the summer of 2022.
  Log into Valheim on a computer which is properly synced and mark all characters and worlds as "Cloud Save"
  if you have not played since prior to version 0.209.8.

  Since the macOS client lacks the custom paths used by the cloud save logics of Valheim prior to 0.209.8 the
  cloud sync will fail silently. Technically, Valheim seems to have used Windows-specific paths and used
  conversion logic on Linux without any support for macOS paths, which has the effect that the macOS client
  cannot resolve the paths and directory structure used by the old saves (as they are saved with the old structure
  in Steam cloud).

  If you suspect sync trouble, check `~/Library/Application Support/Steam/logs/cloud_log.txt` first.

  Notable paths for troubleshooting:

  - Local data: `~/Library/Application Support/unity.IronGate.Valheim-macOS-Custom/`
  - Remote data: `~/Library/Application Support/Steam/userdata/<steam id>/892970/remote/`

  The data you have stored in Steam Cloud for Valheim can be [browsed online] (requires login).

- [Game pads / controllers may not work].

## FAQ

### Why is there no downloadable build?

To avoid distributing copyrighted game data, the build script is provided as a means for players who own Valheim
on Steam to create their own macOS build and play on their preferred hardware.

Additionally, pre-built binaries from untrusted sources could cause havoc if malicious. Having an open-source
build-script available for vetting by anyone limits that risk.

### How to pass launch arguments?

As the game cannot be launched directly from macOS Steam, launch it manually with the desired arguments:

```shell
open build/Valheim.app --args -console
```

### Why is the bundle named `unity.IronGate.Valheim-macOS-Custom` internally?

This is to avoid any collisions with a potential future macOS version by the official development team.

### Where does the Valheim app icon come from?

The icon is the profile image of the [official Valheim Twitter account] and is property of Iron Gate.

## Contributions

Feedback, issues, or pull requests with improvements are more than welcome! 🙏

[DepotDownloader]: https://github.com/SteamRE/DepotDownloader
[Dotnet CLI]: https://learn.microsoft.com/en-us/dotnet/core/tools/
[Game pads / controllers may not work]: https://github.com/timkurvers/valheim-macos/issues/11
[Homebrew]: https://brew.sh/
[Munin]: https://steamcommunity.com/app/892970/discussions/2/3192485276070223820/?ctp=68#c3446961485766994098
[Steam Cloud integration may misbehave]: https://github.com/timkurvers/valheim-macos/issues/10
[Valheim]: https://store.steampowered.com/app/892970/Valheim/
[at your own risk]: LICENSE.md
[browsed online]: https://store.steampowered.com/account/remotestorageapp/?appid=892970
[official Dotnet installer]: https://dotnet.microsoft.com/en-us/download
[official Valheim Twitter account]: https://twitter.com/Valheimgame
[official Public Test FAQ]: https://steamcommunity.com/app/892970/discussions/5/3589961352692584029/
[porting Unity games to different platforms]: https://www.pcgamingwiki.com/wiki/Engine:Unity/Porting
[r/macgaming]: https://www.reddit.com/r/macgaming/comments/1217lko/valheim_macos_build_script/
[the build to be damaged]: https://github.com/timkurvers/valheim-macos/issues/16#issuecomment-1517025125
