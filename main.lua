-- instancing
local drawing_new = Drawing.new
local instance_new = Instance.new

-- workspace
local vector2_new = Vector2.new
local cframe_new = CFrame.new
local raycast_params_new = RaycastParams.new
local raycast = workspace.Raycast

-- color
local color3_rgb = Color3.fromRGB
local color3_hsv = Color3.fromHSV

-- math
local math_random = math.random
local math_randomseed = math.randomseed

-- string
local string_char = string.char

-- table
local table_sort = table.sort

-- task
local task_wait = task.wait

-- namecall
local gdbd = game.GetDebugId
local get_children = game.GetChildren
local find_first_child_of_class = game.FindFirstChildOfClass
local find_first_child = game.FindFirstChild
local is_descendant_of = game.IsDescendantOf
local is_a = game.IsA

-- globals
local workspace = workspace
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
	for _ = 1, len do
		str = str .. string_char(math_random(97, 122))
	end
	return str
end

getgenv().render_loop_stepped_name = getgenv().render_loop_stepped_name or random_string(math_random(15, 35))
getgenv().update_loop_stepped_name = getgenv().render_loop_stepped_name or random_string(math_random(15, 35))

-- services
local players = game:GetService("Players")
local run_service = game:GetService("RunService")
local uis = game:GetService("UserInputService")

-- other
local local_player = players.LocalPlayer
local mouse = local_player:GetMouse()

local cam = find_first_child_of_class(workspace, "Camera")

local enum_rft_blk = Enum.RaycastFilterType.Blacklist
local glass = Enum.Material.Glass

local white = Color3.new(255, 255, 255)

local dummy_part = instance_new("Part", nil)

drawing_new("Square").Visible = false -- initialize drawing lib

-- dont touch lol
local custom_players = true
local refresh_que = false
local start_aim = false
local aim_head = false
local added_fov = 0

-- execute to apply
local options = {
    -- global settings
    frame_delay = 10, -- delay between rendering each frame (in miliseconds)
    refresh_delay = 0.25, -- delay between refreshing script (in seconds)
    max_dist = 9e9, -- 9e9 = very big
    team_check = false,
    wall_check = true,

    loop_all_humanoids = false, -- loop through workspace to find npc's to lock onto
    ignore_player_humanoids = true, -- will not lock onto/esp players (only if loop_all_humanoids is enabled)

    -- ui settings (sort of ui)
    fov_circle = true,
    aiming_at = true,
    ui_toggle_key = Enum.KeyCode["RightControl"],
    ui_visible = true,

    -- aimbot settings
    aimbot = true,
    smoothness = 9,
    fov = 50,

    -- aim type settings
    mouse_emulation = true, -- the default, will emulate user input (and is more natural)

    -- will not lock on to people with this *username*, do not use a displayname for this, use the username
    ignore_people = {
        ["name"] = true, -- example of how you would exclude someone
    },

    -- will try to prefire when aiming
    triggerbot = false,

    -- aimbot activation settings
    acts_as_toggle = false,

    -- https://developer.roblox.com/en-us/api-reference/enum/UserInputType
    mouse_key = Enum.UserInputType.MouseButton1,

    -- headshot odds
    headshot_chance = 10, -- odds for aiming on the head in percentage, 0 = no head (lol) and 100 = always head
    update_on_refresh_delay = false, -- less nauseating, will recalculate odds every refresh instead of every frame

    -- aiming prioritization options
    looking_at_you = false, -- whoever is most likely to hit you
    closest_to_center_screen = false,
    closest_to_you = true,

    -- taxing, usually useless, will iterate backwards through players list if the "best player to lock onto" cant be locked onto
    backwards_iteration = false,
}

-- ui stuff

