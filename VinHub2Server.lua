-- VinHub 2.0 | server side (applies everything here so other players see it too)
-- Type: Script | Name: VinHub2Server | Parent: ServerScriptService

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local SoundService = game:GetService("SoundService")

local Config = require(ReplicatedStorage:WaitForChild("VinHub2Config"))
local Limits = Config.Limits

local remote = ReplicatedStorage:FindFirstChild("VinHub2Remote")
if not remote then
	remote = Instance.new("RemoteEvent")
	remote.Name = "VinHub2Remote"
	remote.Parent = ReplicatedStorage
end

local state = {} -- [player] = what the panel has set, plus their spawn point
local allowed = {} -- [player] = true if they may use the panel
local lastUse = {} -- [player] = { [action] = time of last use }

--------------------------------------------------------------------------
-- Access: owner, listed admins, and everyone while testing in Studio
--------------------------------------------------------------------------

local function checkAccess(player)
	if Config.AllowEveryone or RunService:IsStudio() then
		return true
	end
	if table.find(Config.AllowedUserIds, player.UserId) then
		return true
	end
	if game.CreatorType == Enum.CreatorType.User then
		return player.UserId == game.CreatorId
	end
	local ok, rank = pcall(function()
		return player:GetRankInGroup(game.CreatorId)
	end)
	return ok and rank == 255
end

--------------------------------------------------------------------------
-- Helpers
--------------------------------------------------------------------------

local function getParts(player)
	local character = player.Character
	if not character then
		return nil
	end
	local humanoid = character:FindFirstChildOfClass("Humanoid")
	local root = character:FindFirstChild("HumanoidRootPart")
	if humanoid and root and humanoid.Health > 0 then
		return character, humanoid, root
	end
	return nil
end

-- how far the root part sits above the soles of the feet
local function feetOffset(character, root)
	local boxCFrame, boxSize = character:GetBoundingBox()
	return root.Position.Y - (boxCFrame.Position.Y - boxSize.Y / 2)
end

-- an upright CFrame on the floor under a character, facing the same way
local function floorFromRoot(character, root)
	local position = root.Position - Vector3.new(0, feetOffset(character, root), 0)
	local look = root.CFrame.LookVector
	local flat = Vector3.new(look.X, 0, look.Z)
	if flat.Magnitude < 0.01 then
		flat = Vector3.new(0, 0, -1)
	end
	return CFrame.lookAt(position, position + flat)
end

local function placeOnFloor(character, root, floorCFrame)
	character:PivotTo(floorCFrame * CFrame.new(0, feetOffset(character, root) + 0.5, 0))
	root.AssemblyLinearVelocity = Vector3.zero
end

local function cooldown(player, key, seconds)
	local uses = lastUse[player]
	if not uses then
		uses = {}
		lastUse[player] = uses
	end
	local now = os.clock()
	if uses[key] and now - uses[key] < seconds then
		return false
	end
	uses[key] = now
	return true
end

local function clampNumber(value, limits)
	if type(value) ~= "number" or value ~= value then
		return nil
	end
	return math.clamp(value, limits.Min, limits.Max)
end

--------------------------------------------------------------------------
-- Scale: speed, jump power, spin, size
--------------------------------------------------------------------------

local function applySpeed(player)
	local _, humanoid = getParts(player)
	local value = state[player] and state[player].Speed
	if humanoid and value then
		humanoid.WalkSpeed = value
	end
end

local function applyJump(player)
	local _, humanoid = getParts(player)
	local value = state[player] and state[player].Jump
	if humanoid and value then
		humanoid.UseJumpPower = true
		humanoid.JumpPower = value
	end
end

local function applySpin(player)
	local _, humanoid, root = getParts(player)
	local value = state[player] and state[player].Spin
	if not (humanoid and value) then
		return
	end
	local spinner = root:FindFirstChild("VinHub2Spin")
	if value <= 0 then
		if spinner then
			spinner:Destroy()
		end
		local attachment = root:FindFirstChild("VinHub2SpinAttachment")
		if attachment then
			attachment:Destroy()
		end
		humanoid.AutoRotate = true
		return
	end
	if not spinner then
		local attachment = Instance.new("Attachment")
		attachment.Name = "VinHub2SpinAttachment"
		attachment.Parent = root
		spinner = Instance.new("AngularVelocity")
		spinner.Name = "VinHub2Spin"
		spinner.Attachment0 = attachment
		spinner.RelativeTo = Enum.ActuatorRelativeTo.World
		spinner.MaxTorque = math.huge
		spinner.Parent = root
	end
	spinner.AngularVelocity = Vector3.new(0, value * Config.SpinPerStep, 0)
	humanoid.AutoRotate = false
end

local SCALE_VALUES = { "BodyHeightScale", "BodyWidthScale", "BodyDepthScale", "HeadScale" }

