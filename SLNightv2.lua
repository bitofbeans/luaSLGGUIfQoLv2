-- luaSLGGUIfQoLv2 SOURCE CODE
--[[
  ____   _      ____   ____  _   _  ___  _____  ___    ___   _     
 / ___| | |    / ___| / ___|| | | ||_ _||  ___|/ _ \  / _ \ | |    
 \___ \ | |   | |  _ | |  _ | | | | | | | |_  | | | || | | || |    
  ___) || |___| |_| || |_| || |_| | | | |  _| | |_| || |_| || |___ 
 |____/ |_____|\____| \____| \___/ |___||_|    \__\_\ \___/ |_____|     
                                                     
]]

local GUI = loadstring(game:HttpGet('https://raw.githubusercontent.com/SiriusSoftwareLtd/Rayfield/main/source.lua'))()
--

local Window = GUI:CreateWindow({
Name = "Street Life Gamer GUI for Quality of Life V2",
LoadingTitle = "Loading Street Life Script",
LoadingSubtitle = "by BitBeans",
KeySystem = false,
})

local Shop = Window:CreateTab("Shop", 4483362458) -- Title, Image
local Exploits = Window:CreateTab("Exploits", 4483362458) -- Title, Image
local Movement = Window:CreateTab("Movement", 4483362458) -- Title, Image
local Money = Window:CreateTab("Money", 4483362458) -- Title, Image
local Misc = Window:CreateTab("Misc", 4483362458) -- Title, Image

-- Roblox Variables
local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer
local Camera = workspace.CurrentCamera
local RunService = game:GetService("RunService")
local UIS = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")
local ReplicatedStorage =  game:GetService("ReplicatedStorage")
local Backpack = LocalPlayer.Backpack
local HttpService = game:GetService("HttpService")
local TeleportService = game:GetService("TeleportService")
local VirtualInputManager = game:GetService("VirtualInputManager")
local Heartbeat = game:GetService("RunService").Heartbeat
--

-- custom variables
local RightClickHeld = false
local ClosePlayers
local VisitedServers = {}
local Fly = false
local FlyUp = false
local FlyDown = false
local xvel, yvel, zvel
local AutoDeposit = false
local Stored = LocalPlayer.stored
local FlySpeed = 50
local TPCoords = {-680,4,54} -- Car Dealer initial option
local Recipient
local Actor
local InstaKill
local LagPlayer
local GodMode
local AudioID
local CustomAudioID


local AutoWithdraw = Shop:CreateToggle({
    Name = "Auto Withdraw from Bank (recommended)",
    CurrentValue = true,
    Flag = "AutoWithdraw", -- A flag is the identifier for the configuration file, make sure every element has a different flag if you're using configuration saving to ensure no overlaps
    Callback = function(Value) end
})

-- FUNCTIONS
SimulateInput = {
    Hold = function(key, time)
        VirtualInputManager:SendKeyEvent(true, key, false, nil)
        task.wait(time)
        VirtualInputManager:SendKeyEvent(false, key, false, nil)
    end,
    Press = function(key)
        VirtualInputManager:SendKeyEvent(true, key, false, nil)
        task.wait(0.005)
        VirtualInputManager:SendKeyEvent(false, key, false, nil)
    end
}

local function quickNotify(title,message,duration)
    GUI:Notify({
        Title = title,
        Content = message,
        Duration = duration,
    })
end

local function getSpeed(seat)
    return seat.AssemblyLinearVelocity.Magnitude
end

local function getPlayer(name)
    for i, v in pairs(Players:GetPlayers()) do
        if string.lower(v.Name) == string.lower(name) then
        return v
        end
    end
    return nil
end

local function waitForPlayerToExist(time)
    wait(time)
    local humanoidrootpart = LocalPlayer.Character:WaitForChild("HumanoidRootPart")
    local humanoid = LocalPlayer.Character:WaitForChild("Humanoid")
    return humanoidrootpart
end

local function sendServerDepositMoney(amount) 
    ReplicatedStorage.ATM:FireServer("Deposit", amount)
end

local function sendServerWithdrawMoney(amount) 
    ReplicatedStorage.ATM:FireServer("Withdraw", amount)
end

local function getPlayerCar() 
    return game.workspace:FindFirstChild("CivCars"):FindFirstChild(LocalPlayer.Name .. "'s Car")
end

local function changeItemLocation(item, currentLocation)
    local args = {
        [1] = "Change",
        [2] = item,
        [3] = currentLocation,
        [4] = LocalPlayer.Character.HumanoidRootPart
    }
    ReplicatedStorage.Inventory:FireServer(unpack(args))
end


local function constructInflictPlayerArgs(gun, actorName, recipientName)
    local args ={
        [1] = gun, -- gun obv
        [2] = getPlayer(actorName), -- person that is shooting
        [3] = getPlayer(recipientName).Character.Humanoid, -- player that is being shot
        [4] = getPlayer(recipientName).Character.HumanoidRootPart, -- hrp
        [5] = 99999999, -- damage
        [6] = {
            [1] = 99,-- idk what this shit is wtf
            [2] = 999,
            [3] = false,
            [4] = false,
            [5] = gun.GunScript_Server.IgniteScript,
            [6] = gun.GunScript_Server.IcifyScript,
            [7] = 99999,
            [8] = 9999
        },
        [7] = {
            [1] = false,
            [2] = 999,
            [3] = 9999
        },
        [8] = getPlayer(recipientName).Character.Head,
        [9] = {
            [1] = false,
            [2] = {
                [1] = 999
            },
            [3] = 99,
            [4] = 99,
            [5] = 99
        },
        [10] = Vector3.new(-433.24053955078125, -323.75885009765625, -158.63999938964844),
        [11] = Vector3.new(-0.956211268901825, 0.00013869439135305583, -0.29267749190330505),
        [12] = true -- do damage?
    }
    return args
end


local function equipTool(itemName)
    --check if it is already equipped
    local item = LocalPlayer.Character:FindFirstChild(itemName)
    if item then return item end

    local item = LocalPlayer.Backpack:FindFirstChild(itemName)
    if not item then
        quickNotify("Error", "You do not have a "..itemName.."!", 1.5)
        return
    end
    LocalPlayer.Character.Humanoid:EquipTool(item)

    return LocalPlayer.Character:FindFirstChild(itemName)
end

local function SendMoneyToPlayer(player, amount)
    local Player = getPlayer(player)
    if Player == nil then 
        quickNotify("Error", "Player not found (Make sure it is their actual username!)", 1.5)
    end
    ReplicatedStorage.Phone:FireServer("SendMoney", Player, amount)

    quickNotify("Money Sent", amount .. " Sent to " .. Player.Name, 1.5)

end

local function PlantC4() 
    local PlayerC4 = equipTool("C4")
    ReplicatedStorage.C4:FireServer(PlayerC4, "COMPLETED", workspace.Plant)
    quickNotify("Planted", "", 1.5)
end

local function DepositMoney(amount) 
    if Stored.Bank.Value == 3000000 then return end
    if tonumber(amount) > 100000 then
        local times = math.floor(amount/100000)
        for i = 1, times do
            sendServerDepositMoney(100000)
            wait(0.1)
            if Stored.Bank.Value == 3000000 then return end
            
        end
        
        sendServerDepositMoney(math.fmod(amount, 100000)) --- remainder
    else
        sendServerDepositMoney(amount)
    end
    
end

local function WithdrawMoney(amount) 
    if Stored.Money.Value == 2000000 then return end
    if tonumber(amount) > 100000 then
        local times = math.floor(amount/100000)
        for i = 1, times do
            sendServerWithdrawMoney(100000)
            wait(0.1)
            if Stored.Money.Value == 2000000 then return end
        end
        sendServerWithdrawMoney(math.fmod(amount, 100000)) --- remainder
    else
        if tonumber(amount) > Stored.Bank.Value then 
            sendServerWithdrawMoney(Stored.Bank.Value)
        else
            sendServerWithdrawMoney(amount)
        end
    end
    
end

local function BuyGun(name, price)
    if AutoWithdraw.CurrentValue == true then WithdrawMoney(price) end

    ReplicatedStorage.GBuy:FireServer(name, price)
    
    quickNotify("Bought Gun", "Bought the " .. name .." for ".. price, 1.5)
end

local function BuyItem(name, price)
    if AutoWithdraw.CurrentValue == true then WithdrawMoney(price) end

    ReplicatedStorage.Buy:FireServer(name, price)

    quickNotify("Bought Item", "Bought " .. name .." for ".. price, 1.5)
end

local function Respawn()
    game:GetService("Lighting").bt:FireServer("ss")
end

local function TeleportPlayer(x,y,z)
    LocalPlayer.Character.HumanoidRootPart.CFrame = CFrame.new(x,y,z)
    quickNotify("Teleported", "", 1.5)
end

local function FindPlayerToAimbot() 
    local Mouse = LocalPlayer:GetMouse()
    
    local MaxDistance = 80
    local closestDistance = math.huge
    local player = nil

    for i, v in pairs(Players:GetPlayers()) do
        local HumanoidRootPart = v.Character:FindFirstChild("HumanoidRootPart")
        local Humanoid = v.Character:FindFirstChild("Humanoid")
        
        if not HumanoidRootPart or v == LocalPlayer or v.Character == nil or Humanoid.Health == 0 then
            continue
        elseif (LocalPlayer.Character.HumanoidRootPart.CFrame.Y - v.Character.HumanoidRootPart.CFrame.Y) > 10 then
            continue -- Too Far Underneath or above
        end
        
        local ScreenPoint = Camera:WorldToScreenPoint(HumanoidRootPart.Position)
        local VectorDistance =  (Vector2.new(UIS:GetMouseLocation().X, UIS:GetMouseLocation().Y) - Vector2.new(ScreenPoint.X,ScreenPoint.Y)).Magnitude
        
        if ScreenPoint.Z < 0 then continue end -- They are behind us
        if VectorDistance < closestDistance and VectorDistance < MaxDistance then
            closestDistance = VectorDistance
            player = v
        end
        
    end
    
    return player
end

local function LookAtHeadOfPlayer(player)
    if player == nil then return end
    Target = player.Character
    LocalPlayer.CameraMaxZoomDistance = 0.5
    for i,v in pairs(Players:GetPlayers()) do
        if Target and Target:FindFirstChild("Head") then
            Camera.CFrame = CFrame.new(Camera.CFrame.p, Target.Head.CFrame.p)
        end
    end

    game.Players.LocalPlayer.CameraMaxZoomDistance = 1000
end

local function CarMoneyFarm (player)
    DepositMoney(Stored.Money.Value)
    Respawn()
    waitForPlayerToExist(2)
    local Enabled, MAD
    local iteration = 0
    local function firepp(pp,xx, teleport)
        Enabled = pp.Enabled
        MAD = pp.MaxActivationDistance

        pp.HoldDuration = 0
        pp.RequiresLineOfSight = false
        pp.MaxActivationDistance = math.huge

        if Enabled == true then
            if teleport == true then
                LocalPlayer.Character.HumanoidRootPart.CFrame = pp.Parent.Parent.CFrame + Vector3.new(0,2,2)
                iteration = iteration + 1
            end
            wait(0.25)
            if teleport == false then 
                -- grab load of cash ????
                spawn(function() fireproximityprompt(pp,xx) end)
                spawn(function() fireproximityprompt(pp,xx) end)
                wait(0.75)
            else
                fireproximityprompt(pp,xx)-- break glass
            end
        end
        --
        pp.MaxActivationDistance = MAD
        
        return Enabled
    end

    for i,v in workspace.Interactions:GetDescendants() do
        if v and v.Name == "ProximityPrompt" and v:IsA("ProximityPrompt") then
            
            local result = firepp(v,5, true) 
            if result then
                wait(2.5)
                local result = firepp(v,5, false) 
                wait(0.25)
                DepositMoney(Stored.Money.Value)
                
                if iteration == 3 then 
                    Respawn() -- prevents lagbacks
                    waitForPlayerToExist(1)
                    iteration = 0
                end
            else
                continue
            end

        end
    end
end

local function StealBankMoney()
    if ReplicatedStorage.BankRobbery.Value == true then
        local LootBuyerPrompt = workspace:FindFirstChild("Loot Buyer"):FindFirstChild("Handler")
        for i,v in pairs(game.workspace.BankInteractions:GetChildren()) do
            local ProximityPrompt = v:FindFirstChildOfClass("ProximityPrompt")
            ProximityPrompt.RequiresLineOfSight = false
            ProximityPrompt.MaxActivationDistance = 15
            if ProximityPrompt.Enabled == true then
                waitForPlayerToExist()
                if not LocalPlayer.Character.HumanoidRootPart then wait(1) end
                LocalPlayer.Character.HumanoidRootPart.CFrame = v.CFrame + Vector3.new(0,3,0)
                wait(0.1)
                spawn(function() fireproximityprompt(ProximityPrompt,5) end)
                spawn(function() fireproximityprompt(ProximityPrompt,5) end)
                spawn(function() fireproximityprompt(ProximityPrompt,5) end)
                spawn(function() fireproximityprompt(ProximityPrompt,5) end)
                spawn(function() fireproximityprompt(ProximityPrompt,5) end)
                wait(1)
                LocalPlayer.Character.HumanoidRootPart.CFrame = CFrame.new(-856,3,385)
                wait()
                fireproximityprompt(LootBuyerPrompt,5)
                fireproximityprompt(LootBuyerPrompt,5)
                wait()
                DepositMoney(Stored.Money.Value)
                wait()
                Respawn()
                waitForPlayerToExist(1)
            end
        end 
    end
end

