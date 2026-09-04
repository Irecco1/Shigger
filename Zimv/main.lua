-- main.lua

local config = require("config")
local digger = require("digger")
local fuel = require("fuel")
local inventory = require("inventory")
local movement = require("movement")
local planner = require("planner")
local scanner = require("scanner")
local state = require("state")
local logger = require("logger")

local underground_fail_safe = false

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
inventory.setMovementGoTo(movement.goTo)
inventory.setMovementTurnTo(movement.turnTo)

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
    3.3.1 if inventory gets full after any dig action, use inventory.lua to either throw trash away or go back to chest and then continue work
    3.4 go back to x=0, z=0, y=-8 (using the scan point as the reference)
    3.5 dig 9 blocks down
    3.6 go back to 3.1 until bedrock detected
    3.7 if bedrock detected, create a max depth value that will be our next destination. when we arrive there, scan, save ores inside bedrock in a file and go back
    4. after finishing the mining, go back to surface, empty everything, give the log (preferably create a txt file) of found and not mined targets and finish the program.
    
    If at any point, the robot encounters an error, it should immidietely go back to surface
    --]]

local function main()
    -- set the current depth to control scan position in the future
    local depth = 0

    -- enable logging if config is true
    if config.debug_logger then
        local file = fs.open("Logs.txt", "w")
        file.writeLine("Logging started...")
        file.close()
    end

    -- check the saved position. if its 0, we have just started and continue as always.
    -- if its not 0, 0, 0, then we are underground, probably chunk got unloaded.
    -- in that case, move up to modulo of 8 from current position and jump to main loop
    local saved_state = state.getSavedState()
    if saved_state.position.x ~= 0 or saved_state.position.y ~= 0 or saved_state.position.z ~= 0 then
        underground_fail_safe = true
        local robot_position = state.getPosition()
        local last_scan_position = robot_position.y + math.abs(robot_position.y)%8
        movement.goTo({x=0, y=last_scan_position, z=0})
        depth = last_scan_position
    end

    if not underground_fail_safe then
        -- first refuel with coal from player
        fuel.manualRefuel()
    end


    -- main loop
    while true do

        -- checks for the bedrock to set maximum depth
        scanner.isBedrockFound()

        -- planner uses scanner to get the list of all target blocks from whitelist, and sort it from closes to furthest
        local targets = planner.makePlan()
        -- for each sorted target in list, go there
        for _, target in ipairs(targets) do
            -- this goes to the exact location of the target + if the target is right beside robot, mine it without moving
            digger.dig(target)
            -- enable inventory check in case it was disabled for emptying
            inventory.enableInventoryCheck()
        end
        -- go to the correct place for the next scan
        depth = depth -8
        
        -- check if the maximum depth is set. If so, put it as next depth
        if scanner.max_depth > -1000000 then
            depth = scanner.max_depth
        end
        movement.goTo({x=0, y=depth, z=0})

        -- get current position. If it's equal to the max depth set up by the scanner, break
        local robot_position = state.getPosition()
        if robot_position == scanner.max_depth then
            break
        end
    end
    -- saves blocks inside bedrock
    scanner.saveWhitelistedOres()

    -- goes back to chest and empty inventory
    inventory.emptyInventory()
    inventory.enableInventoryCheck()
    -- create a .txt file with all ores that couldn't be mined (everything close to bedrock + special ores from alltheores)
    saveUnminedBlocks(scanner.getSPecialOresList())
end


-- launch the main function in secure mode. In case of any robot error, go back to surface and empty inventory to chest
local ok, err = pcall(main)
if not ok then
    emergencyReturn(err)
end
