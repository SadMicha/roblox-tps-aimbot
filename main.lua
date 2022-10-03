if not game:IsLoaded() then
    game.Loaded:Wait()
end

if getgenv().roblox_tps_aimbot then
    return
end

-- instancing
local drawing_new = Drawing.new
local instance_new = Instance.new

-- workspace
local vector2_new = Vector2.new
local raycast_params_new = RaycastParams.new
local raycast = workspace.Raycast

-- math
local math_random = math.random
local math_randomseed = math.randomseed

-- string
local string_char = string.char

-- table
local table_sort = table.sort

-- globals
local pairs = pairs
local tick = tick
local getgenv = getgenv
local mousemoverel = mousemoverel
local mouse1press = mouse1press
local mouse1release = mouse1release
local hookfunction = hookfunction
local newcclosure = newcclosure

-- random
math_randomseed(tick())
function random_string(len)
	local str = ""
	for i = 1, len do
		str = str .. string_char(math_random(97, 122))
	end
	return str
end

getgenv().render_loop_stepped_name = getgenv().renderloop_stepped_name or random_string(math_random(15, 35))
getgenv().update_loop_stepped_name = getgenv().update_loop_stepped_name or random_string(math_random(15, 35))
getgenv().roblox_tps_aimbot = true

-- services
local players = game:GetService("Players")
local run_service = game:GetService("RunService")
local Teams = game:GetService("Teams")
local uis = game:GetService("UserInputService")
local HttpService = game:GetService("HttpService")

-- other
local local_player = players.LocalPlayer
local mouse = local_player:GetMouse()

local cam = workspace.CurrentCamera

local enum_rft_blk = Enum.RaycastFilterType.Blacklist
local glass = Enum.Material.Glass

local dummy_part = instance_new("Part", nil)

drawing_new("Square").Visible = false -- initialize drawing lib

local refresh_que = false
local start_aim = false
local frame_delay = 10
local refresh_delay = 0.25

getgenv().options = { -- DEFAULT
    -- misc
    max_distance = 10000,
    team_check = true,
    wall_check = true,

    -- visual
    fov_circle = true,
	fov = 200,
    dynamic_fov = false,

    -- aimbot
    aimbot = true,
    aimbot_toggle_key = Enum.KeyCode["E"].Name,
    smoothness = 3,

    triggerbot = false,
    triggerbot_key = Enum.KeyCode["X"].Name,
    aimbot_key = Enum.UserInputType["MouseButton1"].Name,

    -- ui
    ui_toggle_key = Enum.KeyCode["RightControl"].Name,
    ui_toggle = true,

    -- esp
    esp = true,
    esp_thickness = 1,

    -- esp categories
    box = true,

    -- box
    box_health = true,
    box_distance = true,
    box_name = true,
}

-- color since i cant fix save for color bc shit programer
local box_color = Color3.new(1, 1, 1)
local fov_color = Color3.new(1, 1, 1)

local function loadConfig()
    if not isfolder("vakware but better\\Configs") then makefolder("vakware but better\\Configs") end
    if not isfile("vakware but better\\Configs\\Config.json") then
        writefile("vakware but better\\Configs\\Config.json", "{}")
        return
    end

    local decodeJSON = HttpService:JSONDecode(readfile("vakware but better\\Configs\\Config.json"))
    for i, v in pairs(options) do
        if decodeJSON[i] ~= nil then
            options[i] = decodeJSON[i]
        end
    end
end

local function saveConfig()
    local config = HttpService:JSONDecode(readfile("vakware but better\\Configs\\Config.json"))
    for i, _ in pairs(options) do
        config[i] = options[i]
    end
    writefile("vakware but better\\Configs\\Config.json", HttpService:JSONEncode(config))
end

loadConfig()

