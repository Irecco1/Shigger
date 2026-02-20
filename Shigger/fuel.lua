-- fuel.lua

local state = require("state")
local config = require("config")
local logger = require("logger")


local fuel = {}

-- local variables

local skip_fuel_check = false
local movementgoTo
local max_fuel = config.max_fuel

-- =====================
-- PRIVATE
-- =====================

local function getCurrentDepth()
    return state.getPosition().y
end

local function refuel(max_value)
    while turtle.getFuelLevel() < max_value and (turtle.getItemCount(1) or 0) > 1 do
        turtle.refuel(1)
    end
end

local function startSkippingFuelCheck()
    skip_fuel_check = true
end

local function stopSkippingFuelCheck()
    skip_fuel_check = false
end
-- =====================
-- PUBLIC API
-- =====================

function fuel.setMovementGoTo(func)
    movementgoTo = func
end

function fuel.checkFuelLeft()
    if turtle.getFuelLevel() < -getCurrentDepth() *2 +200 then
        turtle.select(1)

        -- go back to the chest and wait for refuel if there is only 1 coal in inventory
        if turtle.getItemCount(1) <= 1 then
            
            startSkippingFuelCheck()
            movementgoTo({x=0, y=getCurrentDepth(), z=0,})
            movementgoTo({x=0, y=0, z=0,})
            
            while turtle.getFuelLevel() < max_fuel do
                print("OUT OF FUEL! Insert more coal to slot 1 and press ENTER.")
                local input = read()
                refuel(max_fuel)
            end
            stopSkippingFuelCheck()
            return
        end
        refuel()
    end
end

function fuel.manualRefuel()
    print("Insert fuel, must be coal, to slot 1 and press ENTER.")
    local input = read()
    refuel(turtle.getFuelLimit())
    while turtle.getFuelLevel() < max_fuel do
        print("Not enough fuel. Please insert more coal (preferably at once) and press enter")
        local input = read()
        refuel(turtle.getFuelLimit())
    end
    if config.debug_logger then logger.log("Fuel: final fuel: "..turtle.getFuelLevel()) end
end

function fuel.checkFuelSkip()
    return skip_fuel_check
end

return fuel