local function FarmServerBank()
    local Length = 11880 -- seconds it takes to get full bank from farming
    local StartTime = os.time()
    local EndTime = StartTime + Length
    repeat 
        LocalPlayer.DevCameraOcclusionMode = "Invisicam"
        if ReplicatedStorage.BankRobbery.Value == false then
            if ReplicatedStorage.BankCooldown.Value == 0 then 
                Respawn()
                wait(3)
                waitForPlayerToExist(1)
                BuyItem("C4", 2000)
                wait()
                TeleportPlayer(-1239,-260,-371)
                wait(0.5)
                PlantC4()
                wait(6.7)
                StealBankMoney()
                StealBankMoney()
                StealBankMoney()
            end
        else
            StealBankMoney()
            StealBankMoney()
            StealBankMoney()
        end
        
        wait(0.25)
        StealBankMoney()
        --[[
        GUI:Notify({
            Title = "Done",
            Content = "BANK ROBBERY FINISHED!!!!!!!!",
            Duration = 3,
            Image = 4483362458,
        })
        LocalPlayer.DevCameraOcclusionMode = "Zoom"

        ]]
        repeat 
            wait(1) 
            print(ReplicatedStorage.BankCooldown.Value)
            quickNotify(ReplicatedStorage.BankCooldown.Value, "Bank on Cooldown", 0.5)
        until ReplicatedStorage.BankCooldown.Value == 0 or FarmServerBankToggle.CurrentValue == false
        SimulateInput.Hold(Enum.KeyCode.W, 1)
    until os.time() > EndTime or Stored.Money.Value == 3000000 or FarmServerBankToggle.CurrentValue == false
end

