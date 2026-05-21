-- ═══════════════════════════════════════════════════════
--   ScriptHub  |  Custom UI  |  No Libraries
-- ═══════════════════════════════════════════════════════

local Players          = game:GetService("Players")
local TweenService     = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")
local RunService       = game:GetService("RunService")

local LocalPlayer = Players.LocalPlayer
local PlayerGui   = LocalPlayer:WaitForChild("PlayerGui")

-- ── Theme ─────────────────────────────────────────────
local T = {
    BG          = Color3.fromRGB(10,  10,  16),
    Surface     = Color3.fromRGB(16,  16,  26),
    Card        = Color3.fromRGB(20,  20,  32),
    CardHover   = Color3.fromRGB(26,  26,  42),
    Accent      = Color3.fromRGB(112, 72,  255),
    AccentDark  = Color3.fromRGB(80,  48,  200),
    AccentLight = Color3.fromRGB(160, 110, 255),
    Text        = Color3.fromRGB(235, 235, 255),
    Muted       = Color3.fromRGB(110, 110, 148),
    Border      = Color3.fromRGB(36,  36,  56),
    Toggle      = Color3.fromRGB(46,  46,  70),
    Success     = Color3.fromRGB(72,  200, 130),
    Warning     = Color3.fromRGB(255, 185, 50),
    Danger      = Color3.fromRGB(255, 75,  75),
    White       = Color3.fromRGB(255, 255, 255),
    StatusBG    = Color3.fromRGB(12,  12,  20),
}
local FONT      = Enum.Font.GothamMedium
local FONT_BOLD = Enum.Font.GothamBold
local SPD       = 0.18
local SPD_FAST  = 0.10

-- ── Helpers ───────────────────────────────────────────
local function tw(obj, props, dur, style, dir)
    TweenService:Create(obj,
        TweenInfo.new(dur or SPD,
            style or Enum.EasingStyle.Quart,
            dir   or Enum.EasingDirection.Out),
        props):Play()
end

local function make(cls, props)
    local o = Instance.new(cls)
    for k, v in pairs(props) do
        if k ~= "Parent" then o[k] = v end
    end
    if props.Parent then o.Parent = props.Parent end
    return o
end

local function corner(p, r)
    local c = Instance.new("UICorner")
    c.CornerRadius = UDim.new(0, r or 8)
    c.Parent = p; return c
end

local function stroke(p, col, t)
    local s = Instance.new("UIStroke")
    s.Color           = col or T.Border
    s.Thickness       = t   or 1
    s.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
    s.Parent = p; return s
end

local function pad(p, t, b, l, r)
    local u = Instance.new("UIPadding")
    u.PaddingTop    = UDim.new(0, t or 8)
    u.PaddingBottom = UDim.new(0, b or 8)
    u.PaddingLeft   = UDim.new(0, l or 8)
    u.PaddingRight  = UDim.new(0, r or 8)
    u.Parent = p; return u
end

local function grad(p, c0, c1, rot)
    local g = Instance.new("UIGradient")
    g.Color    = ColorSequence.new(c0, c1)
    g.Rotation = rot or 135
    g.Parent = p; return g
end

-- ── Root ──────────────────────────────────────────────
local GUI = make("ScreenGui", {
    Name           = "ScriptHub",
    ResetOnSpawn   = false,
    ZIndexBehavior = Enum.ZIndexBehavior.Sibling,
    IgnoreGuiInset = true,
    Parent         = PlayerGui,
})

-- High-ZIndex overlay layer for dropdowns (escapes window clipping)
local POPUP_LAYER = make("Frame", {
    BackgroundTransparency = 1,
    Size   = UDim2.new(1, 0, 1, 0),
    ZIndex = 80,
    Parent = GUI,
})

-- ══════════════════════════════════════════════════════
--  NOTIFICATION SYSTEM
-- ══════════════════════════════════════════════════════
local NOTIF_FRAME = make("Frame", {
    BackgroundTransparency = 1,
    AnchorPoint = Vector2.new(1, 1),
    Position    = UDim2.new(1, -16, 1, -16),
    Size        = UDim2.new(0, 272, 1, 0),
    ZIndex      = 90,
    Parent      = GUI,
})
make("UIListLayout", {
    FillDirection       = Enum.FillDirection.Vertical,
    VerticalAlignment   = Enum.VerticalAlignment.Bottom,
    HorizontalAlignment = Enum.HorizontalAlignment.Right,
    Padding             = UDim.new(0, 6),
    SortOrder           = Enum.SortOrder.LayoutOrder,
    Parent              = NOTIF_FRAME,
})

local NTYPES = {
    success = { col = Color3.fromRGB(72,  200, 130), icon = "✓" },
    error   = { col = Color3.fromRGB(255, 75,  75 ), icon = "✕" },
    warn    = { col = Color3.fromRGB(255, 185, 50 ), icon = "!" },
    info    = { col = Color3.fromRGB(112, 72,  255), icon = "i" },
}

local function notify(title, msg, ntype, duration)
    local nt  = NTYPES[ntype or "info"] or NTYPES.info
    local dur = duration or 3

    local card = make("Frame", {
        BackgroundColor3    = Color3.fromRGB(16, 16, 28),
        Size                = UDim2.new(1, 0, 0, 68),
        Position            = UDim2.new(1, 30, 0, 0),
        ZIndex              = 91,
        ClipsDescendants    = true,
        Parent              = NOTIF_FRAME,
    })
    corner(card, 10)
    stroke(card, Color3.fromRGB(36, 36, 54), 1)

    -- left accent bar
    local bar = make("Frame", {
        BackgroundColor3 = nt.col,
        Size             = UDim2.new(0, 3, 1, 0),
        ZIndex           = 92,
        Parent           = card,
    })
    corner(bar, 2)

    -- icon badge
    local badge = make("Frame", {
        BackgroundColor3 = nt.col,
        Position         = UDim2.new(0, 12, 0.5, -11),
        Size             = UDim2.new(0, 22, 0, 22),
        ZIndex           = 92,
        Parent           = card,
    })
    corner(badge, 6)
    make("TextLabel", {
        BackgroundTransparency = 1,
        Size       = UDim2.new(1, 0, 1, 0),
        Text       = nt.icon,
        TextColor3 = T.White,
        TextSize   = 13,
        Font       = FONT_BOLD,
        ZIndex     = 93,
        Parent     = badge,
    })

    make("TextLabel", {
        BackgroundTransparency = 1,
        Position  = UDim2.new(0, 42, 0, 10),
        Size      = UDim2.new(1, -52, 0, 18),
        Text      = title,
        TextColor3 = T.Text,
        TextSize  = 13,
        Font      = FONT_BOLD,
        TextXAlignment = Enum.TextXAlignment.Left,
        ZIndex    = 92,
        Parent    = card,
    })
    make("TextLabel", {
        BackgroundTransparency = 1,
        Position  = UDim2.new(0, 42, 0, 29),
        Size      = UDim2.new(1, -52, 0, 28),
        Text      = msg or "",
        TextColor3 = T.Muted,
        TextSize  = 11,
        Font      = FONT,
        TextXAlignment = Enum.TextXAlignment.Left,
        TextWrapped    = true,
        ZIndex    = 92,
        Parent    = card,
    })

    -- progress bar depletes over duration
    local prog = make("Frame", {
        BackgroundColor3    = nt.col,
        BackgroundTransparency = 0.4,
        Position = UDim2.new(0, 0, 1, -3),
        Size     = UDim2.new(1, 0, 0, 3),
        ZIndex   = 93,
        Parent   = card,
    })

    -- slide in
    tw(card, { Position = UDim2.new(0, 0, 0, 0) }, SPD, Enum.EasingStyle.Back, Enum.EasingDirection.Out)
    tw(prog, { Size = UDim2.new(0, 0, 0, 3) }, dur - 0.25, Enum.EasingStyle.Linear)

    task.delay(dur, function()
        tw(card, { Position = UDim2.new(1, 30, 0, 0) }, SPD)
        task.delay(SPD + 0.05, function() card:Destroy() end)
    end)
