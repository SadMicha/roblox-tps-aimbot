---@diagnostic disable: undefined-global

-- options
getgenv().options = {
    aimbot = true,
    aimbot_toggle_key = Enum.KeyCode.E.Name,
    aimbot_key = Enum.UserInputType.MouseButton1.Name,
    fov = 300,
    show_fov = true,
    fov_color = Color3.new(1, 1, 1),
    smoothness = 1,
    triggerbot = false,
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
            end})
            
            SettingSection:Keybind({Name = "Aimbot Key", Key = options.aimbot_key, Mouse = true, Blacklist = {"W","A","S","D","Slash","Tab","Backspace","Escape","Space","Delete","Unknown","Backquote"}, Callback = function(key, bool)
                options.aimbot_key = key
            end})

            SettingSection:Slider({Name = "Smoothness", Min = 0, Max = 10, Value = options.smoothness, Precise = 1, Unit = "", Callback = function(number)
                options.smoothness = number
            end})

            SettingSection:Slider({Name = "Max Distance", Min = 0, Max = 10000, Value = options.max_distance, Precise = 10, Unit = "", Callback = function(number)
                options.max_distance = number
            end})

            SettingSection:Toggle({Name = "Triggerbot", Value = options.triggerbot, Callback = function(bool)
                options.triggerbot = bool
            end})
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
            end})
        end
    end
end

local uis = game:GetService("UserInputService")
local playerService = game:GetService("Players")
local run_service = game:GetService("RunService")
local local_player = playerService.LocalPlayer
local camera = workspace.CurrentCamera
local mouse = local_player:GetMouse()

local aiming = {
    fov_circle_object = nil
}

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

    local raycast_result = workspace.Raycast(workspace, local_player.Character.Head.Position, (target.Character.PrimaryPart.Position - local_player.Character.PrimaryPart.Position).Unit * 1000, raycast_params)
    local result_part = ((raycast_result and raycast_result.Instance))

    raycast_params.FilterDescendantsInstances = ignore_list

    if (result_part.Transparency >= 0.3) or (result_part.Material == Enum.Material.Glass) then
        ignored_instances[#ignored_instances + 1] = result_part
    end

    return game.IsDescendantOf(result_part, target.Character)
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

local function new_drawing(class_name)
    return function(props)
        local inst = Drawing.new(class_name)

        for idx, val in pairs(props) do
            if idx ~= "instance" then
                inst[idx] = val
            end
        end
        
        return inst
    end
end

local function add_or_update_instance(table, child, props)
    local inst = table[child]
    if not inst then
        table[child] = new_drawing(props.instance)(props)
        return inst
    end

    for idx, val in pairs(props) do
        if idx ~= "instance" then
            inst[idx] = val
        end
    end

    return inst
end

local function world_to_view_point(pos)
    local vector, inViewport = camera:WorldToViewportPoint(pos)
    if inViewport then
        return Vector2.new(vector.X, vector.Y)
    end
end

local function is_in_fov(pos)
    local real_pos = world_to_view_point(pos)
    return ((real_pos.X - aiming.fov_circle_object.Position.X) ^ 2 + (real_pos.Y - aiming.fov_circle_object.Position.Y) ^ 2 <= aiming.fov_circle_object.Radius ^ 2)
end

local function closest_player()
    local closest = nil

    for _, players in ipairs(playerService:GetPlayers()) do
        if players == local_player then continue end

        if (mouse.Hit.Position - players.Character.PrimaryPart.Position).Magnitude <= options.max_distance then
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

        add_or_update_instance(aiming, "fov_circle_object", {
            Visible = options.show_fov,
            Thickness = 1,
            Radius = options.fov,
            Position = Vector2.new(mouse.X, mouse.Y + 36),
            Color = options.fov_color,
            instance = "Circle",
        })

        -- code
        if options.aimbot and startAim then
            local closest = closest_player()
            if closest ~= nil then
                print("closest Object", closest)
            end
            if closest then
                print("closest ", closest.Name)
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
            if options.ui_visible ~= nil then
                Window:Toggle(options.ui_visible)
            end
        elseif input.KeyCode.Name == options.aimbot_toggle_key then
            options.aimbot = not options.aimbot
        elseif input.UserInputType.Name == options.aimbot_key then
            startAim = true
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