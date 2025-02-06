# VIN

- author: Jan Zdeněk (<xzdene01@vutbr.cz>)
- date: 06.02.2025
- subject: VIN - Výtvarná informatika

## Description

This is a small demo that showcases both procedural Perlin noise generation and the use of custom shaders. After launching the demo, you will be greeted with some basic parameters for noise generation that you can experiment with at runtime. Custom shaders are a bit more complex, and their usage is explained at the end of this README.

## Running the demo

If you only want to run this app, you can simply download the desired version from itch.io (<https://xzdene01.itch.io/vin-demo>). The entire application was developed and tested on a Windows 11 64-bit machine, but additional binaries are available, so feel free to try those or even build from source by cloning this repository.

## Installation

If you want to integrate this game into the Unity Editor, simply clone this repository and import it using the Unity Hub interface. The original version of the Unity Editor is **6000.0.36f1**. Detailed instructions are as follows:

1. Clone this repo `git clone https://github.com/xzdene01/VIN.git`
2. Open **Unity Hub** (if you haven't installed it yet, download it from <https://unity.com/download>)
3. *Add* $\rightarrow$ *Add project from disk* $\rightarrow$ navigate to the cloned repository
4. Now you will most likely be prompted to install Unity Editor, please do so
5. Now you should be all set!

## Instructions/manual

This demo is straightforward to control, so no external manual is required. The key bindings are as follows:

- **W/S/A/D** - movement
- **E/Q** - ascent/descent
- **SHIFT** - movement speed
- **TAB** - hide GUI

## Shaders

Unfortunately Unity does not allow on-the-fly shader compilation, so you will either need to clone this repository and compile shaders alongside the game or you will need to use external tools like the one i created. Before creating any shaders it is recommended to look at the shader in *Examples* folder in the root of this GitHub repository.

### Cloning the repo (**recommended** but must be used within Unity Editor)

If you wanna choose this method just follow steps from *Installation* part of this README and than paste your custom shaders into *Assets/Shaders*. Than just drag and drop tha shader onto the *PerlinGenerator* script. You can now try your shader right in the editor.

### Using external tool (can be used despite not having Unity Editor)

Detailed instructions on how to compile custom shaders using my tool are on Docker Hub <https://hub.docker.com/r/xzdene01/unity-shader-builder>. Firstly you will need to download the prepared image, secondly you will be able to compile shaders using Unity Editor encapsulated inside docker container. This process is pretty long (especially the first time when the image needs to be downloaded) so i recommend compiling multiple shaders at once.

After compiling shaders and getting the *shaders* file (AssetsBundle file), you just create a new folder in the root of build directory (where the binary is). It is important to name this folder *Data*. Everything in this folder will be loaded during runtime and therefore can be used both in editor and when running the actual build.

### Using own shaders

If you wanna use you own AssetBundled shaders you absolutely can! You put them into the previously mentioned *Data* folder and they will be available from the in-game interface.

**Do not forget to restart the game after putting in new compiled shaders**

### Other way

Sadly I have not found a better way to use custom user-defined shaders in my game. If you have any ideas feel free to contact me.
