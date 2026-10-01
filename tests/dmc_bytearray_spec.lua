--====================================================================--
-- tests/dmc_bytearray_spec.lua
--
-- Unit tests for dmc-bytearray, using Luna Test.
-- Run with tests/run_unit.sh
--
-- lua-bytearray has the full specs; these check the wrapper, and
-- that lua-bytearray's fixes come through it
--====================================================================--


module(..., package.seeall)



--====================================================================--
--== Setup


local ByteArray, LuaByteArray, BufferError

function suite_setup()
	ByteArray = require 'dmc_corona.dmc_bytearray'
	LuaByteArray = require 'lib.dmc_lua.lua_bytearray'
	BufferError = require( 'lib.dmc_lua.lua_bytearray.exceptions' ).BufferError
end



--====================================================================--
--== Tests


-- the shared class, with both versions
function test_module()
	assert_equal( LuaByteArray, ByteArray )
	assert_equal( '0.2.0', ByteArray.VERSION )
	assert_equal( '0.5.0', ByteArray.__version )
	local ba = ByteArray:new()
	assert_true( ba:isa( LuaByteArray ) )
end

function test_no_global_extend()
	assert_nil( rawget( _G, '_extend' ) )
end

-- the Quick Start
function test_quick_start()
	local ba = ByteArray:new()
	ba:writeBuf( "GET / HTTP/1.1\r\n" )
	ba:writeByte( 0 )
	ba:writeBoolean( true )
	assert_equal( 18, ba.length )
	assert_equal( 1, ba.position )
	assert_equal( 18, ba.bytesAvailable )

	local s, e = ba:search( "\r\n" )
	assert_equal( 15, s )
	assert_equal( 16, e )
	assert_equal( 'GET', ba:readBuf( 3 ) )
	assert_equal( 4, ba.position )

	ba.position = 17
	assert_equal( 0, ba:readByte() )
	assert_true( ba:readBoolean() )
	assert_equal( 0, ba.bytesAvailable )
end

-- a read past the end raises a BufferError, and the position stays
function test_read_past_end()
	local ba = ByteArray:new()
	ba:writeBuf( "ab" )
	local ok, err = pcall( ba.readBuf, ba, 10 )
	assert_false( ok )
	assert_true( err:isa( BufferError ) )
	assert_equal( 'Read surpasses buffer size', err.message )
	assert_equal( 1, ba.position )
	assert_equal( 'ab', ba:readBuf( 2 ) )
end

-- lua-bytearray 0.5.0: writeByte() chains
function test_write_byte_chains()
	local ba = ByteArray:new()
	ba:writeByte( 65 ):writeByte( 66 ):writeBuf( "C" )
	assert_equal( 'ABC', ba:toString() )
end

-- lua-bytearray 0.5.0: readBytes() appends to the destination and reads
-- all that's left, instead of writing over its start
function test_read_bytes_appends()
	local src, dst = ByteArray:new(), ByteArray:new()
	src:writeBuf( "hello" )
	dst:writeBuf( "> " )
	src:readBytes( dst )
	assert_equal( '> hello', dst:toString() )
	assert_equal( 0, src.bytesAvailable )
end

-- lua-bytearray 0.5.0: writeBytes() appends to us
function test_write_bytes_appends()
	local src, dst = ByteArray:new(), ByteArray:new()
	src:writeBuf( "world" )
	dst:writeBuf( "hello " )
	dst:writeBytes( src )
	assert_equal( 'hello world', dst:toString() )
end