local function StudioFarm() 
    local pp = game.workspace.Map.Jobs.Studio:GetChildren()[11].Studio:GetChildren()[11].Model.Arm.Head.Model.PopFilt.Part.Handler
    spawn(function() fireproximityprompt(pp,10) end)
    spawn(function() fireproximityprompt(pp,10) end)
    spawn(function() fireproximityprompt(pp,10) end)
    spawn(function() fireproximityprompt(pp,10) end)
    spawn(function() fireproximityprompt(pp,10) end)
    spawn(function() fireproximityprompt(pp,10) end)
    spawn(function() fireproximityprompt(pp,10) end)
    spawn(function() fireproximityprompt(pp,10) end)
    spawn(function() fireproximityprompt(pp,10) end)
    spawn(function() fireproximityprompt(pp,10) end)
    spawn(function() fireproximityprompt(pp,10) end)
    spawn(function() fireproximityprompt(pp,10) end)
    spawn(function() fireproximityprompt(pp,10) end)
    spawn(function() fireproximityprompt(pp,10) end)
    spawn(function() fireproximityprompt(pp,10) end)
    spawn(function() fireproximityprompt(pp,10) end)
    spawn(function() fireproximityprompt(pp,10) end)
    spawn(function() fireproximityprompt(pp,10) end)
    spawn(function() fireproximityprompt(pp,10) end)
    spawn(function() fireproximityprompt(pp,10) end)
    spawn(function() fireproximityprompt(pp,10) end)
    spawn(function() fireproximityprompt(pp,10) end)
    spawn(function() fireproximityprompt(pp,10) end)
    spawn(function() fireproximityprompt(pp,10) end)
    spawn(function() fireproximityprompt(pp,10) end)
    spawn(function() fireproximityprompt(pp,10) end)
    spawn(function() fireproximityprompt(pp,10) end)
    spawn(function() fireproximityprompt(pp,10) end)
    spawn(function() fireproximityprompt(pp,10) end)
    spawn(function() fireproximityprompt(pp,10) end)
    spawn(function() fireproximityprompt(pp,10) end)
    spawn(function() fireproximityprompt(pp,10) end)
    spawn(function() fireproximityprompt(pp,10) end)
    spawn(function() fireproximityprompt(pp,10) end)
    spawn(function() fireproximityprompt(pp,10) end)
    spawn(function() fireproximityprompt(pp,10) end)
    spawn(function() fireproximityprompt(pp,10) end)
    spawn(function() fireproximityprompt(pp,10) end)
    spawn(function() fireproximityprompt(pp,10) end)
    spawn(function() fireproximityprompt(pp,10) end)
    spawn(function() fireproximityprompt(pp,10) end)
    spawn(function() fireproximityprompt(pp,10) end)
    spawn(function() fireproximityprompt(pp,10) end)
    spawn(function() fireproximityprompt(pp,10) end)
    spawn(function() fireproximityprompt(pp,10) end)
    spawn(function() fireproximityprompt(pp,10) end)
    spawn(function() fireproximityprompt(pp,10) end)
    spawn(function() fireproximityprompt(pp,10) end)
    spawn(function() fireproximityprompt(pp,10) end)
    spawn(function() fireproximityprompt(pp,10) end)
    spawn(function() fireproximityprompt(pp,10) end)
    spawn(function() fireproximityprompt(pp,10) end)
    spawn(function() fireproximityprompt(pp,10) end)
    spawn(function() fireproximityprompt(pp,10) end)
    spawn(function() fireproximityprompt(pp,10) end)
    spawn(function() fireproximityprompt(pp,10) end)
    spawn(function() fireproximityprompt(pp,10) end)
    spawn(function() fireproximityprompt(pp,10) end)
    spawn(function() fireproximityprompt(pp,10) end)
    spawn(function() fireproximityprompt(pp,10) end)
    spawn(function() fireproximityprompt(pp,10) end)
    spawn(function() fireproximityprompt(pp,10) end)
    spawn(function() fireproximityprompt(pp,10) end)
    spawn(function() fireproximityprompt(pp,10) end)
    spawn(function() fireproximityprompt(pp,10) end)
    spawn(function() fireproximityprompt(pp,10) end)
    spawn(function() fireproximityprompt(pp,10) end)
    spawn(function() fireproximityprompt(pp,10) end)
    spawn(function() fireproximityprompt(pp,10) end)
    spawn(function() fireproximityprompt(pp,10) end)
    spawn(function() fireproximityprompt(pp,10) end)
    spawn(function() fireproximityprompt(pp,10) end)
    spawn(function() fireproximityprompt(pp,10) end)
    spawn(function() fireproximityprompt(pp,10) end)
    spawn(function() fireproximityprompt(pp,10) end)
    spawn(function() fireproximityprompt(pp,10) end)
    spawn(function() fireproximityprompt(pp,10) end)
    spawn(function() fireproximityprompt(pp,10) end)
    spawn(function() fireproximityprompt(pp,10) end)
    spawn(function() fireproximityprompt(pp,10) end)
    spawn(function() fireproximityprompt(pp,10) end)
    spawn(function() fireproximityprompt(pp,10) end)
    spawn(function() fireproximityprompt(pp,10) end)
    spawn(function() fireproximityprompt(pp,10) end)
    spawn(function() fireproximityprompt(pp,10) end)
    spawn(function() fireproximityprompt(pp,10) end)
    spawn(function() fireproximityprompt(pp,10) end)
    spawn(function() fireproximityprompt(pp,10) end)
    spawn(function() fireproximityprompt(pp,10) end)
    spawn(function() fireproximityprompt(pp,10) end)
    spawn(function() fireproximityprompt(pp,10) end)
    spawn(function() fireproximityprompt(pp,10) end)
    spawn(function() fireproximityprompt(pp,10) end)
    spawn(function() fireproximityprompt(pp,10) end)
    spawn(function() fireproximityprompt(pp,10) end)
    spawn(function() fireproximityprompt(pp,10) end)
    spawn(function() fireproximityprompt(pp,10) end)
    spawn(function() fireproximityprompt(pp,10) end)
    spawn(function() fireproximityprompt(pp,10) end)
    spawn(function() fireproximityprompt(pp,10) end)
    spawn(function() fireproximityprompt(pp,10) end)
    spawn(function() fireproximityprompt(pp,10) end)
    spawn(function() fireproximityprompt(pp,10) end)
    spawn(function() fireproximityprompt(pp,10) end)
    spawn(function() fireproximityprompt(pp,10) end)
    spawn(function() fireproximityprompt(pp,10) end)
    spawn(function() fireproximityprompt(pp,10) end)
    spawn(function() fireproximityprompt(pp,10) end)
    spawn(function() fireproximityprompt(pp,10) end)
    spawn(function() fireproximityprompt(pp,10) end)
    spawn(function() fireproximityprompt(pp,10) end)
    spawn(function() fireproximityprompt(pp,10) end)
    spawn(function() fireproximityprompt(pp,10) end)
    spawn(function() fireproximityprompt(pp,10) end)
    spawn(function() fireproximityprompt(pp,10) end)
    spawn(function() fireproximityprompt(pp,10) end)
    spawn(function() fireproximityprompt(pp,10) end)
    spawn(function() fireproximityprompt(pp,10) end)
    spawn(function() fireproximityprompt(pp,10) end)
    spawn(function() fireproximityprompt(pp,10) end)
    spawn(function() fireproximityprompt(pp,10) end)
    spawn(function() fireproximityprompt(pp,10) end)
    spawn(function() fireproximityprompt(pp,10) end)
    spawn(function() fireproximityprompt(pp,10) end)
    spawn(function() fireproximityprompt(pp,10) end)
    spawn(function() fireproximityprompt(pp,10) end)
    spawn(function() fireproximityprompt(pp,10) end)
    spawn(function() fireproximityprompt(pp,10) end)
    spawn(function() fireproximityprompt(pp,10) end)
    spawn(function() fireproximityprompt(pp,10) end)
    spawn(function() fireproximityprompt(pp,10) end)
    spawn(function() fireproximityprompt(pp,10) end)
    spawn(function() fireproximityprompt(pp,10) end)
    spawn(function() fireproximityprompt(pp,10) end)
    spawn(function() fireproximityprompt(pp,10) end)
    spawn(function() fireproximityprompt(pp,10) end)
    spawn(function() fireproximityprompt(pp,10) end)
    spawn(function() fireproximityprompt(pp,10) end)
    spawn(function() fireproximityprompt(pp,10) end)
    spawn(function() fireproximityprompt(pp,10) end)
    spawn(function() fireproximityprompt(pp,10) end)
    spawn(function() fireproximityprompt(pp,10) end)
    spawn(function() fireproximityprompt(pp,10) end)
    spawn(function() fireproximityprompt(pp,10) end)
    spawn(function() fireproximityprompt(pp,10) end)
    spawn(function() fireproximityprompt(pp,10) end)
    spawn(function() fireproximityprompt(pp,10) end)
    spawn(function() fireproximityprompt(pp,10) end)
    spawn(function() fireproximityprompt(pp,10) end)
    spawn(function() fireproximityprompt(pp,10) end)
    spawn(function() fireproximityprompt(pp,10) end)
    spawn(function() fireproximityprompt(pp,10) end)
    spawn(function() fireproximityprompt(pp,10) end)
    spawn(function() fireproximityprompt(pp,10) end)
    spawn(function() fireproximityprompt(pp,10) end)
    spawn(function() fireproximityprompt(pp,10) end)
    spawn(function() fireproximityprompt(pp,10) end)
    spawn(function() fireproximityprompt(pp,10) end)
    spawn(function() fireproximityprompt(pp,10) end)
    spawn(function() fireproximityprompt(pp,10) end)
    spawn(function() fireproximityprompt(pp,10) end)
    spawn(function() fireproximityprompt(pp,10) end)
    spawn(function() fireproximityprompt(pp,10) end)
    spawn(function() fireproximityprompt(pp,10) end)
    spawn(function() fireproximityprompt(pp,10) end)
    spawn(function() fireproximityprompt(pp,10) end)
    spawn(function() fireproximityprompt(pp,10) end)
    spawn(function() fireproximityprompt(pp,10) end)
    spawn(function() fireproximityprompt(pp,10) end)
    spawn(function() fireproximityprompt(pp,10) end)
    spawn(function() fireproximityprompt(pp,10) end)
    spawn(function() fireproximityprompt(pp,10) end)
    spawn(function() fireproximityprompt(pp,10) end)
    spawn(function() fireproximityprompt(pp,10) end)
    spawn(function() fireproximityprompt(pp,10) end)
    spawn(function() fireproximityprompt(pp,10) end)
    spawn(function() fireproximityprompt(pp,10) end)
    spawn(function() fireproximityprompt(pp,10) end)
    spawn(function() fireproximityprompt(pp,10) end)
    spawn(function() fireproximityprompt(pp,10) end)
    spawn(function() fireproximityprompt(pp,10) end)
    spawn(function() fireproximityprompt(pp,10) end)
    spawn(function() fireproximityprompt(pp,10) end)
    spawn(function() fireproximityprompt(pp,10) end)
    spawn(function() fireproximityprompt(pp,10) end)
    spawn(function() fireproximityprompt(pp,10) end)
    spawn(function() fireproximityprompt(pp,10) end)
    spawn(function() fireproximityprompt(pp,10) end)
    spawn(function() fireproximityprompt(pp,10) end)
    spawn(function() fireproximityprompt(pp,10) end)
    spawn(function() fireproximityprompt(pp,10) end)
    spawn(function() fireproximityprompt(pp,10) end)
    spawn(function() fireproximityprompt(pp,10) end)
    spawn(function() fireproximityprompt(pp,10) end)
    spawn(function() fireproximityprompt(pp,10) end)
    spawn(function() fireproximityprompt(pp,10) end)
    spawn(function() fireproximityprompt(pp,10) end)
    spawn(function() fireproximityprompt(pp,10) end)
    spawn(function() fireproximityprompt(pp,10) end)
    spawn(function() fireproximityprompt(pp,10) end)
    spawn(function() fireproximityprompt(pp,10) end)
    spawn(function() fireproximityprompt(pp,10) end)
    spawn(function() fireproximityprompt(pp,10) end)
    spawn(function() fireproximityprompt(pp,10) end)
    spawn(function() fireproximityprompt(pp,10) end)
    spawn(function() fireproximityprompt(pp,10) end)
    spawn(function() fireproximityprompt(pp,10) end)
    spawn(function() fireproximityprompt(pp,10) end)
    spawn(function() fireproximityprompt(pp,10) end)
    spawn(function() fireproximityprompt(pp,10) end)
    spawn(function() fireproximityprompt(pp,10) end)
    spawn(function() fireproximityprompt(pp,10) end)
    spawn(function() fireproximityprompt(pp,10) end)
    spawn(function() fireproximityprompt(pp,10) end)
    spawn(function() fireproximityprompt(pp,10) end)
    spawn(function() fireproximityprompt(pp,10) end)
    spawn(function() fireproximityprompt(pp,10) end)
    spawn(function() fireproximityprompt(pp,10) end)
    spawn(function() fireproximityprompt(pp,10) end)
    spawn(function() fireproximityprompt(pp,10) end)
    spawn(function() fireproximityprompt(pp,10) end)
    spawn(function() fireproximityprompt(pp,10) end)
    spawn(function() fireproximityprompt(pp,10) end)
    spawn(function() fireproximityprompt(pp,10) end)
    spawn(function() fireproximityprompt(pp,10) end)
    spawn(function() fireproximityprompt(pp,10) end)
    spawn(function() fireproximityprompt(pp,10) end)
    spawn(function() fireproximityprompt(pp,10) end)
    spawn(function() fireproximityprompt(pp,10) end)
    spawn(function() fireproximityprompt(pp,10) end)
    spawn(function() fireproximityprompt(pp,10) end)
    spawn(function() fireproximityprompt(pp,10) end)
    spawn(function() fireproximityprompt(pp,10) end)
    spawn(function() fireproximityprompt(pp,10) end)
    spawn(function() fireproximityprompt(pp,10) end)
    spawn(function() fireproximityprompt(pp,10) end)
    spawn(function() fireproximityprompt(pp,10) end)
    spawn(function() fireproximityprompt(pp,10) end)
    spawn(function() fireproximityprompt(pp,10) end)
    spawn(function() fireproximityprompt(pp,10) end)
    spawn(function() fireproximityprompt(pp,10) end)
    spawn(function() fireproximityprompt(pp,10) end)
    spawn(function() fireproximityprompt(pp,10) end)
    spawn(function() fireproximityprompt(pp,10) end)
    spawn(function() fireproximityprompt(pp,10) end)
    spawn(function() fireproximityprompt(pp,10) end)
    spawn(function() fireproximityprompt(pp,10) end)
    spawn(function() fireproximityprompt(pp,10) end)
    spawn(function() fireproximityprompt(pp,10) end)
    spawn(function() fireproximityprompt(pp,10) end)
    spawn(function() fireproximityprompt(pp,10) end)
    spawn(function() fireproximityprompt(pp,10) end)
    spawn(function() fireproximityprompt(pp,10) end)
    spawn(function() fireproximityprompt(pp,10) end)
    spawn(function() fireproximityprompt(pp,10) end)
    spawn(function() fireproximityprompt(pp,10) end)
    spawn(function() fireproximityprompt(pp,10) end)
    spawn(function() fireproximityprompt(pp,10) end)
    spawn(function() fireproximityprompt(pp,10) end)
    spawn(function() fireproximityprompt(pp,10) end)
    spawn(function() fireproximityprompt(pp,10) end)
    spawn(function() fireproximityprompt(pp,10) end)
    spawn(function() fireproximityprompt(pp,10) end)
    spawn(function() fireproximityprompt(pp,10) end)
    spawn(function() fireproximityprompt(pp,10) end)
    spawn(function() fireproximityprompt(pp,10) end)
    spawn(function() fireproximityprompt(pp,10) end)
    spawn(function() fireproximityprompt(pp,10) end)
    spawn(function() fireproximityprompt(pp,10) end)
    spawn(function() fireproximityprompt(pp,10) end)
    spawn(function() fireproximityprompt(pp,10) end)
    spawn(function() fireproximityprompt(pp,10) end)
    spawn(function() fireproximityprompt(pp,10) end)
    spawn(function() fireproximityprompt(pp,10) end)
    spawn(function() fireproximityprompt(pp,10) end)
    spawn(function() fireproximityprompt(pp,10) end)
    spawn(function() fireproximityprompt(pp,10) end)
    spawn(function() fireproximityprompt(pp,10) end)
    spawn(function() fireproximityprompt(pp,10) end)
    spawn(function() fireproximityprompt(pp,10) end)
    spawn(function() fireproximityprompt(pp,10) end)
    spawn(function() fireproximityprompt(pp,10) end)
    spawn(function() fireproximityprompt(pp,10) end)
    spawn(function() fireproximityprompt(pp,10) end)
    spawn(function() fireproximityprompt(pp,10) end)
    spawn(function() fireproximityprompt(pp,10) end)
    spawn(function() fireproximityprompt(pp,10) end)
    spawn(function() fireproximityprompt(pp,10) end)
    spawn(function() fireproximityprompt(pp,10) end)
    spawn(function() fireproximityprompt(pp,10) end)
    spawn(function() fireproximityprompt(pp,10) end)
    spawn(function() fireproximityprompt(pp,10) end)
    spawn(function() fireproximityprompt(pp,10) end)
    spawn(function() fireproximityprompt(pp,10) end)
    spawn(function() fireproximityprompt(pp,10) end)
    spawn(function() fireproximityprompt(pp,10) end)
    spawn(function() fireproximityprompt(pp,10) end)
    spawn(function() fireproximityprompt(pp,10) end)
    spawn(function() fireproximityprompt(pp,10) end)
    spawn(function() fireproximityprompt(pp,10) end)
    spawn(function() fireproximityprompt(pp,10) end)
    spawn(function() fireproximityprompt(pp,10) end)
    spawn(function() fireproximityprompt(pp,10) end)
    spawn(function() fireproximityprompt(pp,10) end)
    spawn(function() fireproximityprompt(pp,10) end)
    spawn(function() fireproximityprompt(pp,10) end)
    spawn(function() fireproximityprompt(pp,10) end)
    spawn(function() fireproximityprompt(pp,10) end)
    spawn(function() fireproximityprompt(pp,10) end)
    spawn(function() fireproximityprompt(pp,10) end)
    spawn(function() fireproximityprompt(pp,10) end)
    spawn(function() fireproximityprompt(pp,10) end)
    spawn(function() fireproximityprompt(pp,10) end)
    spawn(function() fireproximityprompt(pp,10) end)
    spawn(function() fireproximityprompt(pp,10) end)
    spawn(function() fireproximityprompt(pp,10) end)
    spawn(function() fireproximityprompt(pp,10) end)
    spawn(function() fireproximityprompt(pp,10) end)
    spawn(function() fireproximityprompt(pp,10) end)
    spawn(function() fireproximityprompt(pp,10) end)
    spawn(function() fireproximityprompt(pp,10) end)
    spawn(function() fireproximityprompt(pp,10) end)
    spawn(function() fireproximityprompt(pp,10) end)
    spawn(function() fireproximityprompt(pp,10) end)
    spawn(function() fireproximityprompt(pp,10) end)
    spawn(function() fireproximityprompt(pp,10) end)
    spawn(function() fireproximityprompt(pp,10) end)
    spawn(function() fireproximityprompt(pp,10) end)
    spawn(function() fireproximityprompt(pp,10) end)
    spawn(function() fireproximityprompt(pp,10) end)
    spawn(function() fireproximityprompt(pp,10) end)
    spawn(function() fireproximityprompt(pp,10) end)
    spawn(function() fireproximityprompt(pp,10) end)
    spawn(function() fireproximityprompt(pp,10) end)
    spawn(function() fireproximityprompt(pp,10) end)
    spawn(function() fireproximityprompt(pp,10) end)
    spawn(function() fireproximityprompt(pp,10) end)
    spawn(function() fireproximityprompt(pp,10) end)
    spawn(function() fireproximityprompt(pp,10) end)
    spawn(function() fireproximityprompt(pp,10) end)
    spawn(function() fireproximityprompt(pp,10) end)
    spawn(function() fireproximityprompt(pp,10) end)
    spawn(function() fireproximityprompt(pp,10) end)
    spawn(function() fireproximityprompt(pp,10) end)
    spawn(function() fireproximityprompt(pp,10) end)
    spawn(function() fireproximityprompt(pp,10) end)
    spawn(function() fireproximityprompt(pp,10) end)
    spawn(function() fireproximityprompt(pp,10) end)
    spawn(function() fireproximityprompt(pp,10) end)
    spawn(function() fireproximityprompt(pp,10) end)
    spawn(function() fireproximityprompt(pp,10) end)
    spawn(function() fireproximityprompt(pp,10) end)
    spawn(function() fireproximityprompt(pp,10) end)
    spawn(function() fireproximityprompt(pp,10) end)
    spawn(function() fireproximityprompt(pp,10) end)
    spawn(function() fireproximityprompt(pp,10) end)
    spawn(function() fireproximityprompt(pp,10) end)
    spawn(function() fireproximityprompt(pp,10) end)
    spawn(function() fireproximityprompt(pp,10) end)
    spawn(function() fireproximityprompt(pp,10) end)
    spawn(function() fireproximityprompt(pp,10) end)
    spawn(function() fireproximityprompt(pp,10) end)
    spawn(function() fireproximityprompt(pp,10) end)
    spawn(function() fireproximityprompt(pp,10) end)
    spawn(function() fireproximityprompt(pp,10) end)
    spawn(function() fireproximityprompt(pp,10) end)
    spawn(function() fireproximityprompt(pp,10) end)
    spawn(function() fireproximityprompt(pp,10) end)
    spawn(function() fireproximityprompt(pp,10) end)
    spawn(function() fireproximityprompt(pp,10) end)
    spawn(function() fireproximityprompt(pp,10) end)
    spawn(function() fireproximityprompt(pp,10) end)
    spawn(function() fireproximityprompt(pp,10) end)
    spawn(function() fireproximityprompt(pp,10) end)
    spawn(function() fireproximityprompt(pp,10) end)
    spawn(function() fireproximityprompt(pp,10) end)
    spawn(function() fireproximityprompt(pp,10) end)
    spawn(function() fireproximityprompt(pp,10) end)
    spawn(function() fireproximityprompt(pp,10) end)
    spawn(function() fireproximityprompt(pp,10) end)
    spawn(function() fireproximityprompt(pp,10) end)
    spawn(function() fireproximityprompt(pp,10) end)
    spawn(function() fireproximityprompt(pp,10) end)
    spawn(function() fireproximityprompt(pp,10) end)
    spawn(function() fireproximityprompt(pp,10) end)
    spawn(function() fireproximityprompt(pp,10) end)
    spawn(function() fireproximityprompt(pp,10) end)
    spawn(function() fireproximityprompt(pp,10) end)
    spawn(function() fireproximityprompt(pp,10) end)
    spawn(function() fireproximityprompt(pp,10) end)
    spawn(function() fireproximityprompt(pp,10) end)
    spawn(function() fireproximityprompt(pp,10) end)
    spawn(function() fireproximityprompt(pp,10) end)
    spawn(function() fireproximityprompt(pp,10) end)
    spawn(function() fireproximityprompt(pp,10) end)
    spawn(function() fireproximityprompt(pp,10) end)
    spawn(function() fireproximityprompt(pp,10) end)
    spawn(function() fireproximityprompt(pp,10) end)
    spawn(function() fireproximityprompt(pp,10) end)
    spawn(function() fireproximityprompt(pp,10) end)
    spawn(function() fireproximityprompt(pp,10) end)
    spawn(function() fireproximityprompt(pp,10) end)
    spawn(function() fireproximityprompt(pp,10) end)
    spawn(function() fireproximityprompt(pp,10) end)
    spawn(function() fireproximityprompt(pp,10) end)
    spawn(function() fireproximityprompt(pp,10) end)
    spawn(function() fireproximityprompt(pp,10) end)
    spawn(function() fireproximityprompt(pp,10) end)
    spawn(function() fireproximityprompt(pp,10) end)
    spawn(function() fireproximityprompt(pp,10) end)
    spawn(function() fireproximityprompt(pp,10) end)
    spawn(function() fireproximityprompt(pp,10) end)
    spawn(function() fireproximityprompt(pp,10) end)
    spawn(function() fireproximityprompt(pp,10) end)
    spawn(function() fireproximityprompt(pp,10) end)
    spawn(function() fireproximityprompt(pp,10) end)
    spawn(function() fireproximityprompt(pp,10) end)
    spawn(function() fireproximityprompt(pp,10) end)
    spawn(function() fireproximityprompt(pp,10) end)
    spawn(function() fireproximityprompt(pp,10) end)
    spawn(function() fireproximityprompt(pp,10) end)
    spawn(function() fireproximityprompt(pp,10) end)
    spawn(function() fireproximityprompt(pp,10) end)
    spawn(function() fireproximityprompt(pp,10) end)
    spawn(function() fireproximityprompt(pp,10) end)
    spawn(function() fireproximityprompt(pp,10) end)
    spawn(function() fireproximityprompt(pp,10) end)
    spawn(function() fireproximityprompt(pp,10) end)
    spawn(function() fireproximityprompt(pp,10) end)
    spawn(function() fireproximityprompt(pp,10) end)
    spawn(function() fireproximityprompt(pp,10) end)
    spawn(function() fireproximityprompt(pp,10) end)
    spawn(function() fireproximityprompt(pp,10) end)
    spawn(function() fireproximityprompt(pp,10) end)
    spawn(function() fireproximityprompt(pp,10) end)
    spawn(function() fireproximityprompt(pp,10) end)
    spawn(function() fireproximityprompt(pp,10) end)
    spawn(function() fireproximityprompt(pp,10) end)
    spawn(function() fireproximityprompt(pp,10) end)
    spawn(function() fireproximityprompt(pp,10) end)
    spawn(function() fireproximityprompt(pp,10) end)
    spawn(function() fireproximityprompt(pp,10) end)
    spawn(function() fireproximityprompt(pp,10) end)
    spawn(function() fireproximityprompt(pp,10) end)
    spawn(function() fireproximityprompt(pp,10) end)
    spawn(function() fireproximityprompt(pp,10) end)
    spawn(function() fireproximityprompt(pp,10) end)
    spawn(function() fireproximityprompt(pp,10) end)
    spawn(function() fireproximityprompt(pp,10) end)
    spawn(function() fireproximityprompt(pp,10) end)
    spawn(function() fireproximityprompt(pp,10) end)
    spawn(function() fireproximityprompt(pp,10) end)
    spawn(function() fireproximityprompt(pp,10) end)
    spawn(function() fireproximityprompt(pp,10) end)
    spawn(function() fireproximityprompt(pp,10) end)
    spawn(function() fireproximityprompt(pp,10) end)
    spawn(function() fireproximityprompt(pp,10) end)
    spawn(function() fireproximityprompt(pp,10) end)
    spawn(function() fireproximityprompt(pp,10) end)
    spawn(function() fireproximityprompt(pp,10) end)
    spawn(function() fireproximityprompt(pp,10) end)
    spawn(function() fireproximityprompt(pp,10) end)
    spawn(function() fireproximityprompt(pp,10) end)
    spawn(function() fireproximityprompt(pp,10) end)
    spawn(function() fireproximityprompt(pp,10) end)
    spawn(function() fireproximityprompt(pp,10) end)
    spawn(function() fireproximityprompt(pp,10) end)
    spawn(function() fireproximityprompt(pp,10) end)
    spawn(function() fireproximityprompt(pp,10) end)
    spawn(function() fireproximityprompt(pp,10) end)
    spawn(function() fireproximityprompt(pp,10) end)
    spawn(function() fireproximityprompt(pp,10) end)
    spawn(function() fireproximityprompt(pp,10) end)
    spawn(function() fireproximityprompt(pp,10) end)
    spawn(function() fireproximityprompt(pp,10) end)
    spawn(function() fireproximityprompt(pp,10) end)
    spawn(function() fireproximityprompt(pp,10) end)
    spawn(function() fireproximityprompt(pp,10) end)
    spawn(function() fireproximityprompt(pp,10) end)
    spawn(function() fireproximityprompt(pp,10) end)
    spawn(function() fireproximityprompt(pp,10) end)
    spawn(function() fireproximityprompt(pp,10) end)
    spawn(function() fireproximityprompt(pp,10) end)
    spawn(function() fireproximityprompt(pp,10) end)
    spawn(function() fireproximityprompt(pp,10) end)
    spawn(function() fireproximityprompt(pp,10) end)
    spawn(function() fireproximityprompt(pp,10) end)
    spawn(function() fireproximityprompt(pp,10) end)
    spawn(function() fireproximityprompt(pp,10) end)
    spawn(function() fireproximityprompt(pp,10) end)
    spawn(function() fireproximityprompt(pp,10) end)
    spawn(function() fireproximityprompt(pp,10) end)
    spawn(function() fireproximityprompt(pp,10) end)
    spawn(function() fireproximityprompt(pp,10) end)
    spawn(function() fireproximityprompt(pp,10) end)
    spawn(function() fireproximityprompt(pp,10) end)
    spawn(function() fireproximityprompt(pp,10) end)
    spawn(function() fireproximityprompt(pp,10) end)
    spawn(function() fireproximityprompt(pp,10) end)
    spawn(function() fireproximityprompt(pp,10) end)
    spawn(function() fireproximityprompt(pp,10) end)
    spawn(function() fireproximityprompt(pp,10) end)
    spawn(function() fireproximityprompt(pp,10) end)
    spawn(function() fireproximityprompt(pp,10) end)
    spawn(function() fireproximityprompt(pp,10) end)
    spawn(function() fireproximityprompt(pp,10) end)
    spawn(function() fireproximityprompt(pp,10) end)
    spawn(function() fireproximityprompt(pp,10) end)
    spawn(function() fireproximityprompt(pp,10) end)
    spawn(function() fireproximityprompt(pp,10) end)
    spawn(function() fireproximityprompt(pp,10) end)
    spawn(function() fireproximityprompt(pp,10) end)
    spawn(function() fireproximityprompt(pp,10) end)
    spawn(function() fireproximityprompt(pp,10) end)
    spawn(function() fireproximityprompt(pp,10) end)
    spawn(function() fireproximityprompt(pp,10) end)
    spawn(function() fireproximityprompt(pp,10) end)
    spawn(function() fireproximityprompt(pp,10) end)
    spawn(function() fireproximityprompt(pp,10) end)
    spawn(function() fireproximityprompt(pp,10) end)
    spawn(function() fireproximityprompt(pp,10) end)
    spawn(function() fireproximityprompt(pp,10) end)
    spawn(function() fireproximityprompt(pp,10) end)
    spawn(function() fireproximityprompt(pp,10) end)
    spawn(function() fireproximityprompt(pp,10) end)
    spawn(function() fireproximityprompt(pp,10) end)
    spawn(function() fireproximityprompt(pp,10) end)
    spawn(function() fireproximityprompt(pp,10) end)
    spawn(function() fireproximityprompt(pp,10) end)
    spawn(function() fireproximityprompt(pp,10) end)
    spawn(function() fireproximityprompt(pp,10) end)
    spawn(function() fireproximityprompt(pp,10) end)
    spawn(function() fireproximityprompt(pp,10) end)
    spawn(function() fireproximityprompt(pp,10) end)
    spawn(function() fireproximityprompt(pp,10) end)
    spawn(function() fireproximityprompt(pp,10) end)
    spawn(function() fireproximityprompt(pp,10) end)
    spawn(function() fireproximityprompt(pp,10) end)
    spawn(function() fireproximityprompt(pp,10) end)
    spawn(function() fireproximityprompt(pp,10) end)
    spawn(function() fireproximityprompt(pp,10) end)
    spawn(function() fireproximityprompt(pp,10) end)
    spawn(function() fireproximityprompt(pp,10) end)
    spawn(function() fireproximityprompt(pp,10) end)
    spawn(function() fireproximityprompt(pp,10) end)
    spawn(function() fireproximityprompt(pp,10) end)
    spawn(function() fireproximityprompt(pp,10) end)
    spawn(function() fireproximityprompt(pp,10) end)
    spawn(function() fireproximityprompt(pp,10) end)
    spawn(function() fireproximityprompt(pp,10) end)
    spawn(function() fireproximityprompt(pp,10) end)
    spawn(function() fireproximityprompt(pp,10) end)
    spawn(function() fireproximityprompt(pp,10) end)
    spawn(function() fireproximityprompt(pp,10) end)
    spawn(function() fireproximityprompt(pp,10) end)
    spawn(function() fireproximityprompt(pp,10) end)
    spawn(function() fireproximityprompt(pp,10) end)
    spawn(function() fireproximityprompt(pp,10) end)
    spawn(function() fireproximityprompt(pp,10) end)
    spawn(function() fireproximityprompt(pp,10) end)
    spawn(function() fireproximityprompt(pp,10) end)
    spawn(function() fireproximityprompt(pp,10) end)
    spawn(function() fireproximityprompt(pp,10) end)
    spawn(function() fireproximityprompt(pp,10) end)
    spawn(function() fireproximityprompt(pp,10) end)
    spawn(function() fireproximityprompt(pp,10) end)
    spawn(function() fireproximityprompt(pp,10) end)
    spawn(function() fireproximityprompt(pp,10) end)
    spawn(function() fireproximityprompt(pp,10) end)
    spawn(function() fireproximityprompt(pp,10) end)
    spawn(function() fireproximityprompt(pp,10) end)
    spawn(function() fireproximityprompt(pp,10) end)
    spawn(function() fireproximityprompt(pp,10) end)
    spawn(function() fireproximityprompt(pp,10) end)
    spawn(function() fireproximityprompt(pp,10) end)
    spawn(function() fireproximityprompt(pp,10) end)
    spawn(function() fireproximityprompt(pp,10) end)
    spawn(function() fireproximityprompt(pp,10) end)
    spawn(function() fireproximityprompt(pp,10) end)
    spawn(function() fireproximityprompt(pp,10) end)
    spawn(function() fireproximityprompt(pp,10) end)
    spawn(function() fireproximityprompt(pp,10) end)
    spawn(function() fireproximityprompt(pp,10) end)
    spawn(function() fireproximityprompt(pp,10) end)
    spawn(function() fireproximityprompt(pp,10) end)
    spawn(function() fireproximityprompt(pp,10) end)
    spawn(function() fireproximityprompt(pp,10) end)
    spawn(function() fireproximityprompt(pp,10) end)
    spawn(function() fireproximityprompt(pp,10) end)
    spawn(function() fireproximityprompt(pp,10) end)
    spawn(function() fireproximityprompt(pp,10) end)
    spawn(function() fireproximityprompt(pp,10) end)
    spawn(function() fireproximityprompt(pp,10) end)
    spawn(function() fireproximityprompt(pp,10) end)
    spawn(function() fireproximityprompt(pp,10) end)
    spawn(function() fireproximityprompt(pp,10) end)
    spawn(function() fireproximityprompt(pp,10) end)
    spawn(function() fireproximityprompt(pp,10) end)
    spawn(function() fireproximityprompt(pp,10) end)
    spawn(function() fireproximityprompt(pp,10) end)
    spawn(function() fireproximityprompt(pp,10) end)
    spawn(function() fireproximityprompt(pp,10) end)
    spawn(function() fireproximityprompt(pp,10) end)
    spawn(function() fireproximityprompt(pp,10) end)
    spawn(function() fireproximityprompt(pp,10) end)
    spawn(function() fireproximityprompt(pp,10) end)
    spawn(function() fireproximityprompt(pp,10) end)
    spawn(function() fireproximityprompt(pp,10) end)
    spawn(function() fireproximityprompt(pp,10) end)
    spawn(function() fireproximityprompt(pp,10) end)
    spawn(function() fireproximityprompt(pp,10) end)
    spawn(function() fireproximityprompt(pp,10) end)
    spawn(function() fireproximityprompt(pp,10) end)
    spawn(function() fireproximityprompt(pp,10) end)
    spawn(function() fireproximityprompt(pp,10) end)
    spawn(function() fireproximityprompt(pp,10) end)
    spawn(function() fireproximityprompt(pp,10) end)
    spawn(function() fireproximityprompt(pp,10) end)
    spawn(function() fireproximityprompt(pp,10) end)
    spawn(function() fireproximityprompt(pp,10) end)
    spawn(function() fireproximityprompt(pp,10) end)
    spawn(function() fireproximityprompt(pp,10) end)
    spawn(function() fireproximityprompt(pp,10) end)
    spawn(function() fireproximityprompt(pp,10) end)
    spawn(function() fireproximityprompt(pp,10) end)
    spawn(function() fireproximityprompt(pp,10) end)
    spawn(function() fireproximityprompt(pp,10) end)
    spawn(function() fireproximityprompt(pp,10) end)
    spawn(function() fireproximityprompt(pp,10) end)
    spawn(function() fireproximityprompt(pp,10) end)
    spawn(function() fireproximityprompt(pp,10) end)
    spawn(function() fireproximityprompt(pp,10) end)
    spawn(function() fireproximityprompt(pp,10) end)
    spawn(function() fireproximityprompt(pp,10) end)
    spawn(function() fireproximityprompt(pp,10) end)
    spawn(function() fireproximityprompt(pp,10) end)
    spawn(function() fireproximityprompt(pp,10) end)
    spawn(function() fireproximityprompt(pp,10) end)
    spawn(function() fireproximityprompt(pp,10) end)
    spawn(function() fireproximityprompt(pp,10) end)
    spawn(function() fireproximityprompt(pp,10) end)
    spawn(function() fireproximityprompt(pp,10) end)
    spawn(function() fireproximityprompt(pp,10) end)
    spawn(function() fireproximityprompt(pp,10) end)
    spawn(function() fireproximityprompt(pp,10) end)
    spawn(function() fireproximityprompt(pp,10) end)
    spawn(function() fireproximityprompt(pp,10) end)
    spawn(function() fireproximityprompt(pp,10) end)
    spawn(function() fireproximityprompt(pp,10) end)
    spawn(function() fireproximityprompt(pp,10) end)
    spawn(function() fireproximityprompt(pp,10) end)
    spawn(function() fireproximityprompt(pp,10) end)
    spawn(function() fireproximityprompt(pp,10) end)
    spawn(function() fireproximityprompt(pp,10) end)
    spawn(function() fireproximityprompt(pp,10) end)
    spawn(function() fireproximityprompt(pp,10) end)
    spawn(function() fireproximityprompt(pp,10) end)
    spawn(function() fireproximityprompt(pp,10) end)
    spawn(function() fireproximityprompt(pp,10) end)
    spawn(function() fireproximityprompt(pp,10) end)
    spawn(function() fireproximityprompt(pp,10) end)
    spawn(function() fireproximityprompt(pp,10) end)
    spawn(function() fireproximityprompt(pp,10) end)
    spawn(function() fireproximityprompt(pp,10) end)
    spawn(function() fireproximityprompt(pp,10) end)
    spawn(function() fireproximityprompt(pp,10) end)
    spawn(function() fireproximityprompt(pp,10) end)
    spawn(function() fireproximityprompt(pp,10) end)
    spawn(function() fireproximityprompt(pp,10) end)
    spawn(function() fireproximityprompt(pp,10) end)
    spawn(function() fireproximityprompt(pp,10) end)
    spawn(function() fireproximityprompt(pp,10) end)
    spawn(function() fireproximityprompt(pp,10) end)
    spawn(function() fireproximityprompt(pp,10) end)
    spawn(function() fireproximityprompt(pp,10) end)
    spawn(function() fireproximityprompt(pp,10) end)
    spawn(function() fireproximityprompt(pp,10) end)
    spawn(function() fireproximityprompt(pp,10) end)
    spawn(function() fireproximityprompt(pp,10) end)
    spawn(function() fireproximityprompt(pp,10) end)
    spawn(function() fireproximityprompt(pp,10) end)
    spawn(function() fireproximityprompt(pp,10) end)
    spawn(function() fireproximityprompt(pp,10) end)
    spawn(function() fireproximityprompt(pp,10) end)
    spawn(function() fireproximityprompt(pp,10) end)
    spawn(function() fireproximityprompt(pp,10) end)
    spawn(function() fireproximityprompt(pp,10) end)
    spawn(function() fireproximityprompt(pp,10) end)
    spawn(function() fireproximityprompt(pp,10) end)
    spawn(function() fireproximityprompt(pp,10) end)
    spawn(function() fireproximityprompt(pp,10) end)
    spawn(function() fireproximityprompt(pp,10) end)
    spawn(function() fireproximityprompt(pp,10) end)
    spawn(function() fireproximityprompt(pp,10) end)
    spawn(function() fireproximityprompt(pp,10) end)
    spawn(function() fireproximityprompt(pp,10) end)
    spawn(function() fireproximityprompt(pp,10) end)
    spawn(function() fireproximityprompt(pp,10) end)
    spawn(function() fireproximityprompt(pp,10) end)
    spawn(function() fireproximityprompt(pp,10) end)
    spawn(function() fireproximityprompt(pp,10) end)
    spawn(function() fireproximityprompt(pp,10) end)
    spawn(function() fireproximityprompt(pp,10) end)
    spawn(function() fireproximityprompt(pp,10) end)
    spawn(function() fireproximityprompt(pp,10) end)
    spawn(function() fireproximityprompt(pp,10) end)
    spawn(function() fireproximityprompt(pp,10) end)
    spawn(function() fireproximityprompt(pp,10) end)
    spawn(function() fireproximityprompt(pp,10) end)
    spawn(function() fireproximityprompt(pp,10) end)
    spawn(function() fireproximityprompt(pp,10) end)
    spawn(function() fireproximityprompt(pp,10) end)
    spawn(function() fireproximityprompt(pp,10) end)
    spawn(function() fireproximityprompt(pp,10) end)
    spawn(function() fireproximityprompt(pp,10) end)
    spawn(function() fireproximityprompt(pp,10) end)
    spawn(function() fireproximityprompt(pp,10) end)
    spawn(function() fireproximityprompt(pp,10) end)
    spawn(function() fireproximityprompt(pp,10) end)
    spawn(function() fireproximityprompt(pp,10) end)
    spawn(function() fireproximityprompt(pp,10) end)
    spawn(function() fireproximityprompt(pp,10) end)
    spawn(function() fireproximityprompt(pp,10) end)
    spawn(function() fireproximityprompt(pp,10) end)
    spawn(function() fireproximityprompt(pp,10) end)
    spawn(function() fireproximityprompt(pp,10) end)
    spawn(function() fireproximityprompt(pp,10) end)
    spawn(function() fireproximityprompt(pp,10) end)
    spawn(function() fireproximityprompt(pp,10) end)
    spawn(function() fireproximityprompt(pp,10) end)
    spawn(function() fireproximityprompt(pp,10) end)
    spawn(function() fireproximityprompt(pp,10) end)
    spawn(function() fireproximityprompt(pp,10) end)
    spawn(function() fireproximityprompt(pp,10) end)
    spawn(function() fireproximityprompt(pp,10) end)
    spawn(function() fireproximityprompt(pp,10) end)
    spawn(function() fireproximityprompt(pp,10) end)
    spawn(function() fireproximityprompt(pp,10) end)
    spawn(function() fireproximityprompt(pp,10) end)
    spawn(function() fireproximityprompt(pp,10) end)
    spawn(function() fireproximityprompt(pp,10) end)
    spawn(function() fireproximityprompt(pp,10) end)
    spawn(function() fireproximityprompt(pp,10) end)
    spawn(function() fireproximityprompt(pp,10) end)
    spawn(function() fireproximityprompt(pp,10) end)
    spawn(function() fireproximityprompt(pp,10) end)
    spawn(function() fireproximityprompt(pp,10) end)
    spawn(function() fireproximityprompt(pp,10) end)
    spawn(function() fireproximityprompt(pp,10) end)
    spawn(function() fireproximityprompt(pp,10) end)
    spawn(function() fireproximityprompt(pp,10) end)
    spawn(function() fireproximityprompt(pp,10) end)
    spawn(function() fireproximityprompt(pp,10) end)
    spawn(function() fireproximityprompt(pp,10) end)
    spawn(function() fireproximityprompt(pp,10) end)
    spawn(function() fireproximityprompt(pp,10) end)
    spawn(function() fireproximityprompt(pp,10) end)
    spawn(function() fireproximityprompt(pp,10) end)
    spawn(function() fireproximityprompt(pp,10) end)
    spawn(function() fireproximityprompt(pp,10) end)
    spawn(function() fireproximityprompt(pp,10) end)
    spawn(function() fireproximityprompt(pp,10) end)
    spawn(function() fireproximityprompt(pp,10) end)
    spawn(function() fireproximityprompt(pp,10) end)
    spawn(function() fireproximityprompt(pp,10) end)
    spawn(function() fireproximityprompt(pp,10) end)
    spawn(function() fireproximityprompt(pp,10) end)
    spawn(function() fireproximityprompt(pp,10) end)
    spawn(function() fireproximityprompt(pp,10) end)
    spawn(function() fireproximityprompt(pp,10) end)
    spawn(function() fireproximityprompt(pp,10) end)
    spawn(function() fireproximityprompt(pp,10) end)
    spawn(function() fireproximityprompt(pp,10) end)
    spawn(function() fireproximityprompt(pp,10) end)
    spawn(function() fireproximityprompt(pp,10) end)
    spawn(function() fireproximityprompt(pp,10) end)
    spawn(function() fireproximityprompt(pp,10) end)
    spawn(function() fireproximityprompt(pp,10) end)
    spawn(function() fireproximityprompt(pp,10) end)
    spawn(function() fireproximityprompt(pp,10) end)
    spawn(function() fireproximityprompt(pp,10) end)
    spawn(function() fireproximityprompt(pp,10) end)
    spawn(function() fireproximityprompt(pp,10) end)
    spawn(function() fireproximityprompt(pp,10) end)
    spawn(function() fireproximityprompt(pp,10) end)
    spawn(function() fireproximityprompt(pp,10) end)
    spawn(function() fireproximityprompt(pp,10) end)
    spawn(function() fireproximityprompt(pp,10) end)
    spawn(function() fireproximityprompt(pp,10) end)
    spawn(function() fireproximityprompt(pp,10) end)
    spawn(function() fireproximityprompt(pp,10) end)
    spawn(function() fireproximityprompt(pp,10) end)
    spawn(function() fireproximityprompt(pp,10) end)
    spawn(function() fireproximityprompt(pp,10) end)
    spawn(function() fireproximityprompt(pp,10) end)
    spawn(function() fireproximityprompt(pp,10) end)
    spawn(function() fireproximityprompt(pp,10) end)
    spawn(function() fireproximityprompt(pp,10) end)
    spawn(function() fireproximityprompt(pp,10) end)
    spawn(function() fireproximityprompt(pp,10) end)
    spawn(function() fireproximityprompt(pp,10) end)
    spawn(function() fireproximityprompt(pp,10) end)
    spawn(function() fireproximityprompt(pp,10) end)
    spawn(function() fireproximityprompt(pp,10) end)
    spawn(function() fireproximityprompt(pp,10) end)
    spawn(function() fireproximityprompt(pp,10) end)
    spawn(function() fireproximityprompt(pp,10) end)
    spawn(function() fireproximityprompt(pp,10) end)
    spawn(function() fireproximityprompt(pp,10) end)
    spawn(function() fireproximityprompt(pp,10) end)
    spawn(function() fireproximityprompt(pp,10) end)
    spawn(function() fireproximityprompt(pp,10) end)
    spawn(function() fireproximityprompt(pp,10) end)
    spawn(function() fireproximityprompt(pp,10) end)
    spawn(function() fireproximityprompt(pp,10) end)
    spawn(function() fireproximityprompt(pp,10) end)
    spawn(function() fireproximityprompt(pp,10) end)
    spawn(function() fireproximityprompt(pp,10) end)
    spawn(function() fireproximityprompt(pp,10) end)
    spawn(function() fireproximityprompt(pp,10) end)
    spawn(function() fireproximityprompt(pp,10) end)
    spawn(function() fireproximityprompt(pp,10) end)
    spawn(function() fireproximityprompt(pp,10) end)
    spawn(function() fireproximityprompt(pp,10) end)
    spawn(function() fireproximityprompt(pp,10) end)
    spawn(function() fireproximityprompt(pp,10) end)
    spawn(function() fireproximityprompt(pp,10) end)
    spawn(function() fireproximityprompt(pp,10) end)
    spawn(function() fireproximityprompt(pp,10) end)
    spawn(function() fireproximityprompt(pp,10) end)
    spawn(function() fireproximityprompt(pp,10) end)
    spawn(function() fireproximityprompt(pp,10) end)
    spawn(function() fireproximityprompt(pp,10) end)
    spawn(function() fireproximityprompt(pp,10) end)
    spawn(function() fireproximityprompt(pp,10) end)
    spawn(function() fireproximityprompt(pp,10) end)
    spawn(function() fireproximityprompt(pp,10) end)
    spawn(function() fireproximityprompt(pp,10) end)
    spawn(function() fireproximityprompt(pp,10) end)
    spawn(function() fireproximityprompt(pp,10) end)
    spawn(function() fireproximityprompt(pp,10) end)
    spawn(function() fireproximityprompt(pp,10) end)
    spawn(function() fireproximityprompt(pp,10) end)
    spawn(function() fireproximityprompt(pp,10) end)
    spawn(function() fireproximityprompt(pp,10) end)
    spawn(function() fireproximityprompt(pp,10) end)
    spawn(function() fireproximityprompt(pp,10) end)
    spawn(function() fireproximityprompt(pp,10) end)
    spawn(function() fireproximityprompt(pp,10) end)
    spawn(function() fireproximityprompt(pp,10) end)
    spawn(function() fireproximityprompt(pp,10) end)
    spawn(function() fireproximityprompt(pp,10) end)
    spawn(function() fireproximityprompt(pp,10) end)
    spawn(function() fireproximityprompt(pp,10) end)
    spawn(function() fireproximityprompt(pp,10) end)
    spawn(function() fireproximityprompt(pp,10) end)
    spawn(function() fireproximityprompt(pp,10) end)
    spawn(function() fireproximityprompt(pp,10) end)
    spawn(function() fireproximityprompt(pp,10) end)
    spawn(function() fireproximityprompt(pp,10) end)
    spawn(function() fireproximityprompt(pp,10) end)
    spawn(function() fireproximityprompt(pp,10) end)
    spawn(function() fireproximityprompt(pp,10) end)
    spawn(function() fireproximityprompt(pp,10) end)
    spawn(function() fireproximityprompt(pp,10) end)
    spawn(function() fireproximityprompt(pp,10) end)
    spawn(function() fireproximityprompt(pp,10) end)
    spawn(function() fireproximityprompt(pp,10) end)
    spawn(function() fireproximityprompt(pp,10) end)
    spawn(function() fireproximityprompt(pp,10) end)
    spawn(function() fireproximityprompt(pp,10) end)
    spawn(function() fireproximityprompt(pp,10) end)
    spawn(function() fireproximityprompt(pp,10) end)
    spawn(function() fireproximityprompt(pp,10) end)
    spawn(function() fireproximityprompt(pp,10) end)
    spawn(function() fireproximityprompt(pp,10) end)
    spawn(function() fireproximityprompt(pp,10) end)
    spawn(function() fireproximityprompt(pp,10) end)
    spawn(function() fireproximityprompt(pp,10) end)
    spawn(function() fireproximityprompt(pp,10) end)
    spawn(function() fireproximityprompt(pp,10) end)
    spawn(function() fireproximityprompt(pp,10) end)
    spawn(function() fireproximityprompt(pp,10) end)
    spawn(function() fireproximityprompt(pp,10) end)
    spawn(function() fireproximityprompt(pp,10) end)
    spawn(function() fireproximityprompt(pp,10) end)
    spawn(function() fireproximityprompt(pp,10) end)
    spawn(function() fireproximityprompt(pp,10) end)
    spawn(function() fireproximityprompt(pp,10) end)
    spawn(function() fireproximityprompt(pp,10) end)
    spawn(function() fireproximityprompt(pp,10) end)
    spawn(function() fireproximityprompt(pp,10) end)
    spawn(function() fireproximityprompt(pp,10) end)
    spawn(function() fireproximityprompt(pp,10) end)
    spawn(function() fireproximityprompt(pp,10) end)
    spawn(function() fireproximityprompt(pp,10) end)
    spawn(function() fireproximityprompt(pp,10) end)
    spawn(function() fireproximityprompt(pp,10) end)
    spawn(function() fireproximityprompt(pp,10) end)
    spawn(function() fireproximityprompt(pp,10) end)
    spawn(function() fireproximityprompt(pp,10) end)
    spawn(function() fireproximityprompt(pp,10) end)
    spawn(function() fireproximityprompt(pp,10) end)
    spawn(function() fireproximityprompt(pp,10) end)
    spawn(function() fireproximityprompt(pp,10) end)
    spawn(function() fireproximityprompt(pp,10) end)
    spawn(function() fireproximityprompt(pp,10) end)
    spawn(function() fireproximityprompt(pp,10) end)
    spawn(function() fireproximityprompt(pp,10) end)
    spawn(function() fireproximityprompt(pp,10) end)
    spawn(function() fireproximityprompt(pp,10) end)
    spawn(function() fireproximityprompt(pp,10) end)
    spawn(function() fireproximityprompt(pp,10) end)
    spawn(function() fireproximityprompt(pp,10) end)
    spawn(function() fireproximityprompt(pp,10) end)
    spawn(function() fireproximityprompt(pp,10) end)
    spawn(function() fireproximityprompt(pp,10) end)
    spawn(function() fireproximityprompt(pp,10) end)
    spawn(function() fireproximityprompt(pp,10) end)
    spawn(function() fireproximityprompt(pp,10) end)
    spawn(function() fireproximityprompt(pp,10) end)
    spawn(function() fireproximityprompt(pp,10) end)
    spawn(function() fireproximityprompt(pp,10) end)
    spawn(function() fireproximityprompt(pp,10) end)
    spawn(function() fireproximityprompt(pp,10) end)
    spawn(function() fireproximityprompt(pp,10) end)
    spawn(function() fireproximityprompt(pp,10) end)
    spawn(function() fireproximityprompt(pp,10) end)
    spawn(function() fireproximityprompt(pp,10) end)
    spawn(function() fireproximityprompt(pp,10) end)
    spawn(function() fireproximityprompt(pp,10) end)
    spawn(function() fireproximityprompt(pp,10) end)
    spawn(function() fireproximityprompt(pp,10) end)
    spawn(function() fireproximityprompt(pp,10) end)
    spawn(function() fireproximityprompt(pp,10) end)
    spawn(function() fireproximityprompt(pp,10) end)
    spawn(function() fireproximityprompt(pp,10) end)
    spawn(function() fireproximityprompt(pp,10) end)
    spawn(function() fireproximityprompt(pp,10) end)
    spawn(function() fireproximityprompt(pp,10) end)
    spawn(function() fireproximityprompt(pp,10) end)
    spawn(function() fireproximityprompt(pp,10) end)
    spawn(function() fireproximityprompt(pp,10) end)
    spawn(function() fireproximityprompt(pp,10) end)
    spawn(function() fireproximityprompt(pp,10) end)
    spawn(function() fireproximityprompt(pp,10) end)
    spawn(function() fireproximityprompt(pp,10) end)
    spawn(function() fireproximityprompt(pp,10) end)
    spawn(function() fireproximityprompt(pp,10) end)
    spawn(function() fireproximityprompt(pp,10) end)
    spawn(function() fireproximityprompt(pp,10) end)
    spawn(function() fireproximityprompt(pp,10) end)
    spawn(function() fireproximityprompt(pp,10) end)
    spawn(function() fireproximityprompt(pp,10) end)
    spawn(function() fireproximityprompt(pp,10) end)
    spawn(function() fireproximityprompt(pp,10) end)
    spawn(function() fireproximityprompt(pp,10) end)
    spawn(function() fireproximityprompt(pp,10) end)
    spawn(function() fireproximityprompt(pp,10) end)
    spawn(function() fireproximityprompt(pp,10) end)
    spawn(function() fireproximityprompt(pp,10) end)
    spawn(function() fireproximityprompt(pp,10) end)
    spawn(function() fireproximityprompt(pp,10) end)
    spawn(function() fireproximityprompt(pp,10) end)
    spawn(function() fireproximityprompt(pp,10) end)
    spawn(function() fireproximityprompt(pp,10) end)
    spawn(function() fireproximityprompt(pp,10) end)
    spawn(function() fireproximityprompt(pp,10) end)
    spawn(function() fireproximityprompt(pp,10) end)
    spawn(function() fireproximityprompt(pp,10) end)
    spawn(function() fireproximityprompt(pp,10) end)
    spawn(function() fireproximityprompt(pp,10) end)
    spawn(function() fireproximityprompt(pp,10) end)
    spawn(function() fireproximityprompt(pp,10) end)
    spawn(function() fireproximityprompt(pp,10) end)
    spawn(function() fireproximityprompt(pp,10) end)
    spawn(function() fireproximityprompt(pp,10) end)
    spawn(function() fireproximityprompt(pp,10) end)
    spawn(function() fireproximityprompt(pp,10) end)
    spawn(function() fireproximityprompt(pp,10) end)
    spawn(function() fireproximityprompt(pp,10) end)
    spawn(function() fireproximityprompt(pp,10) end)
    spawn(function() fireproximityprompt(pp,10) end)
    spawn(function() fireproximityprompt(pp,10) end)
    spawn(function() fireproximityprompt(pp,10) end)
    spawn(function() fireproximityprompt(pp,10) end)
    spawn(function() fireproximityprompt(pp,10) end)
    spawn(function() fireproximityprompt(pp,10) end)
    spawn(function() fireproximityprompt(pp,10) end)
    spawn(function() fireproximityprompt(pp,10) end)
    spawn(function() fireproximityprompt(pp,10) end)
    spawn(function() fireproximityprompt(pp,10) end)
    spawn(function() fireproximityprompt(pp,10) end)
    spawn(function() fireproximityprompt(pp,10) end)
    spawn(function() fireproximityprompt(pp,10) end)
    spawn(function() fireproximityprompt(pp,10) end)
    spawn(function() fireproximityprompt(pp,10) end)
    spawn(function() fireproximityprompt(pp,10) end)
    spawn(function() fireproximityprompt(pp,10) end)
    spawn(function() fireproximityprompt(pp,10) end)
    spawn(function() fireproximityprompt(pp,10) end)
