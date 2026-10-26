# HideError

A small World of Warcraft add-on by Ava Hall (ah682) that hides red error text, mutes error speech and silences selected fizzle sounds. You can mute all three or just the fizzle sounds, then turn the mode off to restore your previous settings.

Version **1.5.1** retains the original **10.0.5 interface target (`100005`)**. See [compatibility and testing](#compatibility-and-testing) for client checks.

## Install and use

Copy the inner `HideErrorPack/HideError` folder into your game's add-on directory. For the original Retail layout, the result is:

```text
World of Warcraft/_retail_/Interface/AddOns/HideError/HideError.toc
World of Warcraft/_retail_/Interface/AddOns/HideError/HideError.lua
```

Enable HideError in the character-selection AddOns list. On a compatible client:

- `/hideerror` opens or closes the settings window.
- `/about` prints help without changing the window. This generic command can conflict with other add-ons.
- **Mute error text, speech and fizzle** suppresses `UI_ERROR_MESSAGE`, sets `Sound_EnableErrorSpeech` to `0` temporarily, and mutes four selected fizzle files.
- **Mute only fizzle sounds** mutes those files while leaving other error text and the error-speech preference at their prior values.
- Clear the selected checkbox to return to off. Selecting one mode clears the other checkbox.

Leaving full suppression restores the error-speech setting and error-event registration captured when you entered it. An already-disabled speech preference stays disabled. Sound files are unmuted without playing them, and `PLAYER_LOGOUT` also requests cleanup. Closing the settings window leaves the selected mode active.

## Sound settings

The add-on mutes four legacy FileDataIDs: `569772`, `569774`, `569775` and `569776`. Other fizzle/error sounds may still play. Master volume and other SFX settings are left alone.

There are no SavedVariables: mode selection is not persisted. File muting and CVars affect the client globally. Another add-on muting the same files or changing the same event/CVar can conflict; this code cannot discover ownership of pre-existing file mutes. Leaving suppression unmutes these four files and restores the captured preference, including if it was changed elsewhere while suppression was active. Crashes or forced exits can prevent cleanup. Turn the mode off before disabling/reloading the add-on; if speech remains suppressed, use the client's Audio setting to restore your preferred **Error Speech** value.

## Compatibility and testing

Tests run in Lua with simulated WoW APIs. Current Retail and Classic clients have not been tested. A live client check is still needed for API availability, combat restrictions, audio, rendering and reload/logout timing. For that check, record the client/build and test off → full → fizzle → off with error speech initially enabled and disabled. Check reload/logout cleanup with other add-ons disabled first.

From the repository root, with Lua 5.1–5.4 or LuaJIT installed:

```bash
bash ./scripts/test.sh
# Select an interpreter explicitly:
LUA=lua5.1 bash ./scripts/test.sh
```

The runner also accepts `rpmlua` as a fallback. The recorded local run passed all 12 tests with **Lua 5.3 via rpmlua**. GitHub Actions runs the harness with Lua 5.1 and 5.4.

The harness loads the add-on in a fresh environment for each test and invokes its click, slash-command and event callbacks. It checks both directions of mode switching, restoration of preferences and event registration, repeat selection, unmuting without playback, logout cleanup, `/about`, window toggling and the load message.

The [MuteSoundFile add-on](https://github.com/funkydude/MuteSoundFile/blob/master/Options/Options.lua#L164-L198) provided a reference for `UnmuteSoundFile`, and Blizzard's [audio UI source mirror](https://github.com/Gethe/wow-ui-source/blob/live/Interface/AddOns/Blizzard_SettingsDefinitions_Shared/Audio.lua#L454-L463) documents `Sound_EnableErrorSpeech` as a user preference.

For a separate fizzle-only project, see [RemoveFizzle](https://github.com/ah682/RemoveFizzle).
