-- inventory.lua

local config = require("config")
local state = require("state")
local logger = require("logger")

local inventory = {}

-- local variables

local thrash_list = config.thrash_list
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


function inventory.checkInventory()
    -- in the future, i will add the possibility to throw away cobble and other thrash to save trips back to surface
    -- check if last slot has any items
    if turtle.getItemCount(16) >= 1 then
        if config.debug_logger then logger.log("Inventory: slot 16 item name: "..turtle.getItemDetail(16).name) end -- LOGGING INFO - DEBUG OPTION
        -- first, try to throw away all the thrash
        if config.empty_thrash then
            for i=2, 16 do
                if config.debug_logger then logger.log("Inventory: looking for thrash in slot "..i) end -- LOGGING INFO - DEBUG OPTION
                for _, thrash in ipairs(thrash_list) do
                    local item_name = turtle.getItemDetail(i).name
                    if item_name == thrash then
                        if config.debug_logger then logger.log("Inventory: found thrash "..item_name..", while looking for tag: "..thrash) end -- LOGGING INFO - DEBUG OPTION
                        turtle.select(i)
                        turtle.drop()
                        break
                    end
                end
            end
            turtle.select(1)
            -- we need to clear the 16th slot if it's not thrash. because otherwise the function will loop
            for i=2, 15 do
                if not turtle.getItemDetail(i) and turtle.getItemDetail(16) then
                    turtle.select(16)
                    if not turtle.transferTo(i) then
                        error("Couldn't move an item from slot 16")
                    end
                    turtle.select(1)
                    return
                end
            end
        end

        -- if no thrash was detected, then go back to chest and empty invenotry
        movementgoTo({x=0, y=state.getPosition().y+5, z=0})
        movementgoTo({x=0, y=0, z=0})
        -- turn to chest
        movementturnTo(2)
        for i=2, 16 do
            turtle.select(i)
            turtle.drop()
        end
        turtle.select(1)
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
    movementturnTo(0)
end

return inventory

