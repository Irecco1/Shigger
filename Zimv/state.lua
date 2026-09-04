--[[
state.lua

Responsible for saving and giving current position and rotation of the robot.

Position and rotation should be saved in a file that can be read, at the beggining of work
to check, if the robot was in the middle of working or not (failsafe for unloading chunks).
position also should be saved as local variable, to limit the amount of open/close file.

Same with rotation.
]]--

local state = {}

-- local variables

local state_file = nil

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


--[[
saves current state in a file to be read when machine auto-starts.

{position, direction}
]]--
local function saveState(current_state)
    if not state_file then
        state_file = fs.open("state.txt", "w")
    end
    if state_file then
        state_file.seek("set", 0)
        state_file.write(textutils.serialize(current_state))
        state_file.flush()
        return
    end
end


--[[
returns unserialized table with position and rotation.

{position={x=0, y=0, z=0}, direction=0}
]]--
local function loadState()
    if not fs.exists("state.txt") then
        local file = fs.open("state.txt", "w")
        file.close()
    end
    local file = fs.open("state.txt", "r")
    local raw_data = file.readAll()
    file.close()

    local state_data = textutils.unserialize(raw_data)

    if state_data then
        return state_data
    end
end


-- =====================
-- PUBLIC API
-- =====================


--accepts 'forward', 'back', 'up', 'down'
function state.updatePosition(direction)
    if direction == "forward" then
        data.position.x = data.position.x + DIR[data.direction].x
        data.position.z = data.position.z + DIR[data.direction].z
        saveState(data)
        return
    end
    if direction == "back" then
        data.position.x = data.position.x - DIR[data.direction].x
        data.position.z = data.position.z - DIR[data.direction].z
        saveState(data)
        return
    end
    if direction == "up" then
         data.position.y = data.position.y + 1
         saveState(data)
         return
    end
    if direction == "down" then
         data.position.y = data.position.y - 1
         saveState(data)
         return
    end

    error("Invalid direction")
end

-- <0 left or >0 right direction. Accepts multiple rotations at once
function state.updateDirection(direction)
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
    saveState(data)
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

function state.getSavedState()
    return loadState()
end


return state
