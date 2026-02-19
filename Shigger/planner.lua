-- planner.lua

local config = require("config")
local state = require("state")
local logger = require("logger")

local planner = {}

-- local variables


-- =====================
-- PRIVATE
-- =====================

local function getDistanceToTarget(position, target)
    local dx, dy, dz = math.abs(target.x - position.x), math.abs(target.y - position.y), math.abs(target.z - position.z)
    local distance = dx + dy + dz
    return distance
end



-- =====================
-- PUBLIC API
-- =====================

-- return the points of interest to go and mine
-- it should create the list using greedy Manhattan search: find the closest target (smallest |dx| + |dy| + |dz| ), then starting from the position of that block,
-- again find the closest one to that position and again, and again, and until all targets has bees assigned

function planner.makePlan(targets)
    local target_list_unsorted = targets
    local current_position = state.getPosition()
    local target_list_sorted = {}


    while #target_list_unsorted > 0 do
        local distance = nil
        local closest_block = nil
        for i, v in ipairs(target_list_unsorted) do
            local distance_to_target = getDistanceToTarget(current_position, v)
            if not distance or distance_to_target < distance then
                distance = distance_to_target
                closest_block = i
            end
        end
        table.insert(target_list_sorted, target_list_unsorted[closest_block])
        current_position = {
            x = target_list_unsorted[closest_block].x,
            y = target_list_unsorted[closest_block].y,
            z = target_list_unsorted[closest_block].z,
        }
        table.remove(target_list_unsorted, closest_block)
    end
    return target_list_sorted
end

return planner