end

local function MakeCarInvincible()
    local Car = getPlayerCar()
    if Car == nil then 
        quickNotify("No Car Found for invincibility", "", 1.5)
        return
    end
    
    local CarTouchInterest = Car.Body.FRONT:FindFirstChild("TouchInterest")
    if CarTouchInterest == nil then
        quickNotify("Already applied invincibility", "", 1.5)
        return
    end
    for i,v in (Car.Parent:GetDescendants()) do
        if v.ClassName =="TouchTransmitter" then
            v:Remove()
        end
    end
    quickNotify("Car Now Invincible", "", 1.5)

end

local function RemoteSpawnCar(selectedCar)
    local CarOwned = game.ReplicatedStorage.GetCarInfo:InvokeServer(selectedCar)
    if not CarOwned then
        quickNotify("You do not own the "..selectedCar.."!", "", 2)
        return
    end

    game.ReplicatedStorage:WaitForChild("CarHandler"):FireServer("Spawn", selectedCar)

    wait(1) -- in case we had an old car, so it replaces it in time
    local Car = game.workspace:FindFirstChild("CivCars"):WaitForChild(LocalPlayer.Name .. "'s Car") -- need to wait for child

    if Car == nil then 
        quickNotify("Error, Car Not Found", "Lag? Maybe try again", 2)
        return
    end

    local Front = Car:WaitForChild("Body"):WaitForChild("Front")
    TeleportPlayer(Front.CFrame.Position.X, Front.CFrame.Position.Y + 5, Front.CFrame.Position.Z)
