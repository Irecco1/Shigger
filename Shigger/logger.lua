-- logger.lua

local logger = {}


-- local variables


-- =====================
-- PRIVATE
-- =====================




-- =====================
-- PUBLIC API
-- =====================

-- saving in Logs.txt some text for later

function logger.log(text)
    local file = fs.open("Logs.txt", "a")
    file.writeLine(text)
    file.close()
end
