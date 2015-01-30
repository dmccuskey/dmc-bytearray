# dmc-bytearray

try:
	if not gSTARTED: print( gSTARTED )
except:
	MODULE = "dmc-bytearray"
	include: "../DMC-Corona-Library/snakemake/Snakefile"

module_config = {
	"name": "dmc-bytearray",
	"module": {
		"dir": "dmc_corona",
		"files": [
			"dmc_bytearray.lua"
		],
		"requires": [
			"dmc-corona-boot",
			"DMC-Lua-Library"
		]
	},
	"tests": {
		"files": [],
		"requires": []
	}
}

register( "dmc-bytearray", module_config )