local bracket = loadstring(game:HttpGet("https://raw.githubusercontent.com/AlexR32/Bracket/main/BracketV32.lua"))()
local window = bracket:Window({Name = "vakware but better", Enabled = true, Color = Color3.new(255, 0, 0), Size = UDim2.new(0,496,0,496), Position = UDim2.new(0.5,-248,0.5,-248)}) do
    local aimbotTab = window:Tab({Name = "Aimbot"}) do
        local aimbotSection = aimbotTab:Section({Name = "Aimbot Section", Side = "Left"}) do
            aimbotSection:Toggle({Name = "Aimbot", Value = options.aimbot, Callback = function(bool)
                options.aimbot = bool
            end})
            
            aimbotSection:Keybind({Name = "Aimbot Key", Key = options.mouse_key.Name, Mouse = true, Blacklist = {"W", "A", "S", "D", "RightControl"}, Callback = function(_, key)
                options.mouse_key = key
            end})

            aimbotSection:Toggle({Name = "Show FOV Circle", Value = options.fov_circle, Callback = function(bool)
                options.fov_circle = bool
            end})

            aimbotSection:Slider({Name = "FOV", Min = 0, Max = 1000, Value = options.fov, Precise = 2, Unit = "", Callback = function(number)
                options.fov = number
            end})

            aimbotSection:Colorpicker({Name = "FOV Color", Color = white, Callback = function(color: Color3, _)
                white = color
            end})

            aimbotSection:Slider({Name = "Smoothness", Min = 0, Max = 10, Value = options.smoothness, Precise = 1, Unit = "", Callback = function(number)
                options.smoothness = number
            end})
            
            aimbotSection:Toggle({Name = "Triggerbot", Value = options.triggerbot, Callback = function(bool)
                options.triggerbot = bool
            end})
        end

        local utils = aimbotTab:Section({"Utils", Side = "Right"}) do
            utils:Toggle({Name = "Team check", Value = options.team_check, Callback = function(bool)
                options.team_check = bool
            end})

            utils:Toggle({Name = "Wall Check", Value = options.wall_check, Callback = function(bool)
                options.wall_check = bool
            end})
        end
    end

    local uiTab = window:Tab({Name = "UI Settings"}) do
        local uiSection = uiTab:Section({Name = "General"}) do
            uiSection:Keybind({Name = "UI Toggle Key", Key = options.ui_toggle_key.Name, Mouse = false, Blacklist = {"W", "A", "S", "D"}, Callback = function(_, key)
                options.ui_toggle_key = key
            end})
        end
    end
end

-- how the script will find the players
local characters = {}
local player_names = {}

local function get_players()
	if options.loop_all_humanoids then
        if not player_names[local_player.Name] then -- ran for the first time
            -- get player names
            for _, val in pairs(get_children(players)) do
                player_names[val.Name] = true
            end

            getgenv().player_name_added = players.ChildAdded:Connect(function(added)
                player_names[added.Name] = true
            end)

            getgenv().player_name_removed = players.ChildRemoved:Connect(function(added)
                player_names[added.Name] = nil
            end)

            -- get players with events
            for _, val in pairs(workspace:GetDescendants()) do
                if is_a(val, "Humanoid") and val.Parent ~= local_player.Character and not (options.ignore_player_humanoids and player_names[val.Parent.Name]) then
                    characters[gdbd(val.Parent)] = val.Parent
                end
            end

            getgenv().descendant_hum_added = workspace.DescendantAdded:Connect(function(added)
                if is_a(added, "Humanoid") and added.Parent ~= local_player.Character and not (options.ignore_player_humanoids and player_names[added.Parent.Name]) then
                    characters[gdbd(added.Parent)] = added.Parent
                end
            end)

            getgenv().descendant_hum_removing = workspace.DescendantRemoving:Connect(function(removing)
                if is_a(removing, "Humanoid") then
                    characters[gdbd(removing.Parent)] = nil
                end
            end)
        end

        return characters
    end

    custom_players = false
    return get_children(players)
end

local aiming = {
    fov_circle_obj = nil,
    line = nil,
    circle = nil;
}

local players_table = {}

-- needed functions
local function to_screen(pos)
    local screen_pos, in_screen = find_first_child_of_class(workspace, "Camera"):WorldToViewportPoint(pos)

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

