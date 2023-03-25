# Valheim macOS

## Background

A Steam leak in 2021 seemed to indicate that Iron Gate, developers of Valheim, were exploring macOS
support.

Unfortunately, that seems to be in limbo currently, as pointed out by moderator [Munin]:

> A little update: They [Iron Gate] still want do the Mac version. The question is just when. Currently, they focus on developing the Windows & Linux versions of the game (surprise, surprise - I know), and simply don't have time to work on supporting another OS.
>
> There's already a Valheim Mac Depot (last updated in April 2021), and it runs OK ("Okay") with Unity.

After reading an article on [porting Unity games to different platforms], I started experimenting with
building a custom Valheim build for macOS based on the Linux version: collecting the game data, fetching the
correct dependencies and stitching it all together.

Happy to report that it actually paid off 🥳

https://user-images.githubusercontent.com/378235/227661255-e07504da-6072-4e8c-b383-6d2df6b4e329.mp4

[In the above footage `Bloom` and `SSAO` are turned on for aesthetic effect; turn these off for increased performance]

## Disclaimer

The build has been tested in both single/multiplayer and seems to function adequately without any negative
effects.

That said, there is an inherent risk to using custom game builds. In particular, Valheim interfaces with Steam,
Azure PlayFab cross-play services, and most likely Iron Gate's own services. These services could start treating
this custom build as problematic (or the build itself may behave incorrectly) and put your account, characters
etc. in jeopardy.

> __Warning__
> **Usage of this build script and the resulting macOS build is [at your own risk].**

## Building

### Prerequisites

- A Steam account that owns [Valheim].
- ~15GB free hard disk space.
- An internet connection to download the game data and dependencies.
- [Dotnet CLI]
  - Easiest to install via [Homebrew]: `brew install dotnet@7`.

### Steps

These steps take between 15 to 30 minutes to complete, depending on network speed and computing power.

1. Clone this repository: `git clone https://github.com/timkurvers/valheim-macos`.
2. Navigate to the cloned repository in your terminal of choice.
3. Run `./build.sh` and follow the instructions.

   > __Note__
   > The script requires Steam credentials so that Valheim data can be acquired. As the original
   > macOS Steam client does not have access to Valheim, this is done via [DepotDownloader].

4. Once the build script finishes, verify the presence of `Valheim.app` in the `build` folder.

## Running

1. Start Steam and log into an account that owns Valheim.
2. Launch `Valheim.app`.

> __Note__
> Future Valheim updates will most likely require updates to the build script and you may not be able to
> play with an outdated build.

## Known issues

- Steam overlay is non-functional. For an alternative FPS counter, press `F2` in-game.
- Generating and entering worlds may seem to infinitely hang before a loading screen is shown. Be patient.
- Cloud-saved characters may not show up initially or may not sync at all.

## FAQ

### How well does it perform?

As Apple deprecated OpenGL four years ago (!) performance is not optimal. In addition, running the
game on Apple Silicon hardware requires using the Rosetta 2 translation layer, which incurs an additional
performance penalty.

Some statistics:

- 14" M1 Pro Macbook Pro (2021): 45-60 fps @ 2560x1440 with high draw distance,
all other settings on medium.

- 15" Intel Macbook Pro (2017): 30-40 fps @ 1280x800 with high draw distance,
all other settings on low/off.

Here is to hoping that Iron Gate support macOS natively in the future with Apple Silicon and Metal support.

### Is this legal?

This repository does not distribute any game data, and is provided as a means for players who own
Valheim on Steam to play on their prefered hardware.

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
[Homebrew]: https://brew.sh/
[Munin]: https://steamcommunity.com/app/892970/discussions/2/3192485276070223820/?ctp=68#c3446961485766994098
[Valheim]: https://store.steampowered.com/app/892970/Valheim/
[at your own risk]: LICENSE.md
[official Valheim Twitter account]: https://twitter.com/Valheimgame
[porting Unity games to different platforms]: https://www.pcgamingwiki.com/wiki/Engine:Unity/Porting