end

-- ══════════════════════════════════════════════════════
--  WATERMARK
-- ══════════════════════════════════════════════════════
local WM = make("Frame", {
    BackgroundColor3       = Color3.fromRGB(12, 12, 20),
    BackgroundTransparency = 0.15,
    Position               = UDim2.new(0, 12, 0, 12),
    Size                   = UDim2.new(0, 220, 0, 28),
    ZIndex                 = 20,
    Parent                 = GUI,
})
corner(WM, 6)
stroke(WM, T.Border, 1)

local WM_DOT = make("Frame", {
    BackgroundColor3 = T.Accent,
    Position         = UDim2.new(0, 10, 0.5, -4),
    Size             = UDim2.new(0, 8, 0, 8),
    ZIndex           = 21,
    Parent           = WM,
})
corner(WM_DOT, 4)

make("TextLabel", {
    BackgroundTransparency = 1,
    Position  = UDim2.new(0, 26, 0, 0),
    Size      = UDim2.new(1, -30, 1, 0),
    Text      = "ScriptHub  •  " .. LocalPlayer.Name,
    TextColor3 = T.Muted,
    TextSize  = 11,
    Font      = FONT,
    TextXAlignment = Enum.TextXAlignment.Left,
    ZIndex    = 21,
    Parent    = WM,
})

-- watermark drag
do
    local drag, ds, sp = false, nil, nil
    WM.InputBegan:Connect(function(i)
        if i.UserInputType == Enum.UserInputType.MouseButton1 then
            drag = true; ds = i.Position; sp = WM.Position
        end
    end)
    UserInputService.InputChanged:Connect(function(i)
        if drag and i.UserInputType == Enum.UserInputType.MouseMovement then
            local d = i.Position - ds
            WM.Position = UDim2.new(sp.X.Scale, sp.X.Offset + d.X,
                                    sp.Y.Scale, sp.Y.Offset + d.Y)
        end
    end)
    UserInputService.InputEnded:Connect(function(i)
        if i.UserInputType == Enum.UserInputType.MouseButton1 then drag = false end
    end)
end

-- pulse dot
RunService.Heartbeat:Connect(function()
    local a = math.abs(math.sin(tick() * math.pi * 0.6))
    WM_DOT.BackgroundTransparency = 0.1 + a * 0.6
end)

-- ══════════════════════════════════════════════════════
--  MAIN WINDOW
-- ══════════════════════════════════════════════════════
local WIN = make("Frame", {
    Name             = "Window",
    AnchorPoint      = Vector2.new(0.5, 0.5),
    BackgroundColor3 = T.BG,
    Position         = UDim2.new(0.5, 0, 0.5, 0),
    Size             = UDim2.new(0, 610, 0, 460),
    ZIndex           = 10,
    ClipsDescendants = true,
    Parent           = GUI,
})
corner(WIN, 14)
stroke(WIN, T.Border, 1)
grad(WIN, Color3.fromRGB(18, 12, 34), T.BG, 145)

-- outer glow
make("ImageLabel", {
    AnchorPoint        = Vector2.new(0.5, 0.5),
    BackgroundTransparency = 1,
    Position           = UDim2.new(0.5, 0, 0.5, 4),
    Size               = UDim2.new(1, 46, 1, 46),
    ZIndex             = 9,
    Image              = "rbxassetid://6014261993",
    ImageColor3        = T.Accent,
    ImageTransparency  = 0.80,
    ScaleType          = Enum.ScaleType.Slice,
    SliceCenter        = Rect.new(49, 49, 450, 450),
    Parent             = WIN,
})

-- ── Title Bar ─────────────────────────────────────────
local TITLEBAR = make("Frame", {
    BackgroundColor3 = T.Surface,
    Size             = UDim2.new(1, 0, 0, 50),
    ZIndex           = 12,
    Parent           = WIN,
})
corner(TITLEBAR, 14)
make("Frame", {  -- fill rounded bottom corners
    BackgroundColor3 = T.Surface,
    Position = UDim2.new(0, 0, 0.5, 0),
    Size     = UDim2.new(1, 0, 0.5, 0),
    ZIndex   = 12, Parent = TITLEBAR,
})
grad(TITLEBAR, Color3.fromRGB(20, 14, 38), T.Surface, 0)

-- accent underline
local TITLE_LINE = make("Frame", {
    BackgroundColor3 = T.Accent,
    Position = UDim2.new(0, 0, 1, -2),
    Size     = UDim2.new(1, 0, 0, 2),
    ZIndex   = 14, Parent = TITLEBAR,
})
grad(TITLE_LINE, T.AccentLight, T.AccentDark, 0)

-- periodic shimmer sweep
local shimmer = make("Frame", {
    BackgroundColor3       = T.White,
    BackgroundTransparency = 0.93,
    Position = UDim2.new(-0.12, 0, 0, 0),
    Size     = UDim2.new(0.12, 0, 1, 0),
    ZIndex   = 15, Parent = TITLEBAR,
})
local function shimmerLoop()
    shimmer.Position = UDim2.new(-0.12, 0, 0, 0)
    tw(shimmer, { Position = UDim2.new(1.12, 0, 0, 0) }, 2.5, Enum.EasingStyle.Linear)
    task.delay(5, shimmerLoop)
end
task.delay(1.5, shimmerLoop)

