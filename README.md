# Sub-Optimal_MicroJam018
 
This is source code for the game **Sub-Optimal**, by Florian Castel.  It was originally made in two days for [Micro-Jam 018: Water](https://itch.io/jam/micro-jam-018), where it won both 1st place overall as well as "best MiniScript entry."

## Running the Game

You can play the game online, or download a build for Mac, Windows, or Linux at itch.io: https://florian-castel.itch.io/sub-optimal

Or, if you've cloned this repo, you can run it locally by following these steps:

1. [Download Mini Micro](https://miniscript.org/MiniMicro/#download) for your platform
2. Unpack and launch Mini Micro
3. Click on the top disk slot below the screen, use "Mount Folder...", and select your local clone of this repo
4. Type `reboot` at the Mini Micro prompt and press Return.

## Running the Level Editor

After the jam, Joe Strout added a level editor in his [fork](https://github.com/JoeStrout/Sub-Optimal_MicroJam018) (which has since been incorporated into Florian's main fork).  To run it:

1. While the game is running, press **Control-C** to break out to the prompt.
2. Enter `reset` to stop the background music (and clear all variables).
3. Enter `run "levelEditor"` to launch the level editor.  (Don't forget the quotation marks!)

Usage of the level editor should be fairly discoverable.  It includes a feature where you can generate a short (20-30 character) string describing the level.  If you have such a string, you can apply it here in the level editor, and then play it.  This is a good way to share levels with your friends!
