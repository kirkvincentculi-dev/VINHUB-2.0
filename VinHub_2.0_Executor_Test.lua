--[[
    VinHub 2.0 | Standalone client-side anti-cheat TEST HARNESS
    Authorized testing only, in a private server/game you own or have permission to test.
    Paste into your executor. No HttpGet, remote loader, anti-cheat bypass, or stealth logic.
    Client-side changes may be rejected/overwritten by server-authoritative systems.
]]

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local CoreGui = game:GetService("CoreGui")
local Workspace = game:GetService("Workspace")
local LocalPlayer = Players.LocalPlayer

local old = (gethui and gethui() or CoreGui):FindFirstChild("VinHub20")
if old then old:Destroy() end

local parent = (gethui and gethui()) or CoreGui
local gui = Instance.new("ScreenGui")
gui.Name = "VinHub20"
gui.ResetOnSpawn = false
gui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
gui.Parent = parent

local BLUE = Color3.fromRGB(0, 105, 255)
local CYAN = Color3.fromRGB(0, 190, 255)
local DARK = Color3.fromRGB(8, 12, 22)
local PANEL = Color3.fromRGB(17, 24, 38)
local WHITE = Color3.fromRGB(245, 248, 255)
local LOGO_IMAGE = "" -- Set to "rbxassetid://YOUR_UPLOADED_LOGO_ID" after uploading your logo.
local GRAY = Color3.fromRGB(155, 170, 195)

local function round(obj, px)
    local c = Instance.new("UICorner")
    c.CornerRadius = UDim.new(0, px or 9)
    c.Parent = obj
end

local function outline(obj, color, thickness)
    local s = Instance.new("UIStroke")
    s.Color = color or BLUE
    s.Thickness = thickness or 1.5
    s.Parent = obj
end

local function make(class, props, parentObj)
    local obj = Instance.new(class)
    for k, v in pairs(props) do obj[k] = v end
    obj.Parent = parentObj
    return obj
end

local function getCharacter()
    local char = LocalPlayer.Character
    if not char then return end
    local hum = char:FindFirstChildOfClass("Humanoid")
    local root = char:FindFirstChild("HumanoidRootPart")
    return char, hum, root
end

local savedSpawn
local function captureSpawn(char)
    task.wait(0.25)
    local root = char:FindFirstChild("HumanoidRootPart")
    if root then savedSpawn = root.CFrame end
end
if LocalPlayer.Character then task.spawn(captureSpawn, LocalPlayer.Character) end
LocalPlayer.CharacterAdded:Connect(captureSpawn)

local espOn, aimOn = false, false
local espObjects = {}
local selectedPlayer
local aimConnection
local spinPower = 0
local musicSound

-- Floating draggable launcher. Replace this text mark with your uploaded logo image if desired.
local launcher = make("ImageButton", {
    Name = "VinHubLauncher", Size = UDim2.fromOffset(62, 62),
    Position = UDim2.new(0, 24, 0.42, 0), BackgroundColor3 = DARK,
    Image = LOGO_IMAGE, AutoButtonColor = true
}, gui)
if LOGO_IMAGE == "" then
    make("TextLabel", {BackgroundTransparency = 1, Size = UDim2.fromScale(1, 1),
        Text = "V", TextColor3 = CYAN, TextSize = 35, Font = Enum.Font.GothamBlack}, launcher)
end
round(launcher, 18)
outline(launcher, BLUE, 2)

local window = make("Frame", {
    Name = "Main", Size = UDim2.fromOffset(350, 490),
    Position = UDim2.new(0, 100, 0.5, -245),
    BackgroundColor3 = DARK, Visible = false
}, gui)
round(window, 14)
outline(window, BLUE, 2)

