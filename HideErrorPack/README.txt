HideError by Ava Hall (ah682)
Add-on version: 1.5.1
Legacy TOC Interface: 100005 (10.0.5)

Copy the HideError folder into your game's Interface/AddOns directory.
/hideerror opens/closes settings; /about prints help.

Choose full suppression (error text, speech and four selected fizzle files)
or fizzle-only. Clear the selected checkbox to restore the prior speech
preference/event registration and unmute the selected files. Closing the
window does not disable the mode. Turn suppression off before disabling
or reloading the add-on.

Mode changes are regression-tested using Lua with explicit WoW API fakes.
No live client was tested for this repair; current Retail/Classic support,
audio assets, UI rendering and logout/reload behavior remain unverified.
No SavedVariables are used. Client-global sound settings can conflict with
other add-ons, and interrupted shutdown can prevent cleanup.

See the repository README for installation, limitations and test commands:
https://github.com/ah682/hide-error
