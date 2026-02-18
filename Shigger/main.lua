-- main.lua

local config = require("config")
local digger = require("digger")
local fuel = require("fuel")
local inventory = require("inventory")
local movement = require("movement")
local planner = require("planner")
local scanner = require("scanner")
local state = require("state")


local function emergencyReturn(err)
    print("ERROR:", err)
    movement.goTo({x=state.getPosition().x, y=-5, z=state.getPosition().z})
    inventory.emptyInventory()
end

local function saveUnminedBlocks(list)
    local file = fs.open("unmined.txt", "w")

    for _, block in ipairs(list) do
        file.writeLine(
            block.name ..
            "\nx=" .. block.x ..
            ", y=" .. block.y ..
            ", z=" .. block.z
        )
    end

    file.close()
    
end

fuel.setMovementGoTo(movement.goTo)

-- =====================
-- MAIN LOGIC
-- =====================

 --[[
    1. first start, it should be placed facing north, with the chest behind the robot on the same level.
    2. next, preferably the coal should be put in the slot 1 of the turtle, for it to refuel itself
    3. after that, the robot can start the work:
    3.1 scan the surrounding area and look for whitelist targets
    3.2 plan the target order using the scanner list
    3.3 dig each target
    3.3.1 if inventory gets full after any dig action, use inventory.lua to either throw thrash away or go back to chest and then continue work
    3.4 go back to x=0, z=0, y=-8 (using the scan point as the reference)
    3.5 dig 9 blocks down
    3.6 go back to 3.1 until bedrock detected
    3.7 if bedrock detected, save the list of the scanned targets and just leave. If allthemodium is detected, dont mine it (because it cant), just save it location and continue
    4. after finishing the mining, go back to surface, empty everything, give the log (preferably create a txt file) of found and not mined targets and finish the program.
    
    If at any point, the robot encounters an error, it should immidietely go back to surface
    --]]

local function main()
    fuel.manualRefuel()
    local depth = 0
    while true do
        if scanner.isBedrockFound() then
            break
        end
        local scan_list = scanner.scan()
        local targets = planner.makePlan(scan_list)
        for _, target in ipairs(targets) do
            digger.dig(target)
            inventory.checkInventory()
        end
        depth = depth -8
        movement.goTo({x=0, y=depth, z=0})
    end
    inventory.emptyInventory()

    saveUnminedBlocks(scanner.getSPecialOresList())
end



local ok, err = pcall(main)
if not ok then
    emergencyReturn(err)

end