local function get_rainbow()
    return color3_hsv((tick() % options.rainbow_speed / options.rainbow_speed), 1, 1)
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

    for _, val in pairs(ignored_instances) do
        ignore_list[#ignore_list + 1] = val
    end

    raycast_params.FilterDescendantsInstances = ignore_list

    local raycast_result = raycast(workspace, origin_pos, (part.Position - origin_pos).Unit * options.max_dist, raycast_params)
    local result_part = ((raycast_result and raycast_result.Instance) or dummy_part)

    if result_part ~= dummy_part then
        if result_part.Transparency >= 0.3 then -- ignore low transparency
            ignored_instances[#ignored_instances + 1] = result_part
        end

        if result_part.Material == glass then -- ignore glass
            ignored_instances[#ignored_instances + 1] = result_part
        end
    end

    return is_descendant_of(result_part, part.Parent)
end

local function hitting_what(origin_cframe)
    if not options.wall_check then
        return dummy_part
    end

    local ignore_list = {cam, local_player.Character}

    for idx, val in pairs(ignored_instances) do
        ignore_list[#ignore_list + 1] = val
    end

    raycast_params.FilterDescendantsInstances = ignore_list

    local raycast_result = raycast(workspace, origin_cframe.p, origin_cframe.LookVector * options.max_dist, raycast_params)

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

local function is_inside_fov(point)
    return ((point.x - mouse.X) ^ 2 + (point.y - mouse.Y) ^ 2 <= aiming.fov_circle_obj.Radius ^ 2)
end

local function chanced() -- shanced 2 - 0 gf *tabs*
    return math_random(1, 100) <= options.headshot_chance
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
getgenv().input_began = uis.InputBegan:Connect(function(input)
    if input.UserInputType == options.mouse_key or input.KeyCode == options.mouse_key then
        start_aim = true
    end

    if input.KeyCode == options.ui_toggle_key then
        options.ui_visible = not options.ui_visible
        window:Toggle(options.ui_visible)
    end
end)

getgenv().input_ended = uis.InputEnded:Connect(function(input)
    if input.UserInputType == options.mouse_key or input.KeyCode == options.mouse_key then
        start_aim = false
    end
end)

local last_tick = 0;

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
            Radius = options.fov + added_fov,
            Position = vector2_new(mouse.X, mouse.Y + 36),
            Color = (options.rainbow and get_rainbow()) or white,
            instance = "Circle";
        })

        local closers_chars = {}

        for _, plr in pairs(players_table) do
            if plr == local_player then continue end
            if options.ignore_people[plr.Name] then continue end

            local plr_char = ((options.loop_all_humanoids or custom_players) and plr) or plr.Character

            local root_part =
                find_first_child(plr_char, "Torso")
                or find_first_child(plr_char, "UpperTorso")
                or find_first_child(plr_char, "LowerTorso")
                or find_first_child(plr_char, "HumanoidRootPart")
                or find_first_child(plr_char, "Head")
                or find_first_child_of_class(plr_char, "BasePart")
                or find_first_child_of_class(plr_char, "Part")

            local head = find_first_child(plr_char, "Head") or root_part
            if not head:IsA("BasePart") then continue end
            local mag = (head.Position - mouse.Hit.Position).Magnitude

            if options.aimbot then
                closers_chars[mag] = plr_char
            end
        end

        if not options.aimbot then return; end

        local mags = {}

        for idx in pairs(closers_chars) do
            mags[#mags + 1] = idx
        end

        table_sort(mags)

        local idx_sorted = {}

        for _, idx in pairs(mags) do
            idx_sorted[#idx_sorted + 1] = closers_chars[idx]
        end

        local run_aimbot = nil;
        run_aimbot = function(plr_offset)
            local char = idx_sorted[plr_offset]

            if char then
                local children = get_children(char)
                local parts = {}

                for _, obj in pairs(children) do
                    if is_a(obj, "BasePart") then
                        local part_screen, part_in_screen = to_screen(obj.Position)

                        if can_hit(local_player.Character["HumanoidRootPart"].Position, obj) and (part_in_screen) and (is_inside_fov(part_screen)) then
                            local set = {
                                part = obj,
                                screen = part_screen,
                                visible = part_in_screen;
                            }

                            parts[obj.Name] = set

                            parts[0] = set -- set last part
                        end
                    end
                end

                local chosen = nil;

                if not options.update_on_refresh_delay then
                    aim_head = chanced()
                end

                if parts["Head"] and aim_head then
                    chosen = parts["Head"]
                else
                    local torso = parts["Torso"] or parts["UpperTorso"] or parts["LowerTorso"]
                    if torso then
                        chosen = torso
                    else
                        chosen = parts["Head"] or parts[0] -- aim on head if odds are against the head, but the torso isnt visible, or on other visible part
                    end
                end

                if chosen and start_aim then
                    local smoothness = options.smoothness
					if chosen.visible then
                        mousemoverel((chosen.screen.X - mouse.X) / smoothness, (chosen.screen.Y - (mouse.Y + 36)) / smoothness)
                    end

					if options.triggerbot then
						if is_descendant_of(hitting_what(local_player.Character["HumanoidRootPart"].CFrame), chosen.part.Parent) then
							mouse1press()
						else
							mouse1release()
						end
					end

					return;
				else
					if options.triggerbot then
						mouse1release()
					end
					return;
				end -- aiming?

				return; -- part is on screen, and in fov, no need to find a new player, loop ends here
			end -- part exists?

			if options.triggerbot then
				mouse1release()
			end
        end

        run_aimbot(1);
    end
end

local last_refresh = 0;

run_service:BindToRenderStep(getgenv().render_loop_stepped_name, 300, function()
    if (tick() - last_refresh) > options.refresh_delay then
        last_refresh = tick()
        if options.update_on_refresh_delay then
            aim_head = chanced()
        end

        refresh()
    end
end) -- refresher

run_service:BindToRenderStep(getgenv().update_loop_stepped_name, 199, stepped)