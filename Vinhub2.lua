
local HttpService = game:GetService("HttpService")

local CONFIG_URL = "https://raw.githubusercontent.com/kirkvincentculi-dev/VINHUB-2.0/refs/heads/main/VinHub2Config.lua"

local SERVER_URL = "https://raw.githubusercontent.com/kirkvincentculi-dev/VINHUB-2.0/refs/heads/main/VinHub2Server.lua"

-- Download both scripts
local configSource = HttpService:GetAsync(CONFIG_URL)
local serverSource = HttpService:GetAsync(SERVER_URL)

-- Remove the ModuleScript return statement
local configBody = configSource:gsub("%s*return Config%s*$", "")

-- Replace the original require() with the config code
local oldRequire = 'local Config = require(ReplicatedStorage:WaitForChild("VinHub2Config"))'

local startPos, endPos = string.find(serverSource, oldRequire, 1, true)

assert(startPos, "Config require statement not found")

local combinedSource =
    string.sub(serverSource, 1, startPos - 1)
    .. configBody
    .. "\n"
    .. string.sub(serverSource, endPos + 1)

-- Compile and execute
local compiled, errorMessage = loadstring(combinedSource)

if not compiled then
    error(errorMessage)
end

compiled()
