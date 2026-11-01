--[==[
    VinHub 2.0 for Roblox Executors
    Loadstring Compatible Version
]==]

local CoreGui = game:GetService("CoreGui")
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local LocalPlayer = Players.LocalPlayer

-- Prevent duplicate GUIs if executed multiple times
if CoreGui:FindFirstChild("VinHub2_0") then
	CoreGui.VinHub2_0:Destroy()
end

-- Main ScreenGui
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "VinHub2_0"
ScreenGui.Parent = CoreGui
ScreenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling

-- Moveable Toggle Button with Logo
local ToggleButton = Instance.new("ImageButton")
ToggleButton.Name = "ToggleButton"
ToggleButton.Parent = ScreenGui
ToggleButton.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
ToggleButton.BorderSizePixel = 0
ToggleButton.Position = UDim2.new(0.05, 0, 0.1, 0)
ToggleButton.Size = UDim2.new(0, 60, 0, 60)
ToggleButton.Image = "" 
ToggleButton.ScaleType = Enum.ScaleType.Fit
ToggleButton.Active = true
ToggleButton.Draggable = true

local UICornerBtn = Instance.new("UICorner")
UICornerBtn.CornerRadius = UDim.new(0, 12)
UICornerBtn.Parent = ToggleButton

local LogoLabel = Instance.new("TextLabel")
LogoLabel.Parent = ToggleButton
LogoLabel.BackgroundTransparency = 1
LogoLabel.Size = UDim2.new(1, 0, 1, 0)
LogoLabel.Font = Enum.Font.SourceSansBold
LogoLabel.Text = "VinHub"
LogoLabel.TextColor3 = Color3.fromRGB(0, 162, 255)
LogoLabel.TextSize = 14

-- Main Window Frame
local MainFrame = Instance.new("Frame")
MainFrame.Name = "MainFrame"
MainFrame.Parent = ScreenGui
MainFrame.BackgroundColor3 = Color3.fromRGB(25, 25, 30)
MainFrame.BorderSizePixel = 0
MainFrame.Position = UDim2.new(0.15, 0, 0.15, 0)
MainFrame.Size = UDim2.new(0, 480, 0, 380)
MainFrame.Visible = false
MainFrame.Active = true
MainFrame.Draggable = true

local UICornerMain = Instance.new("UICorner")
UICornerMain.CornerRadius = UDim.new(0, 8)
UICornerMain.Parent = MainFrame

-- Header
local Header = Instance.new("Frame")
Header.Parent = MainFrame
Header.BackgroundColor3 = Color3.fromRGB(15, 15, 20)
Header.Size = UDim2.new(1, 0, 0, 40)

local UICornerHeader = Instance.new("UICorner")
UICornerHeader.CornerRadius = UDim.new(0, 8)
UICornerHeader.Parent = Header

local Title = Instance.new("TextLabel")
Title.Parent = Header
Title.BackgroundTransparency = 1
Title.Position = UDim2.new(0.03, 0, 0, 0)
Title.Size = UDim2.new(0.5, 0, 1, 0)
Title.Font = Enum.Font.GothamBold
Title.Text = "VinHub 2.0"
Title.TextColor3 = Color3.fromRGB(255, 255, 255)
Title.TextSize = 18
Title.TextXAlignment = Enum.TextXAlignment.Left

-- Container
local ScrollingContainer = Instance.new("ScrollingFrame")
ScrollingContainer.Parent = MainFrame
ScrollingContainer.BackgroundTransparency = 1
ScrollingContainer.Position = UDim2.new(0, 0, 0, 45)
ScrollingContainer.Size = UDim2.new(1, 0, 1, -45)
ScrollingContainer.CanvasSize = UDim2.new(0, 0, 2.2, 0)
ScrollingContainer.ScrollBarThickness = 6

