# VPad Tester & Configurator

A simple homebrew for testing the input data on the PS Vita™ made on [Lua Player Plus Vita](https://github.com/Rinnegatamante/lpp-vita)

Extended version of a utility created by Smoke5, converted to Lua by Keinta15

![preview](./img/preview.png)

### Features:

(most of it's not my work, i just added features {in italic} that i was missing)

* highlight currently pressed buttons
* visual feedback & absolute numbers of analogue stick input
* visual feedback of touchscreen/touchpad, including multitouch
* _max range of analogue stick input (useful for adjusting deadzones)_
* stereo audio tester
* _is now a “safe” homebrew, as i saw no reason otherwise_
* _a better colourscheme ([gruvbox dark](https://github.com/gruvbox-community/gruvbox))_
* _better icon and livearea assets_

### Dev Miscellany:

#### Building:

lua player plus' builder is included in .\lpp - read the readme in there, or just run zbuild.bat

* i've modified build.bat to zbuild.bat because i'm lazy
	* use the original if you want to change the name/id
	* you'll have to mess with directories
* [vpk editor](https://qberty.com/ps-vita-vpk-editor/) is quite useful for automatically reducing bit depth
* this is how i visualise stick range

![max range logic](./img/max-logic-pic.png)

---

## Credits to:

- Original VitaTester [SMOKE5](https://github.com/SMOKE5) for [VitaTester](https://github.com/SMOKE5/VitaTester)
- Conversion to Lua [Keinta15](https://github.com/Keinta15/) for [Lua Vita Tester](https://github.com/Keinta15/Lua-Vita-Tester)

## Extra Credits

- [Rinnegatamante](https://github.com/Rinnegatamante) for [lpp-vita](https://github.com/Rinnegatamante/lpp-vita)
- [xerpi](https://github.com/xerpi) for [vita2dlib](https://github.com/xerpi/vita2dlib)
- [tokyoship](https://commons.wikimedia.org/wiki/User:Tokyoship) for the [vita wireframe](https://commons.wikimedia.org/wiki/File:PlayStation_Vita_Layout.svg) [CC BY-SA 3.0](https://creativecommons.org/licenses/by-sa/3.0)
- [remix icons](https://remixicon.com/) for the fingerprint icon, and the cog + spanner on the logo
- [pngquant](https://pngquant.org/) for smaller images
- [Ruben_Wolfe451](https://twitter.com/Ruben_Wolfe451)
