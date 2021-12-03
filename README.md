![yacy thing cropped_panda](https://user-images.githubusercontent.com/13946497/144519134-77e72422-98ac-4d7c-8b5a-5801483213e9.png)

YACY is a recreation of the LevelCrafter editor that allowed an easy way to make 3D levels and share them with friends easily. Originally created by Kevin Manley of Ingenion LLC back in 2007, it unfortunately has become obsolete due to the discontinuation of Adobe Shockwave Player. This project aims to provide a modern experience without any third party plug-ins.

This recreation has a built-in level browser to view and play the many levels that have been archived over time. You are currently able to finish levels and submit your highscores to compete with other players around the world.

## Download
You can find the latest version of YACY in either [GitHub Releases](https://github.com/Ruixel/YACY/releases) or [Itch.io](https://bagster.itch.io/yacy).

## Building
YACY uses the [Godot Engine v3.3](https://godotengine.org/) as its core. You can open this project up in the editor by selecting ``project.godot`` from the main folder. For performance critical areas, the project uses C++ source code that is implemented via GDNative. 

Make sure you have [SConstruct](https://scons.org/) installed as it is required for the build system.

To compile you will first need to clone this project recursively and then generate the C++ bindings for Godot. Replace ``<platform>`` with the target OS (windows/linux/osx) you wish to compile for.
```
cd godot-cpp
scons platform=<platform> generate_bindings=yes -j4
```

Afterwards, head back to the main folder and compile the source code. Add ``target=release`` for an optimised build.
```
scons platform=<platform>
```

The build system should automatically place the .dll file inside the ``bin/`` folder so Godot can detect and use it. For more information, check out the [official documentation](https://docs.godotengine.org/en/stable/tutorials/plugins/gdnative/gdnative-cpp-example.html) for GDNative compilation.

## Contributing
If you're interesting in helping grow this project, just write a feature request on this repository. However, with the project being in its early stages, things may change very quickly.
  
## License
This project uses the [GPLv3 License](https://github.com/Ruixel/YACY/blob/master/LICENSE).
