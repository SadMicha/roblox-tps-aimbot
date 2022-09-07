local HttpService = game:GetService("HttpService")
---@diagnostic disable: undefined-global

-- options
local function getConfigs()
    if not isfolder("vakware but better") then makefolder("vakware but better") end
    if not isfolder("vakware but better\\Configs") then makefolder("vakware but better\\Configs") end
    if not isfile("vakware but better\\Configs\\" .. name .. ".json") then writefile("vakware but better\\Configs\\" .. name .. ".json", "") end

    local Configs = {}
    for Index,File in pairs(listfiles("vakware but better\\Configs") or {}) do
        File = File:gsub("vakware but better\\Configs\\","")
        File = File:gsub(".json","")
        Configs[Index] = File
    end
    return Configs
end

local function loadConfig(name)
    if not isfolder("vakware but better") then makefolder("vakware but better") end
    if not isfolder("vakware but better\\Configs") then makefolder("vakware but better\\Configs") end
    if not isfile("vakware but better\\Configs\\" .. name .. ".json") then writefile("vakware but better\\Configs\\" .. name .. ".json", "") end

    if table.find(getConfigs(), name) then
        local decodeJSON = HttpService:JSONDecode(readfile("vakware but better\\Configs\\" .. name .. ".json"))
        for i, e in pairs(options) do
            print(i, e)
            print(decodeJSON)
        end
    end
end

local function saveConfig(name)

end

getgenv().options = {
    aimbot = true,
    aimbot_toggle_key = Enum.KeyCode.E.Name,
    aimbot_key = Enum.UserInputType.MouseButton1.Name,
    fov = 300,
    show_fov = true,
    fov_color = Color3.new(1, 1, 1),
    smoothness = 1,
    triggerbot = false,
    triggerbot_key = Enum.KeyCode.X.Name,
    max_distance = 1000,

    team_check = true,
    wall_check = true,

    ui_toggle_key = Enum.KeyCode.RightControl.Name,
    ui_visible = true
}

-- random
math.randomseed(tick())
local function random_string(len)
	local str = ""
	for i = 1, len do
		str = str .. string.char(math.random(97, 122))
	end
	return str
end
getgenv().update_loop_stepped_name = random_string(math.random(15, 35))

local startAim = false

-- ui stuff
local Bracket = loadstring(game:HttpGet("https://raw.githubusercontent.com/AlexR32/Bracket/main/BracketV32.lua"))()

