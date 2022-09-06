-- options
getgenv().options = {
    aimbot = true,
    aimbot_toggle_key = "NONE",
    aimbot_key = "NONE",
    fov = 300,
    show_fov = true,
    fov_color = Color3.new(1, 1, 1),
    smoothness = 1,
    triggerbot = false,

    team_check = true,
    wall_check = true,

    ui_toggle_key = "NONE",
    ui_visible = true
}

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
            end}):Keybind({Key = options.aimbot_toggle_key, Mouse = false, Blacklist = {"W","A","S","D","Slash","Tab","Backspace","Escape","Space","Delete","Unknown","Backquote"}, Callback = function(bool, key)
                options.aimbot_toggle_key = key
                print(key)
            end})
            
            SettingSection:Keybind({Name = "Aimbot Key", Key = options.aimbot_key, Mouse = true, Blacklist = {"W","A","S","D","Slash","Tab","Backspace","Escape","Space","Delete","Unknown","Backquote"}, Callback = function(bool, key)
                options.aimbot_key = bool
            end})

            SettingSection:Slider({Name = "Smoothness", Min = 0, Max = 10, Value = options.smoothness, Precise = 1, Unit = "", Callback = function(number)
                options.smoothness = number
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

            Visual:Colorpicker({Name = "FOV Color", Color = options.fov_color, Callback = function(color,table)
                options.fov_color = color
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

    -- settings
    local Settings = Window:Tab({Name = "UI Settings"}) do
        Settings:Divider({Text = "Settings", Side = "Left"})
        local SettingSection = Settings:Section({Name = "Settings", Side = "Left"}) do
            SettingSection:Toggle({Name = "UI Visisble", Value = options.ui_visible, Callback = function(bool)
                options.ui_visible = bool
                print(key)
            end}):Keybind({Key = options.ui_toggle_key, Mouse = false, Blacklist = {"W","A","S","D","Slash","Tab","Backspace","Escape","Space","Delete","Unknown","Backquote"}, Callback = function(bool, key)
                options.ui_toggle_key = key
            end})
        end
    end
end

