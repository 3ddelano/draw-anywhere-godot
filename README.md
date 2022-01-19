Draw Anywhere (Godot Editor)
=========================================
###### (Get it from Godot Asset Library - Coming soon)


### Draw anywhere in the Godot Editor. Supports multiple pen sizes and colors.

<img alt="Godot3" src="https://img.shields.io/badge/-Godot >= 3.2.2-478CBF?style=for-the-badge&logo=godotengine&logoWidth=20&logoColor=white" />
<br>


<img src="https://cdn.discordapp.com/attachments/360062738615107605/932968729208315955/plugin_icon.png" height="400">


Features
--------------

- Floating, draggable toolbar
- Change pen size and color
- Draw over Popups
- Easy keyboard shortcuts

Automatic Installation
--------------
Simply download and install the plugin from the `AssetLib` in the Godot Editor. Then go to `ProjectSettings` and enable it in the `Plugins` tab. 

Manual Installation
--------------

This is a regular plugin for Godot.
Copy the contents of `addons/draw_anywhere/` into the `res://addons/draw_anywhere/` folder which is in your project directory. Then go to `ProjectSettings` and enable it in the `Plugins` tab. 

**Optional:** To exclude the plugin when exporting your project, you can add `addons/draw_anywhere/*` to the `Filters to exclude files/folders from project` in the Export settings.

<img src="https://cdn.discordapp.com/attachments/360062738615107605/932954254740717578/unknown.png" height="250">

Usage
--------------

<img src="https://cdn.discordapp.com/attachments/360062738615107605/932968493891084318/unknown.png" height="75">

Once the plugin is enabled, a new floating toolbar will appear. This toolbar has:

| Button       | Description              |
| ------------ | ------------------------ |
| Help button  | Shows keyboard shortcuts |
| Clear button | Clears the drawing       |
| Pen button   | Chooses the pen tool     |
| Size slider  | Changes the pen size     |
| Color picker | Changes the pen color    |

When draw mode is active, an indicator will be shown in the bottom-left of the screen.

Keyboard Shortcuts
--------------

### Global shortcuts

| Shortcut                         | Description        |
| -------------------------------- | ------------------ |
| Ctrl + **`** (Ctrl + left quote) | Toggle draw mode   |
| Ctrl + F1                        | Toggle the toolbar |

### Draw mode shortcuts
These shortcuts will only work when draw mode is active

| Shortcut    | Description                |
| ----------- | -------------------------- |
| Left Click  | Draw line                  |
| Right Click | Exit draw mode             |
| C           | Clear all lines            |
| Z           | Clear last line            |
| R           | Reset the toolbar position |


Limitations?
--------------
**The global keyboard shortcut will work anywhere**.

The toolbar will work everywhere except when there is a popup open eg.  in EditorSettings, in ProjectSettings, etc.
(not really a limitation since you can use the global keyboard shortcut to enable Draw mode)

### Support the project development
<a href="https://www.buymeacoffee.com/3ddelano" target="_blank"><img height="41" width="174" src="https://cdn.buymeacoffee.com/buttons/v2/default-red.png" alt="Buy Me A Coffee" width="150" ></a>
<br>
Want to support in other ways? Contact me on Discord: `@3ddelano#6033`

For bugs / suggestions do join: [3ddelano Cafe](https://discord.gg/FZY9TqW)
