if game.PlaceId == 6875469709 or game.PlaceId == 7215881810 then
    local player = game.Players.LocalPlayer
    local playerPart = player.Character and player.Character:WaitForChild("HumanoidRootPart")
    local collectDelay = 0.9
    local currentWorld = player.leaderstats.WORLD.Value

    -- Variables generales
    local autoPetEnabled = false
    local autoFarmEnabled = Instance.new("BoolValue")
    autoFarmEnabled.Value = false
    local espEnabled = false
    local espSize = 1
    local noclipEnabled = false
    local espColor = Color3.fromRGB(0, 170, 255)
    local autoWorld = false

    -- Función shuffle para orbes
    local function shuffle(tbl)
        for i = #tbl, 2, -1 do
            local j = math.random(i)
            tbl[i], tbl[j] = tbl[j], tbl[i]
        end
        return tbl
    end

    -- Desactivar UI vieja si existe
    local function removeOldUI()
        local oldGui = player:FindFirstChild("PlayerGui") and player.PlayerGui:FindFirstChild("StrongestPunchGui")
        if oldGui then oldGui:Destroy() end
        local oldScreenGui = player.PlayerGui:FindFirstChild("DeviceSelectGui")
        if oldScreenGui then oldScreenGui:Destroy() end
    end

    removeOldUI()

    -- Crear menú de selección dispositivo
    local deviceGui = Instance.new("ScreenGui")
    deviceGui.Name = "DeviceSelectGui"
    deviceGui.ResetOnSpawn = false
    deviceGui.Parent = player:WaitForChild("PlayerGui")

    local frame = Instance.new("Frame")
    frame.Size = UDim2.new(0, 300, 0, 150)
    frame.Position = UDim2.new(0.5, -150, 0.5, -75)
    frame.BackgroundColor3 = Color3.fromRGB(25, 25, 25)
    frame.BorderSizePixel = 0
    frame.Parent = deviceGui
    frame.AnchorPoint = Vector2.new(0.5, 0.5)
    frame.Visible = true
    frame.ClipsDescendants = true
    frame.BackgroundTransparency = 0.2
    frame.ZIndex = 10
    frame.Rounded = true

    local title = Instance.new("TextLabel")
    title.Size = UDim2.new(1, 0, 0, 40)
    title.BackgroundTransparency = 1
    title.Text = "Select Your Device"
    title.TextColor3 = Color3.new(1,1,1)
    title.Font = Enum.Font.SourceSansBold
    title.TextSize = 24
    title.Parent = frame

    local pcButton = Instance.new("TextButton")
    pcButton.Size = UDim2.new(0.45, 0, 0, 50)
    pcButton.Position = UDim2.new(0.05, 0, 0.5, -25)
    pcButton.BackgroundColor3 = Color3.fromRGB(0, 120, 255)
    pcButton.Text = "PC"
    pcButton.Font = Enum.Font.SourceSansBold
    pcButton.TextSize = 24
    pcButton.TextColor3 = Color3.new(1,1,1)
    pcButton.Parent = frame
    pcButton.AutoButtonColor = true
    pcButton.AnchorPoint = Vector2.new(0,0.5)
    pcButton.BackgroundTransparency = 0

    local phoneButton = Instance.new("TextButton")
    phoneButton.Size = UDim2.new(0.45, 0, 0, 50)
    phoneButton.Position = UDim2.new(0.5, 0, 0.5, -25)
    phoneButton.BackgroundColor3 = Color3.fromRGB(0, 200, 100)
    phoneButton.Text = "Phone"
    phoneButton.Font = Enum.Font.SourceSansBold
    phoneButton.TextSize = 24
    phoneButton.TextColor3 = Color3.new(1,1,1)
    phoneButton.Parent = frame
    phoneButton.AutoButtonColor = true
    phoneButton.AnchorPoint = Vector2.new(0,0.5)
    phoneButton.BackgroundTransparency = 0

    -- Aquí carga UI PC usando Kavo UI
    local function loadPCUI()
        -- quitar menú
        deviceGui:Destroy()

        -- Cargar Kavo UI Library
        local success, Library = pcall(function()
            return loadstring(game:HttpGet("https://raw.githubusercontent.com/xHeptc/Kavo-UI-Library/main/source.lua"))()
        end)
        if not success or not Library then
            warn("Failed to load Kavo UI Library.")
            return
        end

        local Window = Library.CreateLib("Strongest Punch Simulator Script", "Ocean")

        local MainTab = Window:NewTab("Main")
        local VisualsTab = Window:NewTab("Visuals")
        local PlayerTab = Window:NewTab("Player")
        local InfoTab = Window:NewTab("Info")
        local CreditsTab = Window:NewTab("Credits")

        local MainSection = MainTab:NewSection("Farming Options")

        MainSection:NewToggle("Auto Pet Upgrade", "Automatically upgrade your pet", function(state)
            autoPetEnabled = state
            if autoPetEnabled then
                spawn(function()
                    while autoPetEnabled do
                        local args = { [1] = { [1] = "UpgradeCurrentPet" } }
                        game:GetService("ReplicatedStorage").RemoteEvent:FireServer(unpack(args))
                        wait(0.2)
                    end
                end)
            end
        end)

        MainSection:NewToggle("Undetectable AutoFarm", "Collect orbs without teleporting", function(state)
            autoFarmEnabled.Value = state
        end)

        MainSection:NewButton("Risky AutoFarm (OP)", "Highly effective but risky autofarm", function()
            local args = { [1] = { [1] = "WarpPlrToOtherMap", [2] = "Next" } }
            game:GetService("ReplicatedStorage").RemoteEvent:FireServer(unpack(args))
            wait(1.2)

            local maxOrbs = 80
            local collected = 0

            local orbs = game.Workspace.Map.Stages.Boosts[player.leaderstats.WORLD.Value]:GetChildren()
            shuffle(orbs)
            for _, orb in ipairs(orbs) do
                if collected >= maxOrbs then break end
                for _, part in pairs(orb:GetChildren()) do
                    local ti = part:FindFirstChild("TouchInterest")
                    if ti then
                        firetouchinterest(playerPart, part, 0)
                        firetouchinterest(playerPart, part, 1)
                        collected += 1
                        break
                    end
                end
            end
            wait(0.3)
            player:Kick("Collected Orbs Successfully!")
        end)

        MainSection:NewToggle("Auto World", "Automatically switch worlds", function(state)
            autoWorld = state
            if autoWorld then
                spawn(function()
                    while autoWorld do
                        local args = { [1] = { [1] = "WarpPlrToOtherMap", [2] = "Next" } }
                        game:GetService("ReplicatedStorage").RemoteEvent:FireServer(unpack(args))
                        wait(0.3)
                    end
                end)
            end
        end)

        local PlayerSection = PlayerTab:NewSection("Player Settings")

        PlayerSection:NewLabel("Warning: Noclip may cause crashes while autofarming.")

        PlayerSection:NewToggle("Noclip", "Walk through walls", function(state)
            noclipEnabled = state
        end)

        PlayerSection:NewSlider("Walkspeed", "Change your walking speed", 1000, 16, function(value)
            local char = player.Character
            if char and char:FindFirstChild("Humanoid") then
                char.Humanoid.WalkSpeed = value
            end
        end)

        local VisualsSection = VisualsTab:NewSection("Visual Settings")

        VisualsSection:NewColorPicker("ESP Color", "Pick the color for ESP", espColor, function(color)
            espColor = color
        end)

        VisualsSection:NewSlider("ESP Size", "Adjust the ESP size", 4, 1, function(value)
            espSize = value
        end)

        VisualsSection:NewToggle("Orb ESP", "See orbs through walls", function(state)
            espEnabled = state
            if espEnabled then
                spawn(function()
                    while espEnabled do
                        for _, orb in pairs(game.Workspace.Map.Stages.Boosts[currentWorld]:GetChildren()) do
                            local existingGui = orb:FindFirstChild("BillboardGui")
                            if existingGui then existingGui:Destroy() end
                            local billboardGui = Instance.new("BillboardGui", orb)
                            billboardGui.AlwaysOnTop = true
                            billboardGui.Size = UDim2.new(espSize, 0, espSize, 0)
                            billboardGui.Adornee = orb
                            local frame = Instance.new("Frame", billboardGui)
                            frame.Size = UDim2.new(1, 0, 1, 0)
                            frame.BackgroundColor3 = espColor
                        end
                        wait(0.2)
                    end
                end)
            else
                for _, orb in pairs(game.Workspace.Map.Stages.Boosts[currentWorld]:GetChildren()) do
                    local gui = orb:FindFirstChild("BillboardGui")
                    if gui then gui:Destroy() end
                end
            end
        end)

        local InfoSection = InfoTab:NewSection("Controls")
        InfoSection:NewKeybind("Toggle GUI", "Press to open/close the interface", Enum.KeyCode.F, function()
            Library:ToggleUI()
        end)

        local CreditsSection = CreditsTab:NewSection("Credits")
        CreditsSection:NewLabel("UI Library: Kavo UI Library by xHeptc")
        CreditsSection:NewLabel("Script created by deathgod0784")

        -- Anti idle
        player.Idled:Connect(function()
            local vu = game:GetService("VirtualUser")
            vu:Button2Down(Vector2.new(0, 0), workspace.CurrentCamera.CFrame)
            wait(1)
            vu:Button2Up(Vector2.new(0, 0), workspace.CurrentCamera.CFrame)
        end)

        -- Noclip loop
        game:GetService("RunService").Stepped:Connect(function()
            if noclipEnabled then
                local char = player.Character
                if char and char:FindFirstChild("Humanoid") then
                    char.Humanoid:ChangeState(11)
                end
            end
        end)

        player.leaderstats.WORLD.Changed:Connect(function()
            currentWorld = player.leaderstats.WORLD.Value
        end)

        autoFarmEnabled.Changed:Connect(function()
            if autoFarmEnabled.Value then
                spawn(function()
                    while autoFarmEnabled.Value do
                        local orbs = game.Workspace.Map.Stages.Boosts[currentWorld]:GetChildren()
                        if #orbs > 0 then
                            shuffle(orbs)
                            for _, orb in ipairs(orbs) do
                                if not autoFarmEnabled.Value then break end
                                for _, part in pairs(orb:GetChildren()) do
                                    local touch = part:FindFirstChild("TouchInterest")
                                    if touch then
                                        game:GetService("ReplicatedStorage").RemoteEvent:FireServer({ [1] = { [1] = "Activate_Punch" } })
                                        firetouchinterest(playerPart, part, 0)
                                        firetouchinterest(playerPart, part, 1)
                                    end
                                end
                                wait(collectDelay)
                            end
                        else
                            wait(30)
                        end
                    end
                end)
            end
        end)

        print("PC UI Loaded")
    end

    -- UI móvil personalizada
    local function loadMobileUI()
        deviceGui:Destroy()

        local mobileGui = Instance.new("ScreenGui")
        mobileGui.Name = "StrongestPunchGui"
        mobileGui.ResetOnSpawn = false
        mobileGui.Parent = player.PlayerGui

        -- Función para crear un toggle con círculo indicador
        local function createToggle(name, description, default, callback, parent)
            local toggleFrame = Instance.new("Frame")
            toggleFrame.Size = UDim2.new(1, 0, 0, 40)
            toggleFrame.BackgroundTransparency = 1
            toggleFrame.Parent = parent

            local toggleLabel = Instance.new("TextLabel")
            toggleLabel.Size = UDim2.new(0.7, 0, 1, 0)
            toggleLabel.Position = UDim2.new(0, 10, 0, 0)
            toggleLabel.BackgroundTransparency = 1
            toggleLabel.Text = name
            toggleLabel.Font = Enum.Font.SourceSansBold
            toggleLabel.TextSize = 18
            toggleLabel.TextColor3 = Color3.new(1,1,1)
            toggleLabel.TextXAlignment = Enum.TextXAlignment.Left
            toggleLabel.Parent = toggleFrame

            local toggleCircle = Instance.new("Frame")
            toggleCircle.Size = UDim2.new(0, 24, 0, 24)
            toggleCircle.Position = UDim2.new(1, -34, 0.5, -12)
            toggleCircle.BackgroundColor3 = default and Color3.fromRGB(0, 170, 255) or Color3.fromRGB(60, 60, 60)
            toggleCircle.BorderSizePixel = 0
            toggleCircle.Parent = toggleFrame
            toggleCircle.AnchorPoint = Vector2.new(0,0)

            toggleCircle.Rounded = true
            toggleCircle.ClipsDescendants = true
            toggleCircle.Name = "ToggleCircle"

            local toggleCircleUICorner = Instance.new("UICorner")
            toggleCircleUICorner.CornerRadius = UDim.new(1, 0)
            toggleCircleUICorner.Parent = toggleCircle

            local toggleCircleInner = Instance.new("Frame")
            toggleCircleInner.Size = UDim2.new(0.6, 0, 0.6, 0)
            toggleCircleInner.Position = UDim2.new(0.2, 0, 0.2, 0)
            toggleCircleInner.BackgroundColor3 = Color3.new(1,1,1)
            toggleCircleInner.Visible = default
            toggleCircleInner.Name = "InnerCircle"
            toggleCircleInner.Parent = toggleCircle
            toggleCircleInner.Rounded = true

            local toggleCircleInnerUICorner = Instance.new("UICorner")
            toggleCircleInnerUICorner.CornerRadius = UDim.new(1, 0)
            toggleCircleInnerUICorner.Parent = toggleCircleInner

            local toggled = default

            local function updateVisual()
                toggleCircle.BackgroundColor3 = toggled and Color3.fromRGB(0, 170, 255) or Color3.fromRGB(60, 60, 60)
                toggleCircle.InnerCircle.Visible = toggled
            end

            local function toggle()
                toggled = not toggled
                updateVisual()
                callback(toggled)
            end

            -- Detectar toque o click de mouse
            toggleFrame.InputBegan:Connect(function(input)
                if input.UserInputType == Enum.UserInputType.Touch or input.UserInputType == Enum.UserInputType.MouseButton1 then
                    toggle()
                end
            end)

            return toggleFrame
        end

        -- Panel de categorías
        local categories = {
            {Name = "Main", Parent = nil},
            {Name = "Player", Parent = nil},
            {Name = "Visuals", Parent = nil},
            {Name = "Info", Parent = nil},
            {Name = "Credits", Parent = nil},
        }

        -- Crear contenedor principal
        local mainFrame = Instance.new("Frame")
        mainFrame.Size = UDim2.new(0, 350, 0, 400)
        mainFrame.Position = UDim2.new(0.5, -175, 0.5, -200)
        mainFrame.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
        mainFrame.BorderSizePixel = 0
        mainFrame.AnchorPoint = Vector2.new(0.5, 0.5)
        mainFrame.Parent = mobileGui

        -- Barra para los botones de categoría
        local buttonsBar = Instance.new("Frame")
        buttonsBar.Size = UDim2.new(1, 0, 0, 40)
        buttonsBar.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
        buttonsBar.Parent = mainFrame

        -- Contenedor para contenido
        local contentFrame = Instance.new("Frame")
        contentFrame.Size = UDim2.new(1, -20, 1, -50)
        contentFrame.Position = UDim2.new(0, 10, 0, 45)
        contentFrame.BackgroundTransparency = 1
        contentFrame.Parent = mainFrame

        local categoryButtons = {}
        local categoryFrames = {}

        -- Crear frames para cada categoría (ocultos por defecto)
        for i, cat in ipairs(categories) do
            local btn = Instance.new("TextButton")
            btn.Size = UDim2.new(0, 70, 1, 0)
            btn.Position = UDim2.new(0 + (i-1)*75, 0, 0, 0)
            btn.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
            btn.Text = cat.Name
            btn.TextColor3 = Color3.new(1,1,1)
            btn.Font = Enum.Font.SourceSansBold
            btn.TextSize = 18
            btn.Parent = buttonsBar
            btn.AutoButtonColor = true

            categoryButtons[cat.Name] = btn

            local catFrame = Instance.new("ScrollingFrame")
            catFrame.Size = UDim2.new(1, 0, 1, 0)
            catFrame.Position = UDim2.new(0, 0, 0, 0)
            catFrame.BackgroundTransparency = 1
            catFrame.CanvasSize = UDim2.new(0, 0, 0, 0)
            catFrame.ScrollBarThickness = 5
            catFrame.Parent = contentFrame
            catFrame.Visible = false

            categoryFrames[cat.Name] = catFrame

            -- Layout para toggles y botones
            local layout = Instance.new("UIListLayout")
            layout.SortOrder = Enum.SortOrder.LayoutOrder
            layout.Padding = UDim.new(0, 5)
            layout.Parent = catFrame
        end

        -- Mostrar solo categoría "Main" inicialmente
        local function showCategory(name)
            for cname, frame in pairs(categoryFrames) do
                frame.Visible = cname == name
                categoryButtons[cname].BackgroundColor3 = cname == name and Color3.fromRGB(0, 170, 255) or Color3.fromRGB(50, 50, 50)
            end
        end
        showCategory("Main")

        -- Conectar botones para cambiar categoría
        for cname, btn in pairs(categoryButtons) do
            btn.MouseButton1Click:Connect(function()
                showCategory(cname)
            end)
        end

        -- Funciones para toggles (similares a PC UI)
        local function toggleAutoPet(state)
            autoPetEnabled = state
            if autoPetEnabled then
                spawn(function()
                    while autoPetEnabled do
                        local args = { [1] = { [1] = "UpgradeCurrentPet" } }
                        game:GetService("ReplicatedStorage").RemoteEvent:FireServer(unpack(args))
                        wait(0.2)
                    end
                end)
            end
        end

        local function toggleAutoFarm(state)
            autoFarmEnabled.Value = state
        end

        local function toggleNoclip(state)
            noclipEnabled = state
        end

        local function toggleESP(state)
            espEnabled = state
            if espEnabled then
                spawn(function()
                    while espEnabled do
                        for _, orb in pairs(game.Workspace.Map.Stages.Boosts[currentWorld]:GetChildren()) do
                            local existingGui = orb:FindFirstChild("BillboardGui")
                            if existingGui then existingGui:Destroy() end
                            local billboardGui = Instance.new("BillboardGui", orb)
                            billboardGui.AlwaysOnTop = true
                            billboardGui.Size = UDim2.new(espSize, 0, espSize, 0)
                            billboardGui.Adornee = orb
                            local frame = Instance.new("Frame", billboardGui)
                            frame.Size = UDim2.new(1, 0, 1, 0)
                            frame.BackgroundColor3 = espColor
                        end
                        wait(0.2)
                    end
                end)
            else
                for _, orb in pairs(game.Workspace.Map.Stages.Boosts[currentWorld]:GetChildren()) do
                    local gui = orb:FindFirstChild("BillboardGui")
                    if gui then gui:Destroy() end
                end
            end
        end

        local function toggleAutoWorld(state)
            autoWorld = state
            if autoWorld then
                spawn(function()
                    while autoWorld do
                        local args = { [1] = { [1] = "WarpPlrToOtherMap", [2] = "Next" } }
                        game:GetService("ReplicatedStorage").RemoteEvent:FireServer(unpack(args))
                        wait(0.3)
                    end
                end)
            end
        end

        -- Agregar toggles al frame correspondiente

        -- Main
        createToggle("Auto Pet Upgrade", "Automatically upgrade your pet", false, toggleAutoPet, categoryFrames["Main"])
        createToggle("Undetectable AutoFarm", "Collect orbs without teleporting", false, toggleAutoFarm, categoryFrames["Main"])
        createToggle("Auto World", "Automatically switch worlds", false, toggleAutoWorld, categoryFrames["Main"])

        -- Player
        local playerFrame = categoryFrames["Player"]
        local noclipToggle = createToggle("Noclip (May crash)", "Walk through walls", false, toggleNoclip, playerFrame)
        noclipToggle.Parent = playerFrame

        -- Walkspeed slider
        local walkspeedFrame = Instance.new("Frame")
        walkspeedFrame.Size = UDim2.new(1, 0, 0, 50)
        walkspeedFrame.BackgroundTransparency = 1
        walkspeedFrame.Parent = playerFrame

        local walkspeedLabel = Instance.new("TextLabel")
        walkspeedLabel.Size = UDim2.new(0.7, 0, 1, 0)
        walkspeedLabel.Position = UDim2.new(0, 10, 0, 0)
        walkspeedLabel.BackgroundTransparency = 1
        walkspeedLabel.Text = "Walkspeed"
        walkspeedLabel.Font = Enum.Font.SourceSansBold
        walkspeedLabel.TextSize = 18
        walkspeedLabel.TextColor3 = Color3.new(1,1,1)
        walkspeedLabel.TextXAlignment = Enum.TextXAlignment.Left
        walkspeedLabel.Parent = walkspeedFrame

        local walkspeedSlider = Instance.new("Slider")
        walkspeedSlider.Size = UDim2.new(0.3, 0, 0.6, 0)
        walkspeedSlider.Position = UDim2.new(0.7, 0, 0.2, 0)
        walkspeedSlider.Min = 16
        walkspeedSlider.Max = 1000
        walkspeedSlider.Value = 16
        walkspeedSlider.Parent = walkspeedFrame

        walkspeedSlider.Changed:Connect(function(value)
            local char = player.Character
            if char and char:FindFirstChild("Humanoid") then
                char.Humanoid.WalkSpeed = value
            end
        end)

        -- Visuals
        local visualsFrame = categoryFrames["Visuals"]
        createToggle("Orb ESP", "See orbs through walls", false, toggleESP, visualsFrame)

        -- Info
        local infoFrame = categoryFrames["Info"]
        local infoLabel = Instance.new("TextLabel")
        infoLabel.Size = UDim2.new(1, 0, 1, 0)
        infoLabel.BackgroundTransparency = 1
        infoLabel.Text = "Press F to toggle this UI.\nCreated by deathgod0784."
        infoLabel.Font = Enum.Font.SourceSans
        infoLabel.TextSize = 16
        infoLabel.TextColor3 = Color3.new(1,1,1)
        infoLabel.TextWrapped = true
        infoLabel.Parent = infoFrame

        -- Credits
        local creditsFrame = categoryFrames["Credits"]
        local creditsLabel = Instance.new("TextLabel")
        creditsLabel.Size = UDim2.new(1, 0, 1, 0)
        creditsLabel.BackgroundTransparency = 1
        creditsLabel.Text = "UI Library: Custom Mobile UI\nScript by deathgod0784"
        creditsLabel.Font = Enum.Font.SourceSans
        creditsLabel.TextSize = 16
        creditsLabel.TextColor3 = Color3.new(1,1,1)
        creditsLabel.TextWrapped = true
        creditsLabel.Parent = creditsFrame

        -- Toggle visibility keybind
        local UserInputService = game:GetService("UserInputService")
        UserInputService.InputBegan:Connect(function(input, gameProcessed)
            if not gameProcessed and input.KeyCode == Enum.KeyCode.F then
                mainFrame.Visible = not mainFrame.Visible
            end
        end)

        -- Anti idle
        player.Idled:Connect(function()
            local vu = game:GetService("VirtualUser")
            vu:Button2Down(Vector2.new(0, 0), workspace.CurrentCamera.CFrame)
            wait(1)
            vu:Button2Up(Vector2.new(0, 0), workspace.CurrentCamera.CFrame)
        end)

        -- Noclip loop
        game:GetService("RunService").Stepped:Connect(function()
            if noclipEnabled then
                local char = player.Character
                if char and char:FindFirstChild("Humanoid") then
                    char.Humanoid:ChangeState(11)
                end
            end
        end)

        -- Auto farm logic
        autoFarmEnabled.Changed:Connect(function()
            if autoFarmEnabled.Value then
                spawn(function()
                    while autoFarmEnabled.Value do
                        local orbs = game.Workspace.Map.Stages.Boosts[currentWorld]:GetChildren()
                        if #orbs > 0 then
                            shuffle(orbs)
                            for _, orb in ipairs(orbs) do
                                if not autoFarmEnabled.Value then break end
                                for _, part in pairs(orb:GetChildren()) do
                                    local touch = part:FindFirstChild("TouchInterest")
                                    if touch then
                                        game:GetService("ReplicatedStorage").RemoteEvent:FireServer({ [1] = { [1] = "Activate_Punch" } })
                                        firetouchinterest(playerPart, part, 0)
                                        firetouchinterest(playerPart, part, 1)
                                    end
                                end
                                wait(collectDelay)
                            end
                        else
                            wait(30)
                        end
                    end
                end)
            end
        end)

        print("Mobile UI Loaded")
    end

    -- Conectar botones del menú
    pcButton.MouseButton1Click:Connect(loadPCUI)
    phoneButton.MouseButton1Click:Connect(loadMobileUI)

end
