--local GUI = loadstring(game:HttpGet('https://raw.githubusercontent.com/SiriusSoftwareLtd/Rayfield/main/source.lua'))()
local GUI = loadstring(game:HttpGet('https://raw.githubusercontent.com/bitofbeans/NewDropdownRayfield/main/source.lua'))()

--
local Window = GUI:CreateWindow({
   Name = "Street Life Gamer GUI for Quality of Life V2",
   LoadingTitle = "Loading Street Life Script",
   LoadingSubtitle = "by BitBeans",
   KeySystem = false,
})

local Shop = Window:CreateTab("Shop", 4483362458) -- Title, Image
local Exploits = Window:CreateTab("Exploits", 4483362458) -- Title, Image
local Teleport = Window:CreateTab("Teleport", 4483362458) -- Title, Image
local ATM = Window:CreateTab("ATM", 4483362458) -- Title, Image
local Money = Window:CreateTab("Money Exploits", 4483362458) -- Title, Image
local Safe = Window:CreateTab("Safe/Inventory", 4483362458) -- Title, Image
local INFO = Window:CreateTab("INFO", 4483362458) -- Title, Image

GUI:Notify({
   Title = "Script Loaded",
   Content = "I automatically applied instant interactions and a big camera zoom for you(Plus health viewer)",
   Duration = 1,
   Image = 4483362458,
   Actions = { -- Notification Buttons
      Ignore = {
        Name = "Thanks",
        Callback = function() end
   },
},
})

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
--

local RightClickHeld = false
local ClosePlayers
local VisitedServers = {}


local AutoWithdraw = Shop:CreateToggle({
    Name = "Auto Withdraw from Bank (recommended)",
    CurrentValue = true,
    Flag = "AutoWithdraw", -- A flag is the identifier for the configuration file, make sure every element has a different flag if you're using configuration saving to ensure no overlaps
    Callback = function(Value) end
})




-- Quality of Life proximity prompts
for i,v in game:GetDescendants() do
    if v and v:IsA("ProximityPrompt") then
        v.HoldDuration = 0
    end
end
-- and max zoom
LocalPlayer.CameraMaxZoomDistance = 1000
-- health view
LocalPlayer.HealthDisplayDistance = 200



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
local PlantC4 = function() 
    local args = {
        [1] = game:GetService("Players").LocalPlayer.Character.C4,
        [2] = "COMPLETED",
        [3] = workspace.Plant
    }
    ReplicatedStorage.C4:FireServer(unpack(args))
end
local DepositMoney = function(amount) 
    local args = {
        [1] = "Deposit",
        [2] = amount
    }
    ReplicatedStorage.ATM:FireServer(unpack(args))
end
local WithdrawMoney = function(amount) 
    local args = {
        [1] = "Withdraw",
        [2] = amount
    }
    ReplicatedStorage.ATM:FireServer(unpack(args))
end
local BuyGun= function(name, price)
    if AutoWithdraw.CurrentValue == true then WithdrawMoney(price) end
    local args = {
        [1] = name,
        [2] = price
    }

    ReplicatedStorage.GBuy:FireServer(unpack(args))
end
local BuyItem = function(name, price)
    if AutoWithdraw.CurrentValue == true then WithdrawMoney(price) end
    local args = {
        [1] = name,
        [2] = price
    }

    ReplicatedStorage.Buy:FireServer(unpack(args))
end
local Respawn = function () 
    local args = {
        [1] = "ss"
    }

    game:GetService("Lighting").bt:FireServer(unpack(args))
end
local TeleportPlayer = function(x,y,z)
    LocalPlayer.Character.HumanoidRootPart.CFrame = CFrame.new(x,y,z)
end

local GetGunsInBackpack = function()
    local InvalidItems = {"Pistol Clip", "AR Clip", "Fist", "Phone", "C4", "MentosBag", "Balaclava"}
    for i, v in ipairs(InvalidItems) do
        InvalidItems[v] = true -- Mapping the thing so we can check
    end
    
    local items = {}
    for i,v in pairs(LocalPlayer.Backpack:GetChildren()) do
        if v.ClassName == "Tool" and not InvalidItems[v.Name] then
            table.insert(items, v.Name)
        end
    end
    return items
end

