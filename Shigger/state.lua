-- state.lua

local config = require("config")
local logger = require("logger")

local state = {}

-- local variables
local data = {
    position = {x=0,y=0,z=0},
    direction = 0,  -- 0=N, 1=E, 2=S, 3=W
}

local DIR = {
    [0] = {x=0,z=-1},
    [1] = {x=1,z=0},
    [2] = {x=0,z=1},
    [3] = {x=-1,z=0},
}


-- =====================
-- PRIVATE
-- =====================




-- =====================
-- PUBLIC API
-- =====================

function state.updatePosition(direction)
    --accepts 'forward', 'back', 'up', 'down'
    if direction == "forward" then
        data.position.x = data.position.x + DIR[data.direction].x
        data.position.z = data.position.z + DIR[data.direction].z
        return
    end
    if direction == "back" then
        data.position.x = data.position.x - DIR[data.direction].x
        data.position.z = data.position.z - DIR[data.direction].z
        return
    end
    if direction == "up" then
         data.position.y = data.position.y + 1
         return
    end
    if direction == "down" then
         data.position.y = data.position.y - 1
         return
    end

    error("Invalid direction")
    
 
end

function state.updateDirection(direction)
    -- <0 left or >0 right direction. Accepts multiple rotations at once
    if direction < 0 then
        for i=1, -direction do
            data.direction = data.direction - 1
            if data.direction < 0 then
                data.direction = 3
            end
        end
    elseif direction > 0 then
        for i=1, direction do
            data.direction = data.direction + 1
            if data.direction > 3 then
                data.direction = 0
            end
        end
    end
end

function state.getPosition()
    return {
        x = data.position.x,
        y = data.position.y,
        z = data.position.z,
    }
end

function state.getDirection()
    return data.direction
end

return state
