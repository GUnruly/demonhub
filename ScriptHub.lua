-- ═══════════════════════════════════════════════════
--   ScriptHub  |  Custom UI  |  No Libraries
-- ═══════════════════════════════════════════════════

local Players          = game:GetService("Players")
local TweenService     = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")
local RunService       = game:GetService("RunService")

local LP   = Players.LocalPlayer
local PGui = LP:WaitForChild("PlayerGui")

-- ── Theme ──────────────────────────────────────────
local T = {
    BG          = Color3.fromRGB(10,  10,  16),
    Surface     = Color3.fromRGB(17,  17,  27),
    Card        = Color3.fromRGB(22,  22,  34),
    CardH       = Color3.fromRGB(28,  28,  44),
    Accent      = Color3.fromRGB(112, 72,  255),
    AccentD     = Color3.fromRGB(80,  48,  200),
    AccentL     = Color3.fromRGB(165, 115, 255),
    Text        = Color3.fromRGB(235, 235, 255),
    Muted       = Color3.fromRGB(105, 105, 145),
    Border      = Color3.fromRGB(38,  38,  58),
    Track       = Color3.fromRGB(44,  44,  68),
    White       = Color3.fromRGB(255, 255, 255),
    StatBG      = Color3.fromRGB(12,  12,  20),
    Green       = Color3.fromRGB(72,  200, 130),
    Yellow      = Color3.fromRGB(255, 185, 50),
    Red         = Color3.fromRGB(255, 75,  75),
}
local FN  = Enum.Font.GothamMedium
local FNB = Enum.Font.GothamBold
local S   = 0.18
local SF  = 0.10

-- ── Helpers ────────────────────────────────────────
local function tw(o, p, d, st, di)
    TweenService:Create(o,
        TweenInfo.new(d or S,
            st or Enum.EasingStyle.Quart,
            di or Enum.EasingDirection.Out), p):Play()
end

local function mk(cls, t)
    local o = Instance.new(cls)
    for k,v in pairs(t) do if k~="Parent" then o[k]=v end end
    if t.Parent then o.Parent=t.Parent end
    return o
end

local function rnd(p, r)
    local c = Instance.new("UICorner")
    c.CornerRadius = UDim.new(0, r or 8); c.Parent = p; return c
end

local function bdr(p, col, th)
    local s = Instance.new("UIStroke")
    s.Color = col or T.Border; s.Thickness = th or 1
    s.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
    s.Parent = p; return s
end

local function grd(p, c0, c1, rot)
    local g = Instance.new("UIGradient")
    g.Color = ColorSequence.new(c0, c1)
    g.Rotation = rot or 135; g.Parent = p; return g
end