local Bracket = loadstring(game:HttpGet("https://raw.githubusercontent.com/AlexR32/Bracket/main/BracketV32.lua"))()
local Window = Bracket:Window({Name = "vakware but better", Enabled = options.ui_toggle, Color = Color3.new(1, 0, 0), Size = UDim2.new(0,496,0,496), Position = UDim2.new(0.5,-248,0.5,-248)}) do
    Window.Background = imageLabel
    local Aimbot = Window:Tab({Name = "Aimbot"}) do
        -- settings
        Aimbot:Divider({Text = "Settings", Side = "Left"})
        local SettingSection = Aimbot:Section({Name = "Settings", Side = "Left"}) do
            SettingSection:Toggle({Name = "Aimbot", Value = options.aimbot, Callback = function(bool)
                options.aimbot = bool
            end}):Keybind({Key = options.aimbot_toggle_key, Mouse = false, Blacklist = {"W","A","S","D","Slash","Tab","Backspace","Escape","Space","Delete","Unknown","Backquote"}, Callback = function(bool, key)
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

            Visual:Toggle({Name = "Show FOV", Value = options.fov_circle, Callback = function(bool)
                options.fov_circle = bool
            end})

            Visual:Colorpicker({Name = "FOV Color", Color = fov_color, Callback = function(color, table)
                fov_color = table
            end})

            Visual:Toggle({Name = "Dynamic FOV", Value = options.dynamic_fov, Callback = function(bool)
                options.dynamic_fov = bool
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
    local ESP = Window:Tab({Name = "ESP"}) do
        ESP:Divider({Text = "Global", Side = "Right"})
        local GlobalESPSection = ESP:Section({Name = "Global", Side = "Right"}) do
            GlobalESPSection:Toggle({Name = "ESP", Value = options.esp, Callback = function(bool)
                options.esp = bool
            end})

            GlobalESPSection:Slider({Name = "ESP Thickness", Min = 0, Max = 10, Value = options.esp_thickness, Precise = 1, Unit = "", Callback = function(number)
                options.esp_thickness = number
            end})
        end

        ESP:Divider({Text = "Box", Side = "Left"})
        local BoxSection = ESP:Section({Name = "Box", Side = "Left"}) do
            BoxSection:Toggle({Name = "Box", Value = options.box, Callback = function(bool)
                options.box = bool
            end})

            BoxSection:Colorpicker({Name = "Box Color", Color = box_color, Callback = function(color, table)
                box_color = table
            end})

            BoxSection:Toggle({Name = "Box Health", Value = options.box_health, Callback = function(bool)
                options.box_health = bool
            end})

            BoxSection:Toggle({Name = "Box Name", Value = options.box_name, Callback = function(bool)
                options.box_name = bool
            end})
        end
    end

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

local players_table = {}

local function get_players()
    return players:GetPlayers()
end

local aiming = {
    fov_circle_obj = nil,
    cursor_offset = nil,
}

local box = {}
local box_health = {}
local box_name = {}
local box_outline = {}
local box_health_outline = {}

-- needed functions
local function to_screen(vec3)
    local screen_pos, in_screen = cam:WorldToViewportPoint(vec3)
    return Vector3.new(screen_pos.X, screen_pos.Y, screen_pos.Z), in_screen
end

local function new_drawing(class_name)
    return function(props)
        local inst = drawing_new(class_name)

        for idx, val in pairs(props) do
            if idx ~= "instance" then
                inst[idx] = val
            end
        end

        return inst
    end
end

local function add_or_update_instance(tbl, child, props)
    local inst = tbl[child]
    if not inst then
        tbl[child] = new_drawing(props.instance)(props)
        return inst
    end

    for idx, val in pairs(props) do
        if idx ~= "instance" then
            inst[idx] = val
        end
    end

    return inst
end

local function get_character(player: Player)
    local char = nil
    for _, v in ipairs(game:GetService("Workspace"):GetDescendants()) do
        if v:IsA("Model") and v.Name == player.Name and v:FindFirstChildOfClass("Humanoid") then
            char = v
        end
    end

    return (char ~= nil and char) or player.Character
end

local ignored_instances = {}

local raycast_params = raycast_params_new()
raycast_params.FilterType = enum_rft_blk
raycast_params.IgnoreWater = true

local function can_hit(origin_pos, part)
    if not options.wall_check then
        return true
    end

    local ignore_list = {cam, get_character(local_player)}
    for _, val in pairs(ignored_instances) do
        ignore_list[#ignore_list + 1] = val
    end

    raycast_params.FilterDescendantsInstances = ignore_list

    local raycast_result = raycast(workspace, origin_pos, (part.Position - origin_pos).Unit * options.max_distance, raycast_params)
    local result_part = ((raycast_result and raycast_result.Instance) or dummy_part)
    if result_part ~= dummy_part then
        if result_part.Transparency >= 0.3 then -- ignore low transparency
            ignored_instances[#ignored_instances + 1] = result_part
        end

        if result_part.Material == glass then -- ignore glass
            ignored_instances[#ignored_instances + 1] = result_part
        end
    end

    return result_part:IsDescendantOf(part.Parent)
end

local function check_team(obj: Player)
    local placeId = game.PlaceId
    if placeId == (5361853069 or 6941660837) then -- Snow Core Auroras Dam and Pitgrounds
        local leaderboard = local_player:FindFirstChild("PlayerGui"):FindFirstChild("LeaderboardUI")
        local leaderboardNew = leaderboard:FindFirstChild("LeaderboardNew")
        local teamA = leaderboardNew:FindFirstChild("TeamAFrame"):FindFirstChild("TeamA"):FindFirstChild("PlayersList")
        local teamB = leaderboardNew:FindFirstChild("TeamBFrame"):FindFirstChild("TeamB"):FindFirstChild("PlayersList")

        local playerTeams = {}
        local function sortTeam(_obj)
            playerTeams = {}
            for _, items in ipairs(_obj:GetChildren()) do
                if items.Name == obj.Name then
                    playerTeams[#playerTeams + 1] = obj.Name
                elseif items.Name == local_player.Name then
                    playerTeams[#playerTeams + 1] = local_player.Name
                end
            end
        end

        sortTeam(teamA)

        if #playerTeams >= 2 then
            return true
        end

        sortTeam(teamB)

        if #playerTeams >= 2 then
            return true
        end
    elseif placeId == (4632428105 or 2007375127) then -- Port Maersk and Docks
        -- Vaktovians - VACs
        if obj.Team == (Teams.Vaktovians or Teams.VACs) and local_player.Team == (Teams.Vaktovians or Teams.VACs) then
            return true
        else
            if obj.Team == local_player.Team then
                return true
            end
        end
    else
        if obj.Team == local_player.Team then
            return true
        end
    end

    return false
end

local function hitting_what(origin_cframe: CFrame)
    if not options.wall_check then
        return dummy_part
    end

    local ignore_list = {cam, get_character(local_player)}

    for idx, val in pairs(ignored_instances) do
        ignore_list[#ignore_list + 1] = val
    end

    raycast_params.FilterDescendantsInstances = ignore_list

    local raycast_result = raycast(workspace, origin_cframe.Position, origin_cframe.LookVector * options.max_distance, raycast_params)

    local result_part = ((raycast_result and raycast_result.Instance) or dummy_part)

    if result_part ~= dummy_part then
        if result_part.Transparency >= 0.3 then -- ignore low transparency
            ignored_instances[#ignored_instances + 1] = result_part
        end

        if result_part.Material == glass then -- ignore glass
            ignored_instances[#ignored_instances + 1] = result_part
        end
    end

    return result_part
end

local function health_check(obj: Player)
    local char = get_character(obj)
    if not char then return end
    local humanoid = char:FindFirstChildWhichIsA("Humanoid")

    if char and humanoid then
        if humanoid.Health > 0 then
            return true
        end
    end

    return false
end

local function self_health_check()
    local char = get_character(local_player)
    local humanoid = char:FindFirstChildWhichIsA("Humanoid")

    if char and humanoid then
        if humanoid.Health > 0 then
             return true
        end
    end

    return false
end

local function is_inside_fov(point)
    return ((point.x - aiming.fov_circle_obj.Position.X) ^ 2 + (point.y - aiming.fov_circle_obj.Position.Y) ^ 2 <= aiming.fov_circle_obj.Radius ^ 2)
end

-- esp functions
local function remove_esp(index)
    add_or_update_instance(box, index, {
        Visible = false,
        instance = "Square"
    })

    add_or_update_instance(box_name, index, {
        Visible = false,
        instance = "Text"
    })

    add_or_update_instance(box_health, index, {
        Visible = false,
        instance = "Square"
    })

    add_or_update_instance(box_health_outline, index, {
        Visible = false,
        instance = "Square"
    })

    add_or_update_instance(box_outline, index, {
        Visible = false,
        instance = "Square"
    })
end

local function create_box(player, root_part, index)
    local screen_pos, is_visible = to_screen(root_part.Position)
    local scale_factor = 1 / (screen_pos.Z * math.tan(math.rad(cam.FieldOfView * 0.5)) * 2) * 100
    local width, height = math.floor(40 * scale_factor), math.floor(60 * scale_factor)
    local size = vector2_new(width, height)
    
    if is_visible then
        add_or_update_instance(box, index, {
            Visible = options.box,
            Thickness = options.esp_thickness,
            Size = size,
            Position = vector2_new(screen_pos.X - size.X / 2, screen_pos.Y - size.Y / 2),
            ZIndex = 69,
            Color = box_color,
            Filled = false,
            instance = "Square";
        })

        add_or_update_instance(box_outline, index, {
            Visible = options.box,
            Thickness = 3,
            Size = size,
            Position = vector2_new(screen_pos.X - size.X / 2, screen_pos.Y - size.Y / 2),
            ZIndex = 1,
            Color = Color3.new(0, 0, 0),
            Filled = false,
            instance = "Square";
        })

        add_or_update_instance(box_name, index, {
            Visible = options.box_name,
            Color = Color3.new(1, 1, 1),
            Text = player.Name,
            Center = true,
            Outline = true,
            OutlineColor = Color3.new(0, 0, 0),
            Position = vector2_new(screen_pos.X, screen_pos.Y - height * 0.5 + -15),
            Font = 2,
            Size = 13,
            instance = "Text"
        })

        if options.box_health then
            local char = get_character(player)
            local humanoid = char:FindFirstChildWhichIsA("Humanoid")
            if not (humanoid or char) then return end
            local currentHealth = humanoid.Health
            local maxHealth = humanoid.MaxHealth

            local sizeH = vector2_new(2, height)

            add_or_update_instance(box_health, index, {
                Visible = options.box_health,
                Thickness = options.esp_thickness,
                Color = Color3.new(0, 1, 0),
                Filled = true,
                ZIndex = 69,
                Size = vector2_new(1, -(sizeH.Y - 2) * (currentHealth / maxHealth)),
                Position = vector2_new(screen_pos.X - size.X / 2, screen_pos.Y - size.Y / 2) + vector2_new(-3, 0) + vector2_new(1, -1 + (sizeH.Y)),
                instance = "Square"
            })

            add_or_update_instance(box_health_outline, index, {
                Visible = options.box_health,
                Thickness = options.esp_thickness,
                Color = Color3.new(0, 0, 0),
                Filled = true,
                ZIndex = 1,
                Size = sizeH,
                Position = vector2_new(screen_pos.X - size.X / 2, screen_pos.Y - size.Y / 2) + vector2_new(-3, 0),
                instance = "Square"
            })
        end
    else
        remove_esp(index)
    end
end

local function _refresh()
    for idx in pairs(box) do -- hide all esp instances
        remove_esp(idx)
    end

    players_table = get_players() -- fetch new player list
end

local function refresh()
    refresh_que = true -- queue refresh before next render
end

-- player events
getgenv().player_added = players.ChildAdded:Connect(refresh)
getgenv().player_removed = players.ChildRemoved:Connect(refresh)

-- aimbot triggers
getgenv().input_began = uis.InputBegan:Connect(function(input, gpe)
    if gpe then return end
    if (input.UserInputType.Name == options.aimbot_key or input.KeyCode.Name == options.aimbot_key) then
		start_aim = true
    elseif input.KeyCode.Name == options.ui_toggle_key then
        options.ui_visible = not options.ui_visible
        if options.ui_visible then
            Window:Toggle(false)
        else
            Window:Toggle(true)
        end
        saveConfig()
    elseif input.KeyCode.Name == options.triggerbot_key then
        options.triggerbot = not options.triggerbot
    elseif input.KeyCode.Name == options.aimbot_toggle_key then
        options.aimbot = not options.aimbot
    end
end)

getgenv().input_ended = uis.InputEnded:Connect(function(input, gpe)
    if gpe then return end
    if (input.UserInputType.Name == options.aimbot_key or input.KeyCode.Name == options.aimbot_key) then
        start_aim = false
    end
end)

local last_tick = 0
local function stepped()
    if (tick() - last_tick) > (frame_delay / 1000) then
        last_tick = tick()
        saveConfig()

        -- refresh
        if refresh_que then -- refresh queed?
            _refresh()
            refresh_que = false
        end

        -- fov circle
        add_or_update_instance(aiming, "fov_circle_obj", {
            Visible = options.fov_circle,
            Thickness = 1,
            Radius = options.fov,
            Position = vector2_new(uis:GetMouseLocation().X, uis:GetMouseLocation().Y),
            Color = fov_color,
            instance = "Circle";
        })

        -- esp and closest char detection
        local closers_chars = {}
        for _, plr in pairs(players_table) do
            local index = plr:GetDebugId()
            if plr == local_player then continue end
            if (options.team_check and check_team(plr)) then continue end
            if not health_check(plr) then continue end
            if not self_health_check() then continue end

            local char = get_character(plr)
            if char == nil then remove_esp(index) continue end
            local rootPart =
            char:FindFirstChild("Torso")
                or char:FindFirstChild("UpperTorso")
                or char:FindFirstChild("LowerTorso")
                or char:FindFirstChild("HumanoidRootPart")
                or char:FindFirstChild("Head")
                or char:FindFirstChild("BasePart")
                or char:FindFirstChild("Part")

            if rootPart == nil then remove_esp(index) continue end
            if not rootPart:IsA("BasePart") then remove_esp(index) continue end

            local head = char:FindFirstChild("Head") or rootPart
            if not head then continue end
            if not head:IsA("BasePart") then continue end
            local visual_mag = (head.Position - mouse.Hit.Position).Magnitude
            if visual_mag > options.max_distance then remove_esp(index) continue end
            
            local mouse_pos = uis:GetMouseLocation()
            local vector, on_screen = to_screen(head.Position)
            if not on_screen then continue end
            local char_mag = (mouse_pos - vector2_new(vector.X, vector.Y)).Magnitude
            closers_chars[char_mag] = char

            if options.esp then
                if options.box then
                    create_box(plr, rootPart, index)
                else
                    remove_esp(index)
                end
            else
                remove_esp(index)
            end
        end

        -- aimbot
        for _, button in ipairs(uis:GetMouseButtonsPressed()) do
            if button.UserInputType.Name == options.aimbot_key then
                start_aim = true
            end
        end

        local mags = {}
        for idx in pairs(closers_chars) do
            mags[#mags + 1] = idx
        end

        table_sort(mags)

        local idx_sorted = {}
        for _, idx in pairs(mags) do
            idx_sorted[#idx_sorted + 1] = closers_chars[idx]
        end
        
        local function run_aimbot(plr_offset)
            if not options.aimbot then return end
            local char = idx_sorted[plr_offset]
            if char then
                local parts = {}
                
                if options.dynamic_fov then
                    options.fov = 250
                    local distance = (math.floor(local_player:DistanceFromCharacter(char.PrimaryPart.Position)) * 2)
                    options.fov = options.fov - distance
                    if options.fov <= 20 then
                        options.fov = 20
                    end
                end

                for _, obj in pairs(char:GetChildren()) do
                    if obj:IsA("BasePart") then
                        local part_screen, part_in_screen = to_screen(obj.Position)
                        if not local_player then continue end
                        
                        local head = get_character(local_player):FindFirstChild("Head")
                        if not head then continue end

                        if can_hit(head.Position, obj) and (part_in_screen) and (is_inside_fov(part_screen)) then
                            local set = {
                                part = obj,
                                player = players:GetPlayerFromCharacter(obj.Parent),
                                screen = part_screen,
                                visible = part_in_screen;
                            }
                            parts[obj.Name] = set
                            parts[0] = set
                        end
                    end
                end

                local chosen = nil
                local torso = parts["Torso"] or parts["UpperTorso"] or parts["LowerTorso"]
                if torso then
                    chosen = torso
                else
                    chosen = parts["Head"] or parts[0]
                end

                if chosen then
                    if start_aim then
                        local smoothness = options.smoothness
                        if chosen.visible then
                            local mouseLocation = uis:GetMouseLocation()
                            local endX = (chosen.screen.X - mouseLocation.X) / (smoothness * 2)
                            local endY = (chosen.screen.Y - mouseLocation.Y) / (smoothness * 2)
                            mousemoverel(endX, endY)
                        end
                    end

                    if options.triggerbot then
                        if (hitting_what(mouse.Hit):IsDescendantOf(chosen.part.Parent)) then
                            mouse1press()
                        else
                            mouse1release()
                        end
                    end
                end
            end
        end

        run_aimbot(1)
    end
end

local last_refresh = 0
run_service:BindToRenderStep(render_loop_stepped_name, 300, function()
    if (tick() - last_refresh) > refresh_delay then
        last_refresh = tick()

        if not cam or not cam.Parent or cam.Parent ~= workspace then
            cam = workspace.CurrentCamera
        end
        refresh()
    end
end) -- refresher

run_service:BindToRenderStep(update_loop_stepped_name, 199, stepped)