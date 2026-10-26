# HideError

A small World of Warcraft add-on by Ava Hall (ah682) for suppressing error text, error speech and selected fizzle sounds. This is a repair of the legacy add-on, with **TOC `Interface: 100005` (10.0.5)** retained. Add-on version **1.5.1** is separate from that client interface number.

Mode transitions are tested in a Lua harness with explicit WoW API fakes. No live WoW client was tested for this repair; compatibility with current Retail, Classic, combat restrictions and actual sound assets is unverified. Changing the TOC number alone does not establish compatibility.

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

When leaving the full suppression mode, the add-on restores the error-speech CVar and error-event registration captured immediately before entering it. An already-disabled speech preference stays disabled. Sound files are restored with `UnmuteSoundFile`, without playing a sound. A `PLAYER_LOGOUT` handler requests cleanup as well; its real client timing is untested here. Closing the settings window does not change the selected mode.

## Limitations

The retained FileDataIDs are `569772`, `569774`, `569775` and `569776`. This is a fixed legacy selection, not a guarantee that every fizzle/error sound in every client is covered. Other sound settings, such as master volume and all SFX, are left alone.

There are no SavedVariables: mode selection is not persisted. File muting and CVars affect the client globally. Another add-on muting the same files or changing the same event/CVar can conflict; this code cannot discover ownership of pre-existing file mutes. Leaving suppression unmutes these four files and restores the captured preference, including if it was changed elsewhere while suppression was active. Crashes or forced exits can prevent cleanup. Turn the mode off before disabling/reloading the add-on; if speech remains suppressed, use the client's Audio setting to restore your preferred **Error Speech** value.

The repository includes no current-client certification or automated WoW runtime test. For a live check, record the exact client/build, test off → full → fizzle → off with speech initially both enabled and disabled, verify error text/audio and checkbox states, and test reload/logout cleanup with other add-ons disabled first.

## Run the regression harness

From the repository root, with Lua 5.1–5.4 or LuaJIT installed:

```bash
bash ./scripts/test.sh
# Select an interpreter explicitly:
LUA=lua5.1 bash ./scripts/test.sh
```

The runner also accepts the `rpmlua` embedded runtime as a fallback. Local verification used **Lua 5.3 via rpmlua**: 12 tests passed. The GitHub Actions workflow is configured to run Lua 5.1 and 5.4; hosted results are separate evidence.

The harness loads the real add-on and invokes its registered click, slash-command and event callbacks in a fresh environment per test. It checks both directions of mode switching, restoration of original preferences/event registration, repeat selection, file unmuting without playback, logout cleanup, `/about`, window toggling and the add-on-loaded message. Its simulated frames, CVars and file-mute state establish the requested API effects only; they cannot establish actual game audio, UI rendering or client API availability.

The use of `UnmuteSoundFile` follows the independent [MuteSoundFile add-on's removal implementation](https://github.com/funkydude/MuteSoundFile/blob/master/Options/Options.lua#L164-L198); Blizzard's [audio UI source mirror](https://github.com/Gethe/wow-ui-source/blob/live/Interface/AddOns/Blizzard_SettingsDefinitions_Shared/Audio.lua#L454-L463) treats `Sound_EnableErrorSpeech` as a user preference. These references informed the repair; no third-party code or dependencies are bundled.

For a separate fizzle-only project, see [RemoveFizzle](https://github.com/ah682/RemoveFizzle).
