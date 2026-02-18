-- inventory.lua

local config = require("config")
local movement = require("movement")
local state = require("state")

local inventory = {}

-- local variables

local thrash_list = config.thrash_list

-- =====================
-- PRIVATE
-- =====================




-- =====================
-- PUBLIC API
-- =====================

-- should be checking if the invrntory is full and if it is, then:
-- 1) try to empty all tharsh_listed items (need to prepare a list of cobblestone, tuff, blackstone, dirst, gravel etc.)
-- 2) if there is no thrash and inventory is full, go back to surface, empty to chest and go back

function inventory.checkInventory()
    -- in the future, i will add the possibility to throw away cobble and other thrash to save trips back to surface
    -- check if last slot has any items
    if turtle.getItemCount(16) >= 1 then
        -- first, try to throw away all the thrash
        if config.empty_thrash then
            local thrash_exists = false
            for i=2, 16 do
                if turtle.getItemDetail(i) then
                    for _, whitelist in ipairs(config.whitelist) do
                        if turtle.getItemDetail(i).name:find(whitelist, 1 ,true) then
                            break
                        end
                        for _, thrash in ipairs(thrash_list) do
                            if turtle.getItemDetail(i).name:find(thrash, 1 ,true) then
                                turtle.select(i)
                                turtle.drop()
                                thrash_exists = true
                            end
                        end
                    end
                end
            end
            turtle.select(1)
            if thrash_exists then
                -- we need to clear the 16th slot if it's not thrash. because otherwise the function will loop
                if turtle.getItemDetail(16) then
                    for i=2, 15 do
                        if not turtle.getItemDetail(i) then
                            turtle.select(16)
                            turtle.transferTo(i)
                            turtle.select(1)
                            break
                        end
                    end
                end
                return
            end
        end

        -- if no thrash was detected, then go back to chest and empty invenotry
        movement.goTo({x=0, y=state.getPosition().y, z=0})
        movement.goTo({x=0, y=0, z=0})
        -- turn to chest
        movement.turnTo(2)
        for i=2, 16 do
            turtle.select(i)
            turtle.drop()
        end
        turtle.select(1)
    end
end

function inventory.emptyInventory()
    -- empty inventory, first slot (coal) included
    movement.goTo({x=0, y=state.getPosition().y, z=0})
    movement.goTo({x=0, y=0, z=0})
    movement.turnTo(2)
    for i=1, 16 do
            turtle.select(i)
            turtle.drop()
    end
    turtle.select(1)
end

return inventory
