# VIN

- author: Jan Zdeněk (<xzdene01@vutbr.cz>)
- date: 06.02.2025
- subject: VIN - Výtvarná informatika

## Description

This is a small demo that showcases both procedural Perlin noise generation and the use of custom shaders. After launching the demo, you will be greeted with some basic parameters for noise generation that you can experiment with at runtime. Custom shaders are a bit more complex, and their usage is explained at the end of this README.

## Running the demo

If you only want to run this app, you can simply download the desired version from itch.io (<https://xzdene01.itch.io/vin-demo>). The entire application was developed and tested on a Windows 11 64-bit machine, but additional binaries are available, so feel free to try those or even build from source by cloning this repository.

## Requirements

- Preferable **Windows 11 64-bit** machine with **Intel** processor - this was used for testing and development
- **Unity Hub/Editor** - needed for building from source or modifying the code
- **Docker** - needed for custom shader compilation (developed tool runs in docker with Unity Editor)

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

Unfortunately Unity does not allow on-the-fly shader compilation, so you will either need to clone this repository and compile shaders alongside the game or you will need to use external tools like the one i created.

Before writing any shaders look inside *Examples* folder in this repo, there are some raw shaders as inspiration or even already pre-compiled shaders that are ready to use.

### Cloning the repo (**requires Unity Editor**)

If you wanna choose this method just follow steps from *Installation* part of this README and than paste your custom shaders into *Assets/Shaders*. Than just drag and drop tha shader onto the *PerlinGenerator* script. You can now try your shader right in the editor.

### Using pre-build shaders (**No requirements**)

Inside the *Examples/CompiledShader* folder are some example shaders you can use rigth away. They are bundeled inside AssetBundles so they can be loaded in runtime (loading is done every 5 seconds so always wait a bit). Importing of compiled shaders:

1. Copy the *Examples/CompiledShaders* into build directory (directory with binary)
2. Rename the folder to *Data*
3. Try out custom shaders!

This whole process can be done during runtime.

### Using external tool (**Requires Docker**)

Detailed instructions on how to compile custom shaders using my tool are on Docker Hub <https://hub.docker.com/r/xzdene01/unity-shader-builder>. Firstly you will need to download the prepared image, secondly you will be able to compile shaders using Unity Editor encapsulated inside docker container. This process is pretty long (especially the first time when the image needs to be downloaded) so i recommend compiling multiple shaders at once.

Compiling and importing custom shaders:

1. Compile all your shaders using the above mentioned tool
2. Create (if not already created) a folder *Data* inside your build directory (directory with binary)
3. Paste all compiled shaders inside *Data* folder
4. Try out your custom shaders in-game!

If you have already compiled shaders you can skip the first instruction.

### Automatic compilation (**Requires Docker**)

The demo itself can compile shaders for you, meaning it will download and spawn a docker container, that will automatically compile all shaders inside pre-defined folder. Step-by-step instructions:

1. Create folder named *Raw* inside your build directory (directory containing the binary)
2. Place your raw shaders inside this folder (**only .shader Unity style shaders supported**)
3. Run the demo (double-click the binary)
4. Console should spawn and image should start downloading (if not downloaded before)
5. Container should start and compile all shaders
6. Console will close itself
7. Try out your new shaders!

### Other way

Sadly I have not found a better way to use custom user-defined shaders in my game. If you have any ideas please let me know and I will gladly implemet them.