end



local function CarMod()
    local CarSpeed = true
    local PlayerLookVector
    local Car = getPlayerCar()
    local Seat = Car:FindFirstChild("DriveSeat")
    Seat.HeadsUpDisplay = true
    local Speed = 50
    local Wheels = Car:FindFirstChild("Wheels"):GetChildren()
    local XAccel = 0
    
    for i,v in next, Wheels do
        local WheelConnection
        WheelConnection = Heartbeat:Connect(function ()
            if not v.Parent then 
                WheelConnection:Disconnect()
                return 
            end
            local Gyro = v:FindFirstChild("#AV")
            local WheelDirection = v.CFrame.UpVector
    
            if v.Name == "FL" then
                v.AssemblyAngularVelocity = v.AssemblyAngularVelocity +(WheelDirection * (XAccel))
                v:FindFirstChild("Arm"):FindFirstChild("Steer").MaxTorque = Vector3.new(0,100000,0)
            elseif v.Name == "FR" then
                v.AssemblyAngularVelocity = v.AssemblyAngularVelocity +(WheelDirection * (XAccel) *-1)
                v:FindFirstChild("Arm"):FindFirstChild("Steer").MaxTorque = Vector3.new(0,100000,0)
            elseif v.Name == "RL" then
                v.AssemblyAngularVelocity = v.AssemblyAngularVelocity +(WheelDirection * (XAccel))
            elseif v.Name == "RR" then
                v.AssemblyAngularVelocity = v.AssemblyAngularVelocity +(WheelDirection * (XAccel)*-1)
            end
        end)
    
    
    end
    
    local connection
    connection = Heartbeat:Connect(function ()
        if not Seat.Parent then 
            connection:Disconnect()
        end
        XAccel = XAccel + Seat.Throttle * Speed
        if getSpeed(Seat) < 60 then
            XAccel = XAccel * 0.2
        elseif getSpeed(Seat) < 115 then
            XAccel = XAccel * 0.3
        elseif getSpeed(Seat) < 200 then
            XAccel = XAccel * 0.4
        else
            XAccel = XAccel * 0
        end
    end)

    quickNotify("Car speed mod attached", "", 1.5)