local UIListLayout = Instance.new("UIListLayout")
UIListLayout.Parent = ScrollingContainer
UIListLayout.HorizontalAlignment = Enum.HorizontalAlignment.Center
UIListLayout.SortOrder = Enum.SortOrder.LayoutOrder
UIListLayout.Padding = UDim.new(0, 8)

-- Toggle Menu Visibility
ToggleButton.MouseButton1Click:Connect(function()
	MainFrame.Visible = not MainFrame.Visible
end)

local function createSectionLabel(text)
	local lbl = Instance.new("TextLabel")
	lbl.Parent = ScrollingContainer
	lbl.BackgroundTransparency = 1
	lbl.Size = UDim2.new(0, 450, 0, 25)
	lbl.Font = Enum.Font.GothamBold
	lbl.Text = text
	lbl.TextColor3 = Color3.fromRGB(0, 162, 255)
	lbl.TextSize = 14
	lbl.TextXAlignment = Enum.TextXAlignment.Left
end

-- 1. Speed Change (0 - 10000)
createSectionLabel("Speed Change (0 - 10000)")
local SpeedBox = Instance.new("TextBox")
SpeedBox.Parent = ScrollingContainer
SpeedBox.BackgroundColor3 = Color3.fromRGB(35, 35, 45)
SpeedBox.Size = UDim2.new(0, 450, 0, 30)
SpeedBox.Font = Enum.Font.Gotham
SpeedBox.PlaceholderText = "Enter speed (0-10000)"
SpeedBox.Text = ""
SpeedBox.TextColor3 = Color3.fromRGB(255, 255, 255)
SpeedBox.TextSize = 14

SpeedBox.FocusLost:Connect(function(enterPressed)
	if enterPressed then
		local val = tonumber(SpeedBox.Text)
		if val and val >= 0 and val <= 10000 then
			if LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("Humanoid") then
				LocalPlayer.Character.Humanoid.WalkSpeed = val
			end
		end
	end
end)

-- 2. Jump Power (0 - 10000)
createSectionLabel("Jump Power (0 - 10000)")
local JumpBox = Instance.new("TextBox")
JumpBox.Parent = ScrollingContainer
JumpBox.BackgroundColor3 = Color3.fromRGB(35, 35, 45)
JumpBox.Size = UDim2.new(0, 450, 0, 30)
JumpBox.Font = Enum.Font.Gotham
JumpBox.PlaceholderText = "Enter jump power (0-10000)"
JumpBox.Text = ""
JumpBox.TextColor3 = Color3.fromRGB(255, 255, 255)
JumpBox.TextSize = 14

JumpBox.FocusLost:Connect(function(enterPressed)
	if enterPressed then
		local val = tonumber(JumpBox.Text)
		if val and val >= 0 and val <= 10000 then
			if LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("Humanoid") then
				LocalPlayer.Character.Humanoid.UseJumpPower = true
				LocalPlayer.Character.Humanoid.JumpPower = val
			end
		end
	end
end)

-- 3. Change Size [FE] (0.1 - 10)
createSectionLabel("Change Size [FE] (0.1 - 10)")
local SizeBox = Instance.new("TextBox")
SizeBox.Parent = ScrollingContainer
SizeBox.BackgroundColor3 = Color3.fromRGB(35, 35, 45)
SizeBox.Size = UDim2.new(0, 450, 0, 30)
SizeBox.Font = Enum.Font.Gotham
SizeBox.PlaceholderText = "Enter scale size (0.1 - 10)"
SizeBox.Text = ""
SizeBox.TextColor3 = Color3.fromRGB(255, 255, 255)
SizeBox.TextSize = 14

SizeBox.FocusLost:Connect(function(enterPressed)
	if enterPressed then
		local val = tonumber(SizeBox.Text)
		if val and val >= 0.1 and val <= 10 then
			local char = LocalPlayer.Character
			if char and char:FindFirstChild("Humanoid") then
				for _, child in ipairs(char:GetChildren()) do
					if child:IsA("BasePart") and child.Name ~= "HumanoidRootPart" then
						child.Size = child.Size * val
					end
				end
			end
		end
	end
end)

