-- ═══════════════════════════════════════════════════
--   ScriptHub  |  Custom UI  |  No Libraries
-- ═══════════════════════════════════════════════════

local Players          = game:GetService("Players")
local TweenService     = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")
local RunService       = game:GetService("RunService")
local TeleportService  = game:GetService("TeleportService")
local HttpService      = game:GetService("HttpService")

local LP   = Players.LocalPlayer
local PGui = LP:WaitForChild("PlayerGui")

-- ══════════════════════════════════════════════════
--  GETGENV STATE  (persists across re-runs)
-- ══════════════════════════════════════════════════
getgenv().WalkSpeed         = getgenv().WalkSpeed         or 14
getgenv().JumpPower         = getgenv().JumpPower         or 50
getgenv().FlyEnabled        = getgenv().FlyEnabled        or false
getgenv().NoclipEnabled     = getgenv().NoclipEnabled     or false
getgenv().PlayerESP         = getgenv().PlayerESP         or false
getgenv().AntiAFK           = getgenv().AntiAFK           or true
getgenv().AlwaysCrit        = getgenv().AlwaysCrit        or false
getgenv().CritSize          = getgenv().CritSize          or 6
getgenv().CritTransparency  = getgenv().CritTransparency  or 0.8
getgenv().TeamCheck         = getgenv().TeamCheck         or false
getgenv().HitboxEnabled     = getgenv().HitboxEnabled     or false
getgenv().HitboxSize        = getgenv().HitboxSize        or 2
getgenv().HitboxTransp      = getgenv().HitboxTransp      or 0.4
getgenv().AntiWeave         = getgenv().AntiWeave         or false
getgenv().PunchSpeed        = getgenv().PunchSpeed        or 1.7
getgenv().FastmentEnabled   = getgenv().FastmentEnabled   or false

-- ══════════════════════════════════════════════════
--  KEYBIND MANAGER
-- ══════════════════════════════════════════════════
local KB = {}   -- id → { key=KeyCode|nil, cb=fn }

local function kbBind(id, key, cb)
    KB[id] = { key = key, cb = cb }
end
local function kbClear(id)
    if KB[id] then KB[id].key = nil end
end
local function kbSet(id, key)
    if KB[id] then KB[id].key = key end
end

UserInputService.InputBegan:Connect(function(i, gp)
    if gp then return end
    for _, v in pairs(KB) do
        if v.key and i.KeyCode == v.key then pcall(v.cb) end
    end
end)

-- ══════════════════════════════════════════════════
--  CONFIG SYSTEM
-- ══════════════════════════════════════════════════
local CFGS = {}   -- name → encoded string (in-memory + file)
local CFG_DIR = "ScriptHub"

local function cfgEncode()
    local t = {
        walkSpeed        = getgenv().WalkSpeed,
        jumpPower        = getgenv().JumpPower,
        fly              = getgenv().FlyEnabled,
        noclip           = getgenv().NoclipEnabled,
        playerEsp        = getgenv().PlayerESP,
        antiAfk          = getgenv().AntiAFK,
        alwaysCrit       = getgenv().AlwaysCrit,
        critSize         = getgenv().CritSize,
        critTransp       = getgenv().CritTransparency,
        teamCheck        = getgenv().TeamCheck,
        hitbox           = getgenv().HitboxEnabled,
        hitboxSize       = getgenv().HitboxSize,
        hitboxTransp     = getgenv().HitboxTransp,
        antiWeave        = getgenv().AntiWeave,
        punchSpeed       = getgenv().PunchSpeed,
        fastment         = getgenv().FastmentEnabled,
    }
    local ok, s = pcall(function() return HttpService:JSONEncode(t) end)
    return ok and s or ""
end

local function cfgApply(t)
    if not t then return end
    getgenv().WalkSpeed        = t.walkSpeed   or 14
    getgenv().JumpPower        = t.jumpPower   or 50
    getgenv().FlyEnabled       = t.fly         or false
    getgenv().NoclipEnabled    = t.noclip      or false
    getgenv().PlayerESP        = t.playerEsp   or false
    getgenv().AntiAFK          = t.antiAfk     ~= false
    getgenv().AlwaysCrit       = t.alwaysCrit  or false
    getgenv().CritSize         = t.critSize    or 6
    getgenv().CritTransparency = t.critTransp  or 0.8
    getgenv().TeamCheck        = t.teamCheck   or false
    getgenv().HitboxEnabled    = t.hitbox      or false
    getgenv().HitboxSize       = t.hitboxSize  or 2
    getgenv().HitboxTransp     = t.hitboxTransp or 0.4
    getgenv().AntiWeave        = t.antiWeave   or false
    getgenv().PunchSpeed       = t.punchSpeed  or 1.7
    getgenv().FastmentEnabled  = t.fastment    or false
end

local function cfgSave(name)
    if not name or name == "" then return false end
    local s = cfgEncode()
    CFGS[name] = s
    pcall(function()
        if not isfolder(CFG_DIR) then makefolder(CFG_DIR) end
        writefile(CFG_DIR.."/"..name..".json", s)
    end)
    return true
end

local function cfgLoad(name)
    if not name or name == "" then return false end
    local s = CFGS[name]
    if not s then
        pcall(function()
            if isfile(CFG_DIR.."/"..name..".json") then
                s = readfile(CFG_DIR.."/"..name..".json")
                CFGS[name] = s
            end
        end)
    end
    if not s then return false end
    local ok, t = pcall(function() return HttpService:JSONDecode(s) end)
    if ok then cfgApply(t) end
    return ok
end

-- pre-load saved configs
pcall(function()
    if isfolder(CFG_DIR) and listfiles then
        for _, path in ipairs(listfiles(CFG_DIR)) do
            local name = path:match("([^/\\]+)%.json$")
            if name then
                CFGS[name] = readfile(path)
            end
        end
    end
end)

-- ══════════════════════════════════════════════════
--  MOVEMENT LOGIC
-- ══════════════════════════════════════════════════
local function applyWalkSpeed()
    pcall(function()
        local c = LP.Character
        if c then
            local h = c:FindFirstChild("Humanoid")
            if h then h.WalkSpeed = getgenv().WalkSpeed end
        end
    end)
end
LP.CharacterAdded:Connect(function(c)
    local h = c:WaitForChild("Humanoid", 5)
    if h then
        h.WalkSpeed = getgenv().WalkSpeed
        h.JumpPower = getgenv().JumpPower
    end
end)
spawn(function()
    while true do wait(0.08); pcall(function()
        local c = LP.Character
        local h = c and c:FindFirstChild("Humanoid")
        if h then
            if h.WalkSpeed ~= getgenv().WalkSpeed then h.WalkSpeed = getgenv().WalkSpeed end
            if h.JumpPower ~= getgenv().JumpPower  then h.JumpPower = getgenv().JumpPower  end
        end
    end) end
end)

-- Fly  (BodyVelocity — direct, no spring lag)
local flyConn, flyBV, flyBG
local FLY_SPD = 46   -- base speed in studs/s
local function enableFly()
    local c = LP.Character; if not c then return end
    local hrp = c:FindFirstChild("HumanoidRootPart")
    local hum = c:FindFirstChildOfClass("Humanoid")
    if not hrp or not hum then return end
    hum.PlatformStand = true
    -- velocity driver
    flyBV = Instance.new("BodyVelocity")
    flyBV.Velocity  = Vector3.new(0,0,0)
    flyBV.MaxForce  = Vector3.new(1e5,1e5,1e5)
    flyBV.P         = 1e4
    flyBV.Parent    = hrp
    -- gyro to keep character upright / facing cam
    flyBG = Instance.new("BodyGyro")
    flyBG.MaxTorque = Vector3.new(1e5,1e5,1e5)
    flyBG.P         = 1e4
    flyBG.D         = 500
    flyBG.CFrame    = hrp.CFrame
    flyBG.Parent    = hrp
    flyConn = RunService.Heartbeat:Connect(function()
        if not getgenv().FlyEnabled then return end
        local cam = workspace.CurrentCamera
        -- Flatten LookVector to horizontal plane so W/S stay level
        local look  = cam.CFrame.LookVector
        local flat  = Vector3.new(look.X, 0, look.Z)
        if flat.Magnitude > 0.01 then flat = flat.Unit else flat = Vector3.new(0,0,-1) end
        local right = cam.CFrame.RightVector
        local dir   = Vector3.new()
        if UserInputService:IsKeyDown(Enum.KeyCode.W)         then dir = dir + flat  end
        if UserInputService:IsKeyDown(Enum.KeyCode.S)         then dir = dir - flat  end
        if UserInputService:IsKeyDown(Enum.KeyCode.A)         then dir = dir - right end
        if UserInputService:IsKeyDown(Enum.KeyCode.D)         then dir = dir + right end
        if UserInputService:IsKeyDown(Enum.KeyCode.Space)     then dir = dir + Vector3.new(0,1,0) end
        if UserInputService:IsKeyDown(Enum.KeyCode.LeftShift) then dir = dir - Vector3.new(0,1,0) end
        if dir.Magnitude > 0 then dir = dir.Unit end
        flyBV.Velocity = dir * FLY_SPD
        flyBG.CFrame   = CFrame.new(hrp.Position, hrp.Position + flat)
    end)
end
local function disableFly()
    if flyConn then flyConn:Disconnect(); flyConn = nil end
    if flyBV   then flyBV:Destroy();  flyBV = nil end
    if flyBG   then flyBG:Destroy();  flyBG = nil end
    pcall(function()
        local c = LP.Character; local h = c and c:FindFirstChildOfClass("Humanoid")
        if h then h.PlatformStand = false end
    end)
end

-- Noclip
RunService.Stepped:Connect(function()
    if not getgenv().NoclipEnabled then return end
    pcall(function()
        local c = LP.Character; if not c then return end
        for _, p in pairs(c:GetDescendants()) do
            if p:IsA("BasePart") then p.CanCollide = false end
        end
    end)
end)

-- Anti-AFK  (VirtualUser Idled + periodic heartbeat loop)
local VUS; pcall(function() VUS = game:GetService("VirtualUser") end)
local function afkPing()
    if not getgenv().AntiAFK then return end
    pcall(function()
        if VUS then
            VUS:Button2Down(Vector2.new(), workspace.CurrentCamera.CFrame)
            wait(0.1)
            VUS:Button2Up(Vector2.new(), workspace.CurrentCamera.CFrame)
        end
    end)
end
if VUS then
    LP.Idled:Connect(afkPing)
end
-- Periodic fallback every 5 min so the idle timer never reaches the kick threshold
spawn(function()
    while true do wait(300) afkPing() end
end)

