#!/usr/bin/env bash
set -euo pipefail
cd -- "$(dirname -- "${BASH_SOURCE[0]}")/.."
if [[ -n "${LUA:-}" ]]; then
    exec "$LUA" tests/test_hideerror.lua
fi
for runtime in lua lua5.1 lua5.2 lua5.3 lua5.4 luajit; do
    if command -v "$runtime" >/dev/null; then
        exec "$runtime" tests/test_hideerror.lua
    fi
done
if command -v rpmlua >/dev/null; then
    exec rpmlua -e 'dofile("tests/test_hideerror.lua")'
fi
echo 'Install Lua 5.1–5.4/LuaJIT or set LUA to a Lua interpreter.' >&2
exit 1