local GetItemsInBackpack = function()
    local InvalidItems = {"Fist", "Phone"}
    for i, v in ipairs(InvalidItems) do
        InvalidItems[v] = true -- Mapping the thing so we can check
    end
    
    local items = {}
    for i,v in pairs(LocalPlayer.Backpack:GetChildren()) do
        if v.ClassName == "Tool" and not InvalidItems[v.Name] then
            table.insert(items, v.Name)
        end
    end
    return items
end

local GetPlayerNames = function()
    local PlayerNames = {}
    for i,v in pairs(Players:GetPlayers()) do
        table.insert(PlayerNames, v.Name)
    end
    return PlayerNames
end

local FindPlayerToAimbot = function() 
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

local LookAtHeadOfPlayer = function(player)
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
local CarMoneyFarm = function(player)
    DepositMoney(LocalPlayer.stored.Money.Value)
    Respawn()
    wait(2)
    local hd, rlos, en, mad
    local iteration = 0
    local firepp = function(pp,xx, teleport)
        hd = pp.HoldDuration
        rlos = pp.RequiresLineOfSight
        en = pp.Enabled
        mad = pp.MaxActivationDistance

        --

        pp.HoldDuration = 0
        pp.RequiresLineOfSight = false
        --pp.Enabled = true
        pp.MaxActivationDistance = math.huge 
        if en == true then
            if teleport == true then
                LocalPlayer.Character.HumanoidRootPart.CFrame = pp.Parent.Parent.CFrame + Vector3.new(0,2,2)
                iteration = iteration + 1
            end
            wait(0.25)
            fireproximityprompt(pp,xx)  
        end
        --

        --pp.HoldDuration = hd
        pp.RequiresLineOfSight = rlos
        --pp.Enabled = en
        pp.MaxActivationDistance = mad
        if en == true then
            return "enabled"
        end
    end

    for i,v in workspace.Interactions:GetDescendants() do
        if v and v.Name == "ProximityPrompt" and v:IsA("ProximityPrompt") then
            
            local result = ""
            local result = firepp(v,1, true) 
            if result == "enabled" then
                wait(2.5)
                local result = firepp(v,1, false) 
                wait(0.25)
                DepositMoney(LocalPlayer.stored.Money.Value)
                
                if iteration == 3 then 
                    Respawn() -- prevents lagbacks
                    wait(1)
                    iteration = 0
                end
            else
                continue
            end

        end
    end
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
local Label = INFO:CreateLabel("Rip VenPay Exploit")
local Rejoin Game = INFO:CreateButton({
    Name = "Rejoin Game",
    Callback = function() 
        TeleportService:Teleport(game.PlaceId, LocalPlayer)
    end,
})


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
local Section = Shop:CreateSection("Other")
local BuyC4 = Shop:CreateButton({
   Name = "Buy C4",
   Callback = function()
        BuyItem("C4", 1500)
        GUI:Notify({
            Title = "Did it work?",
            Content = "If it didn't, then there are none available. Go kill some people",
            Duration = 6.5,
            Image = 4483362458,
            Actions = { -- Notification Buttons
                Ignore = {
                    Name = "Ok",
                    Callback = function() end
                },
            },
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
local Section = Exploits:CreateSection("Misc")
local InstantRespawn = Exploits:CreateButton({
    Name = "Instant Respawn",
    Callback = function()
        DepositMoney(LocalPlayer.stored.Money.Value)
        local args = {
            [1] = "ss"
        }
        game:GetService("Lighting").bt:FireServer(unpack(args))
    end,
})
local InstantInteract = Exploits:CreateButton({
    Name = "Instant Interact",
    Callback = function()
        for i,v in game:GetDescendants() do
            if v and v:IsA("ProximityPrompt") then
                v.HoldDuration = 0
            end
        end
    end,
})
local NoClipCamera = Exploits:CreateToggle({
    Name = "No Clip Camera (Turn off in cars)",
    CurrentValue = false,
    Flag = "NoClipCamera", 
    Callback = function(Value)
        if Value == true then
            LocalPlayer.DevCameraOcclusionMode = "Invisicam"
        else
            LocalPlayer.DevCameraOcclusionMode = "Zoom"
        end
    end
})
local RefreshMentos = Exploits:CreateButton({
    Name = "Refresh Mentos Uses (Don't Hold MentosBag) (need to own house)",
    Callback = function(Value)
        local args = {
            [1] = "Change",
            [2] = "MentosBag",
            [3] = "Backpack",
            [4] = LocalPlayer.Character.HumanoidRootPart
        }
        ReplicatedStorage.Inventory:FireServer(unpack(args))
        wait(0.5)
        local args = {
            [1] = "Change",
            [2] = "MentosBag",
            [3] = "Inv",
            [4] = LocalPlayer.Character.HumanoidRootPart
        }
        ReplicatedStorage.Inventory:FireServer(unpack(args))
    end
})
local RemoveAccessories = Exploits:CreateButton({
    Name = "Remove Accessories (for aiming purposes)",
    Callback = function(Value)
        for i,v in pairs(LocalPlayer.Character:GetChildren()) do
            if v:IsA("Accessory") then
                v:Remove()
            end
        end
    end
})


local Section = Exploits:CreateSection("Kill Players")
local Label = Exploits:CreateLabel("Make sure you are holding the gun you want to use and you picked a gun to use!!")

local PickGunToUse = Exploits:CreateDropdown({
    Name = "Pick Gun to Damage With",
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
 
local DamageAllPlayersWithGun = Exploits:CreateButton({
    Name = "Damage All Players With Gun",
    Callback = function()
        local gun = PickGunToUse.CurrentOption[1]
        for i,v in pairs(Players:GetPlayers()) do
            local args = {
                [1] = LocalPlayer.Character:FindFirstChild(gun),
                [2] = LocalPlayer,
                [3] = v.Character.Humanoid,
                [4] = v.Character.HumanoidRootPart,
                [5] = 30,
                [6] = {
                    [1] = 0,
                    [2] = 0,
                    [3] = false,
                    [4] = false,
                    [5] = LocalPlayer.Character:FindFirstChild(gun).GunScript_Server.IgniteScript,
                    [6] = LocalPlayer.Character:FindFirstChild(gun).GunScript_Server.IcifyScript,
                    [7] = 100,
                    [8] = 100
                },
                [7] = {
                    [1] = false,
                    [2] = 5,
                    [3] = 3
                },
                [8] = v.Character.Head,
                [9] = {
                    [1] = false,
                    [2] = {
                        [1] = 1930359546
                    },
                    [3] = 1,
                    [4] = 1.5,
                    [5] = 1
                },
                [10] = Vector3.new(-433.24053955078125, -323.75885009765625, -158.63999938964844),
                [11] = Vector3.new(-0.956211268901825, 0.00013869439135305583, -0.29267749190330505),
                [12] = true
            }
            ReplicatedStorage.InflictTarget:InvokeServer(unpack(args))
            
        end
    end,
})
local PersonToDamage = nil
local PickPersonToDamage = Exploits:CreateInput({
    Name = "Pick Person to Damage",
    PlaceholderText = "Type username...",
    RemoveTextAfterFocusLost = false,
    Callback = function(input) 
        PersonToDamage = input
    end,
 })
--[[
local PickPersonToDamage = Exploits:CreateDropdown({
    Name = "Pick Person to Damage ",
    Options = GetPlayerNames(),
    CurrentOption = {"Pick a Player"},
    MultipleOptions = false,
    Flag = "PickPersonToDamage", 
    Callback = function() end,
})
local RefreshPlayerList = Exploits:CreateButton({
    Name = "refresh player list",
    Callback = function() 
        PickPersonToDamage:Set(GetPlayerNames()) 
    end,
})
]]
local DamagePlayerWithGun = Exploits:CreateButton({
    Name = "Damage Player With Gun",
    Callback = function()
        local gun = PickGunToUse.CurrentOption[1]
        local person = PersonToDamage
        local args = {
            [1] = LocalPlayer.Character:FindFirstChild(gun),
            [2] = LocalPlayer,
            [3] = Players:FindFirstChild(person).Character.Humanoid,
            [4] = Players:FindFirstChild(person).Character.HumanoidRootPart,
            [5] = 30,
            [6] = {
                [1] = 0,
                [2] = 0,
                [3] = false,
                [4] = false,
                [5] = LocalPlayer.Character:FindFirstChild(gun).GunScript_Server.IgniteScript,
                [6] = LocalPlayer.Character:FindFirstChild(gun).GunScript_Server.IcifyScript,
                [7] = 100,
                [8] = 100
            },
            [7] = {
                [1] = false,
                [2] = 5,
                [3] = 3
            },
            [8] = Players:FindFirstChild(person).Character.Head,
            [9] = {
                [1] = false,
                [2] = {
                    [1] = 1930359546
                },
                [3] = 1,
                [4] = 1.5,
                [5] = 1
            },
            [10] = Vector3.new(-433.24053955078125, -323.75885009765625, -158.63999938964844),
            [11] = Vector3.new(-0.956211268901825, 0.00013869439135305583, -0.29267749190330505),
            [12] = true
        }
        ReplicatedStorage.InflictTarget:InvokeServer(unpack(args))
    end
})

--AIMBOT
local Section = Exploits:CreateSection("Aimbot")
local Aimbot = Exploits:CreateToggle({
    Name = "Aimbot (Locks to Heads)",
    CurrentValue = false, 
    Callback = function(Value) end,
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
    ClosePlayers = {}
    for i,v in pairs(Players:GetPlayers()) do
        if v == LocalPlayer then continue end
        local distance = v:DistanceFromCharacter(LocalPlayer.Character.HumanoidRootPart.Position)
        if distance < 7 then
            table.insert(ClosePlayers,v)
        end
    end
end)


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
                local args = {
                    [1] = v.Character.Humanoid,
                    [2] = 5
                }
                LocalPlayer.Character.Fist.LocalScript.punched:InvokeServer(unpack(args))
            end
        end
    end,
    
 })
local Section = Exploits:CreateSection("Infinite Yield")
local Label = Exploits:CreateLabel("I like to use infinite yield for chams, locate, etc, so here it is.")
local InjectInfiniteYield = Exploits:CreateButton({
    Name = "Inject Infinite Yield",
    Callback = function() 
        loadstring(game:HttpGet('https://raw.githubusercontent.com/EdgeIY/infiniteyield/master/source'))()
    end,
})


-- Teleport
local BankVaultTP = Teleport:CreateButton({
    Name = "Bank Vault",
    Callback = function() 
        TeleportPlayer(-1239,-260,-371)
    end,
})
local BankLootSellerTP = Teleport:CreateButton({
    Name = "Bank Loot Seller",
    Callback = function() 
        TeleportPlayer(-856,3,385)
    end,
})
local CarDealerTP = Teleport:CreateButton({
    Name = "Car Dealer",
    Callback = function() 
        TeleportPlayer(-680,4,54)
    end,
})
local GunDealerTP = Teleport:CreateButton({
    Name = "Gun Dealer",
    Callback = function() 
        TeleportPlayer(-587,3,-402)
    end,
})
local Section = Teleport:CreateSection("Fun")
local Label = Teleport:CreateLabel("Use this when you have some people in your car lollllll")

local PutCarUnderMap = Teleport:CreateButton({
    Name = "PutCarUnderMap",
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
local Section = ATM:CreateSection("Remote ATM")
local Deposit = ATM:CreateInput({
    Name = "Deposit Money",
    PlaceholderText = "Type amount...",
    RemoveTextAfterFocusLost = true,
    Callback = function(amount)
        DepositMoney(amount)
    end,
 })
local Withdraw = ATM:CreateInput({
    Name = "Withdraw Money",
    PlaceholderText = "Type amount...",
    RemoveTextAfterFocusLost = true,
    Callback = function(amount)
        WithdrawMoney(amount)
    end,
})

local Section = ATM:CreateSection("Quick Action")
local DepositAll = ATM:CreateButton({
    Name = "Deposit All Money",
    Callback = function() 
        DepositMoney(LocalPlayer.stored.Money.Value)
    end,
})
local Withdraw100k = ATM:CreateButton({
    Name = "Withdaw 100,000",
    Callback = function() 
        WithdrawMoney(100000)
    end,
})
local Section = Money:CreateSection("Robbable Cars")
local CarMoneyFarmButton = Money:CreateButton({
    Name = "Run Car Money Farm (Cars reset 3min)",
    Callback = function() CarMoneyFarm() end
 })


local Section = Money:CreateSection("Crypto")
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
local Section = Money:CreateSection("Bank")

local Label = Money:CreateLabel("C4 Plant works anywhere and works on servers with <10 players.")
local C4Exploit = Money:CreateButton({
    Name = "Instant C4 Plant",
    Callback = function(Value)
        PlantC4()
    end
})


local Section = Safe:CreateSection("Remote Safe")
local StoreItem = Safe:CreateInput({
    Name = "Store Item In Safe",
    PlaceholderText = "Type item name...",
    RemoveTextAfterFocusLost = true,
    Callback = function(amount)
        local args = {
            [1] = "Change",
            [2] = ItemToStore,
            [3] = "Backpack",
            [4] = LocalPlayer.Character.HumanoidRootPart
        }
        ReplicatedStorage.Inventory:FireServer(unpack(args))
    end,
})
local TakeItem = Safe:CreateInput({
    Name = "Take Item In Safe",
    PlaceholderText = "Type item name...",
    RemoveTextAfterFocusLost = true,
    Callback = function(amount)
        local args = {
            [1] = "Change",
            [2] = ItemToStore,
            [3] = "Inv",
            [4] = LocalPlayer.Character.HumanoidRootPart
        }
        ReplicatedStorage.Inventory:FireServer(unpack(args))
    end,
})
local StealBankMoney = function ()
    if ReplicatedStorage.BankRobbery.Value == true then
        local LootBuyerPrompt = workspace:FindFirstChild("Loot Buyer"):FindFirstChild("Handler")
        for i,v in pairs(game.workspace.BankInteractions:GetChildren()) do
            local ProximityPrompt = v:FindFirstChildOfClass("ProximityPrompt")
            ProximityPrompt.RequiresLineOfSight = false
            ProximityPrompt.MaxActivationDistance = 15
            if ProximityPrompt.Enabled == true then
                LocalPlayer.Character.HumanoidRootPart.CFrame = v.CFrame + Vector3.new(0,3,0)
                wait(0.25)
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
                DepositMoney(LocalPlayer.stored.Money.Value)
                wait()
                Respawn()
                wait(1.5)
            end
        end 
    end
end
local RobBank = Money:CreateButton({
    Name = "Rob Bank",
    Callback = function()
        LocalPlayer.DevCameraOcclusionMode = "Invisicam"
        StealBankMoney()
        LocalPlayer.DevCameraOcclusionMode = "Zoom"
    end
})
local FarmServerBank = Money:CreateButton({
    Name = "Farm Server Bank",
    Callback = function()
        LocalPlayer.DevCameraOcclusionMode = "Invisicam"
        if ReplicatedStorage.BankRobbery.Value == false then
            if ReplicatedStorage.BankCooldown.Value ~= 0 then 
                print(ReplicatedStorage.BankCooldown.Value)
                return
            end
            Respawn()
            wait(2)
            BuyItem("C4", 1500)
            wait()
            TeleportPlayer(-1239,-260,-371)
            wait(0.5)
            local PlayerC4 = LocalPlayer.Backpack:FindFirstChild("C4")
            LocalPlayer.Character.Humanoid:EquipTool(PlayerC4)
            PlantC4()
            wait(6.7)
            StealBankMoney()
            StealBankMoney()
            StealBankMoney()
        else
            StealBankMoney()
            StealBankMoney()
            StealBankMoney()
        end
        
        wait(0.25)
        StealBankMoney()
        GUI:Notify({
            Title = "Done",
            Content = "BANK ROBBERY FINISHED!!!!!!!!",
            Duration = 3,
            Image = 4483362458,
        })
        LocalPlayer.DevCameraOcclusionMode = "Zoom"
    end
})
-- not working
local findSmallestLobby = function()
    local API = "https://games.roblox.com/v1/games/"
    local PlaceId = game.PlaceId
    local ServersAPILink = API..PlaceId.."/servers/Public?sortOrder=Asc&limit=100"
    local GetAPIResultForLink = function ()
        local raw = HttpService:GetAsync(ServersAPILink)
        print(raw)
        return HttpService:JSONDecode(raw)
    end
    local Server
    local APIResult = GetAPIResultForLink(ServersAPILink)
    local Servers = APIResult.data
    for i,v in pairs(Servers) do
        if v.playing < 10 then
            print(v.id)
            if VisitedServers[v.id] == nil then -- not visited
                if (os.time() - VisitedServers[v.id]) > 600 then
                    table.remove(VisitedServers, v)
                    Server = v
                    break
                else
                    continue
                end
            else
                Server = v
                break
            end
        end
    end
    
    print("Telported to",Server.id)
    print(os.time())
    VisitedServers[Server.id] = os.time()    
    --TeleportService:TeleportToPlaceInstance(PlaceId, Server.id, LocalPlayer)
    
    wait(2)
    print(os.time() - VisitedServers[Server.id])
end