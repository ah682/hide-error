HideError by Ava Hall (ah682)
Add-on version: 1.5.1
Interface target: 100005 (World of Warcraft 10.0.5)

Copy the HideError folder into your game's Interface/AddOns directory.
/hideerror opens or closes settings; /about prints help.

Choose full suppression (error text, speech and four selected fizzle files)
or fizzle-only. Clear the selected checkbox to restore the prior speech
setting and error-event registration, then unmute the selected files.
Closing the window leaves the mode active. Turn it off before disabling
or reloading the add-on.

The mode is not saved between sessions. Sound settings are shared with
other add-ons, and an interrupted shutdown can prevent cleanup.

Mode changes are tested in Lua with simulated WoW APIs. Current Retail
and Classic clients, sound playback and reload/logout cleanup still need
a live client check.

Full installation and testing details:
https://github.com/ah682/hide-error