-- ══════════════════════════════════════════════════
--  ALWAYS-CRIT LOGIC
-- ══════════════════════════════════════════════════
RunService.Heartbeat:Connect(function()
    if not getgenv().AlwaysCrit then return end
    for _, plr in ipairs(Players:GetPlayers()) do
        if plr ~= LP then
            local enemy = not getgenv().TeamCheck or plr.Team ~= LP.Team
            if enemy then
                local live = workspace:FindFirstChild("Live")
                local char = (live and live:FindFirstChild(plr.Name)) or plr.Character
                if char then
                    local torso = char:FindFirstChild("UpperTorso")
                    if torso and torso:IsA("BasePart") then
                        local sz = getgenv().CritSize
                        pcall(function()
                            torso.Size        = Vector3.new(sz, sz * 0.5, sz)
                            torso.Transparency = getgenv().CritTransparency
                            torso.CanCollide  = false
                            torso.Massless    = true
                            torso.Anchored    = false
                        end)
                    end
                end
            end
        end
    end
end)

-- ══════════════════════════════════════════════════
--  HITBOX SYSTEM  (adapted from Punch script)
-- ══════════════════════════════════════════════════
local hbWL    = {}   -- whitelisted players
local hbOrig  = {}   -- original HRP props
local hbConns = {}   -- connection cache

local function hbDisconn(k)
    local c = hbConns[k]; if c then pcall(function() c:Disconnect() end) end
    hbConns[k] = nil
end

local function getLiveEntry(plr)
    local live = workspace:FindFirstChild("Live")
    return live and live:FindFirstChild(plr.Name)
end

local function getKnocked(entry)
    if not entry then return nil end
    local k = entry:FindFirstChild("Knocked")
    return (k and k:IsA("BoolValue")) and k or nil
end

local function applyHitbox()
    if not getgenv().HitboxEnabled then return end
    local sz = getgenv().HitboxSize
    local tr = getgenv().HitboxTransp
    for _, plr in pairs(Players:GetPlayers()) do
        if plr ~= LP and plr.Character then
            local root = plr.Character:FindFirstChild("HumanoidRootPart")
            if hbWL[plr] then
                if root and root:IsA("BasePart") then
                    if not hbOrig[plr] then
                        hbOrig[plr] = { Size=root.Size, Transparency=root.Transparency,
                            CanCollide=root.CanCollide, CanTouch=root.CanTouch, CanQuery=root.CanQuery }
                    end
                    root.Size = Vector3.new(sz,sz,sz)
                    root.Transparency = tr
                    root.CanCollide = false; root.CanTouch = true; root.CanQuery = true
                end
                for _, p in pairs(plr.Character:GetChildren()) do
                    if p:IsA("BasePart") then
                        p.CanCollide = false; p.CanTouch = true; p.CanQuery = true
                    end
                end
            else
                local og = hbOrig[plr]
                if og and root and root:IsA("BasePart") then
                    root.Size        = og.Size;        root.Transparency = og.Transparency
                    root.CanCollide  = og.CanCollide;  root.CanTouch     = og.CanTouch
                    root.CanQuery    = og.CanQuery
                end
            end
        end
    end
end

local function hbAddPlr(plr)   if plr then hbWL[plr]=true;  pcall(applyHitbox) end end
local function hbRemPlr(plr)
    if not plr then return end
    hbWL[plr] = nil
    local og = hbOrig[plr]
    if og and plr.Character then
        local r = plr.Character:FindFirstChild("HumanoidRootPart")
        if r then
            r.Size=og.Size; r.Transparency=og.Transparency
            r.CanCollide=og.CanCollide; r.CanTouch=og.CanTouch; r.CanQuery=og.CanQuery
        end
    end
    pcall(applyHitbox)
end

local function evalHbPlr(plr)
    if not plr then return end
    local c   = plr.Character
    local h   = c and c:FindFirstChildOfClass("Humanoid")
    local ok  = h and h.Health > 0
    local kn  = getKnocked(getLiveEntry(plr))
    local nkn = not kn or kn.Value == false
    if ok and nkn then hbAddPlr(plr) else hbRemPlr(plr) end
end

local function attachKnocked(plr, entry)
    if not plr or not entry then return end
    local kk = plr.UserId.."k"; local ck = plr.UserId.."c"
    hbDisconn(kk); hbDisconn(ck)
    local kn = getKnocked(entry)
    if kn then
        hbConns[kk] = kn.Changed:Connect(function() evalHbPlr(plr) end)
        evalHbPlr(plr)
    else
        hbConns[ck] = entry.ChildAdded:Connect(function(ch)
            if ch.Name == "Knocked" and ch:IsA("BoolValue") then
                hbDisconn(ck); hbDisconn(kk)
                hbConns[kk] = ch.Changed:Connect(function() evalHbPlr(plr) end)
                evalHbPlr(plr)
            end
        end)
    end
end

local function monitorHbPlr(plr)
    if not plr or plr == LP then return end
    hbAddPlr(plr)
    local charK = plr.UserId.."ch"
    hbDisconn(charK)
    hbConns[charK] = plr.CharacterAdded:Connect(function(c)
        local humK=plr.UserId.."h"; local dieK=plr.UserId.."d"
        hbDisconn(humK); hbDisconn(dieK)
        local hum = c:FindFirstChildOfClass("Humanoid") or c:WaitForChild("Humanoid",5)
        if hum then
            hbConns[humK] = hum.HealthChanged:Connect(function() evalHbPlr(plr) end)
            hbConns[dieK] = hum.Died:Connect(function() evalHbPlr(plr) end)
        end
        local e = getLiveEntry(plr)
        if e then attachKnocked(plr, e) else evalHbPlr(plr) end
        pcall(applyHitbox)
    end)
    if plr.Character then
        spawn(function() wait(0.1)
            if not plr.Character then return end
            local h = plr.Character:FindFirstChildOfClass("Humanoid")
            if h then
                local humK=plr.UserId.."h"; local dieK=plr.UserId.."d"
                hbDisconn(humK); hbDisconn(dieK)
                hbConns[humK] = h.HealthChanged:Connect(function() evalHbPlr(plr) end)
                hbConns[dieK] = h.Died:Connect(function() evalHbPlr(plr) end)
            end
            local e = getLiveEntry(plr); if e then attachKnocked(plr, e) else evalHbPlr(plr) end
            pcall(applyHitbox)
        end)
    end
end

local liveRoot = workspace:FindFirstChild("Live"); local liveRootConn
local function attachLiveRoot(root)
    if not root then return end
    for _, e in pairs(root:GetChildren()) do
        local p = Players:FindFirstChild(e.Name); if p then attachKnocked(p, e) end
    end
    if liveRootConn then liveRootConn:Disconnect() end
    liveRootConn = root.ChildAdded:Connect(function(e)
        local p = Players:FindFirstChild(e.Name); if p then attachKnocked(p, e) end
    end)
end
if liveRoot then attachLiveRoot(liveRoot)
else workspace.ChildAdded:Connect(function(c)
    if c.Name=="Live" then liveRoot=c; attachLiveRoot(c) end
end) end
workspace.ChildRemoved:Connect(function(c)
    if c==liveRoot then
        if liveRootConn then liveRootConn:Disconnect(); liveRootConn=nil end; liveRoot=nil end
end)
Players.PlayerAdded:Connect(function(p) monitorHbPlr(p) end)
Players.PlayerRemoving:Connect(function(p)
    hbWL[p]=nil; hbOrig[p]=nil
    for k,_ in pairs(hbConns) do if tostring(k):find(tostring(p.UserId)) then hbDisconn(k) end end
end)
for _,p in pairs(Players:GetPlayers()) do monitorHbPlr(p) end
spawn(function() while true do wait(5); pcall(applyHitbox) end end)

-- ══════════════════════════════════════════════════
--  PUNCH SPEED SYSTEM
-- ══════════════════════════════════════════════════
local punchIDs = {
    -- Philly
    ["rbxassetid://18312333191"]=true,["rbxassetid://18312335714"]=true,
    ["rbxassetid://18312338197"]=true,["rbxassetid://18312340119"]=true,
    ["rbxassetid://18312344029"]=true,["rbxassetid://18312346524"]=true,
    ["rbxassetid://18312348771"]=true,["rbxassetid://18312351760"]=true,
    -- Slap Box
    ["rbxassetid://17796387423"]=true,["rbxassetid://17796396059"]=true,
    ["rbxassetid://17796400708"]=true,["rbxassetid://17796403834"]=true,
}
local pConns = {}
local function pDisconn(k) local c=pConns[k]; if c then pcall(function()c:Disconnect()end) end; pConns[k]=nil end
local function isPunch(t) return t and t.Animation and punchIDs[tostring(t.Animation.AnimationId):lower()] end
local function findLocalLive()
    -- Check workspace.Live folder first (game-specific folder)
    local live = workspace:FindFirstChild("Live")
    local m = live and live:FindFirstChild(LP.Name)
    -- Fallback: direct character in workspace
    if not m or not m.Parent then m = LP.Character end
    if not m or not m.Parent then return nil end
    local h = m:FindFirstChildOfClass("Humanoid"); if not h then return nil end
    return m, h, h:FindFirstChildOfClass("Animator")
end
local function applyPunchSpeed(mul)
    if mul then getgenv().PunchSpeed=mul end
    local m,h,anim=findLocalLive()
    if not m then
        if not pConns["LW"] then pConns["LW"]=workspace.ChildAdded:Connect(function(c)
            if c.Name=="Live" then spawn(function() applyPunchSpeed() end) end end) end
        local live=workspace:FindFirstChild("Live")
        if live and not pConns["MW"] then pConns["MW"]=live.ChildAdded:Connect(function(c)
            if c.Name==LP.Name then spawn(function() applyPunchSpeed() end) end end) end
        return
    end
    pDisconn("LW"); pDisconn("MW")
    if anim then
        for _,t in ipairs(anim:GetPlayingAnimationTracks()) do
            if isPunch(t) then pcall(function()t:AdjustSpeed(getgenv().PunchSpeed)end) end
        end
        pDisconn(anim)
        pConns[anim]=anim.ChildAdded:Connect(function(c)
            if c:IsA("AnimationTrack") and isPunch(c) then
                pcall(function()c:AdjustSpeed(getgenv().PunchSpeed)end) end end)
    end
    if h then pDisconn(h); pConns[h]=h.AnimationPlayed:Connect(function(t)
        if isPunch(t) then pcall(function()t:AdjustSpeed(getgenv().PunchSpeed)end) end end) end
    pDisconn("MR")
    pConns["MR"]=m.AncestryChanged:Connect(function(_,p)
        if not p then pDisconn(anim); pDisconn(h); spawn(function() applyPunchSpeed() end) end end)
end
spawn(function() wait(0.1); applyPunchSpeed() end)

