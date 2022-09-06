local Bracket = loadstring(game:HttpGet("https://raw.githubusercontent.com/AlexR32/Bracket/main/BracketV32.lua"))()

local Window = Bracket:Window({Name = "vakware but better", Enabled = true, Color = Color3.new(1,0.5,0.25), Size = UDim2.new(0,496,0,496), Position = UDim2.new(0.5,-248,0.5,-248)}) do
    local Aimbot = Window:Tav({Name = "Aimbot"}) do
        -- settings
        Aimbot:Divider({Text = "Settings", Side = "Left"})
        local SettingSection = Aimbot:Section({Name = "Settings", Side = "Left"}) do
            SettingSection:Toggle({Name = "Aimbot", Value = true, Callback = function(bool)
                print(bool)
            end}):Keybind({Key = "NONE", Mouse = false, Blacklist = {"W","A","S","D","Slash","Tab","Backspace","Escape","Space","Delete","Unknown","Backquote"}, Callback = function(bool, key)
                print(bool, key)
            end})
            
            SettingSection:Keybind({Name = "Aimbot Key", Key = "NONE", Mouse = true, Blacklist = {"W","A","S","D","Slash","Tab","Backspace","Escape","Space","Delete","Unknown","Backquote"}, Callback = function(bool, key)
                print(bool, key)
            end})

            SettingSection:Slider({Name = "Smoothness", Min = 0, Max = 10, Value = 0, Precise = 1, Unit = "", Callback = function(number)
                print(number)
            end})

            SettingSection:Toggle({Name = "Triggerbot", Value = false, Callback = function(bool)
                print(bool)
            end})
        end

        -- visual
        Aimbot:Divider({Text = "Visual", Side = "Left"})
        local Visual = Aimbot:Section({Name = "Visual", Side = "Left"}) do
            Visual:Slider({Name = "FOV", Min = 0, Max = 1000, Value = 0, Precise = 2, Unit = "", Callback = function(number)
                print(number)
            end})

            Visual:Toggle({Name = "Show FOV", Value = true, Callback = function(bool)
                print(bool)
            end})

            Visual:Colorpicker({Name = "FOV Color", Color = Color3.new(1,0,0), Callback = function(color,table)
                print(color, table)
            end})
        end

        -- misc
        Aimbot:Divider({Text = "Misc", Side = "Right"})
        local Misc = Aimbot:Section({Name = "Misc", Side = "Right"}) do
            Misc:Toggle({Name = "Team Check", Value = true, Callback = function(bool)
                print(bool)
            end})

            Misc:Toggle({Name = "Wall Check", Value = true, Callback = function(bool)
                print(bool)
            end})
        end
    end
end