-- ══════════════════════════════════════════════════
--  ROOT  (notifications + watermark live here,
--  outside WIN so they're never clipped)
-- ══════════════════════════════════════════════════
local GUI = mk("ScreenGui", {
    Name="ScriptHub", ResetOnSpawn=false,
    ZIndexBehavior=Enum.ZIndexBehavior.Sibling,
    IgnoreGuiInset=true, Parent=PGui,
})

-- Overlay layer: dropdown popups parent here so they
-- escape WIN's ClipsDescendants.  It's a Frame so it
-- does NOT steal mouse events from siblings below.
local OVL = mk("Frame", {
    BackgroundTransparency=1,
    Size=UDim2.new(1,0,1,0),
    ZIndex=80, Parent=GUI,
})

-- ══════════════════════════════════════════════════
--  NOTIFICATIONS
-- ══════════════════════════════════════════════════
local NBOX = mk("Frame", {
    BackgroundTransparency=1,
    AnchorPoint=Vector2.new(1,1),
    Position=UDim2.new(1,-14,1,-14),
    Size=UDim2.new(0,270,1,0),
    ZIndex=90, Parent=GUI,
})
mk("UIListLayout",{
    FillDirection=Enum.FillDirection.Vertical,
    VerticalAlignment=Enum.VerticalAlignment.Bottom,
    HorizontalAlignment=Enum.HorizontalAlignment.Right,
    Padding=UDim.new(0,6), Parent=NBOX,
})

local NT = {
    ok   = {Color3.fromRGB(72,200,130), "✓"},
    err  = {Color3.fromRGB(255,75,75),  "✕"},
    warn = {Color3.fromRGB(255,185,50), "!"},
    info = {Color3.fromRGB(112,72,255), "i"},
}

local function notify(title, msg, kind, dur)
    local n = NT[kind or "info"] or NT.info
    dur = dur or 3

    local card = mk("Frame",{
        BackgroundColor3=Color3.fromRGB(16,16,28),
        Size=UDim2.new(1,0,0,66),
        Position=UDim2.new(1,30,0,0),
        ZIndex=91, ClipsDescendants=true, Parent=NBOX,
    }); rnd(card,10); bdr(card,Color3.fromRGB(36,36,54))

    mk("Frame",{BackgroundColor3=n[1],
        Size=UDim2.new(0,3,1,0), ZIndex=92, Parent=card})

    local badge=mk("Frame",{BackgroundColor3=n[1],
        Position=UDim2.new(0,12,0.5,-11),
        Size=UDim2.new(0,22,0,22), ZIndex=92, Parent=card})
    rnd(badge,6)
    mk("TextLabel",{BackgroundTransparency=1, Size=UDim2.new(1,0,1,0),
        Text=n[2], TextColor3=T.White, TextSize=13, Font=FNB,
        ZIndex=93, Parent=badge})

    mk("TextLabel",{BackgroundTransparency=1,
        Position=UDim2.new(0,42,0,10), Size=UDim2.new(1,-52,0,18),
        Text=title, TextColor3=T.Text, TextSize=13, Font=FNB,
        TextXAlignment=Enum.TextXAlignment.Left, ZIndex=92, Parent=card})
    mk("TextLabel",{BackgroundTransparency=1,
        Position=UDim2.new(0,42,0,29), Size=UDim2.new(1,-52,0,28),
        Text=msg or "", TextColor3=T.Muted, TextSize=11, Font=FN,
        TextXAlignment=Enum.TextXAlignment.Left,
        TextWrapped=true, ZIndex=92, Parent=card})

    local prog=mk("Frame",{BackgroundColor3=n[1],
        BackgroundTransparency=0.45,
        Position=UDim2.new(0,0,1,-3),
        Size=UDim2.new(1,0,0,3), ZIndex=93, Parent=card})

    tw(card,{Position=UDim2.new(0,0,0,0)}, S, Enum.EasingStyle.Back, Enum.EasingDirection.Out)
    tw(prog,{Size=UDim2.new(0,0,0,3)}, dur-0.25, Enum.EasingStyle.Linear)
    spawn(function()
        wait(dur)
        tw(card,{Position=UDim2.new(1,30,0,0)}, S)
        wait(S+0.06); card:Destroy()
    end)
end

-- ══════════════════════════════════════════════════
--  WATERMARK
-- ══════════════════════════════════════════════════
local WM = mk("Frame",{
    BackgroundColor3=Color3.fromRGB(12,12,20),
    BackgroundTransparency=0.15,
    Position=UDim2.new(0,12,0,12),
    Size=UDim2.new(0,214,0,27),
    ZIndex=20, Parent=GUI,
})
rnd(WM,6); bdr(WM)

local WMDOT = mk("Frame",{BackgroundColor3=T.Accent,
    Position=UDim2.new(0,10,0.5,-4),
    Size=UDim2.new(0,8,0,8), ZIndex=21, Parent=WM})
rnd(WMDOT,4)

mk("TextLabel",{BackgroundTransparency=1,
    Position=UDim2.new(0,26,0,0),
    Size=UDim2.new(1,-30,1,0),
    Text="ScriptHub  •  "..LP.Name,
    TextColor3=T.Muted, TextSize=11, Font=FN,
    TextXAlignment=Enum.TextXAlignment.Left,
    ZIndex=21, Parent=WM})

do  -- watermark drag
    local d,ds,sp=false
    WM.InputBegan:Connect(function(i)
        if i.UserInputType==Enum.UserInputType.MouseButton1 then
            d=true; ds=i.Position; sp=WM.Position end
    end)
    UserInputService.InputChanged:Connect(function(i)
        if d and i.UserInputType==Enum.UserInputType.MouseMovement then
            local v=i.Position-ds
            WM.Position=UDim2.new(sp.X.Scale,sp.X.Offset+v.X,
                                   sp.Y.Scale,sp.Y.Offset+v.Y) end
    end)
    UserInputService.InputEnded:Connect(function(i)
        if i.UserInputType==Enum.UserInputType.MouseButton1 then d=false end
    end)
end

RunService.Heartbeat:Connect(function()
    WMDOT.BackgroundTransparency = 0.1 + math.abs(math.sin(tick()*math.pi*0.55))*0.65
end)

-- ══════════════════════════════════════════════════
--  MAIN WINDOW
--  Layout: 600 × 450
--  Titlebar  : y=0   h=50
--  Sidebar   : x=0   w=152  y=50 h=368
--  Content   : x=152 w=448  y=50 h=368
--  Status bar: y=418 h=32
-- ══════════════════════════════════════════════════
local WIN = mk("Frame",{
    Name="Window", AnchorPoint=Vector2.new(0.5,0.5),
    BackgroundColor3=T.BG,
    Position=UDim2.new(0.5,0,0.5,0),
    Size=UDim2.new(0,600,0,450),
    ZIndex=10, ClipsDescendants=true, Parent=GUI,
})
rnd(WIN,12); bdr(WIN)
grd(WIN, Color3.fromRGB(18,12,34), T.BG, 145)

-- ── Title Bar ──────────────────────────────────────
local TB = mk("Frame",{
    BackgroundColor3=T.Surface,
    Size=UDim2.new(1,0,0,50),
    ZIndex=11, Parent=WIN,
})
rnd(TB,12)
-- fill bottom-rounded-corners of titlebar so it blends
mk("Frame",{BackgroundColor3=T.Surface,
    Position=UDim2.new(0,0,0.5,0),
    Size=UDim2.new(1,0,0.5,0),
    ZIndex=11, Parent=TB})
grd(TB, Color3.fromRGB(20,14,38), T.Surface, 0)

-- accent underline
local ALINE = mk("Frame",{BackgroundColor3=T.Accent,
    Position=UDim2.new(0,0,1,-2),
    Size=UDim2.new(1,0,0,2), ZIndex=12, Parent=TB})
grd(ALINE, T.AccentL, T.AccentD, 0)

-- logo badge
local LOGO = mk("Frame",{BackgroundColor3=T.Accent,
    Position=UDim2.new(0,14,0.5,-14),
    Size=UDim2.new(0,28,0,28), ZIndex=12, Parent=TB})
rnd(LOGO,8); grd(LOGO, T.AccentL, T.AccentD, 135)
mk("TextLabel",{BackgroundTransparency=1,
    Size=UDim2.new(1,0,1,0), Text="S",
    TextColor3=T.White, TextSize=16, Font=FNB,
    ZIndex=13, Parent=LOGO})

-- title / subtitle
mk("TextLabel",{BackgroundTransparency=1,
    Position=UDim2.new(0,50,0,7), Size=UDim2.new(0,180,0,19),
    Text="ScriptHub", TextColor3=T.Text, TextSize=15, Font=FNB,
    TextXAlignment=Enum.TextXAlignment.Left, ZIndex=12, Parent=TB})
mk("TextLabel",{BackgroundTransparency=1,
    Position=UDim2.new(0,50,0,27), Size=UDim2.new(0,180,0,14),
    Text="v1.0  •  Free", TextColor3=T.Muted, TextSize=10, Font=FN,
    TextXAlignment=Enum.TextXAlignment.Left, ZIndex=12, Parent=TB})

-- ┌─ Window controls ─────────────────────────────┐
--  ZIndex 14 so they sit ABOVE the drag handle (13)
local CBTN = mk("TextButton",{
    AnchorPoint=Vector2.new(1,0.5),
    BackgroundColor3=T.Red,
    Position=UDim2.new(1,-14,0.5,0),
    Size=UDim2.new(0,13,0,13),
    Text="", ZIndex=14, Parent=TB})
rnd(CBTN,7)
CBTN.MouseEnter:Connect(function() tw(CBTN,{BackgroundTransparency=0.35},SF) end)
CBTN.MouseLeave:Connect(function() tw(CBTN,{BackgroundTransparency=0},SF) end)

local MBTN = mk("TextButton",{
    AnchorPoint=Vector2.new(1,0.5),
    BackgroundColor3=T.Yellow,
    Position=UDim2.new(1,-34,0.5,0),
    Size=UDim2.new(0,13,0,13),
    Text="", ZIndex=14, Parent=TB})
rnd(MBTN,7)
MBTN.MouseEnter:Connect(function() tw(MBTN,{BackgroundTransparency=0.35},SF) end)
MBTN.MouseLeave:Connect(function() tw(MBTN,{BackgroundTransparency=0},SF) end)

-- ┌─ Drag handle ──────────────────────────────────┐
--  Transparent TextButton covering the title bar,
--  stops before the control buttons (right ~55px).
--  ZIndex 13 = above decorations (12) but below
--  controls (14), so controls still receive clicks.
local DRAG = mk("TextButton",{
    BackgroundTransparency=1,
    Size=UDim2.new(1,-55,1,0),
    Text="", ZIndex=13, Parent=TB,
})

do  -- drag logic uses UserInputService for movement
    local drag=false; local ds; local wp
    DRAG.MouseButton1Down:Connect(function()
        drag=true
        ds=UserInputService:GetMouseLocation()
        wp=WIN.Position
    end)
    UserInputService.InputEnded:Connect(function(i)
        if i.UserInputType==Enum.UserInputType.MouseButton1 then
            drag=false end
    end)
    UserInputService.InputChanged:Connect(function(i)
        if drag and i.UserInputType==Enum.UserInputType.MouseMovement then
            local d=UserInputService:GetMouseLocation()-ds
            WIN.Position=UDim2.new(wp.X.Scale, wp.X.Offset+d.X,
                                    wp.Y.Scale, wp.Y.Offset+d.Y)
        end
    end)
end

-- ── Sidebar ────────────────────────────────────────
local SB = mk("Frame",{
    BackgroundColor3=T.Surface,
    Position=UDim2.new(0,0,0,50),
    Size=UDim2.new(0,152,0,368),    -- 50+368+32 = 450 ✓
    ZIndex=11, Parent=WIN,
})
grd(SB, T.Surface, Color3.fromRGB(13,13,22), 90)
mk("Frame",{BackgroundColor3=T.Border,  -- right separator
    AnchorPoint=Vector2.new(1,0),
    Position=UDim2.new(1,0,0,0),
    Size=UDim2.new(0,1,1,0),
    ZIndex=12, Parent=SB})

-- tab indicator pill (slides between tabs)
local IND = mk("Frame",{BackgroundColor3=T.Accent,
    Size=UDim2.new(0,3,0,28),
    Position=UDim2.new(0,0,0,18),
    ZIndex=14, Parent=SB})
rnd(IND,2)

-- tab list (all buttons go here)
local TLIST = mk("Frame",{
    BackgroundTransparency=1,
    Size=UDim2.new(1,0,1,0),
    ZIndex=12, Parent=SB,
})
do
    local u=Instance.new("UIPadding")
    u.PaddingTop=UDim.new(0,10); u.PaddingBottom=UDim.new(0,10)
    u.PaddingLeft=UDim.new(0,9); u.PaddingRight=UDim.new(0,9)
    u.Parent=TLIST
end
mk("UIListLayout",{
    FillDirection=Enum.FillDirection.Vertical,
    Padding=UDim.new(0,3), Parent=TLIST,
})

-- ── Content area ───────────────────────────────────
local CA = mk("Frame",{
    BackgroundTransparency=1,
    Position=UDim2.new(0,152,0,50),
    Size=UDim2.new(0,448,0,368),
    ZIndex=11, Parent=WIN,
})

-- ── Status bar ─────────────────────────────────────
local STAT = mk("Frame",{
    BackgroundColor3=T.StatBG,
    Position=UDim2.new(0,0,0,418),
    Size=UDim2.new(1,0,0,32),
    ZIndex=12, Parent=WIN,
})
mk("Frame",{BackgroundColor3=T.Border,
    Size=UDim2.new(1,0,0,1),
    ZIndex=13, Parent=STAT})

local FPS_LBL = mk("TextLabel",{BackgroundTransparency=1,
    Position=UDim2.new(0,12,0,0), Size=UDim2.new(0,72,1,0),
    Text="FPS: --", TextColor3=T.Muted, TextSize=10, Font=FN,
    TextXAlignment=Enum.TextXAlignment.Left, ZIndex=13, Parent=STAT})

local ACT_LBL = mk("TextLabel",{BackgroundTransparency=1,
    Position=UDim2.new(0,88,0,0), Size=UDim2.new(0,130,1,0),
    Text="○  0 active", TextColor3=T.Muted, TextSize=10, Font=FN,
    TextXAlignment=Enum.TextXAlignment.Left, ZIndex=13, Parent=STAT})

mk("TextLabel",{BackgroundTransparency=1,
    AnchorPoint=Vector2.new(1,0.5),
    Position=UDim2.new(1,-12,0.5,0), Size=UDim2.new(0,120,1,0),
    Text="INSERT  to toggle", TextColor3=T.Muted,
    TextSize=10, Font=FN,
    TextXAlignment=Enum.TextXAlignment.Right,
    ZIndex=13, Parent=STAT})

-- FPS counter
do
    local buf={}
    RunService.Heartbeat:Connect(function(dt)
        buf[#buf+1]=1/dt
        if #buf>30 then table.remove(buf,1) end
        local s=0; for _,v in ipairs(buf) do s=s+v end
        local f=math.round(s/#buf)
        FPS_LBL.Text="FPS: "..f
        FPS_LBL.TextColor3 = f>=55 and T.Green or f>=30 and T.Yellow or T.Red
    end)
end

local activeN=0
local function setActive(d)
    activeN=math.max(0,activeN+d)
    ACT_LBL.Text=(activeN>0 and "●  " or "○  ")..activeN.." active"
    ACT_LBL.TextColor3=activeN>0 and T.AccentL or T.Muted
end

-- ══════════════════════════════════════════════════
--  TAB SYSTEM
-- ══════════════════════════════════════════════════
local BTN_H = 36   -- tab button height
local BTN_G = 3    -- gap between buttons
local PAD_T = 10   -- top padding of TLIST
local IND_H = 28

local function indY(idx)   -- indicator Y for tab index
    return PAD_T + idx*(BTN_H+BTN_G) + (BTN_H-IND_H)/2
end

local Tabs={}; local CurTab=nil

local function switchTab(id)
    local tab=Tabs[id]
    if not tab or CurTab==id then return end
    if CurTab then
        local old=Tabs[CurTab]
        tw(old.btn,{BackgroundTransparency=1,BackgroundColor3=T.Card}, S)
        tw(old.ico,{TextColor3=T.Muted}, S)
        tw(old.lbl,{TextColor3=T.Muted}, S)
        old.page.Visible=false
    end
    CurTab=id
    tw(tab.btn,{BackgroundTransparency=0,
        BackgroundColor3=Color3.fromRGB(28,18,54)}, S)
    tw(tab.ico,{TextColor3=T.AccentL}, S)
    tw(tab.lbl,{TextColor3=T.Text}, S)
    tab.page.Visible=true
    tw(IND,{Position=UDim2.new(0,0,0,indY(tab.idx))}, S)
end

local TDEFS={
    {id="Main",   lbl="Main",   ico="▸"},
    {id="Visual", lbl="Visual", ico="◈"},
    {id="World",  lbl="World",  ico="◉"},
    {id="Player", lbl="Player", ico="◎"},
    {id="Misc",   lbl="Misc",   ico="⊞"},
}

for i,def in ipairs(TDEFS) do
    local idx=i-1

    local btn=mk("TextButton",{
        BackgroundColor3=T.Card,
        BackgroundTransparency=1,
        Size=UDim2.new(1,0,0,BTN_H),
        Text="", ZIndex=12, Parent=TLIST,
    }); rnd(btn,6)

    local ico=mk("TextLabel",{BackgroundTransparency=1,
        Position=UDim2.new(0,8,0,0), Size=UDim2.new(0,20,1,0),
        Text=def.ico, TextColor3=T.Muted, TextSize=13, Font=FN,
        ZIndex=13, Parent=btn})

    local lbl=mk("TextLabel",{BackgroundTransparency=1,
        Position=UDim2.new(0,32,0,0), Size=UDim2.new(1,-32,1,0),
        Text=def.lbl, TextColor3=T.Muted, TextSize=12, Font=FN,
        TextXAlignment=Enum.TextXAlignment.Left,
        ZIndex=13, Parent=btn})

    -- scroll page (visible area for tab content)
    local page=mk("Frame",{
        BackgroundTransparency=1,
        Size=UDim2.new(1,0,1,0),
        Visible=false, ZIndex=12, Parent=CA,
    })
    local scroll=mk("ScrollingFrame",{
        BackgroundTransparency=1,
        Size=UDim2.new(1,0,1,0),
        ScrollBarThickness=3,
        ScrollBarImageColor3=T.Accent,
        CanvasSize=UDim2.new(0,0,0,0),
        AutomaticCanvasSize=Enum.AutomaticSize.Y,
        ZIndex=12, Parent=page,
    })
    do
        local u=Instance.new("UIPadding")
        u.PaddingTop=UDim.new(0,12); u.PaddingBottom=UDim.new(0,12)
        u.PaddingLeft=UDim.new(0,12); u.PaddingRight=UDim.new(0,14)
        u.Parent=scroll
    end
    mk("UIListLayout",{
        FillDirection=Enum.FillDirection.Vertical,
        Padding=UDim.new(0,9),
        SortOrder=Enum.SortOrder.LayoutOrder,
        Parent=scroll,
    })

    Tabs[def.id]={btn=btn,ico=ico,lbl=lbl,page=page,scroll=scroll,idx=idx}

    btn.MouseButton1Click:Connect(function() switchTab(def.id) end)
    btn.MouseEnter:Connect(function()
        if CurTab~=def.id then
            tw(btn,{BackgroundTransparency=0.85},SF) end
    end)
    btn.MouseLeave:Connect(function()
        if CurTab~=def.id then
            tw(btn,{BackgroundTransparency=1},SF) end
    end)
end

-- ══════════════════════════════════════════════════
--  COMPONENT BUILDERS
-- ══════════════════════════════════════════════════

-- Section card — returns the items Frame
local function sec(parent, title)
    local card=mk("Frame",{
        BackgroundColor3=T.Card,
        Size=UDim2.new(1,0,0,0),
        AutomaticSize=Enum.AutomaticSize.Y,
        ZIndex=13, Parent=parent,
    }); rnd(card,8); bdr(card,T.Border)

    -- header row (32px)
    local hdr=mk("Frame",{BackgroundTransparency=1,
        Position=UDim2.new(0,0,0,0),
        Size=UDim2.new(1,0,0,32),
        ZIndex=14, Parent=card})
    local pill=mk("Frame",{BackgroundColor3=T.Accent,
        Position=UDim2.new(0,10,0.5,-7),
        Size=UDim2.new(0,3,0,14),
        ZIndex=15, Parent=hdr}); rnd(pill,2)
    mk("TextLabel",{BackgroundTransparency=1,
        Position=UDim2.new(0,20,0,0),
        Size=UDim2.new(1,-20,1,0),
        Text=title, TextColor3=T.Muted, TextSize=10, Font=FNB,
        TextXAlignment=Enum.TextXAlignment.Left,
        ZIndex=15, Parent=hdr})

    -- separator line
    mk("Frame",{BackgroundColor3=T.Border,
        Position=UDim2.new(0,0,0,31),
        Size=UDim2.new(1,0,0,1),
        ZIndex=14, Parent=card})

    -- items container (starts below header + sep)
    local items=mk("Frame",{BackgroundTransparency=1,
        Position=UDim2.new(0,8,0,36),
        Size=UDim2.new(1,-16,0,0),
        AutomaticSize=Enum.AutomaticSize.Y,
        ZIndex=14, Parent=card})
    mk("UIListLayout",{
        FillDirection=Enum.FillDirection.Vertical,
        Padding=UDim.new(0,3),
        SortOrder=Enum.SortOrder.LayoutOrder,
        Parent=items})
    -- 10px bottom padding via a spacer
    local _ord=0
    local function nextOrd() _ord=_ord+1; return _ord end
    return items, nextOrd
end

-- Base row (surface card + hover glow)
local function row(parent, h)
    local r=mk("Frame",{
        BackgroundColor3=T.Surface,
        Size=UDim2.new(1,0,0,h or 46),
        ZIndex=15, Parent=parent,
    }); rnd(r,6); bdr(r,Color3.fromRGB(28,28,46))
    -- hover: use a full-cover transparent button that sits BELOW
    -- interactive children; it only handles enter/leave, not clicks
    local hov=mk("TextButton",{
        BackgroundTransparency=1,
        Size=UDim2.new(1,0,1,0),
        Text="", ZIndex=15, Parent=r,
    })
    hov.MouseEnter:Connect(function() tw(r,{BackgroundColor3=T.CardH},SF) end)
    hov.MouseLeave:Connect(function() tw(r,{BackgroundColor3=T.Surface},SF) end)
    return r
end

-- name + optional desc labels in a row
local function rowLbls(r, name, desc)
    mk("TextLabel",{BackgroundTransparency=1,
        Position=UDim2.new(0,12,0,desc and 5 or 13),
        Size=UDim2.new(0.6,0,0,18),
        Text=name, TextColor3=T.Text, TextSize=13, Font=FN,
        TextXAlignment=Enum.TextXAlignment.Left,
        ZIndex=17, Parent=r})
    if desc then
        mk("TextLabel",{BackgroundTransparency=1,
            Position=UDim2.new(0,12,0,24),
            Size=UDim2.new(0.6,0,0,14),
            Text=desc, TextColor3=T.Muted, TextSize=10, Font=FN,
            TextXAlignment=Enum.TextXAlignment.Left,
            ZIndex=17, Parent=r})
    end
end

-- ── Button ─────────────────────────────────────────
local function addBtn(parent, name, desc, cb)
    local r=row(parent,46); rowLbls(r,name,desc)

    local b=mk("TextButton",{
        AnchorPoint=Vector2.new(1,0.5),
        BackgroundColor3=T.Accent,
        Position=UDim2.new(1,-11,0.5,0),
        Size=UDim2.new(0,76,0,27),
        Text="Run", TextColor3=T.White,
        TextSize=12, Font=FNB, ZIndex=18, Parent=r,
    }); rnd(b,6); grd(b, T.AccentL, T.AccentD, 90)

    b.MouseEnter:Connect(function()    tw(b,{Size=UDim2.new(0,80,0,29)},SF) end)
    b.MouseLeave:Connect(function()    tw(b,{Size=UDim2.new(0,76,0,27)},SF) end)
    b.MouseButton1Down:Connect(function()  tw(b,{Size=UDim2.new(0,72,0,25)},0.07) end)
    b.MouseButton1Up:Connect(function()    tw(b,{Size=UDim2.new(0,76,0,27)},SF) end)
    b.MouseButton1Click:Connect(function()
        notify(name,"Executed successfully","ok",2.5)
        if cb then cb() end
    end)
    return r
end

-- ── Toggle ─────────────────────────────────────────
local function addTgl(parent, name, desc, def, cb)
    local state=(def==true)
    local r=row(parent,46); rowLbls(r,name,desc)

    local track=mk("Frame",{
        AnchorPoint=Vector2.new(1,0.5),
        BackgroundColor3=state and T.Accent or T.Track,
        Position=UDim2.new(1,-12,0.5,0),
        Size=UDim2.new(0,44,0,24), ZIndex=17, Parent=r,
    }); rnd(track,12)

    local knob=mk("Frame",{
        AnchorPoint=Vector2.new(0,0.5),
        BackgroundColor3=T.White,
        Position=UDim2.new(0,state and 22 or 2,0.5,0),
        Size=UDim2.new(0,20,0,20), ZIndex=18, Parent=track,
    }); rnd(knob,10)

    -- hitbox button ON TOP of track (ZIndex 19 > knob 18)
    local hit=mk("TextButton",{
        BackgroundTransparency=1,
        Size=UDim2.new(1,0,1,0),
        Text="", ZIndex=19, Parent=track,
    })
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

-- ── Slider ─────────────────────────────────────────
local function addSld(parent, name, mn, mx, def, cb)
    local v=def or mn; local drag=false
    local r=row(parent,54)

    mk("TextLabel",{BackgroundTransparency=1,
        Position=UDim2.new(0,12,0,7),
        Size=UDim2.new(0.68,0,0,16),
        Text=name, TextColor3=T.Text, TextSize=13, Font=FN,
        TextXAlignment=Enum.TextXAlignment.Left,
        ZIndex=17, Parent=r})

    local vLbl=mk("TextLabel",{
        AnchorPoint=Vector2.new(1,0),
        BackgroundTransparency=1,
        Position=UDim2.new(1,-12,0,7),
        Size=UDim2.new(0,52,0,16),
        Text=tostring(v), TextColor3=T.AccentL,
        TextSize=12, Font=FNB,
        TextXAlignment=Enum.TextXAlignment.Right,
        ZIndex=17, Parent=r})

    local track=mk("Frame",{BackgroundColor3=T.Track,
        Position=UDim2.new(0,12,0,34),
        Size=UDim2.new(1,-24,0,6), ZIndex=16, Parent=r})
    rnd(track,3)

    local pct=(v-mn)/(mx-mn)
    local fill=mk("Frame",{BackgroundColor3=T.Accent,
        Size=UDim2.new(pct,0,1,0), ZIndex=17, Parent=track})
    rnd(fill,3); grd(fill, T.AccentL, T.AccentD, 0)

    local knob=mk("Frame",{
        AnchorPoint=Vector2.new(0.5,0.5),
        BackgroundColor3=T.White,
        Position=UDim2.new(pct,0,0.5,0),
        Size=UDim2.new(0,14,0,14), ZIndex=18, Parent=track})
    rnd(knob,7); bdr(knob, T.Accent, 2)

    -- wide invisible hit area (ZIndex 19)
    local hit=mk("TextButton",{
        BackgroundTransparency=1,
        Position=UDim2.new(0,-8,0,-8),
        Size=UDim2.new(1,16,1,16),
        Text="", ZIndex=19, Parent=track})

    local function upd(x)
        local rel=math.clamp((x-track.AbsolutePosition.X)/track.AbsoluteSize.X,0,1)
        v=math.round(mn+(mx-mn)*rel)
        local p=(v-mn)/(mx-mn)
        tw(fill,{Size=UDim2.new(p,0,1,0)},0.05)
        tw(knob,{Position=UDim2.new(p,0,0.5,0)},0.05)
        vLbl.Text=tostring(v)
        if cb then cb(v) end
    end

    hit.MouseButton1Down:Connect(function(x) drag=true; upd(x) end)
    UserInputService.InputChanged:Connect(function(i)
        if drag and i.UserInputType==Enum.UserInputType.MouseMovement then
            upd(i.Position.X) end
    end)
    UserInputService.InputEnded:Connect(function(i)
        if i.UserInputType==Enum.UserInputType.MouseButton1 then drag=false end
    end)
    return r, function() return v end
end

-- ── Dropdown ───────────────────────────────────────
local openDD=nil

local function addDD(parent, name, opts, def, cb)
    local sel=def or opts[1]; local open=false
    local r=row(parent,46)

    mk("TextLabel",{BackgroundTransparency=1,
        Position=UDim2.new(0,12,0,13),
        Size=UDim2.new(0.44,0,0,18),
        Text=name, TextColor3=T.Text, TextSize=13, Font=FN,
        TextXAlignment=Enum.TextXAlignment.Left,
        ZIndex=17, Parent=r})

    local box=mk("Frame",{
        AnchorPoint=Vector2.new(1,0.5),
        BackgroundColor3=T.BG,
        Position=UDim2.new(1,-11,0.5,0),
        Size=UDim2.new(0,130,0,27), ZIndex=17, Parent=r})
    rnd(box,6); bdr(box)

    local selLbl=mk("TextLabel",{BackgroundTransparency=1,
        Position=UDim2.new(0,9,0,0), Size=UDim2.new(1,-26,1,0),
        Text=sel, TextColor3=T.Text, TextSize=12, Font=FN,
        TextXAlignment=Enum.TextXAlignment.Left,
        ZIndex=18, Parent=box})

    local arr=mk("TextLabel",{
        AnchorPoint=Vector2.new(1,0.5),
        BackgroundTransparency=1,
        Position=UDim2.new(1,-7,0.5,0),
        Size=UDim2.new(0,14,0,14),
        Text="▾", TextColor3=T.Muted, TextSize=11, Font=FN,
        ZIndex=18, Parent=box})

    -- Popup lives in OVL so it escapes WIN clipping
    local OPH=27
    local maxV=math.min(#opts,5)
    local pop=mk("Frame",{
        BackgroundColor3=Color3.fromRGB(18,18,30),
        Size=UDim2.new(0,130,0,0),
        ZIndex=95, Visible=false, ClipsDescendants=true, Parent=OVL})
    rnd(pop,7); bdr(pop)

    local plist=mk("Frame",{BackgroundTransparency=1,
        Size=UDim2.new(1,0,0,0),
        AutomaticSize=Enum.AutomaticSize.Y,
        ZIndex=96, Parent=pop})
    mk("UIListLayout",{Padding=UDim.new(0,2), Parent=plist})
    do
        local u=Instance.new("UIPadding")
        u.PaddingTop=UDim.new(0,4); u.PaddingBottom=UDim.new(0,4)
        u.PaddingLeft=UDim.new(0,4); u.PaddingRight=UDim.new(0,4)
        u.Parent=plist
    end

    local function buildPop()
        for _,opt in ipairs(opts) do
            local isA=(opt==sel)
            local ob=mk("TextButton",{
                BackgroundColor3=isA and Color3.fromRGB(28,18,52) or T.BG,
                BackgroundTransparency=isA and 0 or 1,
                Size=UDim2.new(1,0,0,OPH), Text="",
                ZIndex=97, Parent=plist})
            rnd(ob,5)
            mk("TextLabel",{BackgroundTransparency=1,
                Position=UDim2.new(0,9,0,0),
                Size=UDim2.new(1,-9,1,0),
                Text=opt,
                TextColor3=isA and T.AccentL or T.Text,
                TextSize=12, Font=isA and FNB or FN,
                TextXAlignment=Enum.TextXAlignment.Left,
                ZIndex=98, Parent=ob})
            ob.MouseEnter:Connect(function()
                if not isA then
                    tw(ob,{BackgroundTransparency=0.82,
                        BackgroundColor3=T.Card},SF) end
            end)
            ob.MouseLeave:Connect(function()
                if not isA then tw(ob,{BackgroundTransparency=1},SF) end
            end)
            ob.MouseButton1Click:Connect(function()
                sel=opt; selLbl.Text=opt; open=false
                tw(pop,{Size=UDim2.new(0,130,0,0)},SF)
                tw(arr,{Rotation=0},SF)
                spawn(function() wait(SF+0.05); pop.Visible=false end)
                openDD=nil
                for _,c in ipairs(plist:GetChildren()) do
                    if c:IsA("TextButton") then c:Destroy() end
                end
                buildPop()
                if cb then cb(sel) end
            end)
        end
    end
    buildPop()

    local tgtH=OPH*maxV+8+(maxV-1)*2+8

    local function openPop()
        if openDD and openDD~=pop then
            tw(openDD,{Size=UDim2.new(0,130,0,0)},SF)
            spawn(function() wait(SF+0.05); openDD.Visible=false end)
        end
        local ap=box.AbsolutePosition; local as=box.AbsoluteSize
        pop.Position=UDim2.new(0,ap.X,0,ap.Y+as.Y+4)
        pop.Visible=true
        tw(pop,{Size=UDim2.new(0,130,0,tgtH)},S,
            Enum.EasingStyle.Back, Enum.EasingDirection.Out)
        tw(arr,{Rotation=180},SF)
        openDD=pop; open=true
    end
    local function closePop()
        tw(pop,{Size=UDim2.new(0,130,0,0)},SF)
        tw(arr,{Rotation=0},SF)
        spawn(function() wait(SF+0.05); pop.Visible=false end)
        openDD=nil; open=false
    end

    local hitBtn=mk("TextButton",{BackgroundTransparency=1,
        Size=UDim2.new(1,0,1,0), Text="", ZIndex=19, Parent=box})
    hitBtn.MouseButton1Click:Connect(function()
        if open then closePop() else openPop() end
    end)
    UserInputService.InputBegan:Connect(function(i)
        if not open then return end
        if i.UserInputType~=Enum.UserInputType.MouseButton1 then return end
        local mx,my=i.Position.X,i.Position.Y
        local pp,ps=pop.AbsolutePosition,pop.AbsoluteSize
        if mx<pp.X or mx>pp.X+ps.X or my<pp.Y or my>pp.Y+ps.Y then
            closePop() end
    end)
    return r, function() return sel end
end

-- ── Keybind ────────────────────────────────────────
local function addKey(parent, name, defKey, cb)
    local cur=defKey or Enum.KeyCode.Unknown
    local listen=false
    local r=row(parent,46)
    mk("TextLabel",{BackgroundTransparency=1,
        Position=UDim2.new(0,12,0,13),
        Size=UDim2.new(0.55,0,0,18),
        Text=name, TextColor3=T.Text, TextSize=13, Font=FN,
        TextXAlignment=Enum.TextXAlignment.Left,
        ZIndex=17, Parent=r})

    local badge=mk("TextButton",{
        AnchorPoint=Vector2.new(1,0.5),
        BackgroundColor3=T.BG,
        Position=UDim2.new(1,-11,0.5,0),
        Size=UDim2.new(0,82,0,27),
        Text=cur.Name, TextColor3=T.AccentL,
        TextSize=11, Font=FNB, ZIndex=18, Parent=r})
    rnd(badge,6); bdr(badge, T.Accent)

    badge.MouseButton1Click:Connect(function()
        listen=true
        badge.Text="  . . ."
        badge.TextColor3=T.Yellow
        tw(badge,{BackgroundColor3=Color3.fromRGB(28,22,6)},SF)
    end)
    UserInputService.InputBegan:Connect(function(i,gp)
        if not listen then return end
        if i.UserInputType~=Enum.UserInputType.Keyboard then return end
        listen=false; cur=i.KeyCode
        badge.Text=i.KeyCode.Name; badge.TextColor3=T.AccentL
        tw(badge,{BackgroundColor3=T.BG},SF)
        if cb then cb(cur) end
    end)
    return r, function() return cur end
end

-- ── Text Input ─────────────────────────────────────
local function addInp(parent, name, ph, cb)
    local r=row(parent,46)
    mk("TextLabel",{BackgroundTransparency=1,
        Position=UDim2.new(0,12,0,13),
        Size=UDim2.new(0.4,0,0,18),
        Text=name, TextColor3=T.Text, TextSize=13, Font=FN,
        TextXAlignment=Enum.TextXAlignment.Left,
        ZIndex=17, Parent=r})

    local box=mk("Frame",{
        AnchorPoint=Vector2.new(1,0.5),
        BackgroundColor3=T.BG,
        Position=UDim2.new(1,-11,0.5,0),
        Size=UDim2.new(0,148,0,27), ZIndex=17, Parent=r})
    rnd(box,6)
    local bs=bdr(box)

    local tb=mk("TextBox",{BackgroundTransparency=1,
        Position=UDim2.new(0,8,0,0), Size=UDim2.new(1,-16,1,0),
        Text="", PlaceholderText=ph or "Enter value...",
        PlaceholderColor3=T.Muted, TextColor3=T.Text,
        TextSize=12, Font=FN,
        TextXAlignment=Enum.TextXAlignment.Left,
        ClearTextOnFocus=false, ZIndex=18, Parent=box})

    tb.Focused:Connect(function()
        tw(box,{BackgroundColor3=Color3.fromRGB(16,12,30)},SF)
        bs.Color=T.Accent
    end)
    tb.FocusLost:Connect(function(enter)
        tw(box,{BackgroundColor3=T.BG},SF)
        bs.Color=T.Border
        if enter and cb then cb(tb.Text) end
    end)
    return r, function() return tb.Text end
end

-- ══════════════════════════════════════════════════
--  TAB CONTENT
-- ══════════════════════════════════════════════════

-- MAIN
do
    local sc=Tabs["Main"].scroll
    local s1,_=sec(sc,"MOVEMENT")
    addSld(s1,"Walk Speed",    16, 250, 16,  nil)
    addSld(s1,"Jump Power",    50, 500, 50,  nil)
    addTgl(s1,"Fly",           "Float freely",      false,nil)
    addTgl(s1,"Noclip",        "Phase through walls",false,nil)
    addTgl(s1,"Infinite Jump", "Jump without limits",false,nil)
    addKey(s1,"Fly Hotkey",    Enum.KeyCode.F,       nil)

    local s2=sec(sc,"AUTOMATION")
    addBtn(s2,"Auto Farm",    "Automatically farms resources",nil)
    addBtn(s2,"Auto Collect", "Collects items in radius",     nil)
    addTgl(s2,"Anti AFK",     "Prevents inactivity kick",true,nil)
    addSld(s2,"Farm Radius",  10, 500, 50, nil)
end

-- VISUAL
do
    local sc=Tabs["Visual"].scroll
    local s1=sec(sc,"ESP")
    addTgl(s1,"Player ESP",  "Player bounding boxes",  false,nil)
    addTgl(s1,"Item ESP",    "Ground item highlights", false,nil)
    addTgl(s1,"NPC ESP",     "NPC outlines",           false,nil)
    addTgl(s1,"Name Tags",   "Floating name labels",   false,nil)
    addTgl(s1,"Health Bars", "HP bars above heads",    false,nil)
    addDD( s1,"ESP Color",  {"Team","White","Red","Purple","Cyan"},"Team",nil)

    local s2=sec(sc,"RENDERING")
    addSld(s2,"Field of View",     60, 130, 70,  nil)
    addSld(s2,"Render Distance",  100,2048, 512, nil)
    addTgl(s2,"Fullbright",  "Remove darkness", false,nil)
    addTgl(s2,"No Fog",      "Clear weather fog",false,nil)
end

-- WORLD
do
    local sc=Tabs["World"].scroll
    local s1=sec(sc,"PHYSICS")
    addSld(s1,"Gravity",        0,  400,196,nil)
    addSld(s1,"Wind Speed",     0,  100,  0,nil)
    addTgl(s1,"Freeze Players", "Pause all players",    false,nil)
    addTgl(s1,"No Clip",        "Phase through objects",false,nil)
    addInp(s1,"Custom Gravity", "e.g. 196.2",           nil)

    local s2=sec(sc,"TIME & WEATHER")
    addSld(s2,"Time of Day",  0,  24, 12, nil)
    addTgl(s2,"Lock Time",    "Freeze time", false,nil)
    addDD( s2,"Weather",     {"Clear","Fog","Rain","Snow","Storm"},"Clear",nil)
    addBtn(s2,"Set Sunrise",  "Jump to 06:00",nil)
    addBtn(s2,"Set Midnight", "Jump to 00:00",nil)
end

-- PLAYER
do
    local sc=Tabs["Player"].scroll
    local s1=sec(sc,"CHARACTER")
    addSld(s1,"Health",        0, 100,100,nil)
    addSld(s1,"Walk Speed",   16, 250, 16,nil)
    addTgl(s1,"God Mode",      "Take no damage",   false,nil)
    addTgl(s1,"Invisible",     "Become invisible", false,nil)
    addTgl(s1,"Always Sprint", "Permanent sprint", false,nil)

    local s2=sec(sc,"TELEPORT")
    addDD( s2,"Target",      {"Nearest","Random","Manual"},"Nearest",nil)
    addBtn(s2,"To Spawn",     "Teleport to spawn point",nil)
    addBtn(s2,"To Cursor",    "Teleport to mouse hit",  nil)
    addBtn(s2,"To Player",    "Teleport to selection",  nil)
    addKey(s2,"Teleport Key", Enum.KeyCode.T,            nil)
end

-- MISC
do
    local sc=Tabs["Misc"].scroll
    local s1=sec(sc,"UTILITY")
    addBtn(s1,"Rejoin",         "Reconnect to this server",    nil)
    addBtn(s1,"Server Hop",     "Join a different server",     nil)
    addBtn(s1,"Copy Join Link", "Copy game link to clipboard", nil)
    addTgl(s1,"Debug Info",     "Show FPS & debug overlay",    false,nil)

    local s2=sec(sc,"INTERFACE")
    addTgl(s2,"Watermark",    "Show watermark in corner",true, nil)
    addDD( s2,"Theme",       {"Dark","Darker","AMOLED"},"Dark",nil)
    addSld(s2,"UI Opacity",   40, 100, 100, nil)
    addKey(s2,"Toggle Hub",   Enum.KeyCode.Insert,       nil)
end

-- ══════════════════════════════════════════════════
--  FIRST TAB
-- ══════════════════════════════════════════════════
switchTab("Main")

-- ══════════════════════════════════════════════════
--  WINDOW CONTROLS
-- ══════════════════════════════════════════════════
local minimized=false
MBTN.MouseButton1Click:Connect(function()
    minimized=not minimized
    tw(WIN,{Size=minimized
        and UDim2.new(0,600,0,50)
        or  UDim2.new(0,600,0,450)
    },S,Enum.EasingStyle.Quart)
end)

local shown=true
local function hide()
    shown=false
    tw(WIN,{Size=UDim2.new(0,600,0,0),BackgroundTransparency=1},S)
    spawn(function() wait(S+0.06); WIN.Visible=false end)
end
local function show()
    shown=true; WIN.Visible=true
    tw(WIN,{Size=UDim2.new(0,600,0,450),BackgroundTransparency=0},
        0.38,Enum.EasingStyle.Back,Enum.EasingDirection.Out)
end

CBTN.MouseButton1Click:Connect(hide)

UserInputService.InputBegan:Connect(function(i,gp)
    if gp then return end
    if i.KeyCode==Enum.KeyCode.Insert then
        if shown then hide() else show() end
    end
end)

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
    notify("ScriptHub","Loaded — INSERT to toggle","ok",4)
end)