end

local function TurnInvisible()
    local Char = game:GetService("Players").LocalPlayer.Character
    local OldPos = Char.HumanoidRootPart.Position
    Char:MoveTo(OldPos + Vector3.new(0,10000,0))-- move high in sky
    wait(0.25)

    local OriginalHRP = Char.HumanoidRootPart
    OriginalHRP.Parent = nil -- doing this locks your humanoidrootpart in the sky (because of server/client relations)
    OriginalHRP.Parent = Char -- adding back normal movement functionality
    OriginalHRP.CFrame = CFrame.new(OldPos) -- bring back to old location

    for i,v in next, Char:GetChildren() do
        if v:IsA("BasePart") and v.Name ~= 'HumanoidRootPart' then 
            v.Transparency = 0.75-- visual effect
        end
    end
    quickNotify("Player now invisible", "Use instant respawn to become visible again", 2.5)
end

local function UseGodMode()
    local v = game.workspace.Zones:GetChildren()[4]
    v.CFrame = LocalPlayer.Character.HumanoidRootPart.CFrame
    --backpack gui back on
    game.StarterGui:SetCoreGuiEnabled(Enum.CoreGuiType.Backpack, true)
end


-- TRADING FUNCTIONS
-- Constants for floor, ceiling, and profit margins
local FLOOR_PRICE = 1000
local CEILING_PRICE = 10000
local MIN_PROFIT_MARGIN = 0.05 -- 5%
local MAX_PROFIT_MARGIN = 0.15 -- 15%

-- Function to calculate volatility based on price fluctuations
local function calculateVolatility(previousPrice, currentPrice)
    return math.abs(currentPrice - previousPrice) / previousPrice
end

-- Modified determineAction function
local function determineAction(currentPrice, lastPurchasePrice, previousPrice)
    local volatility = calculateVolatility(previousPrice, currentPrice)
    local profitMargin = (currentPrice - lastPurchasePrice) / lastPurchasePrice

    -- Determine action based on profit margin and volatility
    if profitMargin < MIN_PROFIT_MARGIN or volatility > MAX_PROFIT_MARGIN then
        return "Purchase", currentPrice, profitMargin
    elseif profitMargin > MAX_PROFIT_MARGIN then
        return "Sell", currentPrice, profitMargin
    else
        return "Hold", currentPrice, profitMargin
    end
end

-- Function to get the current price (placeholder, to be implemented)
local function getCurrentPrice()
    -- Placeholder implementation
    return ReplicatedStorage.Crypto.Value
end

-- Function to get the current number of shares (placeholder)
local function getCurrentShares()
    return LocalPlayer.Crypto.Value 
end

-- Function to get the remaining time (placeholder, to be implemented)
local function getTimeRemaining()
    local countdownText = LocalPlayer.PlayerGui.PhoneUI.Main.CryptoFrame.Countdown.Text
    local timeString = countdownText:gsub("s", "") -- Remove the "s" character
    local timeRemaining = tonumber(timeString) -- Convert the string to a number
    return timeRemaining
end

-- Main trading function with the new logic
local function tradeCrypto()
    local lastPurchasePrice = getCurrentPrice() -- Initialize the last purchase price with the current price
    local previousPrice = getCurrentPrice() -- Initialize with the current price
    local currentShares = getCurrentShares() -- Get the current number of shares

    -- Ensure the user starts with 10 shares
    while currentShares < 10 do
        local args = {
            [1] = "Crypto", 
            [2] = "Purchase", 
            [3] = previousPrice -- Assuming each buy action is for 1 share
        }

        --game:GetService("ReplicatedStorage").Phone:FireServer(unpack(args)) -- Testing without so it doesnt lose moenyt
        currentShares = currentShares + 1
        wait(0.5) -- Wait for a half second before the next buy action (adjust as needed)
    end

    -- Continue with the existing trading logic
    while CryptoTrader.CurrentValue do
        -- Check if the remaining time is 29 seconds
        if getTimeRemaining() == 29 then
            local currentPrice = getCurrentPrice()
            local action, price, profitMarginPercent = determineAction(currentPrice, lastPurchasePrice, previousPrice)

            if action == "Purchase" and currentShares < 10 then
                lastPurchasePrice = price -- Update the last purchase price
                currentShares = currentShares + 1 -- Update the number of shares
            elseif action == "Sell" and currentShares > 0 then
                currentShares = currentShares - 1 -- Update the number of shares
            end

            if action ~= "Hold" then
                local args = {
                    [1] = "Crypto", 
                    [2] = action, 
                    [3] = price
                }

            ReplicatedStorage.Phone:FireServer(unpack(args))
            end

            previousPrice = currentPrice -- Update the previous price for the next iteration
        end

        -- Wait for the next price change
        repeat wait(1) until getTimeRemaining() == 29 or CryptoTrader.CurrentValue == false
    end
