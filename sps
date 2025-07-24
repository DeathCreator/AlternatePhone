if game.PlaceId == 6875469709 or game.PlaceId == 7215881810 then
    local Players = game:GetService("Players")
    local player = Players.LocalPlayer
    local PlayerGui = player:WaitForChild("PlayerGui")
    local RunService = game:GetService("RunService")
    local VirtualUser = game:GetService("VirtualUser")
    local Replicated = game:GetService("ReplicatedStorage")

    -- Anti-AFK
    player.Idled:Connect(function()
        VirtualUser:Button2Down(Vector2.new(), workspace.CurrentCamera.CFrame)
        wait(1)
        VirtualUser:Button2Up(Vector2.new(), workspace.CurrentCamera.CFrame)
    end)

    -- Kavo UI
    local Library = loadstring(game:HttpGet("https://raw.githubusercontent.com/xHeptc/Kavo-UI-Library/main/source.lua"))()

    -- Centrar la UI manualmente
    local function overridePosition()
        task.wait(1)
        for _, gui in ipairs(PlayerGui:GetChildren()) do
            if gui:FindFirstChild("Main") then
                local main = gui.Main
                main.AnchorPoint = Vector2.new(0.5, 0.5)
                main.Position = UDim2.new(0.5, 0, 0.5, 0)
            end
        end
    end

    local Window = Library.CreateLib("Strongest Punch Simulator Script", "Ocean")
    local MainTab = Window:NewTab("Main")
    local VisualsTab = Window:NewTab("Visuals")
    local PlayerTab = Window:NewTab("Player")
    local InfoTab = Window:NewTab("Info")
    local CreditsTab = Window:NewTab("Credits")

    -- Variables
    local playerPart = player.Character:WaitForChild("HumanoidRootPart")
    local currentWorld = player.leaderstats.WORLD.Value
    local autoPet = false
    local autoPetThread = nil
    local autoWorld = false
    local autoWorldThread = nil
    local esp = false
    local noclip = false
    local collectDelay = 0.9
    local espSize = 1
    local espColor = Color3.fromRGB(0,170,255)
    local autoFarm = Instance.new("BoolValue"); autoFarm.Value = false

    local function shuffle(t)
        for i = #t,2,-1 do
            local j = math.random(i)
            t[i], t[j] = t[j], t[i]
        end
    end

    -- Main Tab
    local Main = MainTab:NewSection("Farming")
    Main:NewToggle("Auto Pet Upgrade", "Auto upgrade pet", function(s)
        autoPet = s
        if s then
            if autoPetThread then return end
            autoPetThread = task.spawn(function()
                while autoPet do
                    Replicated.RemoteEvent:FireServer({{"UpgradeCurrentPet"}})
                    task.wait(0.2)
                end
                autoPetThread = nil
            end)
        else
            autoPet = false
        end
    end)

    Main:NewToggle("Undetectable AutoFarm", "Collect orbs", function(s)
        autoFarm.Value = s
    end)

    Main:NewButton("Risky AutoFarm (OP)", "Max 80 orbs then kick", function()
        Replicated.RemoteEvent:FireServer({{"WarpPlrToOtherMap","Next"}})
        wait(1.2)
        local col = 0
        local orbs = workspace.Map.Stages.Boosts[currentWorld]:GetChildren()
        shuffle(orbs)
        for _,o in ipairs(orbs) do
            if col >= 80 then break end
            for _,p in ipairs(o:GetChildren()) do
                if p:FindFirstChild("TouchInterest") then
                    firetouchinterest(playerPart,p,0)
                    firetouchinterest(playerPart,p,1)
                    col += 1
                    break
                end
            end
        end
        wait(0.3)
        player:Kick("Collected Orbs Successfully!")
    end)

    Main:NewToggle("Auto World", "Switch worlds", function(s)
        autoWorld = s
        if s then
            if autoWorldThread then return end
            autoWorldThread = task.spawn(function()
                while autoWorld do
                    Replicated.RemoteEvent:FireServer({{"WarpPlrToOtherMap","Next"}})
                    task.wait(0.3)
                end
                autoWorldThread = nil
            end)
        else
            autoWorld = false
        end
    end)

    -- Player Tab
    local P = PlayerTab:NewSection("Player")
    P:NewToggle("Noclip", "Walk through walls", function(s) noclip = s end)
    P:NewSlider("Walkspeed", "Adjust player speed", 500, 16, function(v)
        local hum = player.Character and player.Character:FindFirstChild("Humanoid")
        if hum then hum.WalkSpeed = v end
    end)

    -- Visuals Tab
    local V = VisualsTab:NewSection("Visuals")
    V:NewColorPicker("ESP Color", "Pick color", espColor, function(c) espColor = c end)
    V:NewSlider("ESP Size", "Size", 4, 1, function(v) espSize = v end)
    V:NewToggle("Orb ESP", "See orbs", function(s)
        esp = s
        spawn(function()
            while esp do
                for _,o in pairs(workspace.Map.Stages.Boosts[currentWorld]:GetChildren()) do
                    local g = o:FindFirstChild("BillboardGui")
                    if g then g:Destroy() end
                    local b = Instance.new("BillboardGui", o)
                    b.Size = UDim2.new(espSize, 0, espSize, 0)
                    b.AlwaysOnTop = true
                    b.Adornee = o
                    local f = Instance.new("Frame", b)
                    f.Size = UDim2.new(1, 0, 1, 0)
                    f.BackgroundColor3 = espColor
                end
                wait(0.2)
            end
        end)
        if not esp then
            for _,o in pairs(workspace.Map.Stages.Boosts[currentWorld]:GetChildren()) do
                local g = o:FindFirstChild("BillboardGui")
                if g then g:Destroy() end
            end
        end
    end)

    -- Info & Credits
    InfoTab:NewSection("Controls"):NewKeybind("Toggle UI", "F key", Enum.KeyCode.F, function()
        Library:ToggleUI()
    end)
    local C = CreditsTab:NewSection("Credits")
    C:NewLabel("Script by deathgod0784")
    C:NewLabel("UI Library: Kavo by xHeptc")

    -- Eventos
    player.leaderstats.WORLD.Changed:Connect(function(v)
        currentWorld = v
    end)

    RunService.Stepped:Connect(function()
        if noclip and player.Character and player.Character:FindFirstChild("Humanoid") then
            player.Character.Humanoid:ChangeState(11)
        end
    end)

    autoFarm.Changed:Connect(function()
        if autoFarm.Value then
            spawn(function()
                while autoFarm.Value do
                    local orbs = workspace.Map.Stages.Boosts[currentWorld]:GetChildren()
                    shuffle(orbs)
                    for _,o in ipairs(orbs) do
                        if not autoFarm.Value then break end
                        for _,p in ipairs(o:GetChildren()) do
                            if p:FindFirstChild("TouchInterest") then
                                Replicated.RemoteEvent:FireServer({{"Activate_Punch"}})
                                firetouchinterest(playerPart,p,0)
                                firetouchinterest(playerPart,p,1)
                            end
                        end
                        wait(collectDelay)
                    end
                    wait(30)
                end
            end)
        end
    end)

    overridePosition()
end
