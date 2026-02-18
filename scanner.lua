-- scanner.lua

local config = require("config")
local state = require("state")

local scanner = {}


-- local variables

local white_list = config.whitelist

-- =====================
-- PRIVATE
-- =====================

local function getScanner()
    local device = peripheral.find("geo_scanner")
    if not device then
        error("Geo scanner not found!")
    end
    return device
end


-- =====================
-- PUBLIC API
-- =====================

-- should scan the area and return all target blocks that are on y <= current robot position y.

-- later it should also detect allthemodium to save it and bedrock, to enable special case movement.

function scanner.scan()
    -- should return a list with tables {x,y,z} of all points of interest
    -- should take a whitelist and search for everything on whitelist, no matter if its the full name or just a part of the name

    local device = getScanner()

    local target_list = {}
    local block_list = device.scan(8)
    local robot_position = state.getPosition()

    for _, block in ipairs(block_list) do
        if block.y <= 0 then
            for _, tag in ipairs(white_list) do
                if block.name:find(tag, 1, true) then
                    table.insert(target_list, {x=(block.x + robot_position.x), y=(block.y + robot_position.y), z=(block.z + robot_position.z)})
                    break
                end
            end
        end
    end
    return target_list
end

function scanner.isBedrockFound()
    local device = getScanner()
    local block_list = device.scan(8)
    
    for _, v in ipairs(block_list) do
        if v.name == "minecraft:bedrock" then
            return true
        end
    end
end

return scanner