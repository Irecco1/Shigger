local files = {
    "main.lua",
    "movement.lua",
    "inventory.lua",
    "planner.lua",
    "scanner.lua",
    "fuel.lua",
    "state.lua",
    "config.lua",
    "digger.lua"
}

local base = "https://raw.githubusercontent.com/Irecco1/Shigger/refs/heads/main/Shigger/"

for _, file in ipairs(files) do
    print("Downloading " .. file)
    shell.run("wget", base .. file, file)
end

print("Installation complete.")
