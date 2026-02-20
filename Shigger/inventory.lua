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
    if inventory_emptying then return end
    local thrash_list = {}
    for i=2, 16 do
        if turtle.getItemDetail(i) == nil then return end
        for _, thrash_name in ipairs(config.thrash_list) do
            if turtle.getItemDetail(i) then
                local item_name = turtle.getItemDetail(i).name
                if turtle.getItemDetail(i) and item_name == thrash_name then
                    table.insert(thrash_list, i)
                    break
                end
            end
        end
    end
    if #thrash_list > 1 then
        for _, slot_number in ipairs(thrash_list) do
            turtle.select(slot_number)
            turtle.drop()
        end
        turtle.select(1)
    else
        inventory_emptying = true
        inventory.checkInventory()
        inventory_emptying = false
    end
end

function inventory.checkInventory()
    -- go back to chest and empty invenotry
    movementgoTo({x=0, y=state.getPosition().y, z=0})
    movementgoTo({x=0, y=0, z=0})
    -- turn to chest
    movementturnTo(2)
    for i=2, 16 do
        turtle.select(i)
        turtle.drop()
    end
    turtle.select(1)
end

function inventory.emptyInventory()
    -- empty inventory, first slot (coal) included
    movementgoTo({x=0, y=state.getPosition().y+5, z=0})
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
    movementturnTo = func
end

function inventory.setMovementTurnTo(func)
    movementgoTo = func
end

function inventory.goToChestCheck()
    return inventory_emptying
end

return inventory
