-- AOT:R GUI Auto Farm Script | Thunder Spear + Anti-ban + Toggle

local lib = loadstring(game:HttpGet("https://raw.githubusercontent.com/Belkworks/UI-Library/main/lib.lua"))()
local win = lib:Window("AOT:R AUTO FARM", Color3.fromRGB(44, 120, 224), Enum.KeyCode.RightControl)
local main = win:Tab("Tính năng")

getgenv().AutoFarm = false
getgenv().USE_SPEAR = false

main:Toggle("Auto chém gáy Titan", false, function(v)
    getgenv().AutoFarm = v
end)

main:Toggle("Dùng Thunder Spear", false, function(v)
    getgenv().USE_SPEAR = v
end)

-- Anti kick / log
pcall(function()
    local mt = getrawmetatable(game)
    setreadonly(mt, false)
    local old = mt.__namecall
    mt.__namecall = newcclosure(function(self, ...)
        if getnamecallmethod() == "Kick" then
            return warn("[Anti-Ban] Chặn kick.")
        end
        return old(self, ...)
    end)
end)

-- AutoFarm Logic
task.spawn(function()
    local plr = game.Players.LocalPlayer
    local rs = game:GetService("ReplicatedStorage")
    local ws = game:GetService("Workspace")
    local ts = game:GetService("TweenService")

    while task.wait(0.5) do
        if getgenv().AutoFarm then
            pcall(function()
                local char = plr.Character
                if not char then return end

                -- Equip weapon
                if getgenv().USE_SPEAR then
                    if not char:FindFirstChild("ThunderSpear") then
                        rs.Remotes.Gear:FireServer("EquipSpear")
                    end
                else
                    if not char:FindFirstChild("Blade") then
                        rs.Remotes.Gear:FireServer("EquipBlades")
                    end
                end

                -- Refill gas
                local stats = char:FindFirstChild("Stats")
                if stats and stats:FindFirstChild("Gas") and stats.Gas.Value < 15 then
                    rs.Remotes.Gear:FireServer("RefillGas")
                end

                -- Find nearest titan
                local closest, dist = nil, math.huge
                for _, titan in pairs(ws.Titans:GetChildren()) do
                    if titan:FindFirstChild("HumanoidRootPart") and titan:FindFirstChild("Nape") and titan:FindFirstChild("Humanoid") and titan.Humanoid.Health > 0 then
                        local d = (titan.HumanoidRootPart.Position - char.HumanoidRootPart.Position).Magnitude
                        if d < dist then
                            closest = titan
                            dist = d
                        end
                    end
                end

                if closest then
                    local nape = closest:FindFirstChild("Nape")
                    local pos = nape.Position - closest.HumanoidRootPart.CFrame.LookVector * 3 + Vector3.new(0,2,0)

                    ts:Create(char.HumanoidRootPart, TweenInfo.new(0.3), {CFrame = CFrame.new(pos)}):Play()
                    task.wait(0.3)

                    if getgenv().USE_SPEAR and char:FindFirstChild("ThunderSpear") then
                        rs.Remotes.Spear:FireServer({
                            ["Target"] = closest,
                            ["Position"] = nape.Position
                        })
                    else
                        rs.Remotes.Blade:FireServer("BladeSlash", {
                            ["Direction"] = Vector3.new(0,0,0),
                            ["CameraCF"] = ws.CurrentCamera.CFrame
                        })
                    end
                end
            end)
        end
    end
end)
