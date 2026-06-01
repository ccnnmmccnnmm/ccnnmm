local player = game:GetService("Players").LocalPlayer
local TeleportService = game:GetService("TeleportService")
local HttpService = game:GetService("HttpService")
local character = player.Character or player.CharacterAdded:Wait()
local HumanoidRootPart = character:WaitForChild("HumanoidRootPart")
local humanoid = character:WaitForChild("Humanoid")
local scriptStartTime = os.time()
local forbiddenZoneCenter = Vector3.new(352.884155, 13.0287256, -1353.05396)
local forbiddenRadius = 80

-- 获取可用服务器列表
local function getAvailableServers()
    local servers = HttpService:JSONDecode(game:HttpGet("https://games.roblox.com/v1/games/" .. game.PlaceId .. "/servers/Public?limit=100"))
    local currentJobId = game.JobId
    local availableServers = {}
    for _, server in ipairs(servers.data) do
        if server.id ~= currentJobId and server.playing < server.maxPlayers and server.playing < 38 then
            table.insert(availableServers, server.id)
        end
    end
    return availableServers
end

local availableServers = getAvailableServers()

local targetItems = {
    "Money Printer", "Golden Rose", "Black Rose", "Spectral Scythe", "Void Gem", "Diamond",
    "Blue Candy Cane", "Red Candy Cane", "Heart Balloon", "Golden Clover Balloon", "Bat Balloon",
    "Suitcase Nuke", "Helicopter Key", "Wild Horse Key", "Easter Basket", "Diamond Banana Peel",
    "Nuclear Launcher", "Nuclear Missile Launcher", "Trident", "Golden Cup", "Pearl Necklace",
    "NextBot Grenade", "Golden AK47", "Green Lucky Block", "Candy Cane", "Purple Lucky Block",
    "Treasure Map", "Snowflake Balloon", "Skull Balloon", "Gold AK-47", "Gold Deagle", "Lucky Egg",
    "Orange Lucky Block", "Rollie"
}

local function checkTimeout()
    return (os.time() - scriptStartTime) >= 10
end

-- 换服函数（包含换服后自动执行逻辑）
local function TPServer()
    local servers = getAvailableServers()
    if #servers > 0 then
        -- 设置换服后自动执行的脚本
        local teleportScript = [[
            loadstring(game:HttpGet("https://raw.githubusercontent.com/ccnnmmccnnmm/ccnnmm/refs/heads/main/money.lua"))()
        ]]
        queue_on_teleport(teleportScript)
        
        -- 执行换服
        TeleportService:TeleportToPlaceInstance(game.PlaceId, servers[math.random(1, #servers)], player)
    end
end

local function AutoPickItem()
    while task.wait(0.1) do
        if checkTimeout() then
            TPServer()
            return
        end
        local foundItem = false
        if workspace:FindFirstChild("Game") and workspace.Game:FindFirstChild("Entities") and workspace.Game.Entities:FindFirstChild("ItemPickup") then
            for _, itemFolder in pairs(workspace.Game.Entities.ItemPickup:GetChildren()) do
                for _, item in pairs(itemFolder:GetChildren()) do
                    if (item:IsA("MeshPart") or item:IsA("Part")) then
                        local itemPos = item.Position
                        local distance = (itemPos - forbiddenZoneCenter).Magnitude
                        if distance > forbiddenRadius then
                            for _, child in pairs(item:GetChildren()) do
                                if child:IsA("ProximityPrompt") then
                                    for _, targetName in pairs(targetItems) do
                                        if child.ObjectText == targetName then
                                            foundItem = true
                                            humanoid:Move(Vector3.new(1, 0, 0))
                                            HumanoidRootPart.CFrame = item.CFrame * CFrame.new(0, 2, 0)
                                            child.RequiresLineOfSight = false
                                            child.HoldDuration = 0
                                            fireproximityprompt(child)
                                            task.wait(0.01)
                                        end
                                    end
                                end
                            end
                        end
                    end
                end
            end
        end
        if not foundItem then
            TPServer()
            return
        end
    end
end

AutoPickItem()