end



-- GUI Interactables
-- Shop
local Section = Shop:CreateSection("Ammo")

local BuyPistolClip = Shop:CreateButton({
    Name = "Buy Pistol Clip",
    Callback = function()
        BuyGun("Pistol Clip", 50)
    end,
})
local BuyARClip = Shop:CreateButton({
    Name = "Buy AR Clip",
    Callback = function()
        BuyGun("AR Clip", 100)
    end,
})
local BuyShotgunAmmo = Shop:CreateButton({
    Name = "Buy Shotgun Ammo",
    Callback = function()
        BuyGun("Shotgun Ammo", 100)
    end,
})
local Section = Shop:CreateSection("Guns")
local Buy1911 = Shop:CreateButton({
    Name = "Buy 1911",
    Callback = function()
            BuyGun("1911", 1000)
    end,
})
local BuyARPistol = Shop:CreateButton({
    Name = "Buy ARPistol",
    Callback = function()
        BuyGun("ARPistol", 5000)
    end,
})
local BuyGlockSwitch = Shop:CreateButton({
    Name = "Buy GlockSwitch",
    Callback = function()
        BuyGun("GlockSwitch", 5250)
    end,
})
local BuyAK47 = Shop:CreateButton({
    Name = "Buy AK-47",
    Callback = function()
        BuyGun("AK-47", 8500)
    end,
})

local Section = Shop:CreateSection("Misc")

local BuyC4 = Shop:CreateButton({
Name = "Buy C4",
Callback = function()
        BuyItem("C4", 2000)
        GUI:Notify({
            Title = "Did it work?",
            Content = "If it didn't, then there are none available. Go kill some people",
            Duration = 3,
        })
end,
})

local BuyMentosBag = Shop:CreateButton({
Name = "Buy Mentos Bag",
Callback = function()
        BuyItem("MentosBag", 300)
end,
})



--exploits
local Section = Exploits:CreateSection("Exploits")
local InstantRespawn = Exploits:CreateButton({
    Name = "Instant Respawn",
    Callback = function()
        DepositMoney(Stored.Money.Value)
        Respawn()
        quickNotify("Respawned", "Auto deposited all money", 1.5)
    end,
})
local InstantInteract = Exploits:CreateButton({
    Name = "Instant Interact Prompts",
    Callback = function()
        for i,v in game:GetDescendants() do
            if v and v:IsA("ProximityPrompt") then
                v.HoldDuration = 0
            end
        end
        quickNotify("Applied instant prompts", "", 1.5)
    end,
})

local C4Exploit = Exploits:CreateButton({
    Name = "Instant C4 Plant (works on small lobbies)",
    Callback = function(Value)
        PlantC4()
    end
})

local InvisibleExploitButton = Exploits:CreateButton({
    Name = "Turn Invisible (Guns work)",
    Callback = function(Value)
        TurnInvisible()
    end
})
local GodModeToggle = Exploits:CreateToggle({
    Name = "God Mode (Cant be combat logged)",
    CurrentValue = false,
    Flag = "NoClipCamera", 
    Callback = function(Value)
        if Value == true then
            GodMode = true
            while GodMode == true do
                UseGodMode()
                wait()
            end
        else
            GodMode = false  
        end
    end
})

--AIMBOT
local Section = Exploits:CreateSection("Aimbot")
local Aimbot = Exploits:CreateToggle({
    Name = "Aimbot (Right Click to Use)",
    CurrentValue = false, 
    Callback = function(Value) 
        if Value then 
            quickNotify("Aimbot On", "", 1.5)
        else
            quickNotify("Aimbot Off", "", 1.5)
        end
    end,
})

local connection = UIS.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton2 then 
        RightClickHeld = true
    end
end)

local connection2 = UIS.InputEnded:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton2 then 
        RightClickHeld = false
    end
end)

RunService.RenderStepped:Connect(function()
    if Aimbot.CurrentValue == true then
        if RightClickHeld == true then
            LookAtHeadOfPlayer(FindPlayerToAimbot())
        end
    end

    --for super punch
    if not LocalPlayer.Character then return end
    local LocalHRP = LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
    if not LocalHRP then return end
    ClosePlayers = {}
    for i,v in pairs(Players:GetPlayers()) do
        if v ~= LocalPlayer then
            local distance = v:DistanceFromCharacter(LocalHRP.Position)
            if distance < 7 then
                table.insert(ClosePlayers,v)
            end
        end
    end
end)



local Section = Exploits:CreateSection("Inflict Player Settings")

local PickGunToUse = Exploits:CreateDropdown({
    Name = "Pick Gun to Inflict With (must own it)",
    Options = {
        "AK-47",
        "GlockSwitch",
        "ARPistol",
        "ARPDrum",
        "Vector",
        "FN 5.7",
        "MP5",
        "1911",
    },
    CurrentOption = {"ARPistol"},
    MultipleOptions = false,
    Flag = "PickGunToUse", 
    Callback = function() end,
})

local PickActor = Exploits:CreateInput({
    Name = "Pick Person to be Actor ",
    PlaceholderText = "Type username...",
    RemoveTextAfterFocusLost = false,
    Callback = function(input) 
        Actor = input
    end,
})

local PickRecipient = Exploits:CreateInput({
    Name = "Pick Person to be Recipient",
    PlaceholderText = "Type username...",
    RemoveTextAfterFocusLost = false,
    Callback = function(input) 
        Recipient = input
    end,
})
local InstaKillToggle = Exploits:CreateToggle({
    Name = "Insta Kill Player (Won't tell who killed them)",
    CurrentValue = false,
    Flag = "InstaKillToggle", -- A flag is the identifier for the configuration file, make sure every element has a different flag if you're using configuration saving to ensure no overlaps
    Callback = function(Value) 
        InstaKill = Value
    end
})
local LagPlayerToggle = Exploits:CreateToggle({
    Name = "Lag Player Instead Of Kill (Will loop aswell)",
    CurrentValue = false,
    Flag = "LagToggle", -- A flag is the identifier for the configuration file, make sure every element has a different flag if you're using configuration saving to ensure no overlaps
    Callback = function(Value) 
        LagPlayer = Value
    end
})


--end settings, start functions
Exploits:CreateSection("Inflict Player Functions")

local DamageAllPlayersWithGun = Exploits:CreateButton({
    Name = "Inflict ALL Players With Gun",
    Callback = function()
        local Gun = equipTool(PickGunToUse.CurrentOption[1])
        
        local function InflictAllPlayers() -- function because we have 2 use cases
            for i,v in pairs(Players:GetPlayers()) do
                if v.Character.HumanoidRootPart and v ~= LocalPlayer then 
                    local args = constructInflictPlayerArgs(Gun, Actor, v.Name)
                    if LagPlayer == true then args[12] = false end -- doesnt damage them
                    if InstaKill then args[5] = -999999 end -- bypasses server limit, insta kills

                    spawn( function() ReplicatedStorage.InflictTarget:InvokeServer(unpack(args)) end)
                end
            end
        end
        
        if LagPlayer then
            while LagPlayer == true do
                InflictAllPlayers()
                wait(0.1)
            end
        else
            InflictAllPlayers()
        end
    end,
})



local DamagePlayerWithGun = Exploits:CreateButton({
    Name = "Inflict SINGLE Player With Gun",
    Callback = function()
        local Gun = equipTool(PickGunToUse.CurrentOption[1])

        local args = constructInflictPlayerArgs(Gun, Actor, Recipient)
        if LagPlayer == true then args[12] = false end -- doesnt damage them
        if InstaKill then args[5] = -999999 end -- bypasses server limit, insta kills
        
        if LagPlayer then
            while LagPlayer == true do
                spawn( function() ReplicatedStorage.InflictTarget:InvokeServer(unpack(args)) end)
                wait(0.25)
            end
        else
            spawn( function() ReplicatedStorage.InflictTarget:InvokeServer(unpack(args)) end)
        end
    end
})

-- spoof damage




-- SUPER PUNCH
local Section = Exploits:CreateSection("Super Punch")
local SuperPunchStrength = Exploits:CreateSlider({
    Name = "Super Punch Strength",
    Range = {1, 25},
    Increment = 1,
    Suffix = "x",
    CurrentValue = 1,
    Flag = "SuperPunchStrength", 
    Callback = function(Value) end,
})

local SuperPunch = Exploits:CreateKeybind({
    Name = "Super Punch (Hold fists while using)",
    CurrentKeybind = "R",
    HoldToInteract = false,
    Flag = "SuperPunch", 
    Callback = function(held)
        for i= 1, SuperPunchStrength.CurrentValue do
            if ClosePlayers == nil then return end
            for i,v in pairs(ClosePlayers) do
                spawn(function()
                    game:GetService("Players").LocalPlayer.Character.Fist.LocalScript.punched:InvokeServer(v.Character.Humanoid, "Punch")
                end)
            end
        end
    end,
    
})


local Section = Movement:CreateSection("Fly")
local Label = Movement:CreateLabel("Need to attach fly to player parts to use fly (especially after respawn)")

--check up and down inputs for fly
UIS.InputBegan:Connect(function(input)
    if input.KeyCode == Enum.KeyCode.E then
        FlyUp = true
    end
    if input.KeyCode == Enum.KeyCode.Q then
        FlyDown = true
    end
end)

UIS.InputEnded:Connect(function(input)
    if input.KeyCode == Enum.KeyCode.E then
        FlyUp = false
    end
    if input.KeyCode == Enum.KeyCode.Q then
        FlyDown = false
    end
end)
-- set yvel for corresponding value
Heartbeat:connect(function()
    local Car = getPlayerCar()
    local CarSeat
    if Car ~= nil then 
        CarSeat = Car:FindFirstChild("DriveSeat") 
    end
    
    if Fly == true then
        if FlyUp then
            yvel = 50
        elseif FlyDown then
            yvel = -50
        else
            yvel = 0
        end
        if Car ~= nil and CarSeat ~= nil and CarSeat.Occupant ~= nil then
            CarSeat.Flip.D = 99999999999999
            CarSeat.Flip.MaxTorque = Vector3.new(99999999999999,99999999999999,99999999999999)
        end
    else
        if Car ~= nil and CarSeat ~= nil and CarSeat.Occupant ~= nil then
            if CarSeat.Flip.D > 1000000000 then 
                CarSeat.Flip.D = 0
                CarSeat.Flip.MaxTorque = Vector3.new(0,0,0)
            end
        end
    end
end)


local AttachFly = Movement:CreateButton({
    Name = "Attach QE Fly",
    Callback = function()
        -- attach fly
        for i,v in next, LocalPlayer.Character:GetDescendants() do
            if v:IsA("BasePart") and v.Name ~="HumanoidRootPart" then 
            Heartbeat:connect(function()
                    if Fly == true then
                        xvel = LocalPlayer.Character.Humanoid.MoveDirection.X * FlySpeed
                        zvel = LocalPlayer.Character.Humanoid.MoveDirection.Z * FlySpeed

                        LocalPlayer.MaximumSimulationRadius = math.huge

                        v.AssemblyLinearVelocity = Vector3.new(xvel,yvel,zvel)
                    end
                end)
            end
        end
    end
})
local FlySpeedSlider = Movement:CreateSlider({
    Name = "Fly Speed",
    Range = {20, 150},
    Increment = 10,
    Suffix = "x",
    CurrentValue = 50,
    Flag = "FlySpeed", 
    Callback = function(Value) 
        FlySpeed = Value
    end,
})
local FlyToggle = Movement:CreateToggle({
    Name = "QE Fly Toggle",
    CurrentValue = false,
    Flag = "FlyToggle", -- A flag is the identifier for the configuration file, make sure every element has a different flag if you're using configuration saving to ensure no overlaps
    Callback = function(Value) 
        if Value == true then
            Fly = true
            workspace.Gravity = 0
        else
            Fly = false
            workspace.Gravity = 196.2
        end
    end
})




-- Movement
local Section = Movement:CreateSection("Teleports")

local PickTeleportLocation = Movement:CreateDropdown({
    Name = "Pick Teleport Location",
    Options = {
        "Spawn",
        "CarDealer",
        "GunDealer",
        "Studio",
        "BankVault",
        "BankLootSeller",
        "Apt3",
    },
    CurrentOption = {"CarDealer"},
    MultipleOptions = false,
    Flag = "PickTeleportLocation", 
    Callback = function(option) 
        local Picked = option[1] 
        local LocationToCoordsList = {
            ["Spawn"] = {-723, 3, -79},
            ["CarDealer"] = {-680,4,54},
            ["GunDealer"] = {-587,3,-402},
            ["Studio"] = {-578,4,-31},
            ["BankVault"] = {-1239,-260,-371},
            ["BankLootSeller"] = {-856,3,385},
            ["Apt3"] = {-799, -462, 438},
        }
        TPCoords = LocationToCoordsList[Picked]
    end,
})
local TeleportButton = Movement:CreateButton({
    Name = "Teleport to Location",
    Callback = function() 
        TeleportPlayer(unpack(TPCoords))
    end,
})

