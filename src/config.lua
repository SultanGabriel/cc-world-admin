local Doorways = {
	D_00 = {
		key = "D_00",
		id = "0",
		name = "Main Entrance",
		x = 59,
		y = 1,
		w = 4,
		h = 1,
	},
	D_01 = {
		key = "D_01",
		id = "1",
		name = "ME Controller",
		x = 58,
		y = 3,
		w = 1,
		h = 3,
	},
	D_02 = {
		key = "D_02",
		id = "2",
		name = "ME Server Room",
		x = 75,
		y = 8,
		w = 3,
		h = 1,
	},
	D_03 = {
		key = "D_03",
		id = "3",
		name = "Sefety Door",
		x = 80,
		y = 9,
		w = 1,
		h = 2,
	},
	D_04 = {
		key = "D_04",
		id = "4",
		name = "ME Patterns",
		x = 85,
		y = 11,
		w = 3,
		h = 1,
	},
	D_05 = {
		key = "D_05",
		id = "5",
		name = "Drawer Hole",
		x = 85,
		y = 8,
		w = 3,
		h = 1,
	},
	D_06 = {
		key = "D_06",
		id = "6",
		name = "GTMO",
		x = 89,
		y = 9,
		w = 1,
		h = 2,
	},
}
DOOR_INPUT_SIDE = "top"
local RedstoneInput = {
	D_00 = {
		side = DOOR_INPUT_SIDE,
		mode = "output",
		bundled = colors.white,
	},
	D_01 = {
		side = DOOR_INPUT_SIDE,
		mode = "input",
		bundled = colors.blue,
	},
	D_02 = {
		side = DOOR_INPUT_SIDE,
		mode = "input",
		bundled = colors.green,
	},
	D_03 = {
		side = DOOR_INPUT_SIDE,
		mode = "input",
		bundled = colors.red,
	},
	D_04 = {
		side = DOOR_INPUT_SIDE,
		mode = "input",
		bundled = colors.yellow,
	},
	D_05 = {
		side = DOOR_INPUT_SIDE,
		mode = "input",
		bundled = colors.purple,
	},
	D_06 = {
		side = DOOR_INPUT_SIDE,
		mode = "input",
		bundled = colors.orange,
	},
}

local RedstoneOutput = {}
local Zones = {
{
  name = "Democratic Solutions",
  min = {x = -82, z = -38},
  max = {x = -28, z = -83}
},
{
  name = "Sobranie Srl",
  min = {x = -113, z = 55},
  max = {x = -87, z = 121}
},
{
  name = "GregTech Factory",
  min = {x = -301, z = 47},
  max = {x = -130, z = 131}
},
{
  name = "Spawn",
  min = {x = -345, z = -333},
  max = {x = -265, z = -193}
},
{
  name = "Magic",
  min = {x = -152, z = -578},
  max = {x = -356, z = -728}
},
{
  name = "Chernobyl",
  min = {x = -317, z = -183},
  max = {x = -368, z = -143}
},
}

return {
	Doorways = Doorways,
  RedstoneInput = RedstoneInput,
  RedstoneOutput = RedstoneOutput,
  Zones = Zones,
}
