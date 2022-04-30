--[[
Removes Error Messages
Sets Error Speech to Mute (0)
Mutes Fizz Sounds Files
]]
UIErrorsFrame:UnregisterEvent("UI_ERROR_MESSAGE");
SetCVar("Sound_EnableErrorSpeech", "0");
MuteSoundFile(569772)
MuteSoundFile(569774)
MuteSoundFile(569775)
MuteSoundFile(569776)