```lua
-- Moonlight🌙✨PvB 主程式
-- GitHub: https://github.com/你的用戶名/Moonlight-PvB-Script

local MoonlightPvB = {}

-- 服務引用
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")
local CoreGui = game:GetService("CoreGui")

-- 應用程式狀態
MoonlightPvB.AppOpen = false
MoonlightPvB.AutoJumpEnabled = false
MoonlightPvB.JumpInterval = 5

-- 初始化函數
function MoonlightPvB:Init()
    local player = Players.LocalPlayer
    if not player then
        player = Players.PlayerAdded:Wait()
    end
    
    print("🌙✨ Moonlight PvB 應用程式已載入！")
    print("📱 點擊月亮圖標開啟/關閉介面")
    print("⚡ 快捷鍵: F1開關介面, F2開關自動跳躍")
    
    -- 創建應用程式圖標
    self:CreateAppIcon()
    
    -- 設置快捷鍵
    self:SetupKeybinds()
end

-- 創建月亮應用程式圖標
function MoonlightPvB:CreateAppIcon()
    local screenGui = Instance.new("ScreenGui")
    screenGui.Name = "MoonlightPvB_AppIcon"
    screenGui.ResetOnSpawn = false
    screenGui.Parent = CoreGui
    
    local moonContainer = Instance.new("Frame")
    moonContainer.Name = "MoonAppContainer"
    moonContainer.Size = UDim2.new(0, 70, 0, 70)
    moonContainer.Position = UDim2.new(0, 20, 0.5, -35)
    moonContainer.BackgroundColor3 = Color3.fromRGB(30, 30, 45)
    moonContainer.BackgroundTransparency = 0.2
    moonContainer.BorderSizePixel = 0
    moonContainer.Parent = screenGui
    
    local UICorner = Instance.new("UICorner")
    UICorner.CornerRadius = UDim.new(1, 0)
    UICorner.Parent = moonContainer
    
    local moonButton = Instance.new("TextButton")
    moonButton.Name = "MoonAppIcon"
    moonButton.Size = UDim2.new(1, 0, 1, 0)
    moonButton.BackgroundTransparency = 1
    moonButton.Text = "🌙"
    moonButton.TextColor3 = Color3.fromRGB(255, 255, 200)
    moonButton.TextSize = 35
    moonButton.Font = Enum.Font.GothamBold
    moonButton.Parent = moonContainer
    
    moonButton.MouseEnter:Connect(function()
        local tween = TweenService:Create(
            moonContainer,
            TweenInfo.new(0.3, Enum.EasingStyle.Quad, Enum.EasingDirection.Out),
            {BackgroundTransparency = 0, Size = UDim2.new(0, 75, 0, 75)}
        )
        tween:Play()
    end)
    
    moonButton.MouseLeave:Connect(function()
        local tween = TweenService:Create(
            moonContainer,
            TweenInfo.new(0.3, Enum.EasingStyle.Quad, Enum.EasingDirection.Out),
            {BackgroundTransparency = 0.2, Size = UDim2.new(0, 70, 0, 70)}
        )
        tween:Play()
    end)
    
    moonButton.MouseButton1Click:Connect(function()
        self:ToggleMainUI()
    end)
    
    self:MakeDraggable(moonContainer)
    self.AppIcon = moonContainer
    self.ScreenGui = screenGui
end

-- 創建主介面
function MoonlightPvB:CreateMainUI()
    if self.MainUI then
        self.MainUI:Destroy()
    end
    
    local mainFrame = Instance.new("Frame")
    mainFrame.Name = "MoonlightMainUI"
    mainFrame.Size = UDim2.new(0, 400, 0, 500)
    mainFrame.Position = UDim2.new(0.5, -200, 0.5, -250)
    mainFrame.BackgroundColor3 = Color3.fromRGB(20, 20, 30)
    mainFrame.BorderSizePixel = 0
    mainFrame.Visible = false
    mainFrame.Parent = self.ScreenGui
    
    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0, 12)
    corner.Parent = mainFrame
    
    local titleBar = Instance.new("Frame")
    titleBar.Size = UDim2.new(1, 0, 0, 50)
    titleBar.BackgroundColor3 = Color3.fromRGB(75, 0, 130)
    titleBar.BorderSizePixel = 0
    titleBar.Parent = mainFrame
    
    local titleCorner = Instance.new("UICorner")
    titleCorner.CornerRadius = UDim.new(0, 12)
    titleCorner.Parent = titleBar
    
    local title = Instance.new("TextLabel")
    title.Size = UDim2.new(1, -60, 1, 0)
    title.BackgroundTransparency = 1
    title.Text = "🌙✨ Moonlight PvB"
    title.TextColor3 = Color3.fromRGB(255, 255, 255)
    title.TextSize = 20
    title.Font = Enum.Font.GothamBold
    title.TextXAlignment = Enum.TextXAlignment.Left
    title.Parent = titleBar
    
    local titlePadding = Instance.new("UIPadding")
    titlePadding.PaddingLeft = UDim.new(0, 15)
    titlePadding.Parent = title
    
    local closeButton = Instance.new("TextButton")
    closeButton.Size = UDim2.new(0, 40, 0, 40)
    closeButton.Position = UDim2.new(1, -45, 0, 5)
    closeButton.BackgroundColor3 = Color3.fromRGB(200, 50, 50)
    closeButton.Text = "×"
    closeButton.TextColor3 = Color3.fromRGB(255, 255, 255)
    closeButton.TextSize = 25
    closeButton.Font = Enum.Font.GothamBold
    closeButton.Parent = titleBar
    
    local closeCorner = Instance.new("UICorner")
    closeCorner.CornerRadius = UDim.new(1, 0)
    closeCorner.Parent = closeButton
    
    closeButton.MouseButton1Click:Connect(function()
        self:ToggleMainUI()
    end)
    
    local content = Instance.new("Frame")
    content.Size = UDim2.new(1, -20, 1, -70)
    content.Position = UDim2.new(0, 10, 0, 60)
    content.BackgroundTransparency = 1
    content.Parent = mainFrame
    
    self:CreatePredictionSection(content)
    self:CreateAutoFarmSection(content)
    self:CreateStatusSection(content)
    
    self:MakeDraggable(titleBar, mainFrame)
    self.MainUI = mainFrame
end

-- 種子預測區域
function MoonlightPvB:CreatePredictionSection(parent)
    local section = Instance.new("Frame")
    section.Size = UDim2.new(1, 0, 0, 180)
    section.BackgroundColor3 = Color3.fromRGB(35, 35, 50)
    section.BorderSizePixel = 0
    section.Parent = parent
    
    local sectionCorner = Instance.new("UICorner")
    sectionCorner.CornerRadius = UDim.new(0, 8)
    sectionCorner.Parent = section
    
    local padding = Instance.new("UIPadding")
    padding.PaddingTop = UDim.new(0, 10)
    padding.PaddingBottom = UDim.new(0, 10)
    padding.PaddingLeft = UDim.new(0, 15)
    padding.PaddingRight = UDim.new(0, 15)
    padding.Parent = section
    
    local title = Instance.new("TextLabel")
    title.Size = UDim2.new(1, 0, 0, 25)
    title.BackgroundTransparency = 1
    title.Text = "🎲 種子預測系統"
    title.TextColor3 = Color3.fromRGB(255, 215, 0)
    title.TextSize = 18
    title.Font = Enum.Font.GothamBold
    title.TextXAlignment = Enum.TextXAlignment.Left
    title.Parent = section
    
    local predictButton = Instance.new("TextButton")
    predictButton.Size = UDim2.new(1, 0, 0, 35)
    predictButton.Position = UDim2.new(0, 0, 0, 30)
    predictButton.BackgroundColor3 = Color3.fromRGB(70, 130, 180)
    predictButton.Text = "預測下5個種子"
    predictButton.TextColor3 = Color3.fromRGB(255, 255, 255)
    predictButton.TextSize = 16
    predictButton.Font = Enum.Font.Gotham
    predictButton.Parent = section
    
    local buttonCorner = Instance.new("UICorner")
    buttonCorner.CornerRadius = UDim.new(0, 6)
    buttonCorner.Parent = predictButton
    
    local seedsFrame = Instance.new("ScrollingFrame")
    seedsFrame.Size = UDim2.new(1, 0, 0, 80)
    seedsFrame.Position = UDim2.new(0, 0, 0, 75)
    seedsFrame.BackgroundColor3 = Color3.fromRGB(25, 25, 35)
    seedsFrame.BorderSizePixel = 0
    seedsFrame.ScrollBarThickness = 5
    seedsFrame.CanvasSize = UDim2.new(0, 0, 0, 0)
    seedsFrame.Parent = section
    
    local seedsCorner = Instance.new("UICorner")
    seedsCorner.CornerRadius = UDim.new(0, 6)
    seedsCorner.Parent = seedsFrame
    
    predictButton.MouseButton1Click:Connect(function()
        self:PredictSeeds(5, seedsFrame)
    end)
end

-- 自動掛機區域
function MoonlightPvB:CreateAutoFarmSection(parent)
    local section = Instance.new("Frame")
    section.Size = UDim2.new(1, 0, 0, 150)
    section.Position = UDim2.new(0, 0, 0, 190)
    section.BackgroundColor3 = Color3.fromRGB(35, 35, 50)
    section.BorderSizePixel = 0
    section.Parent = parent
    
    local sectionCorner = Instance.new("UICorner")
    sectionCorner.CornerRadius = UDim.new(0, 8)
    sectionCorner.Parent = section
    
    local padding = Instance.new("UIPadding")
    padding.PaddingTop = UDim.new(0, 10)
    padding.PaddingBottom = UDim.new(0, 10)
    padding.PaddingLeft = UDim.new(0, 15)
    padding.PaddingRight = UDim.new(0, 15)
    padding.Parent = section
    
    local title = Instance.new("TextLabel")
    title.Size = UDim2.new(1, 0, 0, 25)
    title.BackgroundTransparency = 1
    title.Text = "🤖 自動掛機系統"
    title.TextColor3 = Color3.fromRGB(50, 205, 50)
    title.TextSize = 18
    title.Font = Enum.Font.GothamBold
    title.TextXAlignment = Enum.TextXAlignment.Left
    title.Parent = section
    
    local jumpToggle = Instance.new("TextButton")
    jumpToggle.Size = UDim2.new(1, 0, 0, 40)
    jumpToggle.Position = UDim2.new(0, 0, 0, 30)
    jumpToggle.BackgroundColor3 = Color3.fromRGB(60, 179, 113)
    jumpToggle.Text = "🔄 開啟自動跳躍 (F2)"
    jumpToggle.TextColor3 = Color3.fromRGB(255, 255, 255)
    jumpToggle.TextSize = 16
    jumpToggle.Font = Enum.Font.GothamBold
    jumpToggle.Parent = section
    
    local toggleCorner = Instance.new("UICorner")
    toggleCorner.CornerRadius = UDim.new(0, 6)
    toggleCorner.Parent = jumpToggle
    
    local intervalFrame = Instance.new("Frame")
    intervalFrame.Size = UDim2.new(1, 0, 0, 40)
    intervalFrame.Position = UDim2.new(0, 0, 0, 80)
    intervalFrame.BackgroundTransparency = 1
    intervalFrame.Parent = section
    
    local intervalLabel = Instance.new("TextLabel")
    intervalLabel.Size = UDim2.new(0.6, 0, 1, 0)
    intervalLabel.BackgroundTransparency = 1
    intervalLabel.Text = "跳躍間隔 (秒):"
    intervalLabel.TextColor3 = Color3.fromRGB(200, 200, 200)
    intervalLabel.TextSize = 14
    intervalLabel.TextXAlignment = Enum.TextXAlignment.Left
    intervalLabel.Font = Enum.Font.Gotham
    intervalLabel.Parent = intervalFrame
    
    local intervalBox = Instance.new("TextBox")
    intervalBox.Size = UDim2.new(0.35, 0, 1, 0)
    intervalBox.Position = UDim2.new(0.65, 0, 0, 0)
    intervalBox.BackgroundColor3 = Color3.fromRGB(25, 25, 35)
    intervalBox.TextColor3 = Color3.fromRGB(255, 255, 255)
    intervalBox.Text = "5"
    intervalBox.TextSize = 14
    intervalBox.Font = Enum.Font.Gotham
    intervalBox.Parent = intervalFrame
    
    local boxCorner = Instance.new("UICorner")
    boxCorner.CornerRadius = UDim.new(0, 4)
    boxCorner.Parent = intervalBox
    
    jumpToggle.MouseButton1Click:Connect(function()
        self:ToggleAutoJump()
        if self.AutoJumpEnabled then
            jumpToggle.Text = "✅ 自動跳躍中 (F2)"
            jumpToggle.BackgroundColor3 = Color3.fromRGB(46, 125, 50)
        else
            jumpToggle.Text = "🔄 開啟自動跳躍 (F2)"
            jumpToggle.BackgroundColor3 = Color3.fromRGB(60, 179, 113)
        end
    end)
    
    intervalBox.FocusLost:Connect(function()
        local interval = tonumber(intervalBox.Text)
        if interval and interval >= 1 then
            self.JumpInterval = interval
            print("🕒 跳躍間隔設定為: " .. interval .. " 秒")
        else
            intervalBox.Text = "5"
            self.JumpInterval = 5
        end
    end)
end

-- 狀態顯示區域
function MoonlightPvB:CreateStatusSection(parent)
    local section = Instance.new("Frame")
    section.Size = UDim2.new(1, 0, 0, 80)
    section.Position = UDim2.new(0, 0, 0, 350)
    section.BackgroundColor3 = Color3.fromRGB(35, 35, 50)
    section.BorderSizePixel = 0
    section.Parent = parent
    
    local sectionCorner = Instance.new("UICorner")
    sectionCorner.CornerRadius = UDim.new(0, 8)
    sectionCorner.Parent = section
    
    local padding = Instance.new("UIPadding")
    padding.PaddingTop = UDim.new(0, 10)
    padding.PaddingBottom = UDim.new(0, 10)
    padding.PaddingLeft = UDim.new(0, 15)
    padding.PaddingRight = UDim.new(0, 15)
    padding.Parent = section
    
    local title = Instance.new("TextLabel")
    title.Size = UDim2.new(1, 0, 0, 25)
    title.BackgroundTransparency = 1
    title.Text = "📊 系統狀態"
    title.TextColor3 = Color3.fromRGB(135, 206, 250)
    title.TextSize = 18
    title.Font = Enum.Font.GothamBold
    title.TextXAlignment = Enum.TextXAlignment.Left
    title.Parent = section
    
    local statusText = Instance.new("TextLabel")
    statusText.Size = UDim2.new(1, 0, 1, -25)
    statusText.Position = UDim2.new(0, 0, 0, 25)
    statusText.BackgroundTransparency = 1
    statusText.Text = "自動跳躍: 關閉\n最後更新: 載入中..."
    statusText.TextColor3 = Color3.fromRGB(200, 200, 200)
    statusText.TextSize = 12
    statusText.TextXAlignment = Enum.TextXAlignment.Left
    statusText.TextYAlignment = Enum.TextYAlignment.Top
    statusText.Font = Enum.Font.Gotham
    statusText.Parent = section
    
    self.StatusText = statusText
end

-- 種子預測功能
function MoonlightPvB:PredictSeeds(count, displayFrame)
    for _, child in ipairs(displayFrame:GetChildren()) do
        if child:IsA("Frame") then
            child:Destroy()
        end
    end
    
    local seeds = {}
    local currentTime = tick()
    
    for i = 1, count do
        local seedValue = math.random(1000000, 9999999)
        local hexValue = string.format("%08X", seedValue)
        
        table.insert(seeds, {
            index = i,
            value = seedValue,
            hex = hexValue,
            time = currentTime + (i * 2)
        })
    end
    
    displayFrame.CanvasSize = UDim2.new(0, 0, 0, #seeds * 25)
    
    for i, seed in ipairs(seeds) do
        local seedFrame = Instance.new("Frame")
        seedFrame.Size = UDim2.new(1, 0, 0, 20)
        seedFrame.Position = UDim2.new(0, 0, 0, (i-1)*25)
        seedFrame.BackgroundTransparency = 1
        seedFrame.Parent = displayFrame
        
        local seedText = Instance.new("TextLabel")
        seedText.Size = UDim2.new(1, 0, 1, 0)
        seedText.BackgroundTransparency = 1
        seedText.Text = string.format("種子 #%d: %s (%s)", seed.index, seed.value, seed.hex)
        seedText.TextColor3 = Color3.fromRGB(200, 255, 200)
        seedText.TextSize = 12
        seedText.TextXAlignment = Enum.TextXAlignment.Left
        seedText.Font = Enum.Font.Gotham
        seedText.Parent = seedFrame
    end
    
    self:UpdateStatus("已預測 " .. count .. " 個種子")
end

-- 自動跳躍功能
function MoonlightPvB:ToggleAutoJump()
    self.AutoJumpEnabled = not self.AutoJumpEnabled
    self.JumpInterval = self.JumpInterval or 5
    
    if self.AutoJumpEnabled then
        self:StartAutoJump()
        self:UpdateStatus("自動跳躍已啟用 - 每 " .. self.JumpInterval .. " 秒跳一次")
    else
        self:StopAutoJump()
        self:UpdateStatus("自動跳躍已停用")
    end
end

function MoonlightPvB:StartAutoJump()
    self.LastJumpTime = tick()
    
    self.JumpConnection = RunService.Heartbeat:Connect(function(deltaTime)
        if not self.AutoJumpEnabled then return end
        
        local currentTime = tick()
        if currentTime - self.LastJumpTime >= self.JumpInterval then
            self:PerformJump()
            self.LastJumpTime = currentTime
        end
    end)
end

function MoonlightPvB:StopAutoJump()
    if self.JumpConnection then
        self.JumpConnection:Disconnect()
        self.JumpConnection = nil
    end
end

function MoonlightPvB:PerformJump()
    local player = Players.LocalPlayer
    if not player then return end
    
    local character = player.Character
    if not character then return end
    
    local humanoid = character:FindFirstChildOfClass("Humanoid")
    if humanoid and humanoid:GetState() ~= Enum.HumanoidStateType.Dead then
        humanoid.Jump = true
    end
end

-- 介面控制
function MoonlightPvB:ToggleMainUI()
    if not self.MainUI then
        self:CreateMainUI()
    end
    
    self.AppOpen = not self.AppOpen
    self.MainUI.Visible = self.AppOpen
    
    if self.AppOpen then
        self:UpdateStatus("介面已開啟")
        print("📱 Moonlight PvB 介面已開啟")
    else
        self:UpdateStatus("介面已關閉")
        print("📱 Moonlight PvB 介面已關閉")
    end
end

function MoonlightPvB:UpdateStatus(message)
    if self.StatusText then
        local jumpStatus = self.AutoJumpEnabled and "開啟" or "關閉"
        local timeText = os.date("%H:%M:%S")
        self.StatusText.Text = string.format("自動跳躍: %s\n最後更新: %s\n%s", jumpStatus, timeText, message)
    end
end

-- 工具函數
function MoonlightPvB:MakeDraggable(dragHandle, mainFrame)
    local dragging = false
    local dragInput, dragStart, startPos
    
    dragHandle.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            dragging = true
            dragStart = input.Position
            startPos = mainFrame.Position
            
            input.Changed:Connect(function()
                if input.UserInputState == Enum.UserInputState.End then
                    dragging = false
                end
            end)
        end
    end)
    
    dragHandle.InputChanged:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseMovement then
            dragInput = input
        end
    end)
    
    UserInputService.InputChanged:Connect(function(input)
        if input == dragInput and dragging then
            local delta = input.Position - dragStart
            mainFrame.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
        end
    end)
end

function MoonlightPvB:SetupKeybinds()
    UserInputService.InputBegan:Connect(function(input, gameProcessed)
        if gameProcessed then return end
        
        if input.KeyCode == Enum.KeyCode.F1 then
            self:ToggleMainUI()
        elseif input.KeyCode == Enum.KeyCode.F2 then
            self:ToggleAutoJump()
        end
    end)
end

-- 啟動應用程式
MoonlightPvB:Init()

return MoonlightPvB
```
