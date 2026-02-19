-- inventory.lua

local config = require("config")
local state = require("state")
local logger = require("logger")

local inventory = {}

-- local variables

local thrash_list = config.thrash_list
local useful_items_counter = 0
local movementgoTo
local movementturnTo

-- =====================
-- PRIVATE
-- =====================




-- =====================
-- PUBLIC API
-- =====================

-- should be checking if the invrntory is full and if it is, then:
-- 1) try to empty all tharsh_listed items (need to prepare a list of cobblestone, tuff, blackstone, dirst, gravel etc.)
-- 2) if there is no thrash and inventory is full, go back to surface, empty to chest and go back

function inventory.setMovementGoTo(func)
    movementgoTo = func
end
function inventory.setMovementTurnTo(func)
    movementturnTo = func
end

function inventory.throwAwayThrash()
    if useful_items_counter >= 14 then return end
    if config.empty_thrash and turtle.getItemCount(16) > 0 then
        for i=2, 16 do
            local thrash_found = false
            for _, thrash in ipairs(thrash_list) do
                local item_name
                if turtle.getItemDetail(i) then item_name = turtle.getItemDetail(i).name end
                if item_name == thrash then
                    turtle.select(i)
                    turtle.drop()
                    thrash_found = true
                    break
                end
            end
            if not thrash_found then
                useful_items_counter = useful_items_counter +1
                if useful_items_counter >= 14 then return end
            end
        end
        -- we need to clear the 16th slot if it's not thrash. because otherwise the function will loop
        for i=2, 15 do
            if not turtle.getItemDetail(i) and turtle.getItemDetail(16) then
                turtle.select(16)
                if not turtle.transferTo(i) then
                    error("Couldn't move an item from slot 16")
                end
            end
        end
    end
end

function inventory.checkInventory()
    -- in the future, i will add the possibility to throw away cobble and other thrash to save trips back to surface
    -- check if last slot has any items
    if turtle.getItemCount(16) >= 1 then
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
        useful_items_counter = 0
    end
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
    useful_items_counter = 0
    movementturnTo(0)
end

return inventory
