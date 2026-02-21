-- inventory.lua

local config = require("config")
local state = require("state")
local logger = require("logger")

local inventory = {}

-- local variables

local movementgoTo
local movementturnTo
local inventory_emptying = false

-- =====================
-- PRIVATE
-- =====================




-- =====================
-- PUBLIC API
-- =====================

-- should be checking if the invrntory is full and if it is, then:
-- 1) try to empty all tharsh_listed items (need to prepare a list of cobblestone, tuff, blackstone, dirst, gravel etc.)
-- 2) if there is no thrash and inventory is full, go back to surface, empty to chest and go back

function inventory.throwAwayThrash()
    -- throws tharsh away while mining underground
    -- if there is no free slots then throws thrash away
    for i=2, 16 do
        -- if any slot is free, return
        if not turtle.getItemDetail(i) then
            return
        end
    end
    local thrash_list = {}
    for i=2, 16 do
        -- if slot is not free, check if it is thrash
        for _, thrash in ipairs(config.thrash_list) do
            if turtle.getItemDetail(i).name == thrash then
                -- if it is, add it's slot to thrash list
                table.insert(thrash_list, i)
                -- go out of the loop (config.thrash_list)
                break
            end
        end
    end
    -- after checking entire inventory and if there wasn't free slots (if there were, it would return) then check, if there is at least 2 thrash
    -- if so, then throw it away and rearange items
    -- if only 1 or 0 thrash detected, go back to chest and empty
    if #thrash_list > 1 then
        -- throwing thrash away
        for _, slot_number in ipairs(thrash_list) do
            turtle.select(slot_number)
            turtle.drop()
        end
        -- if thrash was thrown away, we need to organise inventory
        for i = 2, 15 do
            if turtle.getItemDetail(i) == nil then
                for j=16, 2, -1 do
                    if turtle.getItemDetail(j) ~= nil and j > i then
                        turtle.select(j)
                        turtle.transferTo(i)
                        break
                    end
                end
            end
        end
        turtle.select(1)

        return
    end
    -- on the other hand, if length of thrash list was 1 or 0 and inventory is full, it is necessary to go to chest, while skipping inventory checks
    local current_position = state.getPosition()
    local current_direction = state.getDirection()
    inventory_emptying = true
    -- empty inventory, first slot (coal) excluded
    movementgoTo({x=0, y=state.getPosition().y, z=0})
    movementgoTo({x=0, y=0, z=0})
    movementturnTo(2)
    for i=2, 16 do
            turtle.select(i)
            turtle.drop()
    end
    turtle.select(1)
    movementgoTo(current_position)
    movementturnTo(current_direction)
end

function inventory.emptyInventory()
    inventory_emptying = true
    -- empty inventory, first slot (coal) included
    movementgoTo({x=0, y=state.getPosition().y, z=0})
    movementgoTo({x=0, y=0, z=0})
    movementturnTo(2)
    for i=1, 16 do
            turtle.select(i)
            turtle.drop()
    end
    turtle.select(1)
    movementturnTo(0)
end

function inventory.setMovementGoTo(func)
    movementgoTo = func
end
function inventory.setMovementTurnTo(func)
    movementturnTo = func
end

function inventory.skipInventoryCheck()
    return inventory_emptying
end

function inventory.enableInventoryCheck()
    inventory_emptying = false
end

return inventory