-- ══════════════════════════════════════════════════
--  ANTI-WEAVE SYSTEM
-- ══════════════════════════════════════════════════
local wConns = {}
local function wDisconn(k) local c=wConns[k]; if c then pcall(function()c:Disconnect()end) end; wConns[k]=nil end
local function connectWeave()
    wDisconn("LW"); wDisconn("MW"); wDisconn("WC")
    local live=workspace:FindFirstChild("Live")
    if not live then
        wConns["LW"]=workspace.ChildAdded:Connect(function(c)
            if c.Name=="Live" then spawn(function() wait(0.05); connectWeave() end) end end); return end
    wConns["MW"]=live.ChildAdded:Connect(function(c)
        if c.Name==LP.Name then spawn(function() wait(0.05); connectWeave() end) end end)
    local pl=live:FindFirstChild(LP.Name); if not pl then return end
    local st=pl:FindFirstChild("WeaveStun")
    if getgenv().AntiWeave and st then pcall(function()st:Destroy()end) end
    wConns["WC"]=pl.ChildAdded:Connect(function(c)
        if getgenv().AntiWeave and c.Name=="WeaveStun" then pcall(function()c:Destroy()end) end end)
    pl.AncestryChanged:Connect(function(_,p) if not p then spawn(function() wait(0.05); connectWeave() end) end end)
end
spawn(function() wait(0.1); connectWeave() end)
spawn(function() while true do wait(0.15)
    if getgenv().AntiWeave then pcall(function()
        local live=workspace:FindFirstChild("Live")
        local pl=live and live:FindFirstChild(LP.Name)
        local st=pl and pl:FindFirstChild("WeaveStun")
        if st then st:Destroy() end end) end end end)

-- ══════════════════════════════════════════════════
--  FASTMENT (Speed Boost on LMB with Tool)
-- ══════════════════════════════════════════════════
local BOOST_SPD = 50
local BOOST_DUR = 0.2
local fastConn
local function enableFastment()
    if fastConn then return end
    fastConn = UserInputService.InputBegan:Connect(function(inp, gp)
        if gp or not getgenv().FastmentEnabled then return end
        if inp.UserInputType == Enum.UserInputType.MouseButton1 then
            pcall(function()
                local c = LP.Character
                if c and c:FindFirstChildOfClass("Tool") then
                    local h = c:FindFirstChildOfClass("Humanoid")
                    if h then
                        h.WalkSpeed = BOOST_SPD
                        wait(BOOST_DUR)
                        if getgenv().FastmentEnabled and h then
                            h.WalkSpeed = getgenv().WalkSpeed
                        end
                    end
                end
            end)
        end
    end)
end
local function disableFastment()
    if fastConn then fastConn:Disconnect(); fastConn = nil end
    pcall(function()
        local c = LP.Character; local h = c and c:FindFirstChildOfClass("Humanoid")
        if h then h.WalkSpeed = getgenv().WalkSpeed end
    end)
end

-- ══════════════════════════════════════════════════
--  SERVER FUNCTIONS
-- ══════════════════════════════════════════════════
local function rejoin()
    pcall(function() TeleportService:Teleport(game.PlaceId, LP) end)
end

local function serverHop()
    -- Try fetching a different server's jobId and jumping to it
    pcall(function()
        local ok, res = pcall(function()
            return HttpService:GetAsync(
                "https://games.roblox.com/v1/games/"..game.PlaceId..
                "/servers/Public?sortOrder=Asc&limit=100", true)
        end)
        if ok and res then
            local ok2, data = pcall(function() return HttpService:JSONDecode(res) end)
            if ok2 and data and data.data then
                local cur = game.JobId
                for _, srv in ipairs(data.data) do
                    if srv.id and srv.id ~= cur and srv.playing and srv.playing < srv.maxPlayers then
                        TeleportService:TeleportToPlaceInstance(game.PlaceId, srv.id, LP)
                        return
                    end
                end
            end
        end
        -- Fallback: plain teleport to same place (new server)
        TeleportService:Teleport(game.PlaceId, LP)
    end)
end

local function copyJoinLink()
    pcall(function()
        setclipboard("https://www.roblox.com/games/"..tostring(game.PlaceId))
    end)
end

local placeIdTarget = game.PlaceId
local function teleportToPlace()
    pcall(function() TeleportService:Teleport(placeIdTarget, LP) end)
end

-- ══════════════════════════════════════════════════
--  PANIC  — reset everything and destroy GUI
-- ══════════════════════════════════════════════════
local function panic(gui)
    getgenv().AlwaysCrit     = false
    getgenv().HitboxEnabled  = false
    getgenv().AntiWeave      = false
    getgenv().FastmentEnabled = false
    getgenv().FlyEnabled     = false
    getgenv().NoclipEnabled  = false
    getgenv().PlayerESP      = false
    disableFastment(); disableFly()
    getgenv().WalkSpeed = 14; getgenv().JumpPower = 50; applyWalkSpeed()
    getgenv().PlayerESP = false   -- periodic loop clears highlights within 0.5 s
    for p,_ in pairs(hbWL) do hbRemPlr(p) end
    if gui then gui:Destroy() end
end

-- ══════════════════════════════════════════════════
--  PLAYER ESP
-- ══════════════════════════════════════════════════
local espHL = {}   -- [Player] = Highlight instance

local ESP_COLORS = {
    White  = { fill=Color3.fromRGB(255,255,255), outline=Color3.fromRGB(200,200,200) },
    Red    = { fill=Color3.fromRGB(255, 60, 60),  outline=Color3.fromRGB(255,150,150) },
    Purple = { fill=Color3.fromRGB(140, 60,255),  outline=Color3.fromRGB(180,120,255) },
    Cyan   = { fill=Color3.fromRGB( 60,220,255),  outline=Color3.fromRGB(100,240,255) },
}
local espColorKey = "Red"   -- updated by dropdown

local function espColorFor(plr)
    if espColorKey == "Team" then
        local ok, c = pcall(function()
            return plr.TeamColor and plr.TeamColor.Color or Color3.fromRGB(255,60,60)
        end)
        return ok and c or Color3.fromRGB(255,60,60), Color3.fromRGB(255,255,255)
    end
    local col = ESP_COLORS[espColorKey] or ESP_COLORS.Red
    return col.fill, col.outline
end

local function removeESP(plr)
    if espHL[plr] then pcall(function() espHL[plr]:Destroy() end); espHL[plr]=nil end
end

local function refreshESP()
    if not getgenv().PlayerESP then
        for plr,_ in pairs(espHL) do removeESP(plr) end
        return
    end
    -- remove stale
    for plr,_ in pairs(espHL) do
        if not plr.Parent then removeESP(plr) end
    end
    for _, plr in ipairs(Players:GetPlayers()) do
        if plr ~= LP then
            local char = plr.Character
            if char then
                if not espHL[plr] then
                    local hl = Instance.new("Highlight")
                    hl.Name = "_ESP_"..plr.Name
                    hl.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop
                    hl.FillTransparency  = 0.55
                    hl.OutlineTransparency = 0
                    hl.Adornee = char
                    hl.Parent  = workspace   -- parented to workspace so it renders
                    espHL[plr] = hl
                end
                -- update colour
                local f, o = espColorFor(plr)
                espHL[plr].FillColor    = f
                espHL[plr].OutlineColor = o
            else
                removeESP(plr)
            end
        end
    end
end

Players.PlayerRemoving:Connect(function(p) removeESP(p) end)
Players.PlayerAdded:Connect(function(p)
    p.CharacterAdded:Connect(function() wait(0.2); refreshESP() end)
end)
spawn(function() while true do wait(0.5); refreshESP() end end)

-- ══════════════════════════════════════════════════
--  LIGHTING STATE  (fullbright / fog / FOV)
-- ══════════════════════════════════════════════════
local Lighting = game:GetService("Lighting")
local _origBright, _origAmb, _origOutAmb
local _origFogEnd, _origFogStart
local _origFOV

local function applyFullbright(on)
    if on then
        _origBright  = Lighting.Brightness
        _origAmb     = Lighting.Ambient
        _origOutAmb  = Lighting.OutdoorAmbient
        Lighting.Brightness       = 2
        Lighting.Ambient          = Color3.fromRGB(178,178,178)
        Lighting.OutdoorAmbient   = Color3.fromRGB(178,178,178)
        for _, e in pairs(Lighting:GetChildren()) do
            if e:IsA("BlurEffect") or e:IsA("ColorCorrectionEffect")
            or e:IsA("DepthOfFieldEffect") or e:IsA("SunRaysEffect")
            or e:IsA("BloomEffect") then
                pcall(function() e.Enabled = false end)
            end
        end
    else
        if _origBright then
            Lighting.Brightness     = _origBright
            Lighting.Ambient        = _origAmb
            Lighting.OutdoorAmbient = _origOutAmb
        end
        for _, e in pairs(Lighting:GetChildren()) do
            if e:IsA("BlurEffect") or e:IsA("ColorCorrectionEffect")
            or e:IsA("DepthOfFieldEffect") or e:IsA("SunRaysEffect")
            or e:IsA("BloomEffect") then
                pcall(function() e.Enabled = true end)
            end
        end
    end
end

local function applyNoFog(on)
    if on then
        _origFogEnd   = Lighting.FogEnd
        _origFogStart = Lighting.FogStart
        Lighting.FogEnd   = 9e9
        Lighting.FogStart = 9e9
    else
        Lighting.FogEnd   = _origFogEnd   or 100000
        Lighting.FogStart = _origFogStart or 0
    end
end

local function applyFOV(v)
    if not v then
        if _origFOV then workspace.CurrentCamera.FieldOfView = _origFOV end
        return
    end
    if not _origFOV then _origFOV = workspace.CurrentCamera.FieldOfView end
    workspace.CurrentCamera.FieldOfView = v
end

local function applyStretch(on)
    -- Try executor-specific APIs; silently fails if unavailable
    pcall(function()
        if on then
            if syn and syn.set_viewport_size then
                syn.set_viewport_size(Vector2.new(1152, 864))
            elseif setresolution then
                setresolution(1152, 864)
            end
        else
            if syn and syn.set_viewport_size then
                syn.set_viewport_size(nil)
            elseif setresolution then
                setresolution(1920, 1080)
            end
        end
    end)
end

-- ══════════════════════════════════════════════════
--  THEME
-- ══════════════════════════════════════════════════
local T = {
    BG      = Color3.fromRGB(10,  10,  16),
    Surface = Color3.fromRGB(17,  17,  27),
    Card    = Color3.fromRGB(22,  22,  34),
    CardH   = Color3.fromRGB(28,  28,  44),
    Accent  = Color3.fromRGB(112, 72,  255),
    AccentD = Color3.fromRGB(80,  48,  200),
    AccentL = Color3.fromRGB(165, 115, 255),
    Text    = Color3.fromRGB(235, 235, 255),
    Muted   = Color3.fromRGB(105, 105, 145),
    Border  = Color3.fromRGB(38,  38,  58),
    Track   = Color3.fromRGB(44,  44,  68),
    White   = Color3.fromRGB(255, 255, 255),
    StatBG  = Color3.fromRGB(12,  12,  20),
    Green   = Color3.fromRGB(72,  200, 130),
    Yellow  = Color3.fromRGB(255, 185, 50),
    Red     = Color3.fromRGB(255, 75,  75),
}
local FN  = Enum.Font.GothamMedium
local FNB = Enum.Font.GothamBold
local S   = 0.18
local SF  = 0.10

