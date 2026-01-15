local Players = game:GetService("Players")
local VirtualInputManager = game:GetService("VirtualInputManager")
local TeleportService = game:GetService("TeleportService")
local HttpService = game:GetService("HttpService")
local player = Players.LocalPlayer
local TARGET_POS = Vector3.new(1111.29, 12.96, -326.66)--现金堆坐标

-- 换服函数：获取随机可用服务器
local function getRandomServer()
    local placeId = game.PlaceId
    local apiUrl = "https://games.roblox.com/v1/games/" .. placeId .. "/servers/Public?sortOrder=Asc&limit=100"
    local cursor = nil
    
    repeat
        local url = apiUrl .. (cursor and "&cursor=" .. cursor or "")
        local success, response = pcall(function()
            return game:HttpGet(url)
        end)
        
        if not success then
            warn("获取服务器列表失败: " .. response)
            task.wait(2)
            return nil
        end
        
        local servers = HttpService:JSONDecode(response)
        local validServers = {}
        
        for _, server in ipairs(servers.data) do
            if server.id ~= game.JobId and server.playing < server.maxPlayers then
                table.insert(validServers, server)
            end
        end
        
        if #validServers > 0 then
            local randomIndex = math.random(1, #validServers)
            return validServers[randomIndex]
        end
        
        cursor = servers.nextPageCursor
        task.wait(1)
    until not cursor
    
    return nil
end

-- 主流程：单次传送+8秒互动+换服
local function main()
    -- 单次传送至现金堆
    local character = player.Character or player.CharacterAdded:Wait()
    local humanoidRootPart = character:WaitForChild("HumanoidRootPart", 5)
    
    if humanoidRootPart then
        humanoidRootPart.CFrame = CFrame.new(TARGET_POS)
        print("已传送至现金堆位置（仅一次）")
    else
        warn("未找到HumanoidRootPart，无法传送")
        return
    end

    -- 自动互动8秒
    print("开始自动互动，持续8秒...")
    local endTime = os.clock() + 8
    while os.clock() < endTime do
        VirtualInputManager:SendKeyEvent(true, "E", false, game)
        task.wait(0.01)
        VirtualInputManager:SendKeyEvent(false, "E", false, game)
        task.wait(0.01)
    end
    print("自动互动结束")

    -- 获取目标服务器并执行换服
    local targetServer = getRandomServer()
    if targetServer then
        print("准备换服至服务器: " .. targetServer.id)
        
        -- 换服后自动执行的脚本
        local teleportScript = [[
            loadstring(game:HttpGet("https://raw.githubusercontent.com/ccnnmmccnnmm/ccnnmm/refs/heads/main/money.lua"))()
        ]]
        queue_on_teleport(teleportScript)
        
        task.wait(1)
        TeleportService:TeleportToPlaceInstance(game.PlaceId, targetServer.id, player)
    else
        warn("未找到可用服务器，换服失败")
    end
end

-- 启动主流程
main()
