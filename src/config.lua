local Doorways = {
	D_00 = {
		key = 'D_00',
		id = '0',
		name = 'Main Entrance',
		x = 59,
		y = 1,
		w = 4,
		h = 1,
	},
	D_01 = {
		key = 'D_01',
		id = '1',
		name = 'ME Controller',
		x = 58,
		y = 3,
		w = 1,
		h = 3,
	},
	D_02 = {
		key = 'D_02',
		id = '2',
		name = 'ME Server Room',
		x = 75,
		y = 8,
		w = 3,
		h = 1,
	},
	D_03 = {
		key = 'D_03',
		id = '3',
		name = 'Sefety Door',
		x = 80,
		y = 9,
		w = 1,
		h = 2,
	},
	D_04 = {
		key = 'D_04',
		id = '4',
		name = 'ME Patterns',
		x = 85,
		y = 11,
		w = 3,
		h = 1,
	},
	D_05 = {
		key = 'D_05',
		id = '5',
		name = 'Drawer Hole',
		x = 85,
		y = 8,
		w = 3,
		h = 1,
	},
	D_06 = {
		key = 'D_06',
		id = '6',
		name = 'GTMO',
		x = 89,
		y = 9,
		w = 1,
		h = 2,
	},
}
DOOR_INPUT_SIDE = 'bottom'
local RedstoneInput = {
	D_00 = {
		side = DOOR_INPUT_SIDE,
		mode = 'input',
		bundled = colors.red,
	},
	D_01 = {
		side = DOOR_INPUT_SIDE,
		mode = 'input',
		bundled = colors.pink,
	},
	D_02 = {
		side = DOOR_INPUT_SIDE,
		mode = 'input',
		bundled = colors.green,
	},
	D_03 = {
		side = DOOR_INPUT_SIDE,
		mode = 'input',
		bundled = colors.lime,
	},
	D_04 = {
		side = DOOR_INPUT_SIDE,
		mode = 'input',
		bundled = colors.blue,
	},
	D_05 = {
		side = DOOR_INPUT_SIDE,
		mode = 'input',
		bundled = colors.purple,
	},
	D_06 = {
		side = DOOR_INPUT_SIDE,
		mode = 'input',
		bundled = colors.orange,
	},
}

local DOOR_OUTPUT_SIDE = 'right'
local RedstoneOutput = {
	OUT_D_00 = {
		side = DOOR_OUTPUT_SIDE,
		mode = 'output',
		bundled = colors.red,
	},
	OUT_D_01 = {
		side = DOOR_OUTPUT_SIDE,
		mode = 'output',
		bundled = colors.pink,
	},
	OUT_D_02 = {
		side = DOOR_OUTPUT_SIDE,
		mode = 'output',
		bundled = colors.green,
	},
	OUT_D_03 = {
		side = DOOR_OUTPUT_SIDE,
		mode = 'output',
		bundled = colors.lime,
	},
	OUT_D_04 = {
		side = DOOR_OUTPUT_SIDE,
		mode = 'output',
		bundled = colors.blue,
	},
	OUT_D_05 = {
		side = DOOR_OUTPUT_SIDE,
		mode = 'output',
		bundled = colors.purple,
	},
	OUT_D_06 = {
		side = DOOR_OUTPUT_SIDE,
		mode = 'output',
		bundled = colors.orange,
	},

}
local Zones = {
	{
		name = 'Democratic Solutions',
		min = { x = -82, z = -38 },
		max = { x = -28, z = -83 }
	},
	{
		name = 'Valvaroz Srl',
		min = { x = -113, z = 55 },
		max = { x = -87, z = 121 }
	},
	{
		name = 'GregTech Factory',
		min = { x = -301, z = 47 },
		max = { x = -130, z = 131 },
    joke = 'The grind is unreal....'
	},
	{
		name = 'Spawn',
		min = { x = -345, z = -333 },
		max = { x = -265, z = -193 }
	},
	{
		name = 'Magic',
		min = { x = -152, z = -578 },
		max = { x = -356, z = -728 }
	},
	{
		name = 'Fabrica de Ciocolata',
		min = { x = -377, z = -181 },
		max = { x = -311, z = -127 },
    joke = 'Straluceste putin, dar ii buna!'
	},
	{
		name = 'Cernavoda SRL',
		min = { x = -43, z = -36 },
		max = { x = 32, z = -37 }
	},
}

Indicators = {
	D_RSI = {
		id = 'D_RSI',
		name = 'Doors Redstone Input',
	},
	D_RSO = {
		id = 'D_RSO',
		name = 'Doors Redstone Output',
	},
	D_CHAT = {
		id = 'D_CHAT',
		name = 'Chat Box',
	},
	MEIO = {
		id = 'MEIO',
		name = 'ME System',
	},
	PDIO = {
		id = 'PDIO',
		name = 'Player Detector',
	},
	MPIO = {
		id = 'MPIO',
		name = 'Media Player',
	},
	ZONES = {
		id = 'ZONES',
		name = 'Domn\' Paznic zones detection'
	},
	RANDOM_FACT = {
		id = 'RANDOM_FACT',
		name = 'Random Facts Broadcasts',
	}
}

return {
	Doorways = Doorways,
	RedstoneInput = RedstoneInput,
	RedstoneOutput = RedstoneOutput,
	Zones = Zones,
	Indicators = Indicators
}