-- ── Helpers ────────────────────────────────────────
local function tw(o, p, d, st, di)
    TweenService:Create(o,
        TweenInfo.new(d or S, st or Enum.EasingStyle.Quart,
            di or Enum.EasingDirection.Out), p):Play()
end
local function mk(cls, t)
    local o = Instance.new(cls)
    for k,v in pairs(t) do if k~="Parent" then o[k]=v end end
    if t.Parent then o.Parent=t.Parent end; return o
end
local function rnd(p,r) local c=Instance.new("UICorner"); c.CornerRadius=UDim.new(0,r or 8); c.Parent=p; return c end
local function bdr(p,col,th)
    local s=Instance.new("UIStroke"); s.Color=col or T.Border; s.Thickness=th or 1
    s.ApplyStrokeMode=Enum.ApplyStrokeMode.Border; s.Parent=p; return s
end
local function grd(p,c0,c1,rot)
    local g=Instance.new("UIGradient"); g.Color=ColorSequence.new(c0,c1); g.Rotation=rot or 135; g.Parent=p; return g
end

-- ══════════════════════════════════════════════════
--  ROOT GUI
-- ══════════════════════════════════════════════════
local GUI = mk("ScreenGui",{
    Name="ScriptHub", ResetOnSpawn=false,
    ZIndexBehavior=Enum.ZIndexBehavior.Sibling,
    IgnoreGuiInset=true, Parent=PGui,
})
local OVL = mk("Frame",{BackgroundTransparency=1,Size=UDim2.new(1,0,1,0),ZIndex=80,Parent=GUI})

-- ── Notifications ──────────────────────────────────
local NBOX = mk("Frame",{BackgroundTransparency=1,AnchorPoint=Vector2.new(1,1),
    Position=UDim2.new(1,-14,1,-14),Size=UDim2.new(0,272,1,0),ZIndex=90,Parent=GUI})
mk("UIListLayout",{FillDirection=Enum.FillDirection.Vertical,
    VerticalAlignment=Enum.VerticalAlignment.Bottom,
    HorizontalAlignment=Enum.HorizontalAlignment.Right,
    Padding=UDim.new(0,6),Parent=NBOX})
local NT={ok={Color3.fromRGB(72,200,130),"✓"},err={Color3.fromRGB(255,75,75),"✕"},
    warn={Color3.fromRGB(255,185,50),"!"},info={Color3.fromRGB(112,72,255),"i"}}

local function notify(title,msg,kind,dur)
    local n=NT[kind or "info"] or NT.info; dur=dur or 3
    local card=mk("Frame",{BackgroundColor3=Color3.fromRGB(16,16,28),
        Size=UDim2.new(1,0,0,66),Position=UDim2.new(1,30,0,0),
        ZIndex=91,ClipsDescendants=true,Parent=NBOX})
    rnd(card,10); bdr(card,Color3.fromRGB(36,36,54))
    mk("Frame",{BackgroundColor3=n[1],Size=UDim2.new(0,3,1,0),ZIndex=92,Parent=card})
    local badge=mk("Frame",{BackgroundColor3=n[1],Position=UDim2.new(0,12,0.5,-11),
        Size=UDim2.new(0,22,0,22),ZIndex=92,Parent=card}); rnd(badge,6)
    mk("TextLabel",{BackgroundTransparency=1,Size=UDim2.new(1,0,1,0),Text=n[2],
        TextColor3=T.White,TextSize=13,Font=FNB,ZIndex=93,Parent=badge})
    mk("TextLabel",{BackgroundTransparency=1,Position=UDim2.new(0,42,0,10),
        Size=UDim2.new(1,-52,0,18),Text=title,TextColor3=T.Text,TextSize=13,Font=FNB,
        TextXAlignment=Enum.TextXAlignment.Left,ZIndex=92,Parent=card})
    mk("TextLabel",{BackgroundTransparency=1,Position=UDim2.new(0,42,0,29),
        Size=UDim2.new(1,-52,0,28),Text=msg or "",TextColor3=T.Muted,TextSize=11,Font=FN,
        TextXAlignment=Enum.TextXAlignment.Left,TextWrapped=true,ZIndex=92,Parent=card})
    local prog=mk("Frame",{BackgroundColor3=n[1],BackgroundTransparency=0.45,
        Position=UDim2.new(0,0,1,-3),Size=UDim2.new(1,0,0,3),ZIndex=93,Parent=card})
    tw(card,{Position=UDim2.new(0,0,0,0)},S,Enum.EasingStyle.Back,Enum.EasingDirection.Out)
    tw(prog,{Size=UDim2.new(0,0,0,3)},dur-0.25,Enum.EasingStyle.Linear)
    spawn(function() wait(dur); tw(card,{Position=UDim2.new(1,30,0,0)},S)
        wait(S+0.06); card:Destroy() end)
end

-- ── Watermark ──────────────────────────────────────
local WM = mk("Frame",{BackgroundColor3=Color3.fromRGB(12,12,20),BackgroundTransparency=0.15,
    Position=UDim2.new(0,12,0,12),Size=UDim2.new(0,214,0,27),ZIndex=20,Parent=GUI})
rnd(WM,6); bdr(WM)
local WMDOT = mk("Frame",{BackgroundColor3=T.Accent,Position=UDim2.new(0,10,0.5,-4),
    Size=UDim2.new(0,8,0,8),ZIndex=21,Parent=WM}); rnd(WMDOT,4)
mk("TextLabel",{BackgroundTransparency=1,Position=UDim2.new(0,26,0,0),
    Size=UDim2.new(1,-30,1,0),Text="ScriptHub  •  "..LP.Name,
    TextColor3=T.Muted,TextSize=11,Font=FN,
    TextXAlignment=Enum.TextXAlignment.Left,ZIndex=21,Parent=WM})
do local d,ds,sp=false
    WM.InputBegan:Connect(function(i)
        if i.UserInputType==Enum.UserInputType.MouseButton1 then d=true;ds=i.Position;sp=WM.Position end end)
    UserInputService.InputChanged:Connect(function(i)
        if d and i.UserInputType==Enum.UserInputType.MouseMovement then
            local v=i.Position-ds
            WM.Position=UDim2.new(sp.X.Scale,sp.X.Offset+v.X,sp.Y.Scale,sp.Y.Offset+v.Y) end end)
    UserInputService.InputEnded:Connect(function(i)
        if i.UserInputType==Enum.UserInputType.MouseButton1 then d=false end end)
end
RunService.Heartbeat:Connect(function()
    WMDOT.BackgroundTransparency=0.1+math.abs(math.sin(tick()*math.pi*0.55))*0.65 end)

-- Debug Overlay
local DBG = mk("Frame",{BackgroundColor3=Color3.fromRGB(0,0,0),BackgroundTransparency=0.45,
    Position=UDim2.new(0,12,0,46),Size=UDim2.new(0,214,0,44),ZIndex=21,Visible=false,Parent=GUI})
rnd(DBG,6); bdr(DBG)
local DBGL=mk("TextLabel",{BackgroundTransparency=1,Size=UDim2.new(1,0,1,0),
    Text="",TextColor3=T.Muted,TextSize=10,Font=FN,ZIndex=22,Parent=DBG})
