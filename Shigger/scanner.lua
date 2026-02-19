-- scanner.lua

local config = require("config")
local state = require("state")
local logger = require("logger")

local scanner = {}


-- local variables

local white_list = config.whitelist

local special_ores = {}

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

local function saveSpecialOre(list, block)
    local robot_position = state.getPosition()
    table.insert(list, {name=block.name, x=block.x, y=(block.y + robot_position.y), z=block.z})
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
                if block.name:match(":(.+)"):find(tag, 1, true) then
                    if config.debug_logger then logger.log("Scanner: "..block.name.." at: x="..block.x..", y="..block.y..", z="..block.z) end -- LOGGING INFO - DEBUG OPTION
                    if block.name:find("allthemodium", 1, true) or block.name:find("vibranium", 1, true) or block.name:find("unobtanium", 1, true) then
                        if config.debug_logger then logger.log("Scanner: found special ore: "..block.name) end  -- LOGGING INFO - DEBUG OPTION
                        saveSpecialOre(special_ores, block)
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

function scanner.isBedrockFound()
    local device = getScanner()
    local block_list = device.scan(8)
    
    for _, v in ipairs(block_list) do
        if v.name == "minecraft:bedrock" then
            if config.debug_logger then logger.log("Scanner: bedrock found") end -- LOGGING INFO - DEBUG OPTION
            local block_list = device.scan(8)
            for _, block in ipairs(block_list) do
                for _, tag in ipairs(white_list) do
                    if block.name:find(tag, 1, true) then
                        saveSpecialOre(special_ores, {block.name, block.x, block.y, block.z})
                        break
                    end
                end
            end
            return true
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