local function applySize(player)
	local character, humanoid = getParts(player)
	local value = state[player] and state[player].Size
	if not (character and value) then
		return
	end
	local changed = false
	for _, name in ipairs(SCALE_VALUES) do
		local scale = humanoid:FindFirstChild(name)
		if scale and scale:IsA("NumberValue") then
			scale.Value = value
			changed = true
		end
	end
	if not changed then
		character:ScaleTo(value) -- R6 and custom rigs have no scale values
	end
end

--------------------------------------------------------------------------
-- Spawn point + respawn
--------------------------------------------------------------------------

local function spawnFloor(player)
	local saved = state[player] and state[player].Spawn
	if saved then
		return saved
	end
	local pad = player.RespawnLocation or workspace:FindFirstChildWhichIsA("SpawnLocation", true)
	if pad then
		return pad.CFrame * CFrame.new(0, pad.Size.Y / 2, 0)
	end
	return CFrame.new(0, 5, 0)
end

local function onCharacterAdded(player, character)
	local humanoid = character:WaitForChild("Humanoid", 10)
	local root = character:WaitForChild("HumanoidRootPart", 10)
	local settings = state[player]
	if not (settings and humanoid and root) then
		return
	end

	-- remember where they spawned
	settings.Spawn = floorFromRoot(character, root)

	-- bring back whatever the panel had set before they respawned
	if settings.Size and humanoid.RigType == Enum.HumanoidRigType.R15 then
		humanoid:WaitForChild("BodyHeightScale", 3)
	end
	applySpeed(player)
	applyJump(player)
	applySpin(player)
	applySize(player)
end

--------------------------------------------------------------------------
-- Music for everyone (only used when Config.MusicForEveryone is true)
--------------------------------------------------------------------------

local musicSound

local function getMusicSound()
	if not musicSound then
		musicSound = Instance.new("Sound")
		musicSound.Name = "VinHub2Music"
		musicSound.Looped = true
		musicSound.Volume = Config.MusicVolume
		musicSound.Parent = SoundService
	end
	return musicSound
end

--------------------------------------------------------------------------
-- What the client can ask for
--------------------------------------------------------------------------

local handlers = {}

local setters = { Speed = applySpeed, Jump = applyJump, Spin = applySpin, Size = applySize }
for key, apply in pairs(setters) do
	handlers[key] = function(player, value)
		value = clampNumber(value, Limits[key])
		if value then
			state[player][key] = value
			apply(player)
		end
	end
end

function handlers.Spawn(player)
	if not cooldown(player, "Spawn", 0.5) then
		return
	end
	local character, _, root = getParts(player)
	if character then
		placeOnFloor(character, root, spawnFloor(player))
	end
end

function handlers.Teleport(player, userId)
	if type(userId) ~= "number" or userId ~= userId or not cooldown(player, "Teleport", 0.5) then
		return
	end
	local target = Players:GetPlayerByUserId(userId)
	if not target or target == player then
		return
	end
	local character, _, root = getParts(player)
	local targetCharacter, _, targetRoot = getParts(target)
	if not (character and targetCharacter) then
		return
	end
	local _, mySize = character:GetBoundingBox()
	local _, theirSize = targetCharacter:GetBoundingBox()
	local gap = (mySize.Z + theirSize.Z) / 2 + 2 -- land just behind them
	placeOnFloor(character, root, floorFromRoot(targetCharacter, targetRoot) * CFrame.new(0, 0, gap))
end

function handlers.Music(player, index)
	if not Config.MusicForEveryone or not cooldown(player, "Music", 0.3) then
		return
	end
	local sound = getMusicSound()
	if index == 0 then
		sound:Stop()
		return
	end
	local track = type(index) == "number" and Config.Music[index]
	if track and (tonumber(track.Id) or 0) ~= 0 then
		sound:Stop()
		sound.SoundId = "rbxassetid://" .. tostring(track.Id)
		sound:Play()
	end
end

function handlers.MusicVolume(player, value)
	if not Config.MusicForEveryone then
		return
	end
	value = clampNumber(value, { Min = 0, Max = 1 })
	if value then
		getMusicSound().Volume = value
	end
end

remote.OnServerEvent:Connect(function(player, action, value)
	if not allowed[player] or not state[player] then
		return
	end
	local handler = type(action) == "string" and handlers[action]
	if handler then
		handler(player, value)
	end
end)

--------------------------------------------------------------------------
-- Players
--------------------------------------------------------------------------

local function onPlayerAdded(player)
	state[player] = {}
	player.CharacterAdded:Connect(function(character)
		onCharacterAdded(player, character)
	end)
	if player.Character then
		task.spawn(onCharacterAdded, player, player.Character)
	end

	local canUse = checkAccess(player) -- can yield for group games
	if not player.Parent then
		return
	end
	allowed[player] = canUse
	player:SetAttribute("VinHub2Access", canUse)
end

Players.PlayerAdded:Connect(onPlayerAdded)
for _, player in ipairs(Players:GetPlayers()) do
	task.spawn(onPlayerAdded, player)
end

Players.PlayerRemoving:Connect(function(player)
	state[player] = nil
	allowed[player] = nil
	lastUse[player] = nil
end)