local Window = Bracket:Window({Name = "vakware but better", Enabled = true, Color = Color3.new(1,0.5,0.25), Size = UDim2.new(0,496,0,496), Position = UDim2.new(0.5,-248,0.5,-248)}) do
    -- aimbot
    local Aimbot = Window:Tab({Name = "Aimbot"}) do
        -- settings
        Aimbot:Divider({Text = "Settings", Side = "Left"})
        local SettingSection = Aimbot:Section({Name = "Settings", Side = "Left"}) do
            SettingSection:Toggle({Name = "Aimbot", Value = options.aimbot, Callback = function(bool)
                options.aimbot = bool
            end}):Keybind({Key = options.aimbot_toggle_key, Mouse = false, Blacklist = {"W","A","S","D","Slash","Tab","Backspace","Escape","Space","Delete","Unknown","Backquote"}, Callback = function(key, boolk)
                options.aimbot_toggle_key = key
            end}):SetValue(options.aimbot_toggle_key)
            
            SettingSection:Keybind({Name = "Aimbot Key", Key = options.aimbot_key, Mouse = true, Blacklist = {"W","A","S","D","Slash","Tab","Backspace","Escape","Space","Delete","Unknown","Backquote"}, Callback = function(key, bool)
                options.aimbot_key = key
            end}):SetValue(options.aimbot_key)

            SettingSection:Slider({Name = "Smoothness", Min = 0, Max = 10, Value = options.smoothness, Precise = 1, Unit = "", Callback = function(number)
                options.smoothness = number
            end})

            SettingSection:Slider({Name = "Max Distance", Min = 0, Max = 10000, Value = options.max_distance, Precise = 10, Unit = "", Callback = function(number)
                options.max_distance = number
            end})

            SettingSection:Toggle({Name = "Triggerbot", Value = options.triggerbot, Callback = function(bool)
                options.triggerbot = bool
            end}):Keybind({Name = "Triggerbot Key", Key = options.triggerbot_key, Mouse = false, Blacklist = {"W","A","S","D","Slash","Tab","Backspace","Escape","Space","Delete","Unknown","Backquote"}, Callback = function(key, bool)
                options.triggerbot_key = key
            end}):SetValue(options.triggerbot_key)
        end

        -- visual
        Aimbot:Divider({Text = "Visual", Side = "Left"})
        local Visual = Aimbot:Section({Name = "Visual", Side = "Left"}) do
            Visual:Slider({Name = "FOV", Min = 0, Max = 1000, Value = options.fov, Precise = 2, Unit = "", Callback = function(number)
                options.fov = number
            end})

            Visual:Toggle({Name = "Show FOV", Value = options.show_fov, Callback = function(bool)
                options.show_fov = bool
            end})

            Visual:Colorpicker({Name = "FOV Color", Color = options.fov_color, Callback = function(color, table)
                options.fov_color = table
            end})
        end

        -- misc
        Aimbot:Divider({Text = "Misc", Side = "Right"})
        local Misc = Aimbot:Section({Name = "Misc", Side = "Right"}) do
            Misc:Toggle({Name = "Team Check", Value = options.team_check, Callback = function(bool)
                options.team_check = bool
            end})

            Misc:Toggle({Name = "Wall Check", Value = options.wall_check, Callback = function(bool)
                options.wall_check = bool
            end})
        end
    end

    -- esp

    -- settings
    local Settings = Window:Tab({Name = "UI Settings"}) do
        Settings:Divider({Text = "Settings", Side = "Left"})
        local SettingSection = Settings:Section({Name = "Settings", Side = "Left"}) do
            SettingSection:Keybind({Name = "UI Toggle", Key = options.ui_toggle_key, Mouse = false, Blacklist = {"W","A","S","D","Slash","Tab","Backspace","Escape","Space","Delete","Unknown","Backquote"}, Callback = function(key, bool)
                options.ui_toggle_key = key
            end}):SetValue(options.ui_toggle_key)
        end
    end
end

local uis = game:GetService("UserInputService")
local playerService = game:GetService("Players")
local run_service = game:GetService("RunService")
local local_player = playerService.LocalPlayer
local camera = workspace.CurrentCamera
local mouse = local_player:GetMouse()

local fov_circle_object = Drawing.new("Circle")
fov_circle_object.Visible = options.show_fov
fov_circle_object.Radius = options.fov
fov_circle_object.Color = options.fov_color
fov_circle_object.Thickness = 1
fov_circle_object.Position = Vector2.new(mouse.X, mouse.Y + 36)