local Section = Movement:CreateSection("Car")

local SelectCar = Movement:CreateDropdown({
    Name = "Select Car (must own)",
    Options = {"Sedan","GLE53","CLS","Hellcat","RollsRoyce","RS6","RS3","M2","Urus"},
    CurrentOption = "Sedan",
    Flag = "CarType",
    Callback = function(option)
    end
})

local RemoteCarSpawn = Movement:CreateButton({
    Name = "Spawn Car",
    Callback = function()
        RemoteSpawnCar(SelectCar.CurrentOption[1])
    end
})


local InvincibleCar = Movement:CreateButton({
    Name = "Invincible Car (Works for your existing car only)",
    Callback = function(Value)
        MakeCarInvincible()
    end
})

local AttachCarMod = Movement:CreateButton({
    Name = "Speed Car Mod (Only mods existing car)",
    Callback = function()
        CarMod()
    end
})

local PutCarUnderMap = Movement:CreateButton({
    Name = "Put Car Under Map",
    Callback = function()
        local PlayerX = LocalPlayer.Character.HumanoidRootPart.CFrame.X
        local PlayerZ = LocalPlayer.Character.HumanoidRootPart.CFrame.z

        TeleportPlayer(PlayerX, -100, PlayerZ)
        wait(0.5)
        SimulateInput.Press(Enum.KeyCode.Space)
        SimulateInput.Press(Enum.KeyCode.Space) -- failsafe
        wait(1)
        TeleportPlayer(PlayerX, 15, PlayerZ)
    end
})


-- ATM Teller Machine
local AutoDepositToggle = Money:CreateToggle({
    Name = "Auto Deposit (Use when farming money)",
    CurrentValue = false,
    Flag = "AutoDeposit", -- A flag is the identifier for the configuration file, make sure every element has a different flag if you're using configuration saving to ensure no overlaps
    Callback = function(Value) 
        if Value == true then
            AutoDeposit = true
            while AutoDeposit == true do
                wait(0.2)
                if Stored.Money.Value == 2000000 and Stored.Bank.Value ~= 3000000 then
                    DepositMoney(Stored.Money.Value)
                end
            end
        else
            AutoDeposit = false
        end
    end
})
local Section = Money:CreateSection("Remote ATM")
local Deposit = Money:CreateInput({
    Name = "Deposit Money",
    PlaceholderText = "Type amount...",
    RemoveTextAfterFocusLost = true,
    Callback = function(amount)
        DepositMoney(amount)
        quickNotify("Deposited "..amount,"", 1.5)
    end,
})

local Withdraw = Money:CreateInput({
    Name = "Withdraw Money",
    PlaceholderText = "Type amount...",
    RemoveTextAfterFocusLost = true,
    Callback = function(amount)
        WithdrawMoney(amount)
        quickNotify("Withdrew "..amount,"", 1.5)
    end,
})

local DepositAll = Money:CreateButton({
    Name = "Deposit All Money",
    Callback = function() 
        DepositMoney(Stored.Money.Value)
        quickNotify("Deposited All","", 1.5)
    end,
})
local WithdrawAll = Money:CreateButton({
    Name = "Withdaw All Money",
    Callback = function() 
        WithdrawMoney(Stored.Bank.Value)
        quickNotify("Withdrew All","", 1.5)
    end,
})


--money
local Section = Money:CreateSection("Money Farms")
local CryptoTrader = Money:CreateToggle({
    Name = "Auto Crypto Trader",
    CurrentValue = false,
    Flag = "AutoWithdraw", -- A flag is the identifier for the configuration file, make sure every element has a different flag if you're using configuration saving to ensure no overlaps
    Callback = function(Value) 
        if Value == true then
            tradeCrypto()
        end
    end
})

local CarMoneyFarmButton = Money:CreateButton({
    Name = "Run Car Money Farm (Cars reset 3min) (Makes 5k)",
    Callback = function() CarMoneyFarm() end
})

local FarmServerBankToggle = Money:CreateToggle({
    Name = "Farm Server Bank (175k each time)",
    CurrentValue = false,
    Flag = "FarmServerBankToggle",
    Callback = function(value)
        if value then
            FarmServerBank()
        end
    end
})

local FarmStudio = Money:CreateButton({
    Name = "Farm Studio (Use auto-deposit)",
    Callback = function()
        spawn(function()
            StudioFarm()
        end)
    end
})


--donate
local Section = Money:CreateSection("Donate")
local GiveAll100k = Money:CreateButton({
    Name = "Give All Players 100k",
    Callback = function()
        for i,v in pairs(Players:GetChildren()) do
            if not v then return end
            spawn(function() SendMoneyToPlayer(v.Name,100000)end)
        end
    end
})
local PickPersonToPay = Money:CreateInput({
    Name = "Pick Person to Pay 100k",
    PlaceholderText = "Type username...",
    RemoveTextAfterFocusLost = false,
    Callback = function(input) 
        SendMoneyToPlayer(input, 100000)
    end,
})



--Misc
local Label = Misc:CreateLabel("Rip VenPay Exploit")
local NoClipCamera = Misc:CreateToggle({
    Name = "No Clip Camera (Turn off in cars)",
    CurrentValue = false,
    Flag = "NoClipCamera", 
    Callback = function(Value)
        if Value == true then
            LocalPlayer.DevCameraOcclusionMode = "Invisicam"
            quickNotify("Noclip Camera On", "", 1.5)
        else
            LocalPlayer.DevCameraOcclusionMode = "Zoom"
            quickNotify("Noclip Camera Off", "", 1.5)
        end
    end
})
local Rejoin Game = Misc:CreateButton({
    Name = "Rejoin Game",
    Callback = function() 
        TeleportService:Teleport(game.PlaceId, LocalPlayer)
    end,
})

local RemoveAccessories = Misc:CreateButton({
    Name = "Remove Accessories (for aiming purposes)",
    Callback = function(Value)
        LocalPlayer.Character.Humanoid:RemoveAccessories()
    end
})
local SetAnimationSpeedFast = Misc:CreateButton({
    Name = "Speed Up All Player Animations",
    Callback = function(Value)
        for i =1, 20 do
            local AnimationsArray = LocalPlayer.Character.Humanoid:GetPlayingAnimationTracks()
            for i,v in pairs(AnimationsArray) do
                v:AdjustSpeed(1000)
            end
            wait()
        end
    end
})
local DisguiseUsername = Misc:CreateInput({
    Name = "Disguise Username (Permanent)",
    PlaceholderText = "Type text here...",
    RemoveTextAfterFocusLost = false,
    Callback = function(NewName)
        LocalPlayer.Character.Head:FindFirstChild("BillboardGui"):FindFirstChild("TextLabel").Text = NewName
        LocalPlayer.CharacterAdded:Connect(function ()
            local head = LocalPlayer.Character:WaitForChild("Head")
            head:WaitForChild("BillboardGui"):WaitForChild("TextLabel").Text = NewName
        end)

    end,
})
local GrabAllTools = Misc:CreateButton({
    Name = "Grab All Floor Loot",
    Callback = function(Value)
        for i,v in next, workspace:GetChildren() do
            if v:IsA("Tool") then 
                local handle = v:FindFirstChild("Handle")
                if handle ~= nil then
                    firetouchinterest(game.Players.LocalPlayer.Character.HumanoidRootPart, handle, 0)
                    wait()
                    firetouchinterest(game.Players.LocalPlayer.Character.HumanoidRootPart, handle, 1)
                end
            end
        end
    end
})

local Section = Misc:CreateSection("Audio Player")
local PickAudioID
PickAudioID = Misc:CreateDropdown({
    Name = "Pick Common Audio ID",
    Options = {
        "Gymnopedie No. 1",
        "New Tank Carti",
        "Pissy Pamper Carti",
        "Hench Mafia Comethazine",
        "FNAF 2 Song",
        "Skibidi Toilet Garbage Song",
        "Carti EarRape Song",
        "Raining Tacos",
        "Taco Song 2 Remix",
        "FNAF 1 Call",
        "PHub Intro",
        "Explosion",
        "Gucci Gang",
        "This Is Sparta",
        "9+10 = 21",
        "Clash Royale Laugh",
        "Discord Ping",
        "Vine Boom",
        "Custom"
    },
    CurrentOption = {"None"},
    MultipleOptions = false,
    Flag = "PickGunToUse", 
    Callback = function(option)
        local Picked = option[1] 
        local NameToIdList = {
            ["Gymnopedie No. 1"] = 9045766377,
            ["New Tank Carti"] = 6681840651,
            ["Pissy Pamper Carti"] = 6917155909,
            ["Hench Mafia Comethazine"] = 6674211522,
            ["FNAF 2 Song"] = 6913550990,
            ["Skibidi Toilet Garbage Song"] = 16190757458,
            ["Carti EarRape Song"] = 6954430911,
            ["Raining Tacos"] = 142376088,
            ["Taco Song 2 Remix"] = 9245552700,
            ["FNAF 1 Call"] = 4835346587,
            ["PHub Intro"] = 4642552560,
            ["Explosion"] = 165969964,
            ["Gucci Gang"] = 2547598538,
            ["This Is Sparta"] = 130781067,
            ["9+10 = 21"] = 6025999413,
            ["Clash Royale Laugh"] = 8156780600,
            ["Discord Ping"] = 2127625442,
            ["Vine Boom"] = 9062874339,
            ["Custom"] = nil
        }
        AudioID = NameToIdList[Picked]
    end,
})

local SetCustomAudioID = Misc:CreateInput({
    Name = "Set Custom Audio ID (Overrides above)",
    PlaceholderText = "Type ID here...",
    RemoveTextAfterFocusLost = false,
    Callback = function(Input)
        CustomAudioID = Input
    end,
})

local VolumeSlider = Misc:CreateSlider({
    Name = "Audio Volume",
    Range = {1, 10},
    Increment = 1,
    Suffix = "x",
    CurrentValue = 2,
    Flag = "VolumeSlider", 
    Callback = function(Value) end,
})

local PlayAudioButton = Misc:CreateButton({
    Name = "Play Audio",
    Callback = function()
        local IDToUse
        if CustomAudioID == nil or CustomAudioID == "" or CustomAudioID == " " or #CustomAudioID < 2 then 
            IDToUse = AudioID
        else
            IDToUse = CustomAudioID
        end

        local args = {
            [1] = "}0, { \n\n } ",
            [2] = "}, { ",
            [3] = {
                ["Pitch"] = 1,
                ["Position"] = game.workspace,
                ["EmitterSize"] = 999,
                ["SoundId"] = "rbxassetid://"..IDToUse,
                ["Replicate"] = false,
                ["Volume"] = VolumeSlider.CurrentValue,
                ["Effects"] = false
            }
        }
        game:GetService("ReplicatedStorage").PlayAudio:FireServer(unpack(args))

        local sound = Instance.new("Sound", workspace)
        sound.SoundId = "rbxassetid://"..IDToUse
        sound.EmitterSize = 999
        sound.Looped = false
        sound.Volume = VolumeSlider.CurrentValue
        sound:Play()
    end,
})



local Section = Misc:CreateSection("Remote Safe (Need to own home)")

local StoreItem = Misc:CreateInput({
    Name = "Store Item In Safe",
    PlaceholderText = "Type item name...",
    RemoveTextAfterFocusLost = true,
    Callback = function(ItemToStore)
        changeItemLocation(ItemToStore, "Backpack")
    end,
})

local TakeItem = Misc:CreateInput({
    Name = "Take Item In Safe",
    PlaceholderText = "Type item name...",
    RemoveTextAfterFocusLost = true,
    Callback = function(ItemToStore)
        changeItemLocation(ItemToStore, "Inv")
    end,
})
local RefreshMentos = Misc:CreateButton({
    Name = "Refresh Mentos Uses (broken?) (need to own house)",
    Callback = function(Value)
        changeItemLocation("MentosBag", "Backpack")
        wait(0.5)
        changeItemLocation("MentosBag", "Inv")
    end
})

local Section = Misc:CreateSection("Infinite Yield")

local Label = Misc:CreateLabel("I like to use infinite yield for chams, locate, etc, so here it is.")

local InjectInfiniteYield = Misc:CreateButton({
    Name = "Inject Infinite Yield",
    Callback = function() 
        spawn(function()
            loadstring(game:HttpGet('https://raw.githubusercontent.com/EdgeIY/infiniteyield/master/source'))()
        end)
        
    end,
})





-- ON LAUNCH ACTIONS
-- Quality of Life proximity prompts
for i,v in game:GetDescendants() do
    if v and v:IsA("ProximityPrompt") then
        v.HoldDuration = 0
    end
end
-- and max zoom
LocalPlayer.CameraMaxZoomDistance = 1000
-- health view
LocalPlayer.CharacterAdded:Connect(function()
    LocalPlayer.HealthDisplayDistance = 200
end)

-- anti idle
for i,v in pairs(getconnections(game:GetService("Players").LocalPlayer.Idled)) do  
    v:Disable()  
end
-- doing both cause idk which actually works
local vu = game:GetService("VirtualUser")
game:GetService("Players").LocalPlayer.Idled:connect(function()
    vu:Button2Down(Vector2.new(0,0),workspace.CurrentCamera.CFrame)
    wait(1)
    vu:Button2Up(Vector2.new(0,0),workspace.CurrentCamera.CFrame)
end)

GUI:Notify({
    Title = "Script Loaded",
    Content = "I automatically applied instant interactions and a big camera zoom for you (Plus health viewer and anti idle)",
    Duration = 3,
    Image = 4483362458,
})