-- logo badge
local LOGO = make("Frame", {
    BackgroundColor3 = T.Accent,
    Position = UDim2.new(0, 14, 0.5, -15),
    Size     = UDim2.new(0, 30, 0, 30),
    ZIndex   = 14, Parent = TITLEBAR,
})
corner(LOGO, 9)
grad(LOGO, T.AccentLight, T.AccentDark, 135)
make("TextLabel", {
    BackgroundTransparency = 1,
    Size       = UDim2.new(1, 0, 1, 0),
    Text       = "S",
    TextColor3 = T.White,
    TextSize   = 17,
    Font       = FONT_BOLD,
    ZIndex     = 15, Parent = LOGO,
})

make("TextLabel", {
    BackgroundTransparency = 1,
    Position  = UDim2.new(0, 54, 0, 7),
    Size      = UDim2.new(0.5, 0, 0, 20),
    Text      = "ScriptHub",
    TextColor3 = T.Text,
    TextSize  = 15,
    Font      = FONT_BOLD,
    TextXAlignment = Enum.TextXAlignment.Left,
    ZIndex    = 14, Parent = TITLEBAR,
})
make("TextLabel", {
    BackgroundTransparency = 1,
    Position  = UDim2.new(0, 54, 0, 28),
    Size      = UDim2.new(0.5, 0, 0, 14),
    Text      = "v1.0  •  Free",
    TextColor3 = T.Muted,
    TextSize  = 10,
    Font      = FONT,
    TextXAlignment = Enum.TextXAlignment.Left,
    ZIndex    = 14, Parent = TITLEBAR,
})

-- controls
local CTRL = make("Frame", {
    BackgroundTransparency = 1,
    AnchorPoint = Vector2.new(1, 0.5),
    Position    = UDim2.new(1, -14, 0.5, 0),
    Size        = UDim2.new(0, 72, 0, 18),
    ZIndex      = 14, Parent = TITLEBAR,
})
make("UIListLayout", {
    FillDirection       = Enum.FillDirection.Horizontal,
    HorizontalAlignment = Enum.HorizontalAlignment.Right,
    VerticalAlignment   = Enum.VerticalAlignment.Center,
    Padding             = UDim.new(0, 7),
    Parent              = CTRL,
})

local function ctrlBtn(col)
    local b = make("TextButton", {
        BackgroundColor3 = col,
        Size  = UDim2.new(0, 14, 0, 14),
        Text  = "",
        ZIndex = 15, Parent = CTRL,
    })
    corner(b, 7)
    b.MouseEnter:Connect(function() tw(b, {BackgroundTransparency=0.3}, SPD_FAST) end)
    b.MouseLeave:Connect(function() tw(b, {BackgroundTransparency=0},   SPD_FAST) end)
    return b
end
local BTN_CLOSE    = ctrlBtn(Color3.fromRGB(255, 70, 70))
local BTN_MINIMIZE = ctrlBtn(Color3.fromRGB(255, 185, 45))

-- ── Sidebar ───────────────────────────────────────────
local SIDEBAR = make("Frame", {
    BackgroundColor3 = T.Surface,
    Position = UDim2.new(0, 0, 0, 50),
    Size     = UDim2.new(0, 158, 1, -82),  -- leaves space for status bar
    ZIndex   = 11, Parent = WIN,
})
make("Frame", {
    BackgroundColor3 = T.Border,
    AnchorPoint = Vector2.new(1, 0),
    Position    = UDim2.new(1, 0, 0, 0),
    Size        = UDim2.new(0, 1, 1, 0),
    ZIndex      = 12, Parent = SIDEBAR,
})
grad(SIDEBAR, T.Surface, Color3.fromRGB(13, 13, 22), 90)

local TAB_LIST = make("Frame", {
    BackgroundTransparency = 1,
    Size   = UDim2.new(1, 0, 1, 0),
    ZIndex = 12, Parent = SIDEBAR,
})
make("UIListLayout", {
    FillDirection = Enum.FillDirection.Vertical,
    Padding       = UDim.new(0, 3),
    Parent        = TAB_LIST,
})
pad(TAB_LIST, 10, 10, 10, 10)

-- indicator pill
local TAB_IND = make("Frame", {
    BackgroundColor3 = T.Accent,
    Position = UDim2.new(0, 0, 0, 20),
    Size     = UDim2.new(0, 3, 0, 30),
    ZIndex   = 16, Parent = SIDEBAR,
})
corner(TAB_IND, 2)

-- ── Content Area ──────────────────────────────────────
local CONTENT = make("Frame", {
    BackgroundTransparency = 1,
    Position = UDim2.new(0, 158, 0, 50),
    Size     = UDim2.new(1, -158, 1, -82),
    ZIndex   = 11, Parent = WIN,
})

-- ── Status Bar ────────────────────────────────────────
local STATUSBAR = make("Frame", {
    BackgroundColor3 = T.StatusBG,
    AnchorPoint = Vector2.new(0, 1),
    Position    = UDim2.new(0, 0, 1, 0),
    Size        = UDim2.new(1, 0, 0, 32),
    ZIndex      = 12, Parent = WIN,
})
make("Frame", {  -- top border line
    BackgroundColor3 = T.Border,
    Size = UDim2.new(1, 0, 0, 1),
    ZIndex = 13, Parent = STATUSBAR,
})

local FPS_LBL = make("TextLabel", {
    BackgroundTransparency = 1,
    Position  = UDim2.new(0, 14, 0, 0),
    Size      = UDim2.new(0, 72, 1, 0),
    Text      = "FPS: --",
    TextColor3 = T.Muted,
    TextSize  = 10,
    Font      = FONT,
    TextXAlignment = Enum.TextXAlignment.Left,
    ZIndex    = 13, Parent = STATUSBAR,
})

local ACTIVE_LBL = make("TextLabel", {
    BackgroundTransparency = 1,
    Position  = UDim2.new(0, 92, 0, 0),
    Size      = UDim2.new(0, 130, 1, 0),
    Text      = "○  0 active",
    TextColor3 = T.Muted,
    TextSize  = 10,
    Font      = FONT,
    TextXAlignment = Enum.TextXAlignment.Left,
    ZIndex    = 13, Parent = STATUSBAR,
})

make("TextLabel", {
    BackgroundTransparency = 1,
    AnchorPoint = Vector2.new(1, 0.5),
    Position    = UDim2.new(1, -14, 0.5, 0),
    Size        = UDim2.new(0, 120, 1, 0),
    Text        = "INSERT  to toggle",
    TextColor3  = T.Muted,
    TextSize    = 10,
    Font        = FONT,
    TextXAlignment = Enum.TextXAlignment.Right,
    ZIndex      = 13, Parent = STATUSBAR,
})