do local u=Instance.new("UIPadding"); u.PaddingTop=UDim.new(0,4); u.PaddingLeft=UDim.new(0,8); u.Parent=DBG end
RunService.Heartbeat:Connect(function()
    if not DBG.Visible then return end
    DBGL.Text = string.format("PlaceID: %d\nJob: %s...\nPlayers: %d",
        game.PlaceId, game.JobId:sub(1,10), #Players:GetPlayers())
end)

-- ══════════════════════════════════════════════════
--  MAIN WINDOW   600 × 450
--  Titlebar  y=0   h=50
--  Sidebar   x=0   w=152  y=50 h=368
--  Content   x=152        y=50 h=368
--  Statusbar             y=418 h=32
-- ══════════════════════════════════════════════════
local WIN = mk("Frame",{Name="Window",AnchorPoint=Vector2.new(0.5,0.5),
    BackgroundColor3=T.BG,Position=UDim2.new(0.5,0,0.5,0),
    Size=UDim2.new(0,600,0,450),ZIndex=10,ClipsDescendants=true,Parent=GUI})
rnd(WIN,12); bdr(WIN); grd(WIN,Color3.fromRGB(18,12,34),T.BG,145)

-- ── Titlebar ───────────────────────────────────────
local TB=mk("Frame",{BackgroundColor3=T.Surface,Size=UDim2.new(1,0,0,50),ZIndex=11,Parent=WIN})
rnd(TB,12)
mk("Frame",{BackgroundColor3=T.Surface,Position=UDim2.new(0,0,0.5,0),Size=UDim2.new(1,0,0.5,0),ZIndex=11,Parent=TB})
grd(TB,Color3.fromRGB(20,14,38),T.Surface,0)
local ALINE=mk("Frame",{BackgroundColor3=T.Accent,Position=UDim2.new(0,0,1,-2),Size=UDim2.new(1,0,0,2),ZIndex=12,Parent=TB})
grd(ALINE,T.AccentL,T.AccentD,0)
local LOGO=mk("Frame",{BackgroundColor3=T.Accent,Position=UDim2.new(0,14,0.5,-14),Size=UDim2.new(0,28,0,28),ZIndex=12,Parent=TB})
rnd(LOGO,8); grd(LOGO,T.AccentL,T.AccentD,135)
mk("TextLabel",{BackgroundTransparency=1,Size=UDim2.new(1,0,1,0),Text="S",TextColor3=T.White,TextSize=16,Font=FNB,ZIndex=13,Parent=LOGO})
mk("TextLabel",{BackgroundTransparency=1,Position=UDim2.new(0,50,0,7),Size=UDim2.new(0,180,0,19),
    Text="ScriptHub",TextColor3=T.Text,TextSize=15,Font=FNB,TextXAlignment=Enum.TextXAlignment.Left,ZIndex=12,Parent=TB})
mk("TextLabel",{BackgroundTransparency=1,Position=UDim2.new(0,50,0,27),Size=UDim2.new(0,180,0,14),
    Text="v1.0  •  Free",TextColor3=T.Muted,TextSize=10,Font=FN,TextXAlignment=Enum.TextXAlignment.Left,ZIndex=12,Parent=TB})

local CBTN=mk("TextButton",{AnchorPoint=Vector2.new(1,0.5),BackgroundColor3=T.Red,
    Position=UDim2.new(1,-14,0.5,0),Size=UDim2.new(0,13,0,13),Text="",ZIndex=14,Parent=TB}); rnd(CBTN,7)
local MBTN=mk("TextButton",{AnchorPoint=Vector2.new(1,0.5),BackgroundColor3=T.Yellow,
    Position=UDim2.new(1,-34,0.5,0),Size=UDim2.new(0,13,0,13),Text="",ZIndex=14,Parent=TB}); rnd(MBTN,7)
CBTN.MouseEnter:Connect(function() tw(CBTN,{BackgroundTransparency=0.35},SF) end)
CBTN.MouseLeave:Connect(function() tw(CBTN,{BackgroundTransparency=0},SF) end)
MBTN.MouseEnter:Connect(function() tw(MBTN,{BackgroundTransparency=0.35},SF) end)
MBTN.MouseLeave:Connect(function() tw(MBTN,{BackgroundTransparency=0},SF) end)

local DRAG=mk("TextButton",{BackgroundTransparency=1,Size=UDim2.new(1,-55,1,0),Text="",ZIndex=13,Parent=TB})
do local drag=false; local ds; local wp
    DRAG.MouseButton1Down:Connect(function()
        drag=true; ds=UserInputService:GetMouseLocation(); wp=WIN.Position end)
    UserInputService.InputEnded:Connect(function(i)
        if i.UserInputType==Enum.UserInputType.MouseButton1 then drag=false end end)
    UserInputService.InputChanged:Connect(function(i)
        if drag and i.UserInputType==Enum.UserInputType.MouseMovement then
            local d=UserInputService:GetMouseLocation()-ds
            WIN.Position=UDim2.new(wp.X.Scale,wp.X.Offset+d.X,wp.Y.Scale,wp.Y.Offset+d.Y) end end)
end

-- ── Sidebar ────────────────────────────────────────
local SB=mk("Frame",{BackgroundColor3=T.Surface,Position=UDim2.new(0,0,0,50),
    Size=UDim2.new(0,152,0,368),ZIndex=11,Parent=WIN})
grd(SB,T.Surface,Color3.fromRGB(13,13,22),90)
mk("Frame",{BackgroundColor3=T.Border,AnchorPoint=Vector2.new(1,0),Position=UDim2.new(1,0,0,0),
    Size=UDim2.new(0,1,1,0),ZIndex=12,Parent=SB})
local IND=mk("Frame",{BackgroundColor3=T.Accent,Size=UDim2.new(0,3,0,28),Position=UDim2.new(0,0,0,18),ZIndex=14,Parent=SB}); rnd(IND,2)
local TLIST=mk("Frame",{BackgroundTransparency=1,Size=UDim2.new(1,0,1,0),ZIndex=12,Parent=SB})
do local u=Instance.new("UIPadding"); u.PaddingTop=UDim.new(0,10); u.PaddingBottom=UDim.new(0,10)
   u.PaddingLeft=UDim.new(0,9); u.PaddingRight=UDim.new(0,9); u.Parent=TLIST end
mk("UIListLayout",{FillDirection=Enum.FillDirection.Vertical,Padding=UDim.new(0,3),Parent=TLIST})

-- ── Content ────────────────────────────────────────
local CA=mk("Frame",{BackgroundTransparency=1,Position=UDim2.new(0,152,0,50),Size=UDim2.new(0,448,0,368),ZIndex=11,Parent=WIN})

-- ── Status bar ─────────────────────────────────────
local STAT=mk("Frame",{BackgroundColor3=T.StatBG,Position=UDim2.new(0,0,0,418),Size=UDim2.new(1,0,0,32),ZIndex=12,Parent=WIN})
mk("Frame",{BackgroundColor3=T.Border,Size=UDim2.new(1,0,0,1),ZIndex=13,Parent=STAT})
local FPS_LBL=mk("TextLabel",{BackgroundTransparency=1,Position=UDim2.new(0,12,0,0),Size=UDim2.new(0,72,1,0),
    Text="FPS: --",TextColor3=T.Muted,TextSize=10,Font=FN,TextXAlignment=Enum.TextXAlignment.Left,ZIndex=13,Parent=STAT})
local ACT_LBL=mk("TextLabel",{BackgroundTransparency=1,Position=UDim2.new(0,88,0,0),Size=UDim2.new(0,130,1,0),
    Text="○  0 active",TextColor3=T.Muted,TextSize=10,Font=FN,TextXAlignment=Enum.TextXAlignment.Left,ZIndex=13,Parent=STAT})
local KBLBL=mk("TextLabel",{BackgroundTransparency=1,AnchorPoint=Vector2.new(1,0.5),Position=UDim2.new(1,-12,0.5,0),
    Size=UDim2.new(0,100,1,0),Text="M  to toggle",TextColor3=T.Muted,TextSize=10,Font=FN,
    TextXAlignment=Enum.TextXAlignment.Right,ZIndex=13,Parent=STAT})
do local buf={}
    RunService.Heartbeat:Connect(function(dt)
        buf[#buf+1]=1/dt; if #buf>30 then table.remove(buf,1) end
        local s=0; for _,v in ipairs(buf) do s=s+v end; local f=math.round(s/#buf)
        FPS_LBL.Text="FPS: "..f
        FPS_LBL.TextColor3=f>=55 and T.Green or f>=30 and T.Yellow or T.Red
    end)
end
local activeN=0
local function setActive(d)
    activeN=math.max(0,activeN+d)
    ACT_LBL.Text=(activeN>0 and "●  " or "○  ")..activeN.." active"
    ACT_LBL.TextColor3=activeN>0 and T.AccentL or T.Muted
end

-- ══════════════════════════════════════════════════
--  TABS  (6 tabs)
-- ══════════════════════════════════════════════════
local BTN_H=36; local BTN_G=3; local PAD_T=10; local IND_H=28
local function indY(idx) return PAD_T+idx*(BTN_H+BTN_G)+(BTN_H-IND_H)/2 end
local Tabs={}; local CurTab=nil

local function switchTab(id)
    local tab=Tabs[id]; if not tab or CurTab==id then return end
    if CurTab then
        local old=Tabs[CurTab]
        tw(old.btn,{BackgroundTransparency=1,BackgroundColor3=T.Card},S)
        tw(old.ico,{TextColor3=T.Muted},S); tw(old.lbl,{TextColor3=T.Muted},S)
        old.page.Visible=false
    end
    CurTab=id
    tw(tab.btn,{BackgroundTransparency=0,BackgroundColor3=Color3.fromRGB(28,18,54)},S)
    tw(tab.ico,{TextColor3=T.AccentL},S); tw(tab.lbl,{TextColor3=T.Text},S)
    tab.page.Visible=true
    tw(IND,{Position=UDim2.new(0,0,0,indY(tab.idx))},S)
end

local TDEFS={
    {id="Main",   lbl="Main",    ico="▸"},
    {id="Visual", lbl="Visual",  ico="◈"},
    {id="World",  lbl="World",   ico="◉"},
    {id="Player", lbl="Player",  ico="◎"},
    {id="Combat", lbl="Combat",  ico="⚔"},
    {id="Settings",lbl="Settings",ico="⊞"},
}

for i,def in ipairs(TDEFS) do
    local idx=i-1
    local btn=mk("TextButton",{BackgroundColor3=T.Card,BackgroundTransparency=1,
        Size=UDim2.new(1,0,0,BTN_H),Text="",ZIndex=12,Parent=TLIST}); rnd(btn,6)
    local ico=mk("TextLabel",{BackgroundTransparency=1,Position=UDim2.new(0,8,0,0),
        Size=UDim2.new(0,20,1,0),Text=def.ico,TextColor3=T.Muted,TextSize=13,Font=FN,ZIndex=13,Parent=btn})
    local lbl=mk("TextLabel",{BackgroundTransparency=1,Position=UDim2.new(0,32,0,0),
        Size=UDim2.new(1,-32,1,0),Text=def.lbl,TextColor3=T.Muted,TextSize=12,Font=FN,
        TextXAlignment=Enum.TextXAlignment.Left,ZIndex=13,Parent=btn})
    local page=mk("Frame",{BackgroundTransparency=1,Size=UDim2.new(1,0,1,0),Visible=false,ZIndex=12,Parent=CA})
    local scroll=mk("ScrollingFrame",{BackgroundTransparency=1,Size=UDim2.new(1,0,1,0),
        ScrollBarThickness=3,ScrollBarImageColor3=T.Accent,
        CanvasSize=UDim2.new(0,0,0,0),AutomaticCanvasSize=Enum.AutomaticSize.Y,
        ZIndex=12,Parent=page})
    do local u=Instance.new("UIPadding")
       u.PaddingTop=UDim.new(0,12); u.PaddingBottom=UDim.new(0,12)
       u.PaddingLeft=UDim.new(0,12); u.PaddingRight=UDim.new(0,14); u.Parent=scroll end
    mk("UIListLayout",{FillDirection=Enum.FillDirection.Vertical,Padding=UDim.new(0,9),
        SortOrder=Enum.SortOrder.LayoutOrder,Parent=scroll})
    Tabs[def.id]={btn=btn,ico=ico,lbl=lbl,page=page,scroll=scroll,idx=idx}
    btn.MouseButton1Click:Connect(function() switchTab(def.id) end)
    btn.MouseEnter:Connect(function() if CurTab~=def.id then tw(btn,{BackgroundTransparency=0.85},SF) end end)
    btn.MouseLeave:Connect(function() if CurTab~=def.id then tw(btn,{BackgroundTransparency=1},SF) end end)
end

-- ══════════════════════════════════════════════════
--  COMPONENT BUILDERS
-- ══════════════════════════════════════════════════

local function sec(parent, title)
    local card=mk("Frame",{BackgroundColor3=T.Card,Size=UDim2.new(1,0,0,0),
        AutomaticSize=Enum.AutomaticSize.Y,ZIndex=13,Parent=parent})
    rnd(card,8); bdr(card,T.Border)
    local hdr=mk("Frame",{BackgroundTransparency=1,Position=UDim2.new(0,0,0,0),
        Size=UDim2.new(1,0,0,32),ZIndex=14,Parent=card})
    local pill=mk("Frame",{BackgroundColor3=T.Accent,Position=UDim2.new(0,10,0.5,-7),
        Size=UDim2.new(0,3,0,14),ZIndex=15,Parent=hdr}); rnd(pill,2)
    mk("TextLabel",{BackgroundTransparency=1,Position=UDim2.new(0,20,0,0),Size=UDim2.new(1,-20,1,0),
        Text=title,TextColor3=T.Muted,TextSize=10,Font=FNB,
        TextXAlignment=Enum.TextXAlignment.Left,ZIndex=15,Parent=hdr})
    mk("Frame",{BackgroundColor3=T.Border,Position=UDim2.new(0,0,0,31),Size=UDim2.new(1,0,0,1),ZIndex=14,Parent=card})
    local items=mk("Frame",{BackgroundTransparency=1,Position=UDim2.new(0,8,0,36),
        Size=UDim2.new(1,-16,0,0),AutomaticSize=Enum.AutomaticSize.Y,ZIndex=14,Parent=card})
    mk("UIListLayout",{FillDirection=Enum.FillDirection.Vertical,Padding=UDim.new(0,3),
        SortOrder=Enum.SortOrder.LayoutOrder,Parent=items})
    return items
end

local function row(parent, h)
    local r=mk("Frame",{BackgroundColor3=T.Surface,Size=UDim2.new(1,0,0,h or 46),ZIndex=15,Parent=parent})
    rnd(r,6); bdr(r,Color3.fromRGB(28,28,46))
    local hov=mk("TextButton",{BackgroundTransparency=1,Size=UDim2.new(1,0,1,0),Text="",ZIndex=15,Parent=r})
    hov.MouseEnter:Connect(function() tw(r,{BackgroundColor3=T.CardH},SF) end)
    hov.MouseLeave:Connect(function() tw(r,{BackgroundColor3=T.Surface},SF) end)
    return r
end

local function rowLbls(r,name,desc)
    mk("TextLabel",{BackgroundTransparency=1,Position=UDim2.new(0,12,0,desc and 5 or 13),
        Size=UDim2.new(0.6,0,0,18),Text=name,TextColor3=T.Text,TextSize=13,Font=FN,
        TextXAlignment=Enum.TextXAlignment.Left,ZIndex=17,Parent=r})
    if desc then mk("TextLabel",{BackgroundTransparency=1,Position=UDim2.new(0,12,0,24),
        Size=UDim2.new(0.6,0,0,14),Text=desc,TextColor3=T.Muted,TextSize=10,Font=FN,
        TextXAlignment=Enum.TextXAlignment.Left,ZIndex=17,Parent=r}) end
end

-- Button
local function addBtn(parent,name,desc,cb,col)
    local r=row(parent,46); rowLbls(r,name,desc)
    local b=mk("TextButton",{AnchorPoint=Vector2.new(1,0.5),BackgroundColor3=col or T.Accent,
        Position=UDim2.new(1,-11,0.5,0),Size=UDim2.new(0,76,0,27),Text="Run",
        TextColor3=T.White,TextSize=12,Font=FNB,ZIndex=18,Parent=r}); rnd(b,6)
    if not col then grd(b,T.AccentL,T.AccentD,90) end
    b.MouseEnter:Connect(function()   tw(b,{Size=UDim2.new(0,80,0,29)},SF) end)
    b.MouseLeave:Connect(function()   tw(b,{Size=UDim2.new(0,76,0,27)},SF) end)
    b.MouseButton1Down:Connect(function()  tw(b,{Size=UDim2.new(0,72,0,25)},0.07) end)
    b.MouseButton1Up:Connect(function()    tw(b,{Size=UDim2.new(0,76,0,27)},SF) end)
    b.MouseButton1Click:Connect(function() if cb then cb() end end)
    return r
end

-- Toggle
local function addTgl(parent,name,desc,def,cb)
    local state=(def==true); local r=row(parent,46); rowLbls(r,name,desc)
    local track=mk("Frame",{AnchorPoint=Vector2.new(1,0.5),BackgroundColor3=state and T.Accent or T.Track,
        Position=UDim2.new(1,-12,0.5,0),Size=UDim2.new(0,44,0,24),ZIndex=17,Parent=r}); rnd(track,12)
    local knob=mk("Frame",{AnchorPoint=Vector2.new(0,0.5),BackgroundColor3=T.White,
        Position=UDim2.new(0,state and 22 or 2,0.5,0),Size=UDim2.new(0,20,0,20),ZIndex=18,Parent=track}); rnd(knob,10)
    local hit=mk("TextButton",{BackgroundTransparency=1,Size=UDim2.new(1,0,1,0),Text="",ZIndex=19,Parent=track})
    hit.MouseButton1Click:Connect(function()
        state=not state
        tw(track,{BackgroundColor3=state and T.Accent or T.Track},SF)
        tw(knob,{Position=UDim2.new(0,state and 22 or 2,0.5,0)},SF)
        setActive(state and 1 or -1)
        if cb then cb(state) end
    end)
    if state then setActive(1) end
    return r, function() return state end
end

-- Slider
local function addSld(parent,name,mn,mx,def,cb)
    local v=def or mn; local drag=false; local r=row(parent,54)
    mk("TextLabel",{BackgroundTransparency=1,Position=UDim2.new(0,12,0,7),Size=UDim2.new(0.68,0,0,16),
        Text=name,TextColor3=T.Text,TextSize=13,Font=FN,TextXAlignment=Enum.TextXAlignment.Left,ZIndex=17,Parent=r})
    local vLbl=mk("TextLabel",{AnchorPoint=Vector2.new(1,0),BackgroundTransparency=1,
        Position=UDim2.new(1,-12,0,7),Size=UDim2.new(0,52,0,16),Text=tostring(v),
        TextColor3=T.AccentL,TextSize=12,Font=FNB,TextXAlignment=Enum.TextXAlignment.Right,ZIndex=17,Parent=r})
    local track=mk("Frame",{BackgroundColor3=T.Track,Position=UDim2.new(0,12,0,34),
        Size=UDim2.new(1,-24,0,6),ZIndex=16,Parent=r}); rnd(track,3)
    local pct=(v-mn)/(mx-mn)
    local fill=mk("Frame",{BackgroundColor3=T.Accent,Size=UDim2.new(pct,0,1,0),ZIndex=17,Parent=track})
    rnd(fill,3); grd(fill,T.AccentL,T.AccentD,0)
    local knob=mk("Frame",{AnchorPoint=Vector2.new(0.5,0.5),BackgroundColor3=T.White,
        Position=UDim2.new(pct,0,0.5,0),Size=UDim2.new(0,14,0,14),ZIndex=18,Parent=track})
    rnd(knob,7); bdr(knob,T.Accent,2)
    local hit=mk("TextButton",{BackgroundTransparency=1,Position=UDim2.new(0,-8,0,-8),
        Size=UDim2.new(1,16,1,16),Text="",ZIndex=19,Parent=track})
    local function upd(x)
        local rel=math.clamp((x-track.AbsolutePosition.X)/track.AbsoluteSize.X,0,1)
        v=math.round(mn+(mx-mn)*rel); local p=(v-mn)/(mx-mn)
        tw(fill,{Size=UDim2.new(p,0,1,0)},0.05); tw(knob,{Position=UDim2.new(p,0,0.5,0)},0.05)
        vLbl.Text=tostring(v); if cb then cb(v) end
    end
    hit.MouseButton1Down:Connect(function(x) drag=true; upd(x) end)
    UserInputService.InputChanged:Connect(function(i)
        if drag and i.UserInputType==Enum.UserInputType.MouseMovement then upd(i.Position.X) end end)
    UserInputService.InputEnded:Connect(function(i)
        if i.UserInputType==Enum.UserInputType.MouseButton1 then drag=false end end)
    return r, function() return v end
end

-- Dropdown
local openDD=nil
local function addDD(parent,name,opts,def,cb)
    local sel=def or opts[1]; local open=false; local r=row(parent,46)
    mk("TextLabel",{BackgroundTransparency=1,Position=UDim2.new(0,12,0,13),
        Size=UDim2.new(0.44,0,0,18),Text=name,TextColor3=T.Text,TextSize=13,Font=FN,
        TextXAlignment=Enum.TextXAlignment.Left,ZIndex=17,Parent=r})
    local box=mk("Frame",{AnchorPoint=Vector2.new(1,0.5),BackgroundColor3=T.BG,
        Position=UDim2.new(1,-11,0.5,0),Size=UDim2.new(0,130,0,27),ZIndex=17,Parent=r})
    rnd(box,6); bdr(box)
    local selLbl=mk("TextLabel",{BackgroundTransparency=1,Position=UDim2.new(0,9,0,0),
        Size=UDim2.new(1,-26,1,0),Text=sel,TextColor3=T.Text,TextSize=12,Font=FN,
        TextXAlignment=Enum.TextXAlignment.Left,ZIndex=18,Parent=box})
    local arr=mk("TextLabel",{AnchorPoint=Vector2.new(1,0.5),BackgroundTransparency=1,
        Position=UDim2.new(1,-7,0.5,0),Size=UDim2.new(0,14,0,14),Text="▾",
        TextColor3=T.Muted,TextSize=11,Font=FN,ZIndex=18,Parent=box})
    local OPH=27; local maxV=math.min(#opts,5)
    local pop=mk("Frame",{BackgroundColor3=Color3.fromRGB(18,18,30),Size=UDim2.new(0,130,0,0),
        ZIndex=95,Visible=false,ClipsDescendants=true,Parent=OVL}); rnd(pop,7); bdr(pop)
    local plist=mk("Frame",{BackgroundTransparency=1,Size=UDim2.new(1,0,0,0),
        AutomaticSize=Enum.AutomaticSize.Y,ZIndex=96,Parent=pop})
    mk("UIListLayout",{Padding=UDim.new(0,2),Parent=plist})
    do local u=Instance.new("UIPadding"); u.PaddingTop=UDim.new(0,4); u.PaddingBottom=UDim.new(0,4)
       u.PaddingLeft=UDim.new(0,4); u.PaddingRight=UDim.new(0,4); u.Parent=plist end
    local function buildPop()
        for _,opt in ipairs(opts) do
            local isA=(opt==sel)
            local ob=mk("TextButton",{BackgroundColor3=isA and Color3.fromRGB(28,18,52) or T.BG,
                BackgroundTransparency=isA and 0 or 1,Size=UDim2.new(1,0,0,OPH),Text="",ZIndex=97,Parent=plist})
            rnd(ob,5)
            mk("TextLabel",{BackgroundTransparency=1,Position=UDim2.new(0,9,0,0),Size=UDim2.new(1,-9,1,0),
                Text=opt,TextColor3=isA and T.AccentL or T.Text,TextSize=12,Font=isA and FNB or FN,
                TextXAlignment=Enum.TextXAlignment.Left,ZIndex=98,Parent=ob})
            ob.MouseEnter:Connect(function() if not isA then tw(ob,{BackgroundTransparency=0.82,BackgroundColor3=T.Card},SF) end end)
            ob.MouseLeave:Connect(function() if not isA then tw(ob,{BackgroundTransparency=1},SF) end end)
            ob.MouseButton1Click:Connect(function()
                sel=opt; selLbl.Text=opt; open=false
                tw(pop,{Size=UDim2.new(0,130,0,0)},SF); tw(arr,{Rotation=0},SF)
                spawn(function() wait(SF+0.05); pop.Visible=false end); openDD=nil
                for _,c in ipairs(plist:GetChildren()) do if c:IsA("TextButton") then c:Destroy() end end
                buildPop(); if cb then cb(sel) end
            end)
        end
    end; buildPop()
    local tgtH=OPH*maxV+8+(maxV-1)*2+8
    local function openPop()
        if openDD and openDD~=pop then
            tw(openDD,{Size=UDim2.new(0,130,0,0)},SF)
            spawn(function() wait(SF+0.05); openDD.Visible=false end) end
        local ap=box.AbsolutePosition; local as=box.AbsoluteSize
        pop.Position=UDim2.new(0,ap.X,0,ap.Y+as.Y+4); pop.Visible=true
        tw(pop,{Size=UDim2.new(0,130,0,tgtH)},S,Enum.EasingStyle.Back,Enum.EasingDirection.Out)
        tw(arr,{Rotation=180},SF); openDD=pop; open=true
    end
    local function closePop()
        tw(pop,{Size=UDim2.new(0,130,0,0)},SF); tw(arr,{Rotation=0},SF)
        spawn(function() wait(SF+0.05); pop.Visible=false end); openDD=nil; open=false
    end
    local hitBtn=mk("TextButton",{BackgroundTransparency=1,Size=UDim2.new(1,0,1,0),Text="",ZIndex=19,Parent=box})
    hitBtn.MouseButton1Click:Connect(function() if open then closePop() else openPop() end end)
    UserInputService.InputBegan:Connect(function(i)
        if not open or i.UserInputType~=Enum.UserInputType.MouseButton1 then return end
        local mx,my=i.Position.X,i.Position.Y; local pp,ps=pop.AbsolutePosition,pop.AbsoluteSize
        if mx<pp.X or mx>pp.X+ps.X or my<pp.Y or my>pp.Y+ps.Y then closePop() end end)
    return r, function() return sel end
end

-- Keybind (with Clear button)
-- addKey(parent, name, defKey, kbId, onSet, onClear)
local function addKey(parent, name, defKey, kbId, onSet, onClear)
    local cur = defKey; local listen = false
    local r = row(parent, 46)
    mk("TextLabel",{BackgroundTransparency=1,Position=UDim2.new(0,12,0,13),
        Size=UDim2.new(0.48,0,0,18),Text=name,TextColor3=T.Text,TextSize=13,Font=FN,
        TextXAlignment=Enum.TextXAlignment.Left,ZIndex=17,Parent=r})
    local badge=mk("TextButton",{AnchorPoint=Vector2.new(1,0.5),BackgroundColor3=T.BG,
        Position=UDim2.new(1,-38,0.5,0),Size=UDim2.new(0,74,0,27),
        Text=cur and cur.Name or "None",TextColor3=T.AccentL,TextSize=11,Font=FNB,ZIndex=18,Parent=r})
    rnd(badge,6); bdr(badge,T.Accent)
    local clrBtn=mk("TextButton",{AnchorPoint=Vector2.new(1,0.5),BackgroundColor3=T.Track,
        Position=UDim2.new(1,-11,0.5,0),Size=UDim2.new(0,22,0,22),
        Text="×",TextColor3=T.Muted,TextSize=14,Font=FNB,ZIndex=18,Parent=r}); rnd(clrBtn,5)
    badge.MouseButton1Click:Connect(function()
        listen=true; badge.Text="  . . ."; badge.TextColor3=T.Yellow
        tw(badge,{BackgroundColor3=Color3.fromRGB(28,22,6)},SF)
    end)
    UserInputService.InputBegan:Connect(function(i,gp)
        if not listen then return end
        if i.UserInputType~=Enum.UserInputType.Keyboard then return end
        listen=false; cur=i.KeyCode
        badge.Text=i.KeyCode.Name; badge.TextColor3=T.AccentL
        tw(badge,{BackgroundColor3=T.BG},SF)
        if kbId then kbSet(kbId, cur) end
        if onSet then onSet(cur) end
    end)
    clrBtn.MouseButton1Click:Connect(function()
        listen=false; cur=nil
        badge.Text="None"; badge.TextColor3=T.Muted
        tw(badge,{BackgroundColor3=T.BG},SF)
        if kbId then kbClear(kbId) end
        if onClear then onClear() end
    end)
    clrBtn.MouseEnter:Connect(function() tw(clrBtn,{BackgroundColor3=T.Card},SF) end)
    clrBtn.MouseLeave:Connect(function() tw(clrBtn,{BackgroundColor3=T.Track},SF) end)
    return r, function() return cur end
end

-- Input field
local function addInp(parent,name,ph,cb)
    local r=row(parent,46)
    mk("TextLabel",{BackgroundTransparency=1,Position=UDim2.new(0,12,0,13),
        Size=UDim2.new(0.4,0,0,18),Text=name,TextColor3=T.Text,TextSize=13,Font=FN,
        TextXAlignment=Enum.TextXAlignment.Left,ZIndex=17,Parent=r})
    local box=mk("Frame",{AnchorPoint=Vector2.new(1,0.5),BackgroundColor3=T.BG,
        Position=UDim2.new(1,-11,0.5,0),Size=UDim2.new(0,148,0,27),ZIndex=17,Parent=r})
    rnd(box,6); local bs=bdr(box)
    local tb=mk("TextBox",{BackgroundTransparency=1,Position=UDim2.new(0,8,0,0),Size=UDim2.new(1,-16,1,0),
        Text="",PlaceholderText=ph or "Enter value...",PlaceholderColor3=T.Muted,TextColor3=T.Text,
        TextSize=12,Font=FN,TextXAlignment=Enum.TextXAlignment.Left,ClearTextOnFocus=false,ZIndex=18,Parent=box})
    tb.Focused:Connect(function() tw(box,{BackgroundColor3=Color3.fromRGB(16,12,30)},SF); bs.Color=T.Accent end)
    tb.FocusLost:Connect(function(enter)
        tw(box,{BackgroundColor3=T.BG},SF); bs.Color=T.Border
        if enter and cb then cb(tb.Text) end end)
    return r, function() return tb.Text end, tb
end

-- Config Manager (special row with name input + save/load)
local function addConfigManager(parent)
    local savedList = {}
    for k,_ in pairs(CFGS) do savedList[#savedList+1] = k end
    if #savedList == 0 then savedList = {"default"} end

    local r=row(parent,46)
    local nameBox=mk("TextBox",{AnchorPoint=Vector2.new(0,0.5),BackgroundColor3=T.BG,
        Position=UDim2.new(0,12,0.5,0),Size=UDim2.new(0,120,0,27),
        Text="",PlaceholderText="Config name...",PlaceholderColor3=T.Muted,
        TextColor3=T.Text,TextSize=11,Font=FN,ClearTextOnFocus=false,ZIndex=18,Parent=r})
    rnd(nameBox,5); bdr(nameBox)

    local saveBtn=mk("TextButton",{AnchorPoint=Vector2.new(1,0.5),BackgroundColor3=T.Accent,
        Position=UDim2.new(1,-72,0.5,0),Size=UDim2.new(0,56,0,27),
        Text="Save",TextColor3=T.White,TextSize=11,Font=FNB,ZIndex=18,Parent=r}); rnd(saveBtn,5)
    grd(saveBtn,T.AccentL,T.AccentD,90)

    local loadBtn=mk("TextButton",{AnchorPoint=Vector2.new(1,0.5),BackgroundColor3=T.Surface,
        Position=UDim2.new(1,-12,0.5,0),Size=UDim2.new(0,56,0,27),
        Text="Load",TextColor3=T.Text,TextSize=11,Font=FNB,ZIndex=18,Parent=r}); rnd(loadBtn,5)
    bdr(loadBtn,T.Border)

    saveBtn.MouseButton1Click:Connect(function()
        local n = nameBox.Text
        if cfgSave(n) then
            notify("Config Saved", '"'..n..'"  saved', "ok", 2.5)
        else
            notify("Config", "Enter a config name first", "warn", 2.5)
        end
    end)
    loadBtn.MouseButton1Click:Connect(function()
        local n = nameBox.Text
        if cfgLoad(n) then
            notify("Config Loaded", '"'..n..'"  applied', "ok", 2.5)
        else
            notify("Config", '"'..n..'"  not found', "err", 2.5)
        end
    end)
    return r
end

-- ══════════════════════════════════════════════════
--  TAB CONTENT
-- ══════════════════════════════════════════════════

-- ── MAIN ───────────────────────────────────────────
do
    local sc=Tabs["Main"].scroll
    local s1=sec(sc,"MOVEMENT")
    addSld(s1,"Walk Speed",14,250,14,function(v)
        getgenv().WalkSpeed=v; applyWalkSpeed() end)
    addSld(s1,"Jump Power",0,500,50,function(v)
        getgenv().JumpPower=v end)
    addTgl(s1,"Fly","Float in the air with WASD",false,function(v)
        getgenv().FlyEnabled=v
        if v then enableFly() else disableFly() end end)
    addTgl(s1,"Noclip","Phase through walls",false,function(v)
        getgenv().NoclipEnabled=v end)
    addKey(s1,"Fly Hotkey",Enum.KeyCode.F,"fly",function(k)
        kbBind("fly",k,function()
            getgenv().FlyEnabled=not getgenv().FlyEnabled
            if getgenv().FlyEnabled then enableFly() else disableFly() end
        end)
    end)
    local s2=sec(sc,"AUTOMATION")
    addBtn(s2,"Auto Farm","Farms resources automatically",nil)
    addBtn(s2,"Auto Collect","Collects items in radius",nil)
    addTgl(s2,"Anti AFK","Prevents inactivity kick",true,function(v)
        getgenv().AntiAFK=v end)
    addSld(s2,"Farm Radius",10,500,50,nil)
end

-- Register fly keybind default
kbBind("fly",Enum.KeyCode.F,function()
    getgenv().FlyEnabled=not getgenv().FlyEnabled
    if getgenv().FlyEnabled then enableFly() else disableFly() end
end)

-- ── VISUAL ─────────────────────────────────────────
do
    local sc=Tabs["Visual"].scroll
    local s1=sec(sc,"ESP")
    addTgl(s1,"Player ESP","Highlight all enemies through walls",false,function(v)
        getgenv().PlayerESP=v; refreshESP() end)
    addTgl(s1,"Item ESP","Ground item highlights",false,nil)    -- placeholder
    addTgl(s1,"NPC ESP","NPC outlines",false,nil)               -- placeholder
    addTgl(s1,"Name Tags","Floating name labels",false,nil)     -- placeholder
    addTgl(s1,"Health Bars","HP bars above heads",false,nil)    -- placeholder
    addDD(s1,"ESP Color",{"Red","White","Purple","Cyan","Team"},"Red",function(v)
        espColorKey=v; refreshESP() end)
    local s2=sec(sc,"RENDERING")
    addSld(s2,"Field of View",60,130,70,function(v)
        applyFOV(v) end)
    addSld(s2,"Render Distance",100,2048,512,nil)
    addTgl(s2,"Fullbright","Remove darkness / lighting effects",false,function(v)
        applyFullbright(v) end)
    addTgl(s2,"No Fog","Clear map fog",false,function(v)
        applyNoFog(v) end)
    addTgl(s2,"Stretched (4:3)","Stretch viewport to 4:3 ratio",false,function(v)
        applyStretch(v)
        if v then notify("Stretch","4:3 applied — may need executor support","info",3)
        else notify("Stretch","Restored native resolution","info",2) end end)
end

-- ── WORLD ──────────────────────────────────────────
do
    local sc=Tabs["World"].scroll
    local s1=sec(sc,"PHYSICS")
    addSld(s1,"Gravity",0,400,196,function(v)
        workspace.Gravity=v end)
    addSld(s1,"Wind Speed",0,100,0,nil)
    addTgl(s1,"Freeze Players","Pause all players",false,nil)
    addTgl(s1,"No Clip","Phase through objects",false,function(v)
        getgenv().NoclipEnabled=v end)
    local s2=sec(sc,"TIME & WEATHER")
    addSld(s2,"Time of Day",0,24,12,function(v)
        pcall(function() game:GetService("Lighting").ClockTime=v end) end)
    addTgl(s2,"Lock Time","Freeze time progression",false,nil)
    addDD(s2,"Weather",{"Clear","Fog","Rain","Snow","Storm"},"Clear",nil)
    addBtn(s2,"Set Sunrise","Jump to 06:00",function()
        pcall(function() game:GetService("Lighting").ClockTime=6 end) end)
    addBtn(s2,"Set Midnight","Jump to 00:00",function()
        pcall(function() game:GetService("Lighting").ClockTime=0 end) end)
end

-- ── PLAYER ─────────────────────────────────────────
do
    local sc=Tabs["Player"].scroll
    local s1=sec(sc,"CHARACTER")
    addSld(s1,"Health",0,100,100,nil)
    addSld(s1,"Walk Speed",14,250,14,function(v)
        getgenv().WalkSpeed=v; applyWalkSpeed() end)
    addTgl(s1,"God Mode","Take no damage",false,nil)
    addTgl(s1,"Invisible","Become invisible",false,nil)
    addTgl(s1,"Always Sprint","Permanent sprint",false,nil)
    local s2=sec(sc,"TELEPORT")
    addDD(s2,"Target",{"Nearest","Random","Manual"},"Nearest",nil)
    addBtn(s2,"To Spawn","Teleport to spawn point",function()
        pcall(function()
            local c=LP.Character; local hrp=c and c:FindFirstChild("HumanoidRootPart")
            if hrp then hrp.CFrame=CFrame.new(0,5,0) end end) end)
    addBtn(s2,"To Cursor","Teleport to mouse hit",function()
        pcall(function()
            local ray=workspace:Raycast(
                workspace.CurrentCamera.CFrame.Position,
                UserInputService:GetMouseLocation())
            -- fallback
            local c=LP.Character; local hrp=c and c:FindFirstChild("HumanoidRootPart")
            if hrp then
                local mouse=LP:GetMouse()
                hrp.CFrame=CFrame.new(mouse.Hit.Position+Vector3.new(0,3,0))
            end end) end)
    addBtn(s2,"To Player","Teleport to selection",nil)
    addKey(s2,"Teleport Key",Enum.KeyCode.T,"tp",nil)
end

-- ── COMBAT ─────────────────────────────────────────
do
    local sc=Tabs["Combat"].scroll
    local s1=sec(sc,"HITBOX")
    addTgl(s1,"Enable Hitbox","Expands HRP hitbox for all enemies",false,function(v)
        getgenv().HitboxEnabled=v; if v then pcall(applyHitbox) end end)
    addSld(s1,"HRP Size",1,8,2,function(v)
        getgenv().HitboxSize=v; pcall(applyHitbox) end)
    addSld(s1,"HRP Transparency",0,100,40,function(v)
        getgenv().HitboxTransp=v/100; pcall(applyHitbox) end)
    addTgl(s1,"Anti-Weave","Destroy WeaveStun instances",false,function(v)
        getgenv().AntiWeave=v end)

    local s2=sec(sc,"ALWAYS CRIT")
    addTgl(s2,"Enable Crit","Forces UpperTorso crit hitbox",false,function(v)
        getgenv().AlwaysCrit=v end)
    addSld(s2,"Crit Size",1,15,6,function(v)
        getgenv().CritSize=v end)
    addSld(s2,"Crit Transparency",0,100,80,function(v)
        getgenv().CritTransparency=v/100 end)
    addTgl(s2,"Team Check","Skip teammates",false,function(v)
        getgenv().TeamCheck=v end)

    local s3=sec(sc,"COMBAT UTILS")
    -- Punch speed: slider 17-50 → 1.7-5.0
    addSld(s3,"Punch Speed ×10",17,50,17,function(v)
        local spd=v/10; getgenv().PunchSpeed=spd; applyPunchSpeed(spd) end)
    addTgl(s3,"Fastment","Speed boost on LMB click with tool",false,function(v)
        getgenv().FastmentEnabled=v
        if v then enableFastment() else disableFastment() end end)
    addKey(s3,"Fastment Hotkey",nil,"fastment",nil)

    local s4=sec(sc,"PANIC")
    addBtn(s4,"⚠  PANIC","Reset everything & destroy hub",function()
        panic(GUI) end, Color3.fromRGB(180,40,40))
end

-- ── SETTINGS ───────────────────────────────────────
do
    local sc=Tabs["Settings"].scroll

    -- Configs
    local sc1=sec(sc,"CONFIGS")
    addConfigManager(sc1)

    -- Keybinds
    local sk=sec(sc,"KEYBINDS")
    addKey(sk,"Hub Toggle",    Enum.KeyCode.M,      "hub",
        function(k) KBLBL.Text = k.Name.."  to toggle" end,
        function()  KBLBL.Text = "—  to toggle" end)
    addKey(sk,"Fly",           Enum.KeyCode.F,      "fly",    nil)
    addKey(sk,"Teleport",      Enum.KeyCode.T,      "tp",     nil)
    addKey(sk,"Always Crit",   nil,                 "crit",   function(k)
        kbBind("crit",k,function()
            getgenv().AlwaysCrit=not getgenv().AlwaysCrit end) end)
    addKey(sk,"Hitbox",        nil,                 "hbox",   function(k)
        kbBind("hbox",k,function()
            getgenv().HitboxEnabled=not getgenv().HitboxEnabled
            if getgenv().HitboxEnabled then pcall(applyHitbox) end end) end)
    addKey(sk,"Anti-Weave",    nil,                 "aw",     function(k)
        kbBind("aw",k,function() getgenv().AntiWeave=not getgenv().AntiWeave end) end)
    addKey(sk,"Fastment",      nil,                 "fastment",function(k)
        kbBind("fastment",k,function()
            getgenv().FastmentEnabled=not getgenv().FastmentEnabled
            if getgenv().FastmentEnabled then enableFastment() else disableFastment() end end) end)

    -- Interface
    local si=sec(sc,"INTERFACE")
    addTgl(si,"Watermark","Show watermark overlay",true,function(v)
        WM.Visible=v end)
    addTgl(si,"Debug Info","Show PlaceID / Job / Players",false,function(v)
        DBG.Visible=v end)
    addDD(si,"Theme",{"Dark","Darker","AMOLED"},"Dark",function(v)
        if v=="Darker" then
            WIN.BackgroundColor3=Color3.fromRGB(6,6,10)
            TB.BackgroundColor3=Color3.fromRGB(10,10,18)
            SB.BackgroundColor3=Color3.fromRGB(10,10,18)
        elseif v=="AMOLED" then
            WIN.BackgroundColor3=Color3.fromRGB(0,0,0)
            TB.BackgroundColor3=Color3.fromRGB(6,6,12)
            SB.BackgroundColor3=Color3.fromRGB(6,6,12)
        else
            WIN.BackgroundColor3=T.BG
            TB.BackgroundColor3=T.Surface
            SB.BackgroundColor3=T.Surface
        end
    end)
    addSld(si,"UI Opacity",40,100,100,function(v)
        WIN.BackgroundTransparency=1-(v/100)*0.98 end)

    -- Server
    local ss=sec(sc,"SERVER")
    addBtn(ss,"Rejoin","Reconnect to this server",function()
        notify("Rejoining...","Teleporting in 2s","info",2)
        spawn(function() wait(2); rejoin() end) end)
    addBtn(ss,"Server Hop","Join a different server",function()
        notify("Server Hop","Teleporting to new server...","info",2)
        spawn(function() wait(1.5); serverHop() end) end)
    addBtn(ss,"Copy Join Link","Copy game URL to clipboard",function()
        copyJoinLink()
        notify("Copied","Join link in clipboard","ok",2.5) end)

    local _,_,placeIdTb = addInp(ss,"Place Teleport",tostring(game.PlaceId),function(v)
        placeIdTarget=tonumber(v) or game.PlaceId end)
    addBtn(ss,"Teleport to Place","Teleport to entered PlaceID",function()
        local id=tonumber(placeIdTb.Text) or placeIdTarget
        notify("Teleporting","To Place: "..tostring(id),"info",2)
        spawn(function() wait(1.5); TeleportService:Teleport(id,LP) end) end)
end

-- ══════════════════════════════════════════════════
--  REGISTER DEFAULT KEYBINDS
-- ══════════════════════════════════════════════════
local shown=true
local function hideWin()
    shown=false; tw(WIN,{Size=UDim2.new(0,600,0,0),BackgroundTransparency=1},S)
    spawn(function() wait(S+0.06); WIN.Visible=false end)
end
local function showWin()
    shown=true; WIN.Visible=true
    tw(WIN,{Size=UDim2.new(0,600,0,450),BackgroundTransparency=0},
        0.38,Enum.EasingStyle.Back,Enum.EasingDirection.Out)
end
kbBind("hub", Enum.KeyCode.M, function()
    if shown then hideWin() else showWin() end
end)

-- ══════════════════════════════════════════════════
--  WINDOW CONTROLS
-- ══════════════════════════════════════════════════
switchTab("Main")

local minimized=false
MBTN.MouseButton1Click:Connect(function()
    minimized=not minimized
    tw(WIN,{Size=minimized and UDim2.new(0,600,0,50) or UDim2.new(0,600,0,450)},
        S,Enum.EasingStyle.Quart)
end)
CBTN.MouseButton1Click:Connect(hideWin)

-- ══════════════════════════════════════════════════
--  OPEN ANIMATION
-- ══════════════════════════════════════════════════
WIN.Size=UDim2.new(0,600,0,0)
WIN.BackgroundTransparency=1
spawn(function()
    wait(0.25)
    tw(WIN,{Size=UDim2.new(0,600,0,450),BackgroundTransparency=0},
        0.42,Enum.EasingStyle.Back,Enum.EasingDirection.Out)
    wait(0.6)
    notify("ScriptHub","Loaded  •  M to toggle","ok",4)
end)
