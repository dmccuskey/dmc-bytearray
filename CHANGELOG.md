# Changelog

## 0.2.0 (2026-10-01)

### Changed

- The byte array is now lua-bytearray 0.5.0's, from DMC-Lua-Library's `lib.dmc_lua.lua_bytearray` (it was 0.4.0). From lua-bytearray 0.5.0:
  - `readBytes()` and `writeBytes()` append to the destination by default, instead of writing over its start, and `readBytes()` reads all the source has left (it read the destination's `bytesAvailable`).
  - `writeByte()` returns the array, so it chains like the other writes.
  - `writeUInt()` and the unsigned longs are fixed (they need lpack, which Solar2D doesn't include).
- Rebuilt with dmc-corona-boot 1.6.0 and the current DMC-Lua-Library.

### Added

- `VERSION`, on lua-bytearray's class (`__version` is lua-bytearray's).
- Unit tests: `tests/run_unit.sh`, plain Lua 5.1.

### Removed

- The copy of `Utils.extend()`, which set the global `_extend`; the module uses DMC-Lua-Library's `lua_utils`.

## 0.1.0

- First release: lua-bytearray packaged for Solar2D.