-- 4. Spin Speed (0 - 10)
createSectionLabel("Spin Speed (0 - 10)")
local SpinBox = Instance.new("TextBox")
SpinBox.Parent = ScrollingContainer
SpinBox.BackgroundColor3 = Color3.fromRGB(35, 35, 45)
SpinBox.Size = UDim2.new(0, 450, 0, 30)
SpinBox.Font = Enum.Font.Gotham
SpinBox.PlaceholderText = "Enter spin multiplier (0 - 10)"
SpinBox.Text = ""
SpinBox.TextColor3 = Color3.fromRGB(255, 255, 255)
SpinBox.TextSize = 14

local spinning = false
SpinBox.FocusLost:Connect(function(enterPressed)
	if enterPressed then
		local val = tonumber(SpinBox.Text)
		if val then
			local char = LocalPlayer.Character
			local root = char and char:FindFirstChild("HumanoidRootPart")
			if val > 0 and root then
				if not spinning then
					spinning = true
					local bav = Instance.new("BodyAngularVelocity")
					bav.Name = "VinHubSpin"
					bav.MaxTorque = Vector3.new(0, math.huge, 0)
					bav.AngularVelocity = Vector3.new(0, val * 5, 0)
					bav.Parent = root
				else
					if root:FindFirstChild("VinHubSpin") then
						root.VinHubSpin:Destroy()
					end
					spinning = false
				end
			end
		end
	end
end)

-- 5. ESP [VISUAL]
createSectionLabel("ESP [VISUAL]")
local EspButton = Instance.new("TextButton")
EspButton.Parent = ScrollingContainer
EspButton.BackgroundColor3 = Color3.fromRGB(45, 45, 55)
EspButton.Size = UDim2.new(0, 450, 0, 35)
EspButton.Font = Enum.Font.GothamBold
EspButton.Text = "Toggle ESP: OFF"
EspButton.TextColor3 = Color3.fromRGB(255, 255, 255)
EspButton.TextSize = 14

local espEnabled = false
local espFolder = Instance.new("Folder", CoreGui)
espFolder.Name = "VinHubESP"

EspButton.MouseButton1Click:Connect(function()
	espEnabled = not espEnabled
	EspButton.Text = "Toggle ESP: " .. (espEnabled and "ON" or "OFF")
	if not espEnabled then
		espFolder:ClearAllChildren()
	end
end)

RunService.RenderStepped:Connect(function()
	if espEnabled then
		espFolder:ClearAllChildren()
		for _, player in ipairs(Players:GetPlayers()) do
			if player ~= LocalPlayer and player.Character and player.Character:FindFirstChild("HumanoidRootPart") then
				local hrp = player.Character.HumanoidRootPart
				local box = Instance.new("BoxHandleAdornment")
				box.Size = player.Character:GetExtentsSize()
				box.Adornee = hrp
				box.AlwaysOnTop = true
				box.ZIndex = 5
				box.Color3 = Color3.fromRGB(0, 162, 255)
				box.Transparency = 0.5
				box.Parent = espFolder
			end
		end
	end
end)

-- 6. Aimbot
createSectionLabel("Aimbot (Locks onto a player)")
local AimbotButton = Instance.new("TextButton")
AimbotButton.Parent = ScrollingContainer
AimbotButton.BackgroundColor3 = Color3.fromRGB(45, 45, 55)
AimbotButton.Size = UDim2.new(0, 450, 0, 35)
AimbotButton.Font = Enum.Font.GothamBold
AimbotButton.Text = "Toggle Aimbot: OFF"
AimbotButton.TextColor3 = Color3.fromRGB(255, 255, 255)
AimbotButton.TextSize = 14

