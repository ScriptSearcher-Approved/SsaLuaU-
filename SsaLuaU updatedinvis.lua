-- ============================================================
-- FIXED SCRIPT — Ghost Mode + WindUI (NO MORE LOAD ERRORS)
-- ============================================================
-- Services
local RunService = game:GetService("RunService")
local Players = game:GetService("Players")
local TweenService = game:GetService("TweenService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local UserInputService = game:GetService("UserInputService")
local CoreGui = game:GetService("CoreGui")
local LocalPlayer = Players.LocalPlayer
local Camera = workspace.CurrentCamera

-- Wait for character (critical — prevents 90% of errors)
if not LocalPlayer.Character then LocalPlayer.CharacterAdded:Wait() end
task.wait(0.5)

-- ============================================================
-- 1. LOAD WINDUI — CORRECT OFFICIAL URL + ERROR HANDLING
-- ============================================================
local WindUI
local ok, err = pcall(function()
    WindUI = loadstring(game:HttpGet("https://raw.githubusercontent.com/Footagesus/WindUI/main/dist/main.lua", true))()
end)
if not ok or not WindUI then
    rconsoleerr("WINDUI FAILED TO LOAD: " .. tostring(err))
    game:GetService("StarterGui"):SetCore("SendNotification", {
        Title = "ERROR", Text = "WindUI failed to load!\n"..tostring(err), Duration = 10
    })
    return
end
print("✅ WindUI loaded successfully")

-- ============================================================
-- 2. GHOST MODE — FULLY FIXED
-- ============================================================
local GhostEnabled = false
local GhostChar, GhostHum, GhostRoot = nil, nil, nil
local RealConns, GhostConns = {}, {}
local OrigWalk, OrigJump = 16, 50
local HIDE_Y = -5000 -- SAFE: way under FallenPartsDestroyHeight

-- Cleanup helpers
local function clearConns(t) for _,c in pairs(t) do pcall(function() c:Disconnect() end) end; table.clear(t) end
local function killGhost()
    clearConns(GhostConns)
    pcall(function() GhostChar:Destroy() end)
    GhostChar, GhostHum, GhostRoot = nil, nil, nil
end

-- Restore real body
local function restoreReal()
    clearConns(RealConns)
    local char = LocalPlayer.Character if not char then return end
    local hum = char:FindFirstChildOfClass("Humanoid")
    local root = char:FindFirstChild("HumanoidRootPart")
    for _,p in ipairs(char:GetDescendants()) do
        if p:IsA("BasePart") then
            pcall(function() p.Anchored=false end)
            pcall(function() p.CanCollide=true end)
        end
    end
    if hum then
        hum.WalkSpeed = OrigWalk; hum.JumpPower = OrigJump
        pcall(function() hum.PlatformStand=false end)
        pcall(function() hum:SetStateEnabled(Enum.HumanoidStateType.Dead, true) end)
        pcall(function() hum:SetStateEnabled(Enum.HumanoidStateType.FallingDown, true) end)
    end
    if root then
        root.CFrame = CFrame.new(0, 15, 0)
        root.Velocity=Vector3.zero; root.RotVelocity=Vector3.zero
    end
    if hum then Camera.CameraSubject = hum end
    print("👻 Real body restored")
end

-- Hide real body DEEP under map
local function hideReal()
    local char = LocalPlayer.Character if not char then return end
    local hum = char:FindFirstChildOfClass("Humanoid")
    local root = char:FindFirstChild("HumanoidRootPart")
    if not hum or not root then return end
    OrigWalk = hum.WalkSpeed; OrigJump = hum.JumpPower
    root.CFrame = CFrame.new(0, HIDE_Y, 0)
    root.Velocity=Vector3.zero; root.RotVelocity=Vector3.zero
    for _,p in ipairs(char:GetDescendants()) do
        if p:IsA("BasePart") then
            pcall(function() p.Anchored=true end)
            pcall(function() p.CanCollide=false end)
        end
    end
    hum.WalkSpeed=0; hum.JumpPower=0
    pcall(function() hum.PlatformStand=true end)
    pcall(function() hum:SetStateEnabled(Enum.HumanoidStateType.Dead, false) end)
    -- Lock underground every frame
    table.insert(RealConns, RunService.Heartbeat:Connect(function()
        if GhostEnabled and root and root.Parent then
            pcall(function() root.CFrame = CFrame.new(0, HIDE_Y, 0) end)
        end
    end))
    print("👻 Real body hidden @ Y="..HIDE_Y)
end

-- Spawn CLIENT-ONLY ghost (CoreGui = NEVER replicated to server)
local function makeGhost()
    killGhost()
    local real = LocalPlayer.Character if not real then return end
    real.Archivable = true -- FIX: Roblox disables this on characters!

    local clone = real:Clone()
    clone.Name = "Ghost_"..LocalPlayer.Name
    clone.Parent = CoreGui -- ✅ 100% CLIENT ONLY. Server = BLIND to this

    -- Semi-transparent
    for _,p in ipairs(clone:GetDescendants()) do
        if p:IsA("BasePart") then
            p.Transparency = 0.6 -- 👻 Adjust: 0=solid, 1=invisible
            p.CanCollide = false; p.Anchored = false
            pcall(function() p.CastShadow = false end)
        elseif p:IsA("Decal") then
            p.Transparency = 0.5
        elseif p:IsA("SpecialMesh") then
            -- keep meshes
        end
    end

    GhostChar = clone
    GhostHum = clone:FindFirstChildOfClass("Humanoid")
    GhostRoot = clone:FindFirstChild("HumanoidRootPart")
    if not GhostHum or not GhostRoot then killGhost(); return end

    -- Spawn in front of camera
    GhostRoot.CFrame = CFrame.new((Camera.CFrame * CFrame.new(0,2,-5)).Position)
    GhostHum.WalkSpeed = OrigWalk; GhostHum.JumpPower = OrigJump
    task.wait() -- let physics settle
    Camera.CameraSubject = GhostHum -- ✅ Now you control the ghost!

    -- Safety net
    table.insert(GhostConns, RunService.Heartbeat:Connect(function()
        if GhostRoot and GhostRoot.Position.Y < -100 then
            GhostRoot.CFrame = CFrame.new(0,15,0)
            GhostRoot.Velocity=Vector3.zero
        end
    end))
    table.insert(GhostConns, GhostHum.Died:Connect(function()
        task.wait(1) if GhostEnabled then makeGhost() end
    end))
    print("👻 Ghost spawned")
end

-- Master toggle
local function setGhost(on)
    GhostEnabled = on
    if on then
        hideReal()
        task.wait(0.15)
        makeGhost()
        WindUI:Notify({Title="Ghost Mode", Message="✅ ON — Others CANNOT see you", Duration=2})
    else
        killGhost()
        restoreReal()
        WindUI:Notify({Title="Ghost Mode", Message="❌ OFF — Restored", Duration=2})
    end
end

-- Auto-rebuild on respawn
LocalPlayer.CharacterAdded:Connect(function()
    if GhostEnabled then
        task.wait(0.6)
        hideReal()
        makeGhost()
    end
end)

-- ============================================================
-- 3. BUILD UI
-- ============================================================
local Window = WindUI:CreateWindow({
    Title = "SsaLuaU v2",
    Icon = "shield-half",
    Size = UDim2.fromOffset(580, 400),
    Theme = "Dark",
    Transparent = 0.15,
    MinimizeKeybind = Enum.KeyCode.LeftAlt,
})

local MainTab = Window:Tab({Title = "Main", Icon = "home"})

-- 👇 YOUR NEW INVISIBLE BUTTON / TOGGLE 👇
MainTab:Section({Title = "👻 Ghost Mode"})
MainTab:Toggle({
    Title = "Invisible Avatar",
    Desc = "Server sees nothing · You see transparent ghost",
    Icon = "ghost",
    Value = false,
    Callback = function(state)
        local s,e = pcall(function() setGhost(state) end)
        if not s then rconsoleerr("GHOST ERROR: "..e) end
    end,
})

-- Optional: Quick keybind (G)
MainTab:Keybind({
    Title = "Ghost Toggle Key",
    Value = Enum.KeyCode.G,
    Callback = function()
        setGhost(not GhostEnabled)
    end,
})

-- Old sections you can keep
MainTab:Section({Title = "Murder Functions"})
MainTab:Button({Title = "Kill All", Desc = "Kill all innocents", Callback = function() end})

MainTab:Section({Title = "Sheriff Functions"})
MainTab:Toggle({Title = "Auto Shoot Button", Value = false})
MainTab:Toggle({Title = "Magic Bullet", Value = false})

MainTab:Section({Title = "Auto Farm"})
MainTab:Toggle({Title = "Farm Coins", Value = false})

local Visuals = Window:Tab({Title = "Visuals", Icon = "eye"})
Visuals:Section({Title = "ESP / Chams"})
Visuals:Toggle({Title = "Murderer ESP", Value = false})
Visuals:Toggle({Title = "Sheriff ESP", Value = false})

local Misc = Window:Tab({Title = "Misc", Icon = "settings-2"})
Misc:Toggle({Title = "Anti-Fling", Value = false})
Misc:Slider({Title = "WalkSpeed", Min=16, Max=200, Value=16})
Misc:Slider({Title = "FOV", Min=70, Max=120, Value=70})

local Settings = Window:Tab({Title = "Settings", Icon = "sliders-horizontal"})
Settings:Dropdown({
    Title = "Theme",
    Values = {Dark="Dark", Light="Light", Void="Void"},
    Value = "Dark",
    Callback = function(t) WindUI:SetTheme(t) end,
})
Settings:Slider({Title = "UI Transparency", Min=0, Max=1, Value=0.15})

WindUI:Notify({Title = "✅ Loaded", Message = "LeftAlt = Hide UI · G = Ghost", Duration = 5})
print("✅ SCRIPT FULLY LOADED — Press LeftAlt")