local ignored_instances = {}
local function can_hit(target)
    if options.wall_check == false then return true end

    local raycast_params = RaycastParams.new()
    raycast_params.FilterType = Enum.RaycastFilterType.Blacklist
    raycast_params.IgnoreWater = true

    local ignore_list = {camera, local_player.Character}

    for _, val in pairs(ignored_instances) do
        ignore_list[#ignore_list + 1] = val
    end

    local raycast_result = workspace.Raycast(workspace, local_player.Character.Head.Position, (target.Character.Head.Position - local_player.Character.Head.Position).Unit * 1000, raycast_params)
    local result_part = ((raycast_result and raycast_result.Instance))

    raycast_params.FilterDescendantsInstances = ignore_list

    if result_part ~= nil then
        if (result_part.Transparency >= 0.3) or (result_part.Material == Enum.Material.Glass) then
            ignored_instances[#ignored_instances + 1] = result_part
        end
        return result_part:IsDescendantOf(target.Character)
    end

    return false
end

local function check_same_team(target)
    if options.team_check == false then return false end
    local placeId = game.PlaceId

    if placeId == 5361853069 then -- Snow Core
        local leaderboard = local_player:FindFirstChild("PlayerGui"):FindFirstChild("LeaderboardUI")
        local leaderboardNew = leaderboard:FindFirstChild("LeaderboardNew")
        local teamA = leaderboardNew:FindFirstChild("TeamAFrame"):FindFirstChild("TeamA"):FindFirstChild("PlayersList")
        local teamB = leaderboardNew:FindFirstChild("TeamBFrame"):FindFirstChild("TeamB"):FindFirstChild("PlayersList")

        local playerTeams = {}

        for _, items in ipairs(teamA:GetChildren()) do
            if items.Name == target.Name then
                playerTeams[#playerTeams + 1] = target.Name
            elseif items.Name == local_player.Name then
                playerTeams[#playerTeams + 1] = local_player.Name
            end
        end

        if #playerTeams >= 2 then
            return true
        else
            playerTeams = {}
            for _, items in ipairs(teamB:GetChildren()) do
                if items.Name == target.Name then
                    playerTeams[#playerTeams + 1] = target.Name
                elseif items.Name == local_player.Name then
                    playerTeams[#playerTeams + 1] = local_player.Name
                end
            end

            if #playerTeams >= 2 then
                return true
            end
        end
    else
        if target.Team == local_player.Team then
            return true
        end
    end

    return false
end

local function world_to_view_point(pos)
    local vector, inViewport = camera:WorldToViewportPoint(pos)
    if inViewport then
        return Vector2.new(vector.X, vector.Y)
    end
end

local function is_in_fov(pos)
    local real_pos = world_to_view_point(pos)
    if real_pos ~= nil and real_pos.X ~= nil and real_pos.Y ~= nil then
        return ((real_pos.X - fov_circle_object.Position.X) ^ 2 + (real_pos.Y - fov_circle_object.Position.Y) ^ 2 <= fov_circle_object.Radius ^ 2)
    end
end

local function closest_player()
    local closest = nil

    for _, players in pairs(playerService:GetPlayers()) do
        if players == local_player then continue end

        if (players ~= nil and players.Character ~= nil and players.Character.PrimaryPart ~= nil) and ((mouse.Hit.Position - players.Character.PrimaryPart.Position).Magnitude < options.max_distance) then
            if can_hit(players) and not check_same_team(players) and is_in_fov(players.Character.PrimaryPart.Position) and players.Character.Humanoid.Health > 0 then
                closest = players
            end
        end
    end

    return closest
end

local function get_aim_part(target)
    if mouse.Target then
        if mouse.Target:FindFirstChild("Humanoid") or mouse.Target.Parent:FindFirstChild("Humanoid") then
            local local_target = playerService:GetPlayerFromCharacter(mouse.Target.Parent)
            if local_target and closest_player() == local_target and (mouse.Target:IsA("BasePart") or mouse.Target:IsA("Part")) then
                return mouse.Target.Position
            end
        end
    end

    return target.Character.HumanoidRootPart.Position
end



local last_tick = 0
local function stepped()
    if (tick() - last_tick) > (10 / 1000) then
        last_tick = tick()
        
        fov_circle_object.Visible = options.show_fov
        fov_circle_object.Radius = options.fov
        fov_circle_object.Color = options.fov_color
        fov_circle_object.Thickness = 1
        fov_circle_object.Position = Vector2.new(mouse.X, mouse.Y + 36)
        
        -- code
        if options.aimbot and startAim then
            local closest = closest_player()
            if closest then
                local aim_part = get_aim_part(closest)
                if aim_part then
                    local real_pos = world_to_view_point(aim_part)
                    mousemoverel((real_pos.X - mouse.X) / options.smoothness, (real_pos.Y - (mouse.Y + 36)) / options.smoothness)
                end
            end
        end
    end
end

uis.InputBegan:Connect(function(input, gameProcessedEvent)
    if not gameProcessedEvent then
        if input.KeyCode.Name == options.ui_toggle_key then
            options.ui_visible = not options.ui_visible
            Window:Toggle(options.ui_visible)
        elseif input.KeyCode.Name == options.aimbot_toggle_key then
            options.aimbot = not options.aimbot
        elseif input.UserInputType.Name == options.aimbot_key then
            startAim = true
        elseif input.KeyCode.Name == options.triggerbot_key then
            options.triggerbot = not options.triggerbot
        end
    end
end)

uis.InputEnded:Connect(function(input, gameProcessedEvent)
    if not gameProcessedEvent then
        if input.UserInputType.Name == options.aimbot_key then
            startAim = false
        end
    end
end)

run_service:BindToRenderStep(update_loop_stepped_name, 199, stepped)