-- FPS counter
local fpsArr = {}
RunService.Heartbeat:Connect(function(dt)
    table.insert(fpsArr, 1 / dt)
    if #fpsArr > 30 then table.remove(fpsArr, 1) end
    local sum = 0
    for _, v in ipairs(fpsArr) do sum = sum + v end
    local fps = math.round(sum / #fpsArr)
    FPS_LBL.Text = "FPS: " .. fps
    FPS_LBL.TextColor3 = fps >= 55 and T.Success or fps >= 30 and T.Warning or T.Danger
end)

local activeCount = 0
local function changeActive(delta)
    activeCount = math.max(0, activeCount + delta)
    ACTIVE_LBL.Text      = (activeCount > 0 and "●  " or "○  ") .. activeCount .. " active"
    ACTIVE_LBL.TextColor3 = activeCount > 0 and T.AccentLight or T.Muted
end

-- ══════════════════════════════════════════════════════
--  TAB SYSTEM
-- ══════════════════════════════════════════════════════
local Tabs      = {}
local ActiveTab = nil

local TAB_DEFS = {
    { id = "Main",   label = "Main",   icon = "▸" },
    { id = "Visual", label = "Visual", icon = "◈" },
    { id = "World",  label = "World",  icon = "◉" },
    { id = "Player", label = "Player", icon = "◎" },
    { id = "Misc",   label = "Misc",   icon = "⊞" },
}

local function setTab(id)
    local tab = Tabs[id]
    if not tab or ActiveTab == id then return end

    if ActiveTab then
        local old = Tabs[ActiveTab]
        tw(old.btn,  { BackgroundTransparency = 1, BackgroundColor3 = T.Card }, SPD)
        tw(old.icon, { TextColor3 = T.Muted }, SPD)
        tw(old.lbl,  { TextColor3 = T.Muted }, SPD)
        old.page.Visible = false
    end

    ActiveTab       = id
    tab.page.Visible = true
    tw(tab.btn,  { BackgroundTransparency = 0, BackgroundColor3 = Color3.fromRGB(28, 20, 52) }, SPD)
    tw(tab.icon, { TextColor3 = T.AccentLight }, SPD)
    tw(tab.lbl,  { TextColor3 = T.Text }, SPD)

    local btnY = tab.btn.AbsolutePosition.Y - SIDEBAR.AbsolutePosition.Y
    local btnH = tab.btn.AbsoluteSize.Y
    tw(TAB_IND, { Position = UDim2.new(0, 0, 0, btnY + (btnH - 30) / 2) }, SPD)
end

local function newTab(def)
    local btn = make("TextButton", {
        BackgroundColor3       = T.Card,
        BackgroundTransparency = 1,
        Size   = UDim2.new(1, 0, 0, 38),
        Text   = "",
        ZIndex = 13, Parent = TAB_LIST,
    })
    corner(btn, 7)

    local ico = make("TextLabel", {
        BackgroundTransparency = 1,
        Position  = UDim2.new(0, 10, 0, 0),
        Size      = UDim2.new(0, 22, 1, 0),
        Text      = def.icon,
        TextColor3 = T.Muted,
        TextSize  = 14,
        Font      = FONT,
        ZIndex    = 14, Parent = btn,
    })
    local lbl = make("TextLabel", {
        BackgroundTransparency = 1,
        Position  = UDim2.new(0, 36, 0, 0),
        Size      = UDim2.new(1, -36, 1, 0),
        Text      = def.label,
        TextColor3 = T.Muted,
        TextSize  = 13,
        Font      = FONT,
        TextXAlignment = Enum.TextXAlignment.Left,
        ZIndex    = 14, Parent = btn,
    })

    -- page wrapper
    local page = make("Frame", {
        BackgroundTransparency = 1,
        Size    = UDim2.new(1, 0, 1, 0),
        Visible = false,
        ZIndex  = 12, Parent = CONTENT,
    })

    local scroll = make("ScrollingFrame", {
        BackgroundTransparency = 1,
        Size                   = UDim2.new(1, 0, 1, 0),
        ScrollBarThickness     = 3,
        ScrollBarImageColor3   = T.Accent,
        CanvasSize             = UDim2.new(0, 0, 0, 0),
        AutomaticCanvasSize    = Enum.AutomaticSize.Y,
        ZIndex                 = 12, Parent = page,
    })
    pad(scroll, 14, 14, 14, 14)
    make("UIListLayout", {
        FillDirection = Enum.FillDirection.Vertical,
        Padding       = UDim.new(0, 10),
        SortOrder     = Enum.SortOrder.LayoutOrder,
        Parent        = scroll,
    })

    Tabs[def.id] = { btn = btn, icon = ico, lbl = lbl, page = page, scroll = scroll }

    btn.MouseButton1Click:Connect(function() setTab(def.id) end)
    btn.MouseEnter:Connect(function()
        if ActiveTab ~= def.id then tw(btn, {BackgroundTransparency=0.88}, SPD_FAST) end
    end)
    btn.MouseLeave:Connect(function()
        if ActiveTab ~= def.id then tw(btn, {BackgroundTransparency=1},    SPD_FAST) end
    end)
end

for _, d in ipairs(TAB_DEFS) do newTab(d) end

-- ══════════════════════════════════════════════════════
--  COMPONENT BUILDERS
-- ══════════════════════════════════════════════════════

-- Section card
local function section(parent, title)
    local wrap = make("Frame", {
        BackgroundColor3 = T.Card,
        Size             = UDim2.new(1, 0, 0, 0),
        AutomaticSize    = Enum.AutomaticSize.Y,
        ZIndex           = 13, Parent = parent,
    })
    corner(wrap, 9)
    stroke(wrap, T.Border, 1)

    local hdr = make("Frame", {
        BackgroundTransparency = 1,
        Size   = UDim2.new(1, 0, 0, 32),
        ZIndex = 14, Parent = wrap,
    })
    local pill = make("Frame", {
        BackgroundColor3 = T.Accent,
        Position = UDim2.new(0, 12, 0.5, -7),
        Size     = UDim2.new(0, 3, 0, 14),
        ZIndex   = 15, Parent = hdr,
    })
    corner(pill, 2)
    make("TextLabel", {
        BackgroundTransparency = 1,
        Position  = UDim2.new(0, 22, 0, 0),
        Size      = UDim2.new(1, -22, 1, 0),
        Text      = title,
        TextColor3 = T.Muted,
        TextSize  = 10,
        Font      = FONT_BOLD,
        TextXAlignment = Enum.TextXAlignment.Left,
        ZIndex    = 15, Parent = hdr,
    })

    local items = make("Frame", {
        BackgroundTransparency = 1,
        Position  = UDim2.new(0, 0, 0, 32),
        Size      = UDim2.new(1, 0, 0, 0),
        AutomaticSize = Enum.AutomaticSize.Y,
        ZIndex    = 14, Parent = wrap,
    })
    make("UIListLayout", {
        FillDirection = Enum.FillDirection.Vertical,
        Padding       = UDim.new(0, 2),
        Parent        = items,
    })
    pad(items, 0, 10, 10, 10)
    return items
end

-- Base row (shared chrome + hover)
local function baseRow(parent, h)
    local row = make("Frame", {
        BackgroundColor3 = T.Surface,
        Size             = UDim2.new(1, 0, 0, h or 46),
        ZIndex           = 15, Parent = parent,
    })
    corner(row, 7)
    stroke(row, Color3.fromRGB(28, 28, 46), 1)

    local hit = make("Frame", {
        BackgroundTransparency = 1,
        Size   = UDim2.new(1, 0, 1, 0),
        ZIndex = 14, Parent = row,
    })
    hit.MouseEnter:Connect(function() tw(row, {BackgroundColor3=T.CardHover}, SPD_FAST) end)
    hit.MouseLeave:Connect(function() tw(row, {BackgroundColor3=T.Surface},   SPD_FAST) end)

    return row
end

local function rowLabels(row, name, desc, yOff)
    make("TextLabel", {
        BackgroundTransparency = 1,
        Position  = UDim2.new(0, 13, 0, yOff or (desc and 5 or 13)),
        Size      = UDim2.new(0.62, 0, 0, 18),
        Text      = name,
        TextColor3 = T.Text,
        TextSize  = 13,
        Font      = FONT,
        TextXAlignment = Enum.TextXAlignment.Left,
        ZIndex    = 16, Parent = row,
    })
    if desc then
        make("TextLabel", {
            BackgroundTransparency = 1,
            Position  = UDim2.new(0, 13, 0, 24),
            Size      = UDim2.new(0.62, 0, 0, 14),
            Text      = desc,
            TextColor3 = T.Muted,
            TextSize  = 10,
            Font      = FONT,
            TextXAlignment = Enum.TextXAlignment.Left,
            ZIndex    = 16, Parent = row,
        })
    end
end

-- ── Button ────────────────────────────────────────────
local function addButton(parent, name, desc, cb)
    local row = baseRow(parent, 46)
    rowLabels(row, name, desc)

    local btn = make("TextButton", {
        AnchorPoint      = Vector2.new(1, 0.5),
        BackgroundColor3 = T.Accent,
        Position         = UDim2.new(1, -12, 0.5, 0),
        Size             = UDim2.new(0, 80, 0, 28),
        Text             = "Run",
        TextColor3       = T.White,
        TextSize         = 12,
        Font             = FONT_BOLD,
        ZIndex           = 17, Parent = row,
    })
    corner(btn, 7)
    grad(btn, T.AccentLight, T.AccentDark, 90)

    btn.MouseEnter:Connect(function()    tw(btn, {Size=UDim2.new(0,84,0,30)}, SPD_FAST) end)
    btn.MouseLeave:Connect(function()    tw(btn, {Size=UDim2.new(0,80,0,28)}, SPD_FAST) end)
    btn.MouseButton1Down:Connect(function()  tw(btn, {Size=UDim2.new(0,76,0,26)}, 0.07) end)
    btn.MouseButton1Up:Connect(function()    tw(btn, {Size=UDim2.new(0,80,0,28)}, SPD_FAST) end)
    btn.MouseButton1Click:Connect(function()
        notify(name, "Executed successfully", "success", 2.5)
        if cb then cb() end
    end)
    return row
end

-- ── Toggle ────────────────────────────────────────────
local function addToggle(parent, name, desc, default, cb)
    local state = default == true
    local row   = baseRow(parent, 46)
    rowLabels(row, name, desc)

    local track = make("Frame", {
        AnchorPoint      = Vector2.new(1, 0.5),
        BackgroundColor3 = state and T.Accent or T.Toggle,
        Position         = UDim2.new(1, -13, 0.5, 0),
        Size             = UDim2.new(0, 46, 0, 25),
        ZIndex           = 16, Parent = row,
    })
    corner(track, 13)

    local knob = make("Frame", {
        AnchorPoint      = Vector2.new(0, 0.5),
        BackgroundColor3 = T.White,
        Position         = UDim2.new(0, state and 23 or 2, 0.5, 0),
        Size             = UDim2.new(0, 21, 0, 21),
        ZIndex           = 17, Parent = track,
    })
    corner(knob, 11)

    local hit = make("TextButton", {
        BackgroundTransparency = 1,
        Size   = UDim2.new(1, 0, 1, 0),
        Text   = "",
        ZIndex = 18, Parent = track,
    })
    hit.MouseButton1Click:Connect(function()
        state = not state
        tw(track, { BackgroundColor3 = state and T.Accent or T.Toggle }, SPD_FAST)
        tw(knob,  { Position = UDim2.new(0, state and 23 or 2, 0.5, 0) }, SPD_FAST)
        changeActive(state and 1 or -1)
        if cb then cb(state) end
    end)

    if state then changeActive(1) end
    return row, function() return state end
end

-- ── Slider ────────────────────────────────────────────
local function addSlider(parent, name, minV, maxV, default, cb)
    local val      = default or minV
    local dragging = false
    local row      = baseRow(parent, 56)

    make("TextLabel", {
        BackgroundTransparency = 1,
        Position  = UDim2.new(0, 13, 0, 8),
        Size      = UDim2.new(0.68, 0, 0, 16),
        Text      = name,
        TextColor3 = T.Text,
        TextSize  = 13,
        Font      = FONT,
        TextXAlignment = Enum.TextXAlignment.Left,
        ZIndex    = 16, Parent = row,
    })
    local valLbl = make("TextLabel", {
        AnchorPoint  = Vector2.new(1, 0),
        BackgroundTransparency = 1,
        Position  = UDim2.new(1, -13, 0, 8),
        Size      = UDim2.new(0, 58, 0, 16),
        Text      = tostring(val),
        TextColor3 = T.AccentLight,
        TextSize  = 12,
        Font      = FONT_BOLD,
        TextXAlignment = Enum.TextXAlignment.Right,
        ZIndex    = 16, Parent = row,
    })

    local track = make("Frame", {
        BackgroundColor3 = T.Toggle,
        Position = UDim2.new(0, 13, 0, 36),
        Size     = UDim2.new(1, -26, 0, 6),
        ZIndex   = 16, Parent = row,
    })
    corner(track, 3)

    local pct  = (val - minV) / (maxV - minV)
    local fill = make("Frame", {
        BackgroundColor3 = T.Accent,
        Size             = UDim2.new(pct, 0, 1, 0),
        ZIndex           = 17, Parent = track,
    })
    corner(fill, 3)
    grad(fill, T.AccentLight, T.AccentDark, 0)

    local knob = make("Frame", {
        AnchorPoint      = Vector2.new(0.5, 0.5),
        BackgroundColor3 = T.White,
        Position         = UDim2.new(pct, 0, 0.5, 0),
        Size             = UDim2.new(0, 14, 0, 14),
        ZIndex           = 18, Parent = track,
    })
    corner(knob, 7)
    stroke(knob, T.Accent, 2)

    local hit = make("TextButton", {
        BackgroundTransparency = 1,
        Position = UDim2.new(0, -8, 0, -8),
        Size     = UDim2.new(1, 16, 1, 16),
        Text     = "",
        ZIndex   = 19, Parent = track,
    })

    local function update(x)
        local rel = math.clamp((x - track.AbsolutePosition.X) / track.AbsoluteSize.X, 0, 1)
        val = math.round(minV + (maxV - minV) * rel)
        local p = (val - minV) / (maxV - minV)
        tw(fill, { Size = UDim2.new(p, 0, 1, 0) }, 0.05)
        tw(knob, { Position = UDim2.new(p, 0, 0.5, 0) }, 0.05)
        valLbl.Text = tostring(val)
        if cb then cb(val) end
    end

    hit.MouseButton1Down:Connect(function(x) dragging = true; update(x) end)
    UserInputService.InputChanged:Connect(function(i)
        if dragging and i.UserInputType == Enum.UserInputType.MouseMovement then
            update(i.Position.X)
        end
    end)
    UserInputService.InputEnded:Connect(function(i)
        if i.UserInputType == Enum.UserInputType.MouseButton1 then dragging = false end
    end)

    return row, function() return val end
end

-- ── Dropdown ──────────────────────────────────────────
local openDrop = nil

local function addDropdown(parent, name, options, default, cb)
    local selected = default or options[1]
    local isOpen   = false
    local row      = baseRow(parent, 46)

    make("TextLabel", {
        BackgroundTransparency = 1,
        Position  = UDim2.new(0, 13, 0, 13),
        Size      = UDim2.new(0.44, 0, 0, 18),
        Text      = name,
        TextColor3 = T.Text,
        TextSize  = 13,
        Font      = FONT,
        TextXAlignment = Enum.TextXAlignment.Left,
        ZIndex    = 16, Parent = row,
    })

    local selBox = make("Frame", {
        AnchorPoint      = Vector2.new(1, 0.5),
        BackgroundColor3 = T.BG,
        Position         = UDim2.new(1, -12, 0.5, 0),
        Size             = UDim2.new(0, 132, 0, 28),
        ZIndex           = 16, Parent = row,
    })
    corner(selBox, 6)
    stroke(selBox, T.Border, 1)

    local selLbl = make("TextLabel", {
        BackgroundTransparency = 1,
        Position  = UDim2.new(0, 10, 0, 0),
        Size      = UDim2.new(1, -28, 1, 0),
        Text      = selected,
        TextColor3 = T.Text,
        TextSize  = 12,
        Font      = FONT,
        TextXAlignment = Enum.TextXAlignment.Left,
        ZIndex    = 17, Parent = selBox,
    })
    local arrowLbl = make("TextLabel", {
        AnchorPoint  = Vector2.new(1, 0.5),
        BackgroundTransparency = 1,
        Position  = UDim2.new(1, -8, 0.5, 0),
        Size      = UDim2.new(0, 16, 0, 16),
        Text      = "▾",
        TextColor3 = T.Muted,
        TextSize  = 12,
        Font      = FONT,
        ZIndex    = 17, Parent = selBox,
    })

    -- popup lives in POPUP_LAYER to escape clipping
    local OPT_H    = 28
    local visible  = math.min(#options, 5)
    local popup    = make("Frame", {
        BackgroundColor3 = Color3.fromRGB(18, 18, 30),
        Size             = UDim2.new(0, 132, 0, 0),
        ZIndex           = 95,
        Visible          = false,
        ClipsDescendants = true,
        Parent           = POPUP_LAYER,
    })
    corner(popup, 7)
    stroke(popup, T.Border, 1)

    local popList = make("Frame", {
        BackgroundTransparency = 1,
        Size    = UDim2.new(1, 0, 0, 0),
        AutomaticSize = Enum.AutomaticSize.Y,
        ZIndex  = 96, Parent = popup,
    })
    make("UIListLayout", { Padding = UDim.new(0, 2), Parent = popList })
    pad(popList, 4, 4, 4, 4)

    local function buildOpts()
        for _, opt in ipairs(options) do
            local isActive = (opt == selected)
            local ob = make("TextButton", {
                BackgroundColor3       = isActive and Color3.fromRGB(28, 20, 52) or T.BG,
                BackgroundTransparency = isActive and 0 or 1,
                Size   = UDim2.new(1, 0, 0, OPT_H),
                Text   = "",
                ZIndex = 97, Parent = popList,
            })
            corner(ob, 5)
            make("TextLabel", {
                BackgroundTransparency = 1,
                Position  = UDim2.new(0, 10, 0, 0),
                Size      = UDim2.new(1, -10, 1, 0),
                Text      = opt,
                TextColor3 = isActive and T.AccentLight or T.Text,
                TextSize  = 12,
                Font      = isActive and FONT_BOLD or FONT,
                TextXAlignment = Enum.TextXAlignment.Left,
                ZIndex    = 98, Parent = ob,
            })
            ob.MouseEnter:Connect(function()
                if not isActive then tw(ob, {BackgroundTransparency=0.85, BackgroundColor3=T.Card}, SPD_FAST) end
            end)
            ob.MouseLeave:Connect(function()
                if not isActive then tw(ob, {BackgroundTransparency=1}, SPD_FAST) end
            end)
            ob.MouseButton1Click:Connect(function()
                selected    = opt
                selLbl.Text = opt
                isOpen      = false
                tw(popup, { Size = UDim2.new(0, 132, 0, 0) }, SPD_FAST)
                tw(arrowLbl, { Rotation = 0 }, SPD_FAST)
                task.delay(SPD_FAST, function() popup.Visible = false end)
                openDrop = nil
                for _, c in ipairs(popList:GetChildren()) do
                    if c:IsA("TextButton") then c:Destroy() end
                end
                buildOpts()
                if cb then cb(selected) end
            end)
        end
    end
    buildOpts()

    local targetH = OPT_H * visible + 8 + (visible - 1) * 2 + 8

    local function openPopup()
        if openDrop and openDrop ~= popup then
            tw(openDrop, { Size = UDim2.new(0, 132, 0, 0) }, SPD_FAST)
            task.delay(SPD_FAST, function() openDrop.Visible = false end)
        end
        local ap = selBox.AbsolutePosition
        local as = selBox.AbsoluteSize
        popup.Position = UDim2.new(0, ap.X, 0, ap.Y + as.Y + 4)
        popup.Visible  = true
        tw(popup, { Size = UDim2.new(0, 132, 0, targetH) }, SPD, Enum.EasingStyle.Back, Enum.EasingDirection.Out)
        tw(arrowLbl, { Rotation = 180 }, SPD_FAST)
        openDrop = popup
        isOpen   = true
    end

    local function closePopup()
        tw(popup, { Size = UDim2.new(0, 132, 0, 0) }, SPD_FAST)
        tw(arrowLbl, { Rotation = 0 }, SPD_FAST)
        task.delay(SPD_FAST, function() popup.Visible = false end)
        openDrop = nil
        isOpen   = false
    end

    local selBtn = make("TextButton", {
        BackgroundTransparency = 1,
        Size   = UDim2.new(1, 0, 1, 0),
        Text   = "",
        ZIndex = 18, Parent = selBox,
    })
    selBtn.MouseButton1Click:Connect(function()
        if isOpen then closePopup() else openPopup() end
    end)

    UserInputService.InputBegan:Connect(function(i)
        if not isOpen or i.UserInputType ~= Enum.UserInputType.MouseButton1 then return end
        local mx, my = i.Position.X, i.Position.Y
        local p, s   = popup.AbsolutePosition, popup.AbsoluteSize
        if mx < p.X or mx > p.X + s.X or my < p.Y or my > p.Y + s.Y then
            closePopup()
        end
    end)

    return row, function() return selected end
end

-- ── Keybind ───────────────────────────────────────────
local function addKeybind(parent, name, defaultKey, cb)
    local curKey   = defaultKey or Enum.KeyCode.Unknown
    local listening = false
    local row       = baseRow(parent, 46)

    make("TextLabel", {
        BackgroundTransparency = 1,
        Position  = UDim2.new(0, 13, 0, 13),
        Size      = UDim2.new(0.55, 0, 0, 18),
        Text      = name,
        TextColor3 = T.Text,
        TextSize  = 13,
        Font      = FONT,
        TextXAlignment = Enum.TextXAlignment.Left,
        ZIndex    = 16, Parent = row,
    })

    local badge = make("TextButton", {
        AnchorPoint      = Vector2.new(1, 0.5),
        BackgroundColor3 = T.BG,
        Position         = UDim2.new(1, -12, 0.5, 0),
        Size             = UDim2.new(0, 84, 0, 28),
        Text             = curKey.Name,
        TextColor3       = T.AccentLight,
        TextSize         = 11,
        Font             = FONT_BOLD,
        ZIndex           = 17, Parent = row,
    })
    corner(badge, 6)
    stroke(badge, T.Accent, 1)

    badge.MouseButton1Click:Connect(function()
        listening          = true
        badge.Text         = "  . . ."
        badge.TextColor3   = T.Warning
        tw(badge, { BackgroundColor3 = Color3.fromRGB(28, 22, 8) }, SPD_FAST)
        tw(badge, { Size = UDim2.new(0, 84, 0, 28) }, SPD_FAST)
    end)

    UserInputService.InputBegan:Connect(function(i, gp)
        if not listening then return end
        if i.UserInputType ~= Enum.UserInputType.Keyboard then return end
        listening        = false
        curKey           = i.KeyCode
        badge.Text       = i.KeyCode.Name
        badge.TextColor3 = T.AccentLight
        tw(badge, { BackgroundColor3 = T.BG }, SPD_FAST)
        if cb then cb(curKey) end
    end)

    return row, function() return curKey end
end

-- ── Input Field ───────────────────────────────────────
local function addInput(parent, name, placeholder, cb)
    local row = baseRow(parent, 46)

    make("TextLabel", {
        BackgroundTransparency = 1,
        Position  = UDim2.new(0, 13, 0, 13),
        Size      = UDim2.new(0.42, 0, 0, 18),
        Text      = name,
        TextColor3 = T.Text,
        TextSize  = 13,
        Font      = FONT,
        TextXAlignment = Enum.TextXAlignment.Left,
        ZIndex    = 16, Parent = row,
    })

    local box = make("Frame", {
        AnchorPoint      = Vector2.new(1, 0.5),
        BackgroundColor3 = T.BG,
        Position         = UDim2.new(1, -12, 0.5, 0),
        Size             = UDim2.new(0, 150, 0, 28),
        ZIndex           = 16, Parent = row,
    })
    corner(box, 6)
    local boxStroke = stroke(box, T.Border, 1)

    local tb = make("TextBox", {
        BackgroundTransparency = 1,
        Position          = UDim2.new(0, 9, 0, 0),
        Size              = UDim2.new(1, -18, 1, 0),
        Text              = "",
        PlaceholderText   = placeholder or "Enter value...",
        PlaceholderColor3 = T.Muted,
        TextColor3        = T.Text,
        TextSize          = 12,
        Font              = FONT,
        TextXAlignment    = Enum.TextXAlignment.Left,
        ClearTextOnFocus  = false,
        ZIndex            = 17, Parent = box,
    })

    tb.Focused:Connect(function()
        tw(box, { BackgroundColor3 = Color3.fromRGB(16, 12, 30) }, SPD_FAST)
        boxStroke.Color = T.Accent
    end)
    tb.FocusLost:Connect(function(enter)
        tw(box, { BackgroundColor3 = T.BG }, SPD_FAST)
        boxStroke.Color = T.Border
        if enter and cb then cb(tb.Text) end
    end)

    return row, function() return tb.Text end
end

-- ══════════════════════════════════════════════════════
--  TAB CONTENT
-- ══════════════════════════════════════════════════════

-- MAIN ─────────────────────────────────────────────────
do
    local sc = Tabs["Main"].scroll
    local s1 = section(sc, "MOVEMENT")
    addSlider( s1, "Walk Speed",    16,  250, 16,  nil)
    addSlider( s1, "Jump Power",    50,  500, 50,  nil)
    addToggle( s1, "Fly",           "Float freely in the air",    false, nil)
    addToggle( s1, "Noclip",        "Phase through all objects",  false, nil)
    addToggle( s1, "Infinite Jump", "Jump without height limits", false, nil)
    addKeybind(s1, "Fly Hotkey",    Enum.KeyCode.F,               nil)

    local s2 = section(sc, "AUTOMATION")
    addButton( s2, "Auto Farm",    "Automatically farms resources", nil)
    addButton( s2, "Auto Collect", "Collects items in radius",      nil)
    addToggle( s2, "Anti AFK",     "Prevents inactivity kick", true,  nil)
    addSlider( s2, "Farm Radius",  10,  500, 50,  nil)
end

-- VISUAL ───────────────────────────────────────────────
do
    local sc = Tabs["Visual"].scroll
    local s1 = section(sc, "ESP")
    addToggle(  s1, "Player ESP",  "Player bounding boxes",  false, nil)
    addToggle(  s1, "Item ESP",    "Ground item highlights", false, nil)
    addToggle(  s1, "NPC ESP",     "NPC outlines",           false, nil)
    addToggle(  s1, "Name Tags",   "Floating name labels",   false, nil)
    addToggle(  s1, "Health Bars", "HP bars above players",  false, nil)
    addDropdown(s1, "ESP Color",   {"Team","White","Red","Purple","Cyan"}, "Team", nil)

    local s2 = section(sc, "RENDERING")
    addSlider( s2, "Field of View",     60, 130, 70,  nil)
    addSlider( s2, "Render Distance",  100, 2048,512, nil)
    addToggle( s2, "Fullbright",   "Remove all darkness",   false, nil)
    addToggle( s2, "No Fog",       "Clear weather fog",     false, nil)
end

-- WORLD ────────────────────────────────────────────────
do
    local sc = Tabs["World"].scroll
    local s1 = section(sc, "PHYSICS")
    addSlider(  s1, "Gravity",          0,   400, 196, nil)
    addSlider(  s1, "Wind Speed",       0,   100, 0,   nil)
    addToggle(  s1, "Freeze Players",   "Pause all players",     false, nil)
    addToggle(  s1, "No Clip",          "Phase through objects", false, nil)
    addInput(   s1, "Custom Gravity",   "e.g. 196.2",            nil)

    local s2 = section(sc, "TIME & WEATHER")
    addSlider(  s2, "Time of Day",   0,  24, 12,   nil)
    addToggle(  s2, "Lock Time",     "Freeze time progression", false, nil)
    addDropdown(s2, "Weather",       {"Clear","Fog","Rain","Snow","Storm"}, "Clear", nil)
    addButton(  s2, "Set Sunrise",   "Jump to 06:00",  nil)
    addButton(  s2, "Set Midnight",  "Jump to 00:00",  nil)
end

-- PLAYER ───────────────────────────────────────────────
do
    local sc = Tabs["Player"].scroll
    local s1 = section(sc, "CHARACTER")
    addSlider(  s1, "Health",         0,   100, 100, nil)
    addSlider(  s1, "Walk Speed",     16,  250, 16,  nil)
    addToggle(  s1, "God Mode",       "Take no damage",    false, nil)
    addToggle(  s1, "Invisible",      "Become invisible",  false, nil)
    addToggle(  s1, "Always Sprint",  "Permanent sprint",  false, nil)

    local s2 = section(sc, "TELEPORT")
    addDropdown(s2, "Target",        {"Nearest","Random","Manual"}, "Nearest", nil)
    addButton(  s2, "To Spawn",       "Teleport to spawn point", nil)
    addButton(  s2, "To Cursor",      "Teleport to mouse hit",   nil)
    addButton(  s2, "To Player",      "Teleport to selection",   nil)
    addKeybind( s2, "Teleport Key",   Enum.KeyCode.T,            nil)
end

-- MISC ─────────────────────────────────────────────────
do
    local sc = Tabs["Misc"].scroll
    local s1 = section(sc, "UTILITY")
    addButton(  s1, "Rejoin",          "Reconnect to this server",    nil)
    addButton(  s1, "Server Hop",      "Join a different server",     nil)
    addButton(  s1, "Copy Join Link",  "Copy game link to clipboard", nil)
    addToggle(  s1, "Debug Info",      "Show FPS & debug overlay",    false, nil)

    local s2 = section(sc, "INTERFACE")
    addToggle(  s2, "Watermark",       "Show watermark in corner",    true,  nil)
    addDropdown(s2, "Theme",           {"Dark","Darker","AMOLED"},    "Dark", nil)
    addSlider(  s2, "UI Opacity",      40,  100, 100, nil)
    addKeybind( s2, "Toggle Hub",      Enum.KeyCode.Insert,           nil)
end

-- ── Activate first tab ────────────────────────────────
setTab("Main")

-- ══════════════════════════════════════════════════════
--  DRAG
-- ══════════════════════════════════════════════════════
do
    local drag, ds, sp = false, nil, nil
    TITLEBAR.InputBegan:Connect(function(i)
        if i.UserInputType == Enum.UserInputType.MouseButton1 then
            drag = true; ds = i.Position; sp = WIN.Position
        end
    end)
    UserInputService.InputChanged:Connect(function(i)
        if drag and i.UserInputType == Enum.UserInputType.MouseMovement then
            local d = i.Position - ds
            WIN.Position = UDim2.new(sp.X.Scale, sp.X.Offset + d.X,
                                     sp.Y.Scale, sp.Y.Offset + d.Y)
        end
    end)
    UserInputService.InputEnded:Connect(function(i)
        if i.UserInputType == Enum.UserInputType.MouseButton1 then drag = false end
    end)
end

-- ══════════════════════════════════════════════════════
--  WINDOW CONTROLS
-- ══════════════════════════════════════════════════════
local minimized = false
BTN_MINIMIZE.MouseButton1Click:Connect(function()
    minimized = not minimized
    tw(WIN,
        { Size = minimized and UDim2.new(0, 610, 0, 50) or UDim2.new(0, 610, 0, 460) },
        SPD, Enum.EasingStyle.Quart)
end)

local visible = true
local function hideWin()
    visible = false
    tw(WIN, { Size = UDim2.new(0, 610, 0, 0), BackgroundTransparency = 1 }, SPD)
    task.delay(SPD + 0.05, function() WIN.Visible = false end)
end
local function showWin()
    visible = true
    WIN.Visible = true
    tw(WIN, { Size = UDim2.new(0, 610, 0, 460), BackgroundTransparency = 0 },
        0.36, Enum.EasingStyle.Back, Enum.EasingDirection.Out)
end

BTN_CLOSE.MouseButton1Click:Connect(hideWin)

UserInputService.InputBegan:Connect(function(i, gp)
    if gp then return end
    if i.KeyCode == Enum.KeyCode.Insert then
        if visible then hideWin() else showWin() end
    end
end)

-- ══════════════════════════════════════════════════════
--  OPEN ANIMATION
-- ══════════════════════════════════════════════════════
WIN.Size                   = UDim2.new(0, 610, 0, 0)
WIN.BackgroundTransparency = 1
task.defer(function()
    task.wait(0.2)
    tw(WIN, { Size = UDim2.new(0, 610, 0, 460), BackgroundTransparency = 0 },
        0.4, Enum.EasingStyle.Back, Enum.EasingDirection.Out)
    task.wait(0.5)
    notify("ScriptHub", "Loaded  •  press INSERT to toggle", "success", 4)
end)