local aimbotEnabled = false
AimbotButton.MouseButton1Click:Connect(function()
	aimbotEnabled = not aimbotEnabled
	AimbotButton.Text = "Toggle Aimbot: " .. (aimbotEnabled and "ON" or "OFF")
end)

RunService.RenderStepped:Connect(function()
	if aimbotEnabled then
		local camera = workspace.CurrentCamera
		local target = nil
		local shortestDist = math.huge
		for _, player in ipairs(Players:GetPlayers()) do
			if player ~= LocalPlayer and player.Character and player.Character:FindFirstChild("Head") then
				local head = player.Character.Head
				local dist = (head.Position - camera.CFrame.Position).Magnitude
				if dist < shortestDist then
					shortestDist = dist
					target = head
				end
			end
		end
		if target then
			camera.CFrame = CFrame.new(camera.CFrame.Position, target.Position)
		end
	end
end)

-- 7. Go to Spawn
createSectionLabel("Go to Spawn")
local SpawnButton = Instance.new("TextButton")
SpawnButton.Parent = ScrollingContainer
SpawnButton.BackgroundColor3 = Color3.fromRGB(45, 45, 55)
SpawnButton.Size = UDim2.new(0, 450, 0, 35)
SpawnButton.Font = Enum.Font.GothamBold
SpawnButton.Text = "Teleport to Spawn"
SpawnButton.TextColor3 = Color3.fromRGB(255, 255, 255)
SpawnButton.TextSize = 14

SpawnButton.MouseButton1Click:Connect(function()
	local char = LocalPlayer.Character
	if char and char:FindFirstChild("HumanoidRootPart") then
		for _, obj in ipairs(workspace:GetDescendants()) do
			if obj:IsA("SpawnLocation") then
				char.HumanoidRootPart.CFrame = obj.CFrame + Vector3.new(0, 3, 0)
				break
			end
		end
	end
end)

-- 8. Teleport to Player Selection
createSectionLabel("Teleport to Player Selection")
local TpDropdown = Instance.new("TextBox")
TpDropdown.Parent = ScrollingContainer
TpDropdown.BackgroundColor3 = Color3.fromRGB(35, 35, 45)
TpDropdown.Size = UDim2.new(0, 450, 0, 30)
TpDropdown.Font = Enum.Font.Gotham
TpDropdown.PlaceholderText = "Type target player name & press Enter"
TpDropdown.Text = ""
TpDropdown.TextColor3 = Color3.fromRGB(255, 255, 255)
TpDropdown.TextSize = 14

TpDropdown.FocusLost:Connect(function(enterPressed)
	if enterPressed then
		local targetName = TpDropdown.Text:lower()
		for _, player in ipairs(Players:GetPlayers()) do
			if player.Name:lower():sub(1, #targetName) == targetName and player ~= LocalPlayer then
				if player.Character and player.Character:FindFirstChild("HumanoidRootPart") then
					if LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart") then
						LocalPlayer.Character.HumanoidRootPart.CFrame = player.Character.HumanoidRootPart.CFrame
					end
				end
			end
		end
	end
end)

-- 9. Music Selection Handler
createSectionLabel("Music Selection (Enter filename)")
local MusicBox = Instance.new("TextBox")
MusicBox.Parent = ScrollingContainer
MusicBox.BackgroundColor3 = Color3.fromRGB(35, 35, 45)
MusicBox.Size = UDim2.new(0, 450, 0, 30)
MusicBox.Font = Enum.Font.Gotham
MusicBox.PlaceholderText = "e.g., songname"
MusicBox.Text = ""
MusicBox.TextColor3 = Color3.fromRGB(255, 255, 255)
MusicBox.TextSize = 14

MusicBox.FocusLost:Connect(function(enterPressed)
	if enterPressed then
		local songName = MusicBox.Text
		print("Loaded music file reference: " .. songName)
	end
end)

print("VinHub 2.0 Loaded Successfully!")
