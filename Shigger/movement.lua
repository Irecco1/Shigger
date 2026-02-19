-- movement.lua

local state = require("state")
local config = require("config")
local fuel = require("fuel")
local logger = require("logger")
local inventory = require("inventory")

local movement = {}

-- local variables

local retry_amount = config.max_movement_retry_amount
local found_bedrock = false


-- =====================
-- PRIVATE
-- =====================



-- =====================
-- PUBLIC API
-- =====================

function movement.goForward()
    turtle.dig()
    inventory.throwAwayThrash()
    for i=1,retry_amount do
        local _, block_in_front = turtle.inspect()
        if block_in_front.name == "minecraft:bedrock" then
            found_bedrock = true
            return
        end
        if turtle.forward() then
            state.updatePosition("forward")
            if not fuel.checkFuelSkip() then
                fuel.checkFuelLeft() -- will refuel in fuel.lua
            end
            return
        end
        turtle.dig()
        sleep(0.5)
    end
    error("Movement couldn't be completed!")
end


-- actually, goBack will probably never be used, go to is simpler if it just considers the forward movement.
-- only place it is in use, is when the rotation is wrong and robot goes for a journey into the unknnown
function movement.goBack()
    if turtle.back() then
        state.updatePosition("back")
        if not fuel.checkFuelSkip() then
            fuel.checkFuelLeft()
        end
        return
    end
    local _, reason = turtle.back()
    if reason == "Movement obstructed" then
        -- this error happens, when turtle tries to fuck go back and there is a block behind. Either planner fucked up, or the rotation state drifted
        movement.turnLeft()
        movement.turnLeft()
        turtle.dig()
        sleep(0.5)
        if turtle.detect() then
            -- it must have been gravel that has fallen behind the robot
            while turtle.detect() do
                turtle.dig()
                sleep(0.5)
            end
            movement.turnLeft()
            movement.turnLeft()
            if turtle.back() then
                state.updatePosition("back")
                if not fuel.checkFuelSkip() then
                    fuel.checkFuelLeft()
                end
                return
            end
            error("Movement failed for unknown reason")
        else
            error("Path was blocked for unexpected reason! Might be a state drift or palnner problem!")
        end
    end
    error("Movement failed for unknown reason")
end

function movement.goUp()
    turtle.digUp()
    inventory.throwAwayThrash()
    for i=1,retry_amount do
        if turtle.up() then
            state.updatePosition("up")
            if not fuel.checkFuelSkip() then
                fuel.checkFuelLeft() -- will refuel in fuel.lua
            end
            return
        end
        turtle.digUp()
        sleep(0.5)
    end
    error("Movement couldn't be completed!")
end

function movement.goDown()
    turtle.digDown()
    inventory.throwAwayThrash()
    for i=1,retry_amount do
        if turtle.down() then
            state.updatePosition("down")
            if not fuel.checkFuelSkip() then
                fuel.checkFuelLeft() -- will refuel in fuel.lua
            end
            return
        end
        turtle.digDown()
        sleep(0.5)
    end
    error("Movement couldn't be completed!")
end

function movement.turnLeft()
    turtle.turnLeft()
    state.updateDirection(-1)
end

function movement.turnRight()
    turtle.turnRight()
    state.updateDirection(1)
end

function movement.turnTo(direction)
    -- accepts numbers 0, 1, 2, 3 and rotates to it
    local current_direction = state.getDirection()
    -- if looking to N
    if direction == 0 then
        if current_direction == 0 then
            return
        end
        if current_direction == 1 then
            movement.turnLeft()
            return
        end
        if current_direction == 2 then
            movement.turnLeft()
            movement.turnLeft()
            return
        end
        if current_direction == 3 then
            movement.turnRight()
            return
        end
    end

    -- if looking to E
    if direction == 1 then
        if current_direction == 0 then
            movement.turnRight()
            return
        end
        if current_direction == 1 then
            return
        end
        if current_direction == 2 then
            movement.turnLeft()
            return
        end
        if current_direction == 3 then
            movement.turnRight()
            movement.turnRight()
            return
        end
    end

    -- if looking to S
    if direction == 2 then
        if current_direction == 0 then
            movement.turnRight()
            movement.turnRight()
            return
        end
        if current_direction == 1 then
            movement.turnRight()
            return
        end
        if current_direction == 2 then
            return
        end
        if current_direction == 3 then
            movement.turnLeft()
            return
        end
    end

    -- if looking to W
    if direction == 3 then
        if current_direction == 0 then
            movement.turnLeft()
            return
        end
        if current_direction == 1 then
            movement.turnLeft()
            movement.turnLeft()
            return
        end
        if current_direction == 2 then
            movement.turnRight()
            return
        end
        if current_direction == 3 then
            return
        end
    end
end

function movement.goTo(target_position)
    -- target_position is a table {x=i, y=j, z=k}. Robot should be able to go there and rotate on his own from this function.
    -- Later, it will be used by dig, which is gonna just give the target position, and robot will go there as quickly as it can and mine it
    -- planner will just give the correct order of which blocks to dig

    -- dig will need an option to recognize, if the block is close and if so, just dig it without movement. Reminder for later


    -- first, the robot goes to correct y level
    while target_position.y < state.getPosition().y do
        movement.goDown()
    end
    while target_position.y > state.getPosition().y do
        movement.goUp()
    end

    -- next, the robot will go to correct z
    -- If the target is North from robot

    if found_bedrock then
        return
    end
    if state.getPosition().z > target_position.z then
        movement.turnTo(0)
    end

    -- if the target is South from robot
    if state.getPosition().z < target_position.z then
        movement.turnTo(2)
    end

    local i = 1
    while state.getPosition().z ~= target_position.z do
        movement.goForward()
        i = i+1
        if i > 20 then
            for j=1, 20 do
                movement.goBack()
            end
            error("Rotation was wrong and robot missed target")
        end
    end
    i = 1

    -- now the x axis, everything is the same as Z except rotation values
    -- if the target is East from robot
    if state.getPosition().x < target_position.x then
        movement.turnTo(1)
    end

    -- if the target is West from robot
    if state.getPosition().x > target_position.x then
        movement.turnTo(3)
    end
    
    while state.getPosition().x ~= target_position.x do
        movement.goForward()
        i = i+1
        if i > 20 then
            for j=1, 20 do
                movement.goBack()
            end
            error("Rotation was wrong and robot missed target")
        end
    end

end

return movement