local header = make("Frame", {
    Size = UDim2.new(1, 0, 0, 52), BackgroundColor3 = Color3.fromRGB(5, 30, 67)
}, window)
round(header, 14)
make("TextLabel", {
    BackgroundTransparency = 1, Position = UDim2.fromOffset(14, 0),
    Size = UDim2.new(1, -65, 1, 0), Text = "VINHUB 2.0",
    TextColor3 = WHITE, Font = Enum.Font.GothamBlack,
    TextSize = 21, TextXAlignment = Enum.TextXAlignment.Left
}, header)
local close = make("TextButton", {
    Size = UDim2.fromOffset(34, 32), Position = UDim2.new(1, -42, 0, 10),
    BackgroundColor3 = PANEL, Text = "×", TextColor3 = WHITE,
    Font = Enum.Font.GothamBold, TextSize = 23
}, header)
round(close, 8)
close.MouseButton1Click:Connect(function() window.Visible = false end)
launcher.MouseButton1Click:Connect(function() window.Visible = not window.Visible end)

-- Drag launcher and window header on mouse or touch.
local function draggable(handle, target)
    local dragging, startInput, startPos
    handle.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            dragging, startInput, startPos = true, input, target.Position
            input.Changed:Connect(function()
                if input.UserInputState == Enum.UserInputState.End then dragging = false end
            end)
        end
    end)
    UserInputService.InputChanged:Connect(function(input)
        if dragging and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
            local delta = input.Position - startInput.Position
            target.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X,
                startPos.Y.Scale, startPos.Y.Offset + delta.Y)
        end
    end)
end
draggable(launcher, launcher)
draggable(header, window)

local scroll = make("ScrollingFrame", {
    Position = UDim2.fromOffset(9, 61), Size = UDim2.new(1, -18, 1, -70),
    BackgroundTransparency = 1, BorderSizePixel = 0,
    ScrollBarThickness = 4, ScrollBarImageColor3 = BLUE,
    CanvasSize = UDim2.new(), AutomaticCanvasSize = Enum.AutomaticSize.Y
}, window)
local list = make("UIListLayout", {
    Padding = UDim.new(0, 6), SortOrder = Enum.SortOrder.LayoutOrder
}, scroll)

local function section(text)
    make("TextLabel", {
        Size = UDim2.new(1, -5, 0, 24), BackgroundTransparency = 1,
        Text = string.upper(text), TextColor3 = CYAN,
        Font = Enum.Font.GothamBold, TextSize = 12,
        TextXAlignment = Enum.TextXAlignment.Left
    }, scroll)
end

local function newRow(height)
    local r = make("Frame", {
        Size = UDim2.new(1, -5, 0, height or 40),
        BackgroundColor3 = PANEL
    }, scroll)
    round(r, 8)
    return r
end

local function rowLabel(r, text, width)
    make("TextLabel", {
        Position = UDim2.fromOffset(9, 0), Size = UDim2.new(0, width or 150, 1, 0),
        BackgroundTransparency = 1, Text = text, TextColor3 = WHITE,
        Font = Enum.Font.GothamMedium, TextSize = 12,
        TextXAlignment = Enum.TextXAlignment.Left
    }, r)
end

local function button(r, text, callback, width)
    local b = make("TextButton", {
        Size = UDim2.fromOffset(width or 70, 29),
        Position = UDim2.new(1, -(width or 70) - 7, 0.5, -14),
        BackgroundColor3 = BLUE, Text = text, TextColor3 = WHITE,
        Font = Enum.Font.GothamBold, TextSize = 11
    }, r)
    round(b, 7)
    b.MouseButton1Click:Connect(callback)
    return b
end

local function numberRow(title, initial, min, max, callback)
    local r = newRow(42)
    rowLabel(r, title, 155)
    local box = make("TextBox", {
        Size = UDim2.fromOffset(75, 28), Position = UDim2.new(1, -83, 0.5, -14),
        BackgroundColor3 = DARK, TextColor3 = WHITE, PlaceholderColor3 = GRAY,
        Font = Enum.Font.Gotham, TextSize = 12, Text = tostring(initial),
        ClearTextOnFocus = false
    }, r)
    round(box, 6)
    box.FocusLost:Connect(function()
        local n = tonumber(box.Text)
        if not n then box.Text = tostring(initial); return end
        n = math.clamp(n, min, max)
        box.Text = tostring(n)
        callback(n)
    end)
