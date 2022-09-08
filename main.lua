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

-- random
math_randomseed(tick())
function random_string(len)
	local str = ""
	for i = 1, len do
		str = str .. string_char(math_random(97, 122))
	end
	return str
end

getgenv().render_loop_stepped_name = renderloop_stepped_name or random_string(math_random(15, 35))
getgenv().update_loop_stepped_name = update_loop_stepped_name or random_string(math_random(15, 35))

-- services
local players = game:GetService("Players")
local run_service = game:GetService("RunService")
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
local aim_head = false

getgenv().options = {
    -- internal
    frame_delay = 10,
    refresh_delay = 0.25,

    -- misc
    max_distance = 10000,
    team_check = true,
    wall_check = true,

    -- visual
    fov_circle = true,
	fov = 200,
	fov_color = Color3.new(1, 1, 1),

    -- aimbot
    aimbot = true,
    aimbot_toggle_key = Enum.KeyCode["E"].Name,
    smoothness = 3,

    ignore_people = {
        ["name"] = true,
    },

    triggerbot = false,
    triggerbot_key = Enum.KeyCode["X"].Name,
    aimbot_key = Enum.UserInputType["MouseButton1"].Name,

    -- ui
    ui_toggle_key = Enum.KeyCode["RightControl"].Name,
    ui_toggle = true
}

local function loadConfig()
    if not isfolder("vakware but better") then makefolder("vakware but better") end
    if not isfolder("vakware but better\\Configs") then makefolder("vakware but better\\Configs") end
    if not isfile("vakware but better\\Configs\\Config.json") then
        writefile("vakware but better\\Configs\\Config.json", "{}")
        return
    end

    local decodeJSON = HttpService:JSONDecode(readfile("vakware but better\\Configs\\Config.json"))
    for i, _ in pairs(options) do
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

local function get_players()
    return players:GetPlayers()
end

local aiming = {
    fov_circle_obj = nil;
}

local players_table = {}

-- needed functions
local function to_screen(vec3)
    local screen_pos, in_screen = cam:WorldToViewportPoint(vec3)
    return vector2_new(screen_pos.X, screen_pos.Y), in_screen
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

        return inst;
    end

    for idx, val in pairs(props) do
        if idx ~= "instance" then
            inst[idx] = val
        end
    end

    return inst
end

local ignored_instances = {}

local raycast_params = raycast_params_new()
raycast_params.FilterType = enum_rft_blk
raycast_params.IgnoreWater = true

local function can_hit(origin_pos, part)
    if not options.wall_check then
        return true
    end

    local ignore_list = {cam, local_player.Character}

    for idx, val in pairs(ignored_instances) do
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
    if obj.Team == local_player.Team then
        return true
    end

    return false
end

local function hitting_what(origin_cframe: CFrame)
    if not options.wall_check then
        return dummy_part
    end

    local ignore_list = {cam, local_player.Character}

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
    local char = obj.Character or obj.CharacterAdded:Wait()
    local humanoid = char:FindFirstChildWhichIsA("Humanoid")

    if char and humanoid then
        if humanoid.Health > 0 then
            return true
        end
    end

    return false
end

local function self_health_check()
    local char = local_player.Character or local_player.CharacterAdded:Wait()
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

local function _refresh()
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
    if input.UserInputType.Name == options.aimbot_key then
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
    if input.UserInputType.Name == options.aimbot_key then
        start_aim = false
    end
end)

local last_tick = 0
local function stepped()
    if (tick() - last_tick) > (options.frame_delay / 1000) then
        last_tick = tick()

        if refresh_que then -- refresh queed?
            _refresh()
            refresh_que = false
        end

        add_or_update_instance(aiming, "fov_circle_obj", {
            Visible = options.fov_circle,
            Thickness = 1,
            Radius = options.fov,
            Position = Vector2.new(uis:GetMouseLocation().X, uis:GetMouseLocation().Y),
            Color = options.fov_color,
            instance = "Circle";
        })

        local closers_chars = {}

        for _, plr in pairs(players_table) do
            if plr == local_player then continue end
            if options.ignore_people[plr.Name] then continue end
            if options.team_check and check_team(plr) then continue end
            if not health_check(plr) then return end
            if not self_health_check() then return end

            local plr_char = plr.Character
            local root_part =
                plr_char:FindFirstChild("Torso")
                or plr_char:FindFirstChild("UpperTorso")
                or plr_char:FindFirstChild("LowerTorso")
                or plr_char:FindFirstChild("HumanoidRootPart")
                or plr_char:FindFirstChild("Head")
                or plr_char:FindFirstChild("BasePart")
                or plr_char:FindFirstChild("Part")

            local head = plr_char:FindFirstChild("Head") or root_part
            if not head:IsA("BasePart") then continue end
            local mag = (head.Position - mouse.Hit.Position).Magnitude

            if options.aimbot then
				closers_chars[mag] = plr_char
            end
        end

        if not options.aimbot then return end

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
            local char = idx_sorted[plr_offset]

            if char then
                local children = char:GetChildren()
                local parts = {}

                for _, obj in pairs(children) do
                    if obj:IsA("BasePart") then
                        local part_screen, part_in_screen = to_screen(obj.Position)

                        if can_hit(local_player.Character.Head.Position, obj) and (part_in_screen) and (is_inside_fov(part_screen)) then
                            local set = {
                                part = obj,
                                screen = part_screen,
                                visible = part_in_screen;
                            }

                            parts[obj.Name] = set
                            parts[0] = set
                        end
                    end
                end

                local chosen = nil

                if parts["Head"] and aim_head then
                    chosen = parts["Head"]
                else
                    local torso = parts["Torso"] or parts["UpperTorso"] or parts["LowerTorso"]
                    if torso then
                        chosen = torso
                    else
                        chosen = parts["Head"] or parts[0]
                    end
                end

                if chosen then
                    if start_aim then
                        local smoothness = options.smoothness
                        if chosen.visible then
                            local x = (chosen.screen.X - mouse.X) + math.random(10, 20) / (smoothness * 2)
                            local y = (chosen.screen.Y - (mouse.Y + 36)) + math.random(10, 20) / (smoothness * 2)
                            mousemoverel(x, y)
                        end
                    end
                    if options.triggerbot then
                        if hitting_what(local_player.Character.Head.CFrame):IsDescendantOf(chosen.part.Parent) then
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
    if (tick() - last_refresh) > options.refresh_delay then
        last_refresh = tick()

        if not cam or not cam.Parent or cam.Parent ~= workspace then
            cam = workspace.CurrentCamera
        end
        refresh()
    end
end) -- refresher

run_service:BindToRenderStep(update_loop_stepped_name, 199, stepped)