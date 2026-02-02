local Reactors = {
	"fusionReactorLogicAdapter_0",
	"fusionReactorLogicAdapter_1",
	-- "fusionReactorLogicAdapter_2",
}
local Tanks = {
	{
		peripheral = "dynamicValve_4",
		name = "Fusion Fuel",
    tag = "DT_TANK"
	},
	{
		peripheral = "dynamicValve_5",
		name = "Deuterium",
    tag = "D_TANK"
	},
	{
		peripheral = "dynamicValve_6",
		name = "Tritium",
    tag = "T_TANk"
	},
}

local InductionMatrix = "inductionPort_2"

return {
	REACTORS = Reactors,
	TANKS = Tanks,
	INDUCTION_MATRIX = InductionMatrix,
}
