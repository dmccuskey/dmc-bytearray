# dmc-bytearray

A byte buffer for Solar2D (formerly Corona SDK): write bytes at the end, read them back from a position that moves forward, and get an error you can catch when a read asks for more than the buffer holds.

dmc-bytearray is [lua-bytearray](https://github.com/dmccuskey/lua-bytearray) packaged like the other DMC Solar2D libraries. Its API follows ActionScript's `ByteArray`; [dmc-websockets](https://github.com/dmccuskey/dmc-websockets) uses it to collect socket data and read frames out of it:

```lua
local ByteArray = require 'dmc_corona.dmc_bytearray'

local ba = ByteArray:new()
ba:writeBuf( "hello" )
print( ba:readBuf( 2 ), ba.bytesAvailable )  --> he	3
```

## Features

- Append bytes, strings, booleans; read them back in order, or reset the position and read again
- `bytesAvailable` says how much is left to read; reading past the end raises a `BufferError`, so a parser can wait for more data
- Overwrite bytes at an index, copy bytes between arrays, search the buffer
- A hex dump for debugging
- Pure Lua, no plugins needed; MIT licensed

## Quick Start

The following code will get you up and running in about 10 minutes in the Solar2D Simulator on macOS or Windows. It fills a byte array, reads it back, and catches a read past its end.

Prerequisites: the [Solar2D](https://solar2d.com/) Simulator and a copy of this repository (`git clone https://github.com/dmccuskey/dmc-bytearray.git`, or download the ZIP from GitHub).

### 1. Copy the Library into Your Project

Copy these from this repository into the root of your project folder:

```text
dmc_corona_boot.lua     loader for the DMC libraries
dmc_corona.cfg          configuration
dmc_corona/             dmc-bytearray and the modules it needs
```

**Going further:** keep the libraries in a subfolder, or combine several DMC libraries ([dmc-corona-boot Configuration](https://github.com/dmccuskey/dmc-corona-boot/blob/master/docs/configuration.md)).

### 2. Use It

Create `main.lua` in the project folder:

```lua
local ByteArray = require 'dmc_corona.dmc_bytearray'
local BufferError = require( 'lib.dmc_lua.lua_bytearray.exceptions' ).BufferError

local ba = ByteArray:new()
ba:writeBuf( "GET / HTTP/1.1\r\n" )
ba:writeByte( 0 )
ba:writeBoolean( true )
print( ba.length, ba.position, ba.bytesAvailable )

print( ba:search( "\r\n" ) )
print( ba:readBuf( 3 ), ba.position )

ba.position = 17
print( ba:readByte(), ba:readBoolean(), ba.bytesAvailable )

local ok, err = pcall( ba.readBuf, ba, 10 )
print( ok, err:isa( BufferError ), err.message )

display.newText( "bytes: " .. ba.length, display.contentCenterX, display.contentCenterY, native.systemFont, 32 )
```

Open the project in the Simulator. The screen shows `bytes: 18`; the console shows:

```text
18	1	18
15	16
GET	4
0	true	0
false	true	Read surpasses buffer size
```

If the console shows `module 'dmc_corona.dmc_bytearray' not found` instead, `dmc_corona/` is missing from the root of the project folder.

Writing doesn't move the position: it starts at 1 and only reads advance it. The last read asks for 10 bytes when none are left, so it raises a `BufferError` instead of returning a short string; a parser catches it and tries again when more data has arrived. `BufferError` comes from `lib.dmc_lua.lua_bytearray.exceptions`, the name the boot loader gives the module in `dmc_corona/lib/dmc_lua/`.

To update, copy `dmc_corona_boot.lua` and `dmc_corona/` again from the newer version. Keep your own `dmc_corona.cfg` if you have changed it.

## Documentation

`require 'dmc_corona.dmc_bytearray'` returns lua-bytearray's `ByteArray` class, so its documentation applies as written:

- [How It Works](https://github.com/dmccuskey/lua-bytearray#how-it-works): a string and a read position
- [Reference](https://github.com/dmccuskey/lua-bytearray#reference): the properties, the byte and string methods, and `BufferError`
- [In Solar2D](https://github.com/dmccuskey/lua-bytearray#in-solar2d): the typed number methods (`readInt()`, `writeDouble()`, ...) need the lpack C module, which Solar2D doesn't include, so they are missing here (`attempt to call method 'writeUShort'`)
- [Known Issues](https://github.com/dmccuskey/lua-bytearray#known-issues) of the byte array

## Configuration

dmc-bytearray has no settings: `dmc_corona.cfg` needs no section for it, only the `[DMC_CORONA]` section that tells the loader where the libraries are. See [dmc-corona-boot Configuration](https://github.com/dmccuskey/dmc-corona-boot/blob/master/docs/configuration.md).

## Known Issues

The bugs of the byte array itself are in lua-bytearray's [Known Issues](https://github.com/dmccuskey/lua-bytearray#known-issues); the ones most likely to be met in Solar2D: `readBytes()` and `writeBytes()` write from index 1 by default, over what the destination holds, and `readBytes()`'s default length is the destination's `bytesAvailable`. In `dmc_bytearray.lua`:

- It sets the global `_extend` (its copy of `Utils.extend()` declares the inner function without `local`).
- Its version (`0.1.0`) isn't available to code.

## Development

Only `dmc_corona/dmc_bytearray.lua` is written in this repository. It loads the DMC boot loader and returns lua-bytearray's class from `lib.dmc_lua.lua_bytearray`. Everything else is a generated copy; fix it in its own repository, then rebuild:

| file | owner |
|---|---|
| every file in `dmc_corona/lib/dmc_lua/` | [DMC-Lua-Library](https://github.com/dmccuskey/DMC-Lua-Library), which copies them from the `lua-*` repositories ([lua-bytearray](https://github.com/dmccuskey/lua-bytearray), [lua-class](https://github.com/dmccuskey/lua-class), [lua-error](https://github.com/dmccuskey/lua-error), ...) |
| `dmc_corona_boot.lua` | [dmc-corona-boot](https://github.com/dmccuskey/dmc-corona-boot) |

The copies are made by Snakemake from sibling checkouts of the repositories above (`../DMC-Lua-Library`, `../dmc-corona-boot`, `../DMC-Corona-Library` for the shared rules). From this repository's root folder:

```sh
snakemake --cores 1 build_all
```

dmc-bytearray has no tests of its own; lua-bytearray's are in its `spec/`. The Quick Start is the check that the package loads in Solar2D.

## License

dmc-bytearray is released under the [MIT License](LICENSE).
