-- [[ Vin Hub - Steal an Egg (Sleek Blue UI Edition) ]]

local CoreGui = game:GetService("CoreGui")
local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")

local player = Players.LocalPlayer
local playerGui = player:FindFirstChild("PlayerGui") or CoreGui

-- Remove existing VinHub if already loaded
if playerGui:FindFirstChild("VinHubGui") then
    playerGui.VinHubGui:Destroy()
end

local screenGui = Instance.new("ScreenGui")
screenGui.Name = "VinHubGui"
screenGui.ResetOnSpawn = false
screenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
screenGui.Parent = playerGui

-- [[ Draggable Toggle Button (Logo Icon with Blue Border) ]]
local toggleButton = Instance.new("ImageButton")
toggleButton.Name = "ToggleIcon"
toggleButton.Size = UDim2.new(0, 56, 0, 56)
toggleButton.Position = UDim2.new(0, 30, 0, 150)
toggleButton.BackgroundColor3 = Color3.fromRGB(12, 12, 18)
toggleButton.Image = "rbxassetid://79968435808183"
toggleButton.Parent = screenGui

local uiCornerBtn = Instance.new("UICorner")
uiCornerBtn.CornerRadius = UDim.new(1, 0)
uiCornerBtn.Parent = toggleButton

local uiStrokeBtn = Instance.new("UIStroke")
uiStrokeBtn.Color = Color3.fromRGB(0, 150, 255)
uiStrokeBtn.Thickness = 2.5
uiStrokeBtn.Parent = toggleButton

-- [[ Main Hub Window ]]
local mainFrame = Instance.new("Frame")
mainFrame.Name = "MainFrame"
mainFrame.Size = UDim2.new(0, 460, 0, 310)
mainFrame.Position = UDim2.new(0.5, -230, 0.5, -155)
mainFrame.BackgroundColor3 = Color3.fromRGB(14, 14, 22)
mainFrame.BorderSizePixel = 0
mainFrame.Visible = false
mainFrame.Parent = screenGui

local uiCornerMain = Instance.new("UICorner")
uiCornerMain.CornerRadius = UDim.new(0, 10)
uiCornerMain.Parent = mainFrame

-- Slicker Outer Blue Border
local uiStrokeMain = Instance.new("UIStroke")
uiStrokeMain.Color = Color3.fromRGB(0, 136, 255)
uiStrokeMain.Thickness = 2
uiStrokeMain.Parent = mainFrame

-- Top Bar / Header
local topBar = Instance.new("Frame")
topBar.Name = "TopBar"
topBar.Size = UDim2.new(1, 0, 0, 42)
topBar.BackgroundColor3 = Color3.fromRGB(20, 20, 30)
topBar.BorderSizePixel = 0
topBar.Parent = mainFrame

local uiCornerTop = Instance.new("UICorner")
uiCornerTop.CornerRadius = UDim.new(0, 10)
uiCornerTop.Parent = topBar

-- Fix bottom corners of top bar to make it flush
local topBarCover = Instance.new("Frame")
topBarCover.Size = UDim2.new(1, 0, 0, 6)
topBarCover.Position = UDim2.new(0, 0, 1, -6)
topBarCover.BackgroundColor3 = Color3.fromRGB(20, 20, 30)
topBarCover.BorderSizePixel = 0
topBarCover.Parent = topBar

local titleLabel = Instance.new("TextLabel")
titleLabel.Size = UDim2.new(1, -20, 1, 0)
titleLabel.Position = UDim2.new(0, 14, 0, 0)
titleLabel.BackgroundTransparency = 1
titleLabel.Font = Enum.Font.GothamBold
titleLabel.Text = "VIN HUB  |  Steal an Egg"
titleLabel.TextColor3 = Color3.fromRGB(0, 170, 255)
titleLabel.TextSize = 15
titleLabel.TextXAlignment = Enum.TextXAlignment.Left
titleLabel.Parent = topBar

-- Content Container
local contentContainer = Instance.new("ScrollingFrame")
contentContainer.Size = UDim2.new(1, -24, 1, -58)
contentContainer.Position = UDim2.new(0, 12, 0, 48)
contentContainer.BackgroundTransparency = 1
contentContainer.BorderSizePixel = 0
contentContainer.CanvasSize = UDim2.new(0, 0, 0, 0)
contentContainer.AutomaticCanvasSize = Enum.AutomaticSize.Y
contentContainer.ScrollBarThickness = 3
contentContainer.ScrollBarImageColor3 = Color3.fromRGB(0, 150, 255)
contentContainer.Parent = mainFrame

local uiLayout = Instance.new("UIListLayout")
uiLayout.Padding = UDim.new(0, 8)
uiLayout.SortOrder = Enum.SortOrder.LayoutOrder
uiLayout.Parent = contentContainer

-- Helper function to create slick buttons with subtle blue outlines
function createButton(name, callback)
    local btn = Instance.new("TextButton")
    btn.Size = UDim2.new(1, 0, 0, 36)
    btn.BackgroundColor3 = Color3.fromRGB(22, 22, 35)
    btn.Font = Enum.Font.GothamMedium
    btn.Text = "   " .. name
    btn.TextColor3 = Color3.fromRGB(230, 230, 230)
    btn.TextSize = 13
    btn.TextXAlignment = Enum.TextXAlignment.Left
    btn.Parent = contentContainer
    
    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0, 6)
    corner.Parent = btn
    
    local stroke = Instance.new("UIStroke")
    stroke.Color = Color3.fromRGB(35, 55, 90)
    stroke.Thickness = 1
    stroke.Parent = btn
    
    -- Hover effect
    btn.MouseEnter:Connect(function()
        stroke.Color = Color3.fromRGB(0, 150, 255)
    end)
    btn.MouseLeave:Connect(function()
        stroke.Color = Color3.fromRGB(35, 55, 90)
    end)
    
    btn.MouseButton1Click:Connect(function()
        pcall(callback)
    end)
end

-- Steal an Egg Options
createButton("Auto Farm Eggs / Collect", function()
    print("Vin Hub: Auto Farm activated!")
end)

createButton("Instant Egg Hatch", function()
    print("Vin Hub: Instant Hatch activated!")
end)

createButton("Speed Boost (Fast Escape)", function()
    if player.Character and player.Character:FindFirstChild("Humanoid") then
        player.Character.Humanoid.WalkSpeed = 32
        print("Vin Hub: Speed set to 32!")
    end
end)

createButton("Infinite Jump / Fly Mode", function()
    print("Vin Hub: Jump toggled!")
end)

-- [[ Toggle UI Visibility Logic ]]
local isOpen = false
toggleButton.MouseButton1Click:Connect(function()
    isOpen = not isOpen
    mainFrame.Visible = isOpen
end)

-- [[ Draggable Functionality for the Toggle Icon ]]
local dragging, dragInput, dragStart, startPos

toggleButton.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
        dragging = true
        dragStart = input.Position
        startPos = toggleButton.Position
        
        input.Changed:Connect(function()
            if input.UserInputState == Enum.UserInputState.End then
                dragging = false
            end
        end)
    end
end)

toggleButton.InputChanged:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch then
        dragInput = input
    end
end)

UserInputService.InputChanged:Connect(function(input)
    if input == dragInput and dragging then
        local delta = input.Position - dragStart
        toggleButton.Position = UDim2.new(
            startPos.X.Scale, 
            startPos.X.Offset + delta.X, 
            startPos.Y.Scale, 
            startPos.Y.Offset + delta.Y
        )
    end
end)