end

local function toggleRow(title, initial, callback)
    local state = initial
    local r = newRow(40)
    rowLabel(r, title, 210)
    local b
    b = button(r, state and "ON" or "OFF", function()
        state = not state
        b.Text = state and "ON" or "OFF"
        b.BackgroundColor3 = state and Color3.fromRGB(0, 145, 95) or BLUE
        callback(state)
    end, 62)
    if state then b.BackgroundColor3 = Color3.fromRGB(0, 145, 95) end
end

section("Movement tests")
numberRow("Speed  (0–10000)", 16, 0, 10000, function(n)
    local _, hum = getCharacter()
    if hum then hum.WalkSpeed = n end
end)
numberRow("Jump Power", 50, 0, 10000, function(n)
    local _, hum = getCharacter()
    if hum then hum.UseJumpPower = true; hum.JumpPower = n end
end)
numberRow("Scale  (0.1–10)", 1, 0.1, 10, function(n)
    local char = LocalPlayer.Character
    if char then pcall(function() char:ScaleTo(n) end) end
end)
numberRow("Spin  (0–10)", 0, 0, 10, function(n)
    spinPower = n
    local _, _, root = getCharacter()
    if root and n == 0 then root.AssemblyAngularVelocity = Vector3.zero end
end)
toggleRow("Spin continuously", false, function(on)
    spinPower = on and 5 or 0
    if not on then
        local _, _, root = getCharacter()
        if root then root.AssemblyAngularVelocity = Vector3.zero end
    end
end)

local spinConnection = RunService.Heartbeat:Connect(function()
    if spinPower > 0 then
        local _, _, root = getCharacter()
        if root then root.AssemblyAngularVelocity = Vector3.new(0, spinPower * 8, 0) end
    end
end)

section("Visual-only tests")
local function clearESP()
    for _, obj in pairs(espObjects) do
        if obj then obj:Destroy() end
    end
    table.clear(espObjects)
end
local function refreshESP()
    clearESP()
    if not espOn then return end
    for _, target in ipairs(Players:GetPlayers()) do
        if target ~= LocalPlayer and target.Character then
            local h = Instance.new("Highlight")
            h.Name = "VinHub_LocalESP"
            h.FillColor = CYAN
            h.OutlineColor = WHITE
            h.FillTransparency = 0.72
            h.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop
            h.Adornee = target.Character
            h.Parent = gui
            espObjects[target] = h
        end
    end
end
toggleRow("ESP  [LOCAL VISUAL]", false, function(on)
    espOn = on
    refreshESP()
end)

section("Player selection")
local selectedText = make("TextLabel", {
    Size = UDim2.new(1, -5, 0, 24), BackgroundTransparency = 1,
    Text = "Selected: none", TextColor3 = WHITE,
    Font = Enum.Font.Gotham, TextSize = 12,
    TextXAlignment = Enum.TextXAlignment.Left
}, scroll)

local playerBox = make("Frame", {
    Size = UDim2.new(1, -5, 0, 110), BackgroundColor3 = PANEL
}, scroll)
round(playerBox, 8)
local playerScroll = make("ScrollingFrame", {
    Position = UDim2.fromOffset(5, 5), Size = UDim2.new(1, -10, 1, -10),
    BackgroundTransparency = 1, BorderSizePixel = 0,
    ScrollBarThickness = 3, AutomaticCanvasSize = Enum.AutomaticSize.Y,
    CanvasSize = UDim2.new()
}, playerBox)
make("UIListLayout", {Padding = UDim.new(0, 4)}, playerScroll)

