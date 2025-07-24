if game.PlaceId == 6875469709 or game.PlaceId == 7215881810 then
    local Players = game:GetService("Players")
    local player = Players.LocalPlayer
    local PlayerGui = player:WaitForChild("PlayerGui")
    local RunService = game:GetService("RunService")
    local VirtualUser = game:GetService("VirtualUser")
    local Replicated = game:GetService("ReplicatedStorage")

    -- Helper: anti-afk
    player.Idled:Connect(function()
        VirtualUser:Button2Down(Vector2.new(), workspace.CurrentCamera.CFrame)
        wait(1)
        VirtualUser:Button2Up(Vector2.new(), workspace.CurrentCamera.CFrame)
    end)

    -- Selector UI
    local selector = Instance.new("ScreenGui", PlayerGui)
    selector.Name = "DeviceSelector"
    selector.ResetOnSpawn = false

    local frame = Instance.new("Frame", selector)
    frame.Size = UDim2.new(0, 300, 0, 200)
    frame.Position = UDim2.new(0.5, -150, 0.5, -100)
    frame.BackgroundColor3 = Color3.fromRGB(40,40,40)
    Instance.new("UICorner", frame)

    local title = Instance.new("TextLabel", frame)
    title.Size = UDim2.new(1,0,0,50)
    title.BackgroundTransparency = 1
    title.Text = "Select Device"
    title.TextColor3 = Color3.new(1,1,1)
    title.Font = Enum.Font.GothamBold
    title.TextSize = 24

    local function makeBtn(text, color)
        local b = Instance.new("TextButton", frame)
        b.Size = UDim2.new(0.4,0,0.3,0)
        b.BackgroundColor3 = color
        b.Text = text
        b.TextColor3 = Color3.new(1,1,1)
        b.Font = Enum.Font.GothamBold
        b.TextSize = 20
        Instance.new("UICorner", b)
        return b
    end

    local pcBtn = makeBtn("PC", Color3.fromRGB(60,100,255))
    pcBtn.Position = UDim2.new(0.05,0,0.5,0)
    local phoneBtn = makeBtn("Phone", Color3.fromRGB(60,255,100))
    phoneBtn.Position = UDim2.new(0.55,0,0.5,0)

    -- Reset UI
    local function closeSelector()
        selector:Destroy()
    end

    ---------------
    -- PC VERSION --
    ---------------
    local function runPC()
        closeSelector()
        -- Kavo UI script begins
        local Library = loadstring(game:HttpGet("https://raw.githubusercontent.com/xHeptc/Kavo-UI-Library/main/source.lua"))()
        local Window = Library.CreateLib("Strongest Punch Simulator Script", "Ocean")
        local MainTab = Window:NewTab("Main")
        local VisualsTab = Window:NewTab("Visuals")
        local PlayerTab = Window:NewTab("Player")
        local InfoTab = Window:NewTab("Info")
        local CreditsTab = Window:NewTab("Credits")

        -- Variables
        local playerPart = player.Character:WaitForChild("HumanoidRootPart")
        local currentWorld = player.leaderstats.WORLD.Value
        local autoPet, esp, noclip, autoWorld = false, false, false, false
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

        local Main = MainTab:NewSection("Farming")
        Main:NewToggle("Auto Pet Upgrade","Auto upgrade pet",function(s)
            autoPet = s
            if s then spawn(function()
                while autoPet do
                    Replicated.RemoteEvent:FireServer({{"UpgradeCurrentPet"}}); wait(0.2)
                end
            end) end
        end)
        Main:NewToggle("Undetectable AutoFarm","Collect orbs",function(s) autoFarm.Value = s end)
        Main:NewButton("Risky AutoFarm (OP)","Max 80 orbs then kick",function()
            Replicated.RemoteEvent:FireServer({{"WarpPlrToOtherMap","Next"}}); wait(1.2)
            local col = 0; local orbs = workspace.Map.Stages.Boosts[currentWorld]:GetChildren()
            shuffle(orbs)
            for _,o in ipairs(orbs) do
                if col>=80 then break end
                for _,p in ipairs(o:GetChildren()) do
                    if p:FindFirstChild("TouchInterest") then
                        firetouchinterest(playerPart,p,0);firetouchinterest(playerPart,p,1)
                        col+=1; break
                    end
                end
            end
            wait(0.3); player:Kick("Collected Orbs Successfully!")
        end)
        Main:NewToggle("Auto World","Switch worlds",function(s)
            autoWorld = s
            if s then spawn(function()
                while autoWorld do
                    Replicated.RemoteEvent:FireServer({{"WarpPlrToOtherMap","Next"}}); wait(0.3)
                end
            end) end
        end)

        local P = PlayerTab:NewSection("Player")
        P:NewToggle("Noclip","Walk thru walls",function(s) noclip = s end)
        P:NewSlider("Walkspeed","Speed",500,16,function(v)
            local hum = player.Character and player.Character:FindFirstChild("Humanoid")
            if hum then hum.WalkSpeed = v end
        end)

        local V = VisualsTab:NewSection("Visuals")
        V:NewColorPicker("ESP Color","Pick color",espColor,function(c) espColor=c end)
        V:NewSlider("ESP Size","Size",4,1,function(v) espSize=v end)
        V:NewToggle("Orb ESP","See orbs",function(s)
            esp = s
            spawn(function()
                while esp do
                    for _,o in pairs(workspace.Map.Stages.Boosts[currentWorld]:GetChildren()) do
                        local g = o:FindFirstChild("BillboardGui")
                        if g then g:Destroy() end
                        local b = Instance.new("BillboardGui",o); b.Size=UDim2.new(espSize,0,espSize,0);b.AlwaysOnTop=true; b.Adornee=o
                        local f=Instance.new("Frame",b); f.Size=UDim2.new(1,0,1,0); f.BackgroundColor3=espColor
                    end
                    wait(0.2)
                end
            end)
            if not esp then
                for _,o in pairs(workspace.Map.Stages.Boosts[currentWorld]:GetChildren()) do
                    local g=o:FindFirstChild("BillboardGui")
                    if g then g:Destroy() end
                end
            end
        end)

        InfoTab:NewSection("Controls"):NewKeybind("Toggle UI","F key",Enum.KeyCode.F,function() Library:ToggleUI() end)
        local C = CreditsTab:NewSection("Credits")
        C:NewLabel("Script by deathgod0784"); C:NewLabel("UI Library: Kavo by xHeptc")

        -- Connections
        player.leaderstats.WORLD.Changed:Connect(function(v) currentWorld=v end)
        RunService.Stepped:Connect(function()
            if noclip and player.Character and player.Character:FindFirstChild("Humanoid") then
                player.Character.Humanoid:ChangeState(11)
            end
        end)
        autoFarm.Changed:Connect(function()
            if autoFarm.Value then spawn(function()
                while autoFarm.Value do
                    local orbs = workspace.Map.Stages.Boosts[currentWorld]:GetChildren()
                    shuffle(orbs)
                    for _,o in ipairs(orbs) do
                        if not autoFarm.Value then break end
                        for _,p in pairs(o:GetChildren()) do
                            if p:FindFirstChild("TouchInterest") then
                                Replicated.RemoteEvent:FireServer({{"Activate_Punch"}})
                                firetouchinterest(playerPart,p,0); firetouchinterest(playerPart,p,1)
                            end
                        end
                        wait(collectDelay)
                    end
                    wait(30)
                end
            end) end
        end)

        print("PC UI loaded")
        -- Kavo UI script ends
    end

    ------------------
    -- PHONE VERSION --
    ------------------
    local function runPhone()
        closeSelector()
        local gui = Instance.new("ScreenGui", PlayerGui)
        gui.Name = "MobileUI"
        gui.ResetOnSpawn = false

        local frame = Instance.new("Frame", gui)
        frame.Size = UDim2.new(0.9,0,0.8,0)
        frame.Position = UDim2.new(0.05,0,0.1,0)
        frame.BackgroundColor3 = Color3.fromRGB(30,30,30)
        Instance.new("UICorner", frame)

        local	tabNames = {"Main","Player","Visuals","Info","Credits"}
        local tabButtons = {}
        local tabFrames = {}

        local btnContainer = Instance.new("Frame", frame)
        btnContainer.Size = UDim2.new(0,80,1,0)
        btnContainer.BackgroundTransparency = 1
        for i,name in ipairs(tabNames) do
            local b = Instance.new("TextButton", btnContainer)
            b.Size = UDim2.new(1,0,0,40)
            b.Position = UDim2.new(0,0,(i-1)*40,0)
            b.Text = name
            b.BackgroundColor3 = Color3.fromRGB(40,40,40)
            b.TextColor3 = Color3.new(1,1,1)
            b.Font = Enum.Font.GothamBold
            b.TextSize = 18
            Instance.new("UICorner", b)
            tabButtons[name] = b
            local f = Instance.new("Frame", frame)
            f.Size = UDim2.new(1,-80,1,0)
            f.Position = UDim2.new(0,80,0,0)
            f.BackgroundTransparency = 1
            f.Visible = false
            tabFrames[name] = f
            local layout = Instance.new("UIListLayout", f)
            layout.Padding = UDim.new(0,6)
        end

        local function show(name)
            for n,f in pairs(tabFrames) do
                f.Visible = (n==name)
                tabButtons[n].BackgroundColor3 = (n==name) and Color3.fromRGB(0,170,255) or Color3.fromRGB(40,40,40)
            end
        end
        show("Main")

        -- Variables
        local playerPart = player.Character:WaitForChild("HumanoidRootPart")
        local currentWorld = player.leaderstats.WORLD.Value
        local collectDelay = 0.9

        local autoPet, autoFarm, noclip = false,false,false

        local function shuffle(t) for i=#t,2,-1 do local j=math.random(i); t[i],t[j]=t[j],t[i] end end

        -- Helpers
        local function createToggle(tab, text, fn)
            local parent = tabFrames[tab]
            local btn = Instance.new("TextButton", parent)
            btn.Size = UDim2.new(1,-20,0,40); btn.BackgroundColor3 = Color3.fromRGB(50,50,50)
            btn.Text = ""; Instance.new("UICorner", btn)
            local circ = Instance.new("Frame",btn)
            circ.Size = UDim2.new(0,20,0,20); circ.Position = UDim2.new(0,10,0.5,-10)
            circ.BackgroundColor3 = Color3.fromRGB(100,100,100); Instance.new("UICorner",circ).CornerRadius=UDim.new(1,0)
            local lbl = Instance.new("TextLabel",btn)
            lbl.Size = UDim2.new(1,-40,1,0); lbl.Position = UDim2.new(0,40,0,0)
            lbl.BackgroundTransparency = 1; lbl.Text = text; lbl.TextColor3 = Color3.new(1,1,1)
            lbl.Font = Enum.Font.Gotham; lbl.TextScaled = true

            local st = false
            local function toggle()
                st = not st
                circ.BackgroundColor3 = st and Color3.fromRGB(0,170,0) or Color3.fromRGB(100,100,100)
                fn(st)
            end
            btn.MouseButton1Click:Connect(toggle)
            btn.TouchTap:Connect(toggle)
        end

        local function createButton(tab, text, fn)
            local parent = tabFrames[tab]
            local btn = Instance.new("TextButton", parent)
            btn.Size = UDim2.new(1,-20,0,40); btn.BackgroundColor3=Color3.fromRGB(70,70,70)
            btn.Text=text; btn.Font=Enum.Font.GothamBold; btn.TextColor3=Color3.new(1,1,1)
            Instance.new("UICorner", btn)
            btn.MouseButton1Click:Connect(fn)
            btn.TouchTap:Connect(fn)
        end

        -- Build controls
        createToggle("Main","Auto Pet Upgrade",function(s)
            autoPet = s
            if s then spawn(function()
                while autoPet do
                    Replicated.RemoteEvent:FireServer({{"UpgradeCurrentPet"}}); wait(0.2)
                    if not autoPet then break end
                end
            end) end
        end)
        createToggle("Main","Undetectable AutoFarm",function(s)
            autoFarm = s
            if s then spawn(function()
                while autoFarm do
                    local orbs = workspace.Map.Stages.Boosts[currentWorld]:GetChildren()
                    shuffle(orbs)
                    for _,o in ipairs(orbs) do
                        for _,p in ipairs(o:GetChildren()) do
                            if p:FindFirstChild("TouchInterest") then
                                firetouchinterest(playerPart,p,0); firetouchinterest(playerPart,p,1)
                            end
                        end
                        wait(0.05)
                    end
                    wait(0.4)
                end
            end) end
        end)
        createButton("Main","Risky AutoFarm (OP)",function()
            Replicated.RemoteEvent:FireServer({{"WarpPlrToOtherMap","Next"}}); wait(1)
            local col=0; shuffle(workspace.Map.Stages.Boosts[currentWorld]:GetChildren())
            for _,o in ipairs(workspace.Map.Stages.Boosts[currentWorld]:GetChildren()) do
                if col>=80 then break end
                for _,p in ipairs(o:GetChildren()) do
                    if p:FindFirstChild("TouchInterest") then
                        firetouchinterest(playerPart,p,0);firetouchinterest(playerPart,p,1); col+=1; break
                    end
                end
            end
            wait(0.3); player:Kick("Collected Orbs Successfully!")
        end)

        createToggle("Player","Noclip",function(s)
            noclip = s
        end)

        createToggle("Visuals","Orb ESP",function(s)
            spawn(function()
                while s and workspace.Map.Stages.Boosts[currentWorld] do
                    for _,o in ipairs(workspace.Map.Stages.Boosts[currentWorld]:GetChildren()) do
                        local g = o:FindFirstChild("BillboardGui")
                        if g then g:Destroy() end
                        local b = Instance.new("BillboardGui",o)
                        b.Size = UDim2.new(espSize,0,espSize,0); b.AlwaysOnTop = true
                        b.Adornee = o
                        local f = Instance.new("Frame",b)
                        f.Size = UDim2.new(1,0,1,0); f.BackgroundColor3 = espColor
                    end
                    wait(0.2)
                end
            end)
        end)

        createButton("Credits","Script by deathgod0784",function() end)

        for _,name in ipairs(tabNames) do
            tabButtons[name].MouseButton1Click:Connect(function() show(name) end)
            tabButtons[name].TouchTap:Connect(function() show(name) end)
        end

        show = show -- keep reference
        RunService.Stepped:Connect(function()
            if noclip and player.Character and player.Character:FindFirstChild("Humanoid") then
                player.Character.Humanoid:ChangeState(11)
            end
        end)

        player.leaderstats.WORLD.Changed:Connect(function(v) currentWorld = v end)
        print("Mobile UI loaded")
    end

    pcBtn.MouseButton1Click:Connect(runPC)
    phoneBtn.MouseButton1Click:Connect(runPhone)
end
