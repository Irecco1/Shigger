-- scanner.lua

local config = require("config")
local state = require("state")
local logger = require("logger")

local scanner = {}


-- local variables

local white_list = config.whitelist

local special_ores = {}

local closest_bedrock = -1000000

local max_depth = -1000000

-- =====================
-- PRIVATE
-- =====================

local device = peripheral.find("geo_scanner")
if not device then
    error("Geo scanner not found!")
end

local function saveSpecialOre(block)
    local robot_position = state.getPosition()
    table.insert(special_ores, {name=block.name, x=block.x, y=(block.y + robot_position.y), z=block.z})
end


-- =====================
-- PUBLIC API
-- =====================

-- should scan the area and return all target blocks that are on y <= current robot position y.

-- later it should also detect allthemodium to save it and bedrock, to enable special case movement.

function scanner.scan()
    -- should return a list with tables {x,y,z} of all points of interest
    -- should take a whitelist and search for everything on whitelist, no matter if its the full name or just a part of the name

    local target_list = {}
    local block_list = device.scanBlocks(8)
    local robot_position = state.getPosition()

    for _, block in ipairs(block_list) do
        if block.y <= 0 then
            for _, tag in ipairs(white_list) do
                if block.name:match(":(.+)"):find(tag, 1, true) and block.x > -8 and block.z < 8 and block.y >= max_depth then
                    if block.name:find("allthemodium", 1, true) or block.name:find("vibranium", 1, true) or block.name:find("unobtanium", 1, true) then
                        saveSpecialOre({name=block.name, x=block.x, y=block.y, z=block.z})
                        break
                    else
                        table.insert(target_list, {x=block.x, y=(block.y + robot_position.y), z=block.z})
                        break
                    end
                end
            end
        end
    end
    return target_list
end

--[[
idea is when we find bedrock, we save the max depth we can go to.
after reaching that depth, we will instantly stop the movement, scan for ores inside bedrock and proceed to end digging
]]--
function scanner.isBedrockFound()
    local block_list = device.scanBlocks(8)
    local robot_position = state.getPosition()
    
    if max_depth > -1000000 then
        return
    end
    for _, v in ipairs(block_list) do
        if v.name == "minecraft:bedrock" and v.y > closest_bedrock then
            closest_bedrock = v.y
        end
    end

    if closest_bedrock > -1000000 then
        max_depth = closest_bedrock + robot_position.y + 1
    end
end

-- used to save whitelisted ores that are below bedrock
function scanner.saveWhitelistedOres(block_list)
    for _, block in ipairs(block_list) do
        for _, tag in ipairs(white_list) do
            if block.name:find(tag, 1, true) and block.x > -8 and block.z < 8 then
                saveSpecialOre({name=block.name, x=block.x, y=block.y, z=block.z})
                break
            end
        end
    end
end

function scanner.getSPecialOresList()
    local list = {}
    for _, v in ipairs(special_ores) do
        table.insert(list, {
            name=v.name,
            x=v.x,
            y=v.y,
            z=v.z,
        })
    end
    return list
end

return scanner