local function rebuildPlayers()
    for _, child in ipairs(playerScroll:GetChildren()) do
        if child:IsA("TextButton") then child:Destroy() end
    end
    for _, target in ipairs(Players:GetPlayers()) do
        if target ~= LocalPlayer then
            local b = make("TextButton", {
                Size = UDim2.new(1, -3, 0, 27), BackgroundColor3 = Color3.fromRGB(12, 47, 82),
                Text = target.DisplayName .. "  (@" .. target.Name .. ")",
                TextColor3 = WHITE, Font = Enum.Font.Gotham, TextSize = 11
            }, playerScroll)
            round(b, 6)
            b.MouseButton1Click:Connect(function()
                selectedPlayer = target
                selectedText.Text = "Selected: " .. target.Name
            end)
        end
    end
end
rebuildPlayers()
Players.PlayerAdded:Connect(function() task.wait(0.2); rebuildPlayers(); refreshESP() end)
Players.PlayerRemoving:Connect(function(p)
    if selectedPlayer == p then selectedPlayer = nil; selectedText.Text = "Selected: none" end
    task.wait()
    rebuildPlayers()
    refreshESP()
end)

toggleRow("Aim camera at selected", false, function(on)
    aimOn = on
    if aimConnection then aimConnection:Disconnect(); aimConnection = nil end
    if on then
        aimConnection = RunService.RenderStepped:Connect(function()
            if not selectedPlayer or not selectedPlayer.Character then return end
            local targetRoot = selectedPlayer.Character:FindFirstChild("HumanoidRootPart")
            local camera = Workspace.CurrentCamera
            if targetRoot and camera then
                camera.CFrame = CFrame.lookAt(camera.CFrame.Position, targetRoot.Position)
            end
        end)
    end
end)

section("Teleport tests  [CLIENT REQUEST]")
local spawnRow = newRow(40)
rowLabel(spawnRow, "Return to saved spawn", 190)
button(spawnRow, "TEST", function()
    local _, _, root = getCharacter()
    if root and savedSpawn then root.CFrame = savedSpawn end
end)

local targetRow = newRow(40)
rowLabel(targetRow, "Teleport to selected", 190)
button(targetRow, "TEST", function()
    local _, _, root = getCharacter()
    local targetRoot = selectedPlayer and selectedPlayer.Character and selectedPlayer.Character:FindFirstChild("HumanoidRootPart")
    if root and targetRoot then root.CFrame = targetRoot.CFrame * CFrame.new(3, 0, 0) end
end)

section("Music  [LOCAL]")
local tracks = {
    {"Mthu - It's Like I'm Not Even Here (Slowed) [Instrumental]", "rbxassetid://0"},
    {"mthu - it's like i'm not even here", "rbxassetid://0"},
    {"Nope your too late i already died", "rbxassetid://0"},
}
for _, track in ipairs(tracks) do
    local r = newRow(42)
    rowLabel(r, track[1], 235)
    button(r, "PLAY", function()
        if musicSound then musicSound:Stop(); musicSound:Destroy(); musicSound = nil end
        if track[2] == "rbxassetid://0" then
            warn("Upload this audio to Roblox and replace the placeholder SoundId in the script.")
            return
        end
        musicSound = Instance.new("Sound")
        musicSound.SoundId = track[2]
        musicSound.Volume = 0.5
        musicSound.Looped = true
        musicSound.Parent = Workspace.CurrentCamera
        musicSound:Play()
    end, 58)
end
local stopRow = newRow(38)
rowLabel(stopRow, "Stop music", 150)
button(stopRow, "STOP", function()
    if musicSound then musicSound:Stop(); musicSound:Destroy(); musicSound = nil end
end, 60)

LocalPlayer.CharacterAdded:Connect(function()
    task.wait(1)
    refreshESP()
end)

-- Clean up active loops when the GUI is removed.
gui.Destroying:Connect(function()
    if spinConnection then spinConnection:Disconnect() end
    if aimConnection then aimConnection:Disconnect() end
    clearESP()
    if musicSound then musicSound:Destroy() end
end)

print("VinHub 2.0 test harness loaded. Use only in an authorized private test session.")
