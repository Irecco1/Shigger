-- dig.lua

local movement = require("movement")
local state = require("state")


local digger = {}

-- local variables



-- =====================
-- PRIVATE
-- =====================




-- =====================
-- PUBLIC API
-- =====================

-- here it will just recive info, on what block on exact coordinates to mine. It should check if the block is nerby to mine it and if not,
-- just use movement.goTo(target) that will go there and mine it. It should recive a list from planner, which is gonna consist of all blocks to mine in correct order.

function digger.dig(target)
    -- the target is just x,y,z table. If it's close, just dig it or rotate and dig if necessary. If it's far, use movement.goTo() to got there and dig it
    -- list of blocks to dig from planner will go to main, where it will take the list of blocks, and call digger.dig on every single one of them.

    -- first check if the target is directly above or below the robot
    local robot_position = state.getPosition()

    if target.y == robot_position.y +1 and target.x == robot_position.x and target.z == robot_position.z then
        turtle.digUp()
        return
    end
    if target.y == robot_position.y -1 and target.x == robot_position.x and target.z == robot_position.z then
        turtle.digDown()
        return
    end

    -- next check if the target is in any of the cardinal directions of the robot

    local robot_direction = state.getDirection()

    -- target is 1 block to the North
    if target.z - robot_position.z == -1 and target.x == robot_position.x and target.y == robot_position.y then
        movement.turnTo(0)
        turtle.dig()
        return
    end

    -- target is 1 block to the South
    if target.z - robot_position.z == 1 and target.x == robot_position.x and target.y == robot_position.y then
        movement.turnTo(2)
        turtle.dig()
        return
    end
    
    -- target is 1 block to the East
    if target.x - robot_position.x == 1 and target.z == robot_position.z and target.y == robot_position.y then
        movement.turnTo(1)
        turtle.dig()
        return
    end

    -- target is 1 block to the West
    if target.x - robot_position.x == -1 and target.z == robot_position.z and target.y == robot_position.y then
        movement.turnTo(3)
        turtle.dig()
        return
    end

    -- if the target wasnt nearby, then just go straight to the target
    movement.goTo(target)
end

return digger