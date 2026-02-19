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
    3.3.1 if inventory gets full after any dig action, use inventory.lua to either throw thrash away or go back to chest and then continue work
    3.4 go back to x=0, z=0, y=-8 (using the scan point as the reference)
    3.5 dig 9 blocks down
    3.6 go back to 3.1 until bedrock detected
    3.7 if bedrock detected, save the list of the scanned targets and just leave. If allthemodium is detected, dont mine it (because it cant), just save it location and continue
    4. after finishing the mining, go back to surface, empty everything, give the log (preferably create a txt file) of found and not mined targets and finish the program.
    
    If at any point, the robot encounters an error, it should immidietely go back to surface
    --]]

local function main()
    -- enable logging if config is true
    if config.debug_logger then
        local file = fs.open("Logs.txt", "w")
        file.writeLine("Logging started...")
        file.close()
    end
    -- first refuel with coal from player
    fuel.manualRefuel()

    -- set the current depth to control scan position in the future
    local depth = 0

    -- main loop
    while true do

        -- first checks if the scan returned bedrock
        if scanner.isBedrockFound() then
            if config.debug_logger then logger.log("Main: reached the end, going back to home") end -- LOGGING INFO - DEBUG OPTION

            -- go out of the loop
            break
        end

        -- planner uses scanner to get the list of all target blocks from whitelist, and sort it from closes to furthest
        local targets = planner.makePlan()

        -- for each sorted target in list, go there
        for _, target in ipairs(targets) do

            -- this goes to the exact location of the target + if the target is right beside robot, mine it without moving
            digger.dig(target)

            -- another check for bedrock to be double safe, this time if movement detects bedrock in front of the robot
            if movement.found_bedrock then

                -- go out of the loop - finish digging
                break
            end
        end

        -- go to the correct place for the next scan
        depth = depth -8
        movement.goTo({x=0, y=depth, z=0})
    end

    -- goes back to chest and empty inventory
    inventory.emptyInventory()

    -- create a .txt file with all ores that couldn't be mined (everything close to bedrock + special ores from alltheores)
    saveUnminedBlocks(scanner.getSPecialOresList())
end


-- launch the main function in secure mode. In case of any robot error, go back to surface and empty inventory to chest
local ok, err = pcall(main)
if not ok then
    emergencyReturn(err)
end
