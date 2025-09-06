
-- lib/MekFissionReactor.lua

--- 
--- 

local DEBUG_LOGS = true
DEV_BYPASS_STRING = "DEV_MODE"  -- Special string to enable dev mode with mock data

local MekFissionReactor = {}
MekFissionReactor.__index = MekFissionReactor

local L = require('logger').getInstance('MekFissionReactor')

--- Create a new MekFissionReactor instance
-- @param peripheral table (e.g., result from peripheral.wrap("back"))
-- @param stateFrame Basalt frame containing state
function MekFissionReactor.new(reactorPeripheral, stateFrame)
	local self = setmetatable({}, MekFissionReactor)

	if type(reactorPeripheral) == 'table' and reactorPeripheral.getDTFuel then
		self.peripheral = reactorPeripheral
		L:info('MekFissionReactor peripheral attached: ' ..
            tostring(reactorPeripheral))
    elseif type(reactorPeripheral) == 'string' and reactorPeripheral == DEV_BYPASS_STRING then
        self.peripheral = reactorPeripheral
        L:warn('MekFissionReactor running in DEV_MODE with mock data')
	else
        L:error('Invalid MekFissionReactor peripheral: ' ..
            tostring(reactorPeripheral))
	end

	assert(self.stateFrame, 'Invalid MekFissionReactor state frame.')

	self.stateFrame = stateFrame
	self.config = config or {}
	self.inputCache = {}

	self:_setupBindings()
	self:_selfChecks()

	L:info('MekFissionReactor initialized successfully')
	return self
end

--- Internal: Verify config consistency and duplicates
function MekFissionReactor:_selfChecks()
	-- TODO check if the states that are needed exist
end

--- Internal: Setup hooks from state to redstone outputs
function MekFissionReactor:_setupBindings()

end


function MekFissionReactor:activateReactor()
    L:info('activateReactor called')
end

function MekFissionReactor:getActualBurnRate()
    if self.peripheral == DEV_BYPASS_STRING then
        return 69420.0  -- Mock value for dev mode
    end

    local status, result = pcall(function() return self.peripheral.getActualBurnRate() end)
    if status and result then
        return result
    else
        L:error('getActualBurnRate failed: ' .. tostring(result))
        return nil
    end
end

function MekFissionReactor:getBurnRate()
    if self.peripheral == DEV_BYPASS_STRING then
        return 12345.0  -- Mock value for dev mode
    end

    local status, result = pcall(function() return self.peripheral.getBurnRate() end)
    if status and result then
        return result
    else
        L:error('getBurnRate failed: ' .. tostring(result))
        return nil
    end
end

function MekFissionReactor:getDamagePercent()
    if self.peripheral == DEV_BYPASS_STRING then
        return 12-- Mock value for dev mode
    end

    local status, result = pcall(function() return self.peripheral.getDamagePercent() end)
    if status and result then
        return result
    else
        L:error('getDamagePercent failed: ' .. tostring(result))
        return nil
    end
end



return MekFissionReactor


-- ==== Fission Reactor Multiblock (formed) ====

-- Method Name	Params	Returns	Description

-----------------  TO IMPLEMENT ------------------
-- getFuel		Table (ChemicalStack)	Get the contents of the fuel tank.
-- getFuelCapacity		Number (long)	Get the capacity of the fuel tank.
-- getMaxBurnRate		Number (long)	
-- getHeatingRate		Number (long)	
-- getStatus		boolean	true -> active, false -> off
-- scram			Must be enabled
-- getTemperature		Number (double)	Get the temperature of the reactor in Kelvin.

-- ??????? -- getFuelAssemblies		Number (int)	

-- setBurnRate	rate Number (double)

--------- already implemented ---------
-- activate			Must be disabled, and if meltdowns are disabled must not have been force disabled
-- getActualBurnRate		Number (double)	Actual burn rate as it may be lower if say there is not enough fuel
-- getBurnRate		Number (double)	Configured burn rate
-- getDamagePercent		Number (long)	


----


-- getBoilEfficiency		Number (double)	
-- getCoolant		Table (ChemicalStack) or Table (FluidStack)	
-- getCoolantCapacity		Number (long)	
-- getCoolantFilledPercentage		Number (double)	
-- getCoolantNeeded		Number (long)	
-- getEnvironmentalLoss		Number (double)	
-- getFuelFilledPercentage		Number (double)	Get the filled percentage of the fuel tank.
-- getFuelNeeded		Number (long)	Get the amount needed to fill the fuel tank.
-- getFuelSurfaceArea		Number (int)	
-- getHeatCapacity		Number (double)	
-- getHeatedCoolant		Table (ChemicalStack)	Get the contents of the heated coolant.
-- getHeatedCoolantCapacity		Number (long)	Get the capacity of the heated coolant.
-- getHeatedCoolantFilledPercentage		Number (double)	Get the filled percentage of the heated coolant.
-- getHeatedCoolantNeeded		Number (long)	Get the amount needed to fill the heated coolant.
-- getWaste		Table (ChemicalStack)	Get the contents of the waste tank.
-- getWasteCapacity		Number (long)	Get the capacity of the waste tank.
-- getWasteFilledPercentage		Number (double)	Get the filled percentage of the waste tank.
-- getWasteNeeded		Number (long)	Get the amount needed to fill the waste tank.
-- isForceDisabled		boolean	

-- =======================================
-- ==== Fission Reactor Logic Adapter ====

-- Method Name	Params	Returns	Description
-- getLogicMode		String (FissionReactorLogic)	
-- getRedstoneLogicStatus		String (RedstoneStatus)	
-- setLogicMode	
-- logicType
-- String (FissionReactorLogic)
