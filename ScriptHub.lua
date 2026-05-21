-- ═══════════════════════════════════════════════
--   ScriptHub  |  Custom UI  |  No Libraries
-- ═══════════════════════════════════════════════

local Players          = game:GetService("Players")
local TweenService     = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")

local LocalPlayer = Players.LocalPlayer
local PlayerGui   = LocalPlayer:WaitForChild("PlayerGui")

-- ── Theme ────────────────────────────────────────
local T = {
    BG          = Color3.fromRGB(10,  10,  16 ),
    Surface     = Color3.fromRGB(16,  16,  26 ),
    Card        = Color3.fromRGB(20,  20,  32 ),
    CardHover   = Color3.fromRGB(26,  26,  40 ),
    Accent      = Color3.fromRGB(112, 72,  255),
    AccentDark  = Color3.fromRGB(80,  48,  200),
    AccentLight = Color3.fromRGB(160, 110, 255),
    Text        = Color3.fromRGB(235, 235, 255),
    Muted       = Color3.fromRGB(110, 110, 148),
    Border      = Color3.fromRGB(36,  36,  56 ),
    Toggle      = Color3.fromRGB(46,  46,  70 ),
    Success     = Color3.fromRGB(72,  200, 130),
    White       = Color3.fromRGB(255, 255, 255),
}
local FONT      = Enum.Font.GothamMedium
local FONT_BOLD = Enum.Font.GothamBold
local SPD       = 0.18   -- normal tween
local SPD_FAST  = 0.10   -- fast tween

-- ── Helpers ──────────────────────────────────────
local function tween(obj, props, dur, style, dir)
    TweenService:Create(obj,
        TweenInfo.new(dur or SPD, style or Enum.EasingStyle.Quart, dir or Enum.EasingDirection.Out),
        props):Play()
end

local function make(class, props)
    local o = Instance.new(class)
    for k, v in pairs(props) do
        if k ~= "Parent" then o[k] = v end
    end
    if props.Parent then o.Parent = props.Parent end
    return o
end

local function corner(p, r)
    local c = Instance.new("UICorner")
    c.CornerRadius = UDim.new(0, r or 8)
    c.Parent = p
    return c
end

local function stroke(p, col, thick)
    local s = Instance.new("UIStroke")
    s.Color             = col   or T.Border
    s.Thickness         = thick or 1
    s.ApplyStrokeMode   = Enum.ApplyStrokeMode.Border
    s.Parent            = p
    return s
end

local function pad(p, t, b, l, r)
    local u = Instance.new("UIPadding")
    u.PaddingTop    = UDim.new(0, t or 8)
    u.PaddingBottom = UDim.new(0, b or 8)
    u.PaddingLeft   = UDim.new(0, l or 8)
    u.PaddingRight  = UDim.new(0, r or 8)
    u.Parent        = p
    return u
end

local function gradient(p, c0, c1, rot)
    local g = Instance.new("UIGradient")
    g.Color    = ColorSequence.new(c0, c1)
    g.Rotation = rot or 135
    g.Parent   = p
    return g
end

-- ── Root ─────────────────────────────────────────
local GUI = make("ScreenGui", {
    Name              = "ScriptHub",
    ResetOnSpawn      = false,
    ZIndexBehavior    = Enum.ZIndexBehavior.Sibling,
    IgnoreGuiInset    = true,
    Parent            = PlayerGui,
})

-- ── Main Window ──────────────────────────────────
local WIN = make("Frame", {
    Name            = "Window",
    AnchorPoint     = Vector2.new(0.5, 0.5),
    BackgroundColor3 = T.BG,
    Position        = UDim2.new(0.5, 0, 0.5, 0),
    Size            = UDim2.new(0, 600, 0, 440),
    ZIndex          = 10,
    ClipsDescendants = true,
    Parent          = GUI,
})
corner(WIN, 14)
stroke(WIN, T.Border, 1)
gradient(WIN, Color3.fromRGB(18, 12, 34), T.BG, 145)

-- subtle glow border (outer ring via ImageLabel shadow)
local GLOW = make("ImageLabel", {
    Name               = "Glow",
    AnchorPoint        = Vector2.new(0.5, 0.5),
    BackgroundTransparency = 1,
    Position           = UDim2.new(0.5, 0, 0.5, 3),
    Size               = UDim2.new(1, 40, 1, 40),
    ZIndex             = 9,
    Image              = "rbxassetid://6014261993",
    ImageColor3        = T.Accent,
    ImageTransparency  = 0.82,
    ScaleType          = Enum.ScaleType.Slice,
    SliceCenter        = Rect.new(49, 49, 450, 450),
    Parent             = WIN,
})

-- ── Title Bar ────────────────────────────────────
local TITLEBAR = make("Frame", {
    Name             = "TitleBar",
    BackgroundColor3 = T.Surface,
    Size             = UDim2.new(1, 0, 0, 50),
    ZIndex           = 12,
    Parent           = WIN,
})
corner(TITLEBAR, 14)
-- fill bottom corners
make("Frame", {
    BackgroundColor3 = T.Surface,
    Position         = UDim2.new(0, 0, 0.5, 0),
    Size             = UDim2.new(1, 0, 0.5, 0),
    ZIndex           = 12,
    Parent           = TITLEBAR,
})
gradient(TITLEBAR, Color3.fromRGB(20, 14, 38), T.Surface, 0)

-- accent underline
local TITLE_LINE = make("Frame", {
    BackgroundColor3 = T.Accent,
    Position         = UDim2.new(0, 0, 1, -2),
    Size             = UDim2.new(1, 0, 0, 2),
    ZIndex           = 14,
    Parent           = TITLEBAR,
})
gradient(TITLE_LINE, T.Accent, T.AccentDark, 0)

-- logo badge
local LOGO = make("Frame", {
    BackgroundColor3 = T.Accent,
    Position         = UDim2.new(0, 14, 0.5, -15),
    Size             = UDim2.new(0, 30, 0, 30),
    ZIndex           = 14,
    Parent           = TITLEBAR,
})
corner(LOGO, 9)
gradient(LOGO, T.AccentLight, T.AccentDark, 135)
make("TextLabel", {
    BackgroundTransparency = 1,
    Size        = UDim2.new(1, 0, 1, 0),
    Text        = "S",
    TextColor3  = T.White,
    TextSize    = 17,
    Font        = FONT_BOLD,
    ZIndex      = 15,
    Parent      = LOGO,
})

-- title + sub
make("TextLabel", {
    BackgroundTransparency = 1,
    Position    = UDim2.new(0, 54, 0, 7),
    Size        = UDim2.new(0.5, 0, 0, 20),
    Text        = "ScriptHub",
    TextColor3  = T.Text,
    TextSize    = 15,
    Font        = FONT_BOLD,
    TextXAlignment = Enum.TextXAlignment.Left,
    ZIndex      = 14,
    Parent      = TITLEBAR,
})
make("TextLabel", {
    BackgroundTransparency = 1,
    Position    = UDim2.new(0, 54, 0, 27),
    Size        = UDim2.new(0.5, 0, 0, 14),
    Text        = "v1.0  •  Free",
    TextColor3  = T.Muted,
    TextSize    = 10,
    Font        = FONT,
    TextXAlignment = Enum.TextXAlignment.Left,
    ZIndex      = 14,
    Parent      = TITLEBAR,
})

-- window controls (macOS style)
local CTRL = make("Frame", {
    BackgroundTransparency = 1,
    AnchorPoint  = Vector2.new(1, 0.5),
    Position     = UDim2.new(1, -14, 0.5, 0),
    Size         = UDim2.new(0, 72, 0, 18),
    ZIndex       = 14,
    Parent       = TITLEBAR,
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
        Size             = UDim2.new(0, 14, 0, 14),
        Text             = "",
        ZIndex           = 15,
        Parent           = CTRL,
    })
    corner(b, 7)
    b.MouseEnter:Connect(function() tween(b, {BackgroundTransparency=0.3}, SPD_FAST) end)
    b.MouseLeave:Connect(function() tween(b, {BackgroundTransparency=0  }, SPD_FAST) end)
    return b
end
local BTN_CLOSE    = ctrlBtn(Color3.fromRGB(255, 70,  70 ))
local BTN_MINIMIZE = ctrlBtn(Color3.fromRGB(255, 185, 45 ))

-- ── Sidebar ──────────────────────────────────────
local SIDEBAR = make("Frame", {
    Name             = "Sidebar",
    BackgroundColor3 = T.Surface,
    Position         = UDim2.new(0, 0, 0, 50),
    Size             = UDim2.new(0, 158, 1, -50),
    ZIndex           = 11,
    Parent           = WIN,
})
make("Frame", {  -- right separator
    BackgroundColor3 = T.Border,
    AnchorPoint      = Vector2.new(1, 0),
    Position         = UDim2.new(1, 0, 0, 0),
    Size             = UDim2.new(0, 1, 1, 0),
    ZIndex           = 12,
    Parent           = SIDEBAR,
})
gradient(SIDEBAR, T.Surface, Color3.fromRGB(13, 13, 22), 90)

local TAB_LIST = make("Frame", {
    BackgroundTransparency = 1,
    Size    = UDim2.new(1, 0, 1, 0),
    ZIndex  = 12,
    Parent  = SIDEBAR,
})
make("UIListLayout", {
    FillDirection = Enum.FillDirection.Vertical,
    Padding       = UDim.new(0, 3),
    Parent        = TAB_LIST,
})
pad(TAB_LIST, 10, 10, 10, 10)

-- active indicator pill
local TAB_IND = make("Frame", {
    BackgroundColor3 = T.Accent,
    Position         = UDim2.new(0, 0, 0, 20),
    Size             = UDim2.new(0, 3, 0, 30),
    ZIndex           = 15,
    Parent           = SIDEBAR,
})
corner(TAB_IND, 2)

-- ── Content area ─────────────────────────────────
local CONTENT = make("Frame", {
    BackgroundTransparency = 1,
    Position = UDim2.new(0, 158, 0, 50),
    Size     = UDim2.new(1, -158, 1, -50),
    ZIndex   = 11,
    Parent   = WIN,
})

-- ── Tab system ───────────────────────────────────
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
        tween(old.btn,   { BackgroundTransparency = 1,    BackgroundColor3 = T.Card }, SPD)
        tween(old.icon,  { TextColor3 = T.Muted }, SPD)
        tween(old.lbl,   { TextColor3 = T.Muted, Font = FONT }, SPD)
        old.page.Visible = false
    end

    ActiveTab = id
    tween(tab.btn,  { BackgroundTransparency = 0,    BackgroundColor3 = Color3.fromRGB(28, 20, 50) }, SPD)
    tween(tab.icon, { TextColor3 = T.AccentLight }, SPD)
    tween(tab.lbl,  { TextColor3 = T.Text, Font = FONT_BOLD }, SPD)
    tab.page.Visible = true

    -- slide indicator
    local btnY    = tab.btn.AbsolutePosition.Y - SIDEBAR.AbsolutePosition.Y
    local btnH    = tab.btn.AbsoluteSize.Y
    tween(TAB_IND, { Position = UDim2.new(0, 0, 0, btnY + (btnH - 30) / 2) }, SPD)
end

local function newTab(def)
    -- sidebar button
    local btn = make("TextButton", {
        BackgroundColor3    = T.Card,
        BackgroundTransparency = 1,
        Size                = UDim2.new(1, 0, 0, 38),
        Text                = "",
        ZIndex              = 13,
        Parent              = TAB_LIST,
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
        ZIndex    = 14,
        Parent    = btn,
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
        ZIndex    = 14,
        Parent    = btn,
    })

    -- page
    local page = make("ScrollingFrame", {
        BackgroundTransparency = 1,
        Size                   = UDim2.new(1, 0, 1, 0),
        ScrollBarThickness     = 3,
        ScrollBarImageColor3   = T.Accent,
        CanvasSize             = UDim2.new(0, 0, 0, 0),
        AutomaticCanvasSize    = Enum.AutomaticSize.Y,
        ZIndex                 = 12,
        Visible                = false,
        Parent                 = CONTENT,
    })
    pad(page, 14, 14, 14, 14)
    make("UIListLayout", {
        FillDirection = Enum.FillDirection.Vertical,
        Padding       = UDim.new(0, 10),
        SortOrder     = Enum.SortOrder.LayoutOrder,
        Parent        = page,
    })

    Tabs[def.id] = { btn = btn, icon = ico, lbl = lbl, page = page }

    btn.MouseButton1Click:Connect(function() setTab(def.id) end)
    btn.MouseEnter:Connect(function()
        if ActiveTab ~= def.id then
            tween(btn, { BackgroundTransparency = 0.88 }, SPD_FAST)
        end
    end)
    btn.MouseLeave:Connect(function()
        if ActiveTab ~= def.id then
            tween(btn, { BackgroundTransparency = 1 }, SPD_FAST)
        end
    end)
end

for _, d in ipairs(TAB_DEFS) do newTab(d) end

-- ── Component builders ───────────────────────────

-- Section header
local function section(parent, title)
    local wrap = make("Frame", {
        BackgroundColor3 = T.Card,
        Size             = UDim2.new(1, 0, 0, 0),
        AutomaticSize    = Enum.AutomaticSize.Y,
        ZIndex           = 13,
        Parent           = parent,
    })
    corner(wrap, 9)
    stroke(wrap, T.Border, 1)

    local hdr = make("Frame", {
        BackgroundTransparency = 1,
        Size    = UDim2.new(1, 0, 0, 34),
        ZIndex  = 14,
        Parent  = wrap,
    })
    local pill = make("Frame", {
        BackgroundColor3 = T.Accent,
        Position = UDim2.new(0, 12, 0.5, -7),
        Size     = UDim2.new(0, 3, 0, 14),
        ZIndex   = 15,
        Parent   = hdr,
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
        ZIndex    = 15,
        Parent    = hdr,
    })

    local items = make("Frame", {
        BackgroundTransparency = 1,
        Position  = UDim2.new(0, 0, 0, 34),
        Size      = UDim2.new(1, 0, 0, 0),
        AutomaticSize = Enum.AutomaticSize.Y,
        ZIndex    = 14,
        Parent    = wrap,
    })
    make("UIListLayout", {
        FillDirection = Enum.FillDirection.Vertical,
        Padding       = UDim.new(0, 2),
        Parent        = items,
    })
    pad(items, 0, 10, 10, 10)

    return items
end

-- Row base (shared chrome)
local function baseRow(parent, h)
    local row = make("Frame", {
        BackgroundColor3 = T.Surface,
        Size             = UDim2.new(1, 0, 0, h or 46),
        ZIndex           = 15,
        Parent           = parent,
    })
    corner(row, 7)
    stroke(row, Color3.fromRGB(30, 30, 48), 1)
    return row
end

-- Button
local function addButton(parent, name, desc, cb)
    local row = baseRow(parent, 46)

    make("TextLabel", {
        BackgroundTransparency = 1,
        Position  = UDim2.new(0, 13, 0, 5),
        Size      = UDim2.new(0.6, 0, 0, 18),
        Text      = name,
        TextColor3 = T.Text,
        TextSize  = 13,
        Font      = FONT,
        TextXAlignment = Enum.TextXAlignment.Left,
        ZIndex    = 16,
        Parent    = row,
    })
    if desc then
        make("TextLabel", {
            BackgroundTransparency = 1,
            Position  = UDim2.new(0, 13, 0, 24),
            Size      = UDim2.new(0.6, 0, 0, 14),
            Text      = desc,
            TextColor3 = T.Muted,
            TextSize  = 10,
            Font      = FONT,
            TextXAlignment = Enum.TextXAlignment.Left,
            ZIndex    = 16,
            Parent    = row,
        })
    end

    local btn = make("TextButton", {
        AnchorPoint      = Vector2.new(1, 0.5),
        BackgroundColor3 = T.Accent,
        Position         = UDim2.new(1, -12, 0.5, 0),
        Size             = UDim2.new(0, 82, 0, 28),
        Text             = "Run",
        TextColor3       = T.White,
        TextSize         = 12,
        Font             = FONT_BOLD,
        ZIndex           = 17,
        Parent           = row,
    })
    corner(btn, 7)
    gradient(btn, T.AccentLight, T.AccentDark, 90)

    btn.MouseEnter:Connect(function()  tween(btn, {Size=UDim2.new(0,86,0,30)}, SPD_FAST) end)
    btn.MouseLeave:Connect(function()  tween(btn, {Size=UDim2.new(0,82,0,28)}, SPD_FAST) end)
    btn.MouseButton1Down:Connect(function()  tween(btn, {Size=UDim2.new(0,78,0,26)}, 0.07) end)
    btn.MouseButton1Up:Connect(function()    tween(btn, {Size=UDim2.new(0,82,0,28)}, SPD_FAST) end)
    btn.MouseButton1Click:Connect(function() if cb then cb() end end)

    return row
end

-- Toggle
local function addToggle(parent, name, desc, default, cb)
    local state = default == true
    local row   = baseRow(parent, 46)

    make("TextLabel", {
        BackgroundTransparency = 1,
        Position  = UDim2.new(0, 13, 0, 5),
        Size      = UDim2.new(0.65, 0, 0, 18),
        Text      = name,
        TextColor3 = T.Text,
        TextSize  = 13,
        Font      = FONT,
        TextXAlignment = Enum.TextXAlignment.Left,
        ZIndex    = 16,
        Parent    = row,
    })
    if desc then
        make("TextLabel", {
            BackgroundTransparency = 1,
            Position  = UDim2.new(0, 13, 0, 24),
            Size      = UDim2.new(0.65, 0, 0, 14),
            Text      = desc,
            TextColor3 = T.Muted,
            TextSize  = 10,
            Font      = FONT,
            TextXAlignment = Enum.TextXAlignment.Left,
            ZIndex    = 16,
            Parent    = row,
        })
    end

    local track = make("Frame", {
        AnchorPoint      = Vector2.new(1, 0.5),
        BackgroundColor3 = state and T.Accent or T.Toggle,
        Position         = UDim2.new(1, -13, 0.5, 0),
        Size             = UDim2.new(0, 46, 0, 25),
        ZIndex           = 16,
        Parent           = row,
    })
    corner(track, 13)

    local knob = make("Frame", {
        AnchorPoint      = Vector2.new(0, 0.5),
        BackgroundColor3 = T.White,
        Position         = UDim2.new(0, state and 23 or 2, 0.5, 0),
        Size             = UDim2.new(0, 21, 0, 21),
        ZIndex           = 17,
        Parent           = track,
    })
    corner(knob, 11)

    local hitbox = make("TextButton", {
        BackgroundTransparency = 1,
        Size   = UDim2.new(1, 0, 1, 0),
        Text   = "",
        ZIndex = 18,
        Parent = track,
    })
    hitbox.MouseButton1Click:Connect(function()
        state = not state
        tween(track, { BackgroundColor3 = state and T.Accent or T.Toggle }, SPD_FAST)
        tween(knob,  { Position = UDim2.new(0, state and 23 or 2, 0.5, 0) }, SPD_FAST)
        if cb then cb(state) end
    end)

    return row, function() return state end
end

-- Slider
local function addSlider(parent, name, minV, maxV, default, cb)
    local val      = default or minV
    local dragging = false
    local row      = baseRow(parent, 56)

    make("TextLabel", {
        BackgroundTransparency = 1,
        Position  = UDim2.new(0, 13, 0, 8),
        Size      = UDim2.new(0.7, 0, 0, 16),
        Text      = name,
        TextColor3 = T.Text,
        TextSize  = 13,
        Font      = FONT,
        TextXAlignment = Enum.TextXAlignment.Left,
        ZIndex    = 16,
        Parent    = row,
    })

    local valLbl = make("TextLabel", {
        AnchorPoint  = Vector2.new(1, 0),
        BackgroundTransparency = 1,
        Position  = UDim2.new(1, -13, 0, 8),
        Size      = UDim2.new(0, 56, 0, 16),
        Text      = tostring(val),
        TextColor3 = T.AccentLight,
        TextSize  = 12,
        Font      = FONT_BOLD,
        TextXAlignment = Enum.TextXAlignment.Right,
        ZIndex    = 16,
        Parent    = row,
    })

    local track = make("Frame", {
        BackgroundColor3 = T.Toggle,
        Position = UDim2.new(0, 13, 0, 36),
        Size     = UDim2.new(1, -26, 0, 6),
        ZIndex   = 16,
        Parent   = row,
    })
    corner(track, 3)

    local pct  = (val - minV) / (maxV - minV)
    local fill = make("Frame", {
        BackgroundColor3 = T.Accent,
        Size             = UDim2.new(pct, 0, 1, 0),
        ZIndex           = 17,
        Parent           = track,
    })
    corner(fill, 3)
    gradient(fill, T.AccentLight, T.AccentDark, 0)

    local knob = make("Frame", {
        AnchorPoint      = Vector2.new(0.5, 0.5),
        BackgroundColor3 = T.White,
        Position         = UDim2.new(pct, 0, 0.5, 0),
        Size             = UDim2.new(0, 14, 0, 14),
        ZIndex           = 18,
        Parent           = track,
    })
    corner(knob, 7)
    stroke(knob, T.Accent, 2)

    local hit = make("TextButton", {
        BackgroundTransparency = 1,
        Position = UDim2.new(0, -8, 0, -8),
        Size     = UDim2.new(1, 16, 1, 16),
        Text     = "",
        ZIndex   = 19,
        Parent   = track,
    })

    local function update(x)
        local rel = math.clamp((x - track.AbsolutePosition.X) / track.AbsoluteSize.X, 0, 1)
        val       = math.round(minV + (maxV - minV) * rel)
        local p   = (val - minV) / (maxV - minV)
        tween(fill,  { Size     = UDim2.new(p, 0, 1, 0)       }, 0.05)
        tween(knob,  { Position = UDim2.new(p, 0, 0.5, 0)     }, 0.05)
        valLbl.Text = tostring(val)
        if cb then cb(val) end
    end

    hit.MouseButton1Down:Connect(function(x) dragging = true; update(x) end)
    UserInputService.InputChanged:Connect(function(inp)
        if dragging and inp.UserInputType == Enum.UserInputType.MouseMovement then
            update(inp.Position.X)
        end
    end)
    UserInputService.InputEnded:Connect(function(inp)
        if inp.UserInputType == Enum.UserInputType.MouseButton1 then dragging = false end
    end)

    return row, function() return val end
end

-- Separator label (light divider inside a section)
local function addDivider(parent, label)
    local row = make("Frame", {
        BackgroundTransparency = 1,
        Size   = UDim2.new(1, 0, 0, 18),
        ZIndex = 15,
        Parent = parent,
    })
    if label then
        make("TextLabel", {
            BackgroundTransparency = 1,
            Size      = UDim2.new(1, 0, 1, 0),
            Text      = label,
            TextColor3 = T.Muted,
            TextSize  = 10,
            Font      = FONT_BOLD,
            TextXAlignment = Enum.TextXAlignment.Left,
            ZIndex    = 16,
            Parent    = row,
        })
    end
    make("Frame", {
        AnchorPoint      = Vector2.new(0, 0.5),
        BackgroundColor3 = T.Border,
        Position         = UDim2.new(0, 0, 0.5, 0),
        Size             = UDim2.new(1, 0, 0, 1),
        ZIndex           = 16,
        Parent           = row,
    })
    return row
end

-- ── Tab Content ──────────────────────────────────

-- MAIN
do
    local p = Tabs["Main"].page
    local s = section(p, "MOVEMENT")
    addSlider(s,  "Walk Speed",    16,  250, 16,  nil)
    addSlider(s,  "Jump Power",    50,  500, 50,  nil)
    addToggle(s,  "Fly",           "Float freely",           false, nil)
    addToggle(s,  "Noclip",        "Phase through walls",    false, nil)
    addToggle(s,  "Infinite Jump", "Jump without limits",    false, nil)

    local s2 = section(p, "AUTOMATION")
    addButton(s2, "Auto Farm",     "Farms resources automatically",  nil)
    addButton(s2, "Auto Collect",  "Collects nearby items",          nil)
    addToggle(s2, "Anti AFK",      "Prevents inactivity kick",  true,  nil)
end

-- VISUAL
do
    local p = Tabs["Visual"].page
    local s = section(p, "ESP")
    addToggle(s, "Player ESP",   "Player bounding boxes",  false, nil)
    addToggle(s, "Item ESP",     "Ground item highlights", false, nil)
    addToggle(s, "NPC ESP",      "NPC outlines",           false, nil)
    addToggle(s, "Name Tags",    "Floating name labels",   false, nil)
    addToggle(s, "Health Bars",  "Show player HP",         false, nil)

    local s2 = section(p, "RENDERING")
    addSlider( s2, "Field of View",      60,  130, 70,  nil)
    addSlider( s2, "Render Distance",   100, 2048, 512, nil)
    addToggle( s2, "Fullbright",   "Remove darkness",       false, nil)
    addToggle( s2, "No Fog",       "Clear weather fog",     false, nil)
end

-- WORLD
do
    local p = Tabs["World"].page
    local s = section(p, "PHYSICS")
    addSlider( s, "Gravity",        0,  400, 196, nil)
    addSlider( s, "Wind Speed",     0,  100, 0,   nil)
    addToggle( s, "Freeze Players", "Freeze others",   false, nil)
    addToggle( s, "No Clip",        "Phase through objects", false, nil)

    local s2 = section(p, "TIME & WEATHER")
    addSlider( s2, "Time of Day",   0,  24,  12,  nil)
    addToggle( s2, "Lock Time",     "Freeze time",     false, nil)
    addButton( s2, "Set Sunrise",   "Jump to 06:00",   nil)
    addButton( s2, "Set Midnight",  "Jump to 00:00",   nil)
end

-- PLAYER
do
    local p = Tabs["Player"].page
    local s = section(p, "CHARACTER")
    addSlider( s, "Health",   0, 100, 100, nil)
    addToggle( s, "God Mode",    "Take no damage",  false, nil)
    addToggle( s, "Invisible",   "Become invisible",false, nil)
    addToggle( s, "Always Sprint","Permanent sprint",false, nil)

    local s2 = section(p, "TELEPORT")
    addButton( s2, "To Spawn",      "Teleport to spawn", nil)
    addButton( s2, "To Cursor",     "Teleport to mouse", nil)
    addButton( s2, "To Random Player","Teleport to a player",nil)
end

-- MISC
do
    local p = Tabs["Misc"].page
    local s = section(p, "UTILITY")
    addButton(s, "Rejoin",        "Reconnect to server",         nil)
    addButton(s, "Copy Join Link","Copy game link to clipboard", nil)
    addToggle(s, "Debug Info",    "Show FPS & debug overlay",    false, nil)

    local s2 = section(p, "INTERFACE")
    addToggle( s2, "Show Hub",     "Toggle this window",    true, nil)
    addSlider( s2, "UI Scale",     60,  150, 100, nil)
    addSlider( s2, "UI Opacity",   40,  100, 100, nil)
end

-- ── Activate first tab ───────────────────────────
setTab("Main")

-- ── Drag ─────────────────────────────────────────
do
    local dragging, dragStart, startPos = false, nil, nil
    TITLEBAR.InputBegan:Connect(function(inp)
        if inp.UserInputType == Enum.UserInputType.MouseButton1 then
            dragging  = true
            dragStart = inp.Position
            startPos  = WIN.Position
        end
    end)
    UserInputService.InputChanged:Connect(function(inp)
        if dragging and inp.UserInputType == Enum.UserInputType.MouseMovement then
            local d = inp.Position - dragStart
            WIN.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + d.X,
                                     startPos.Y.Scale, startPos.Y.Offset + d.Y)
        end
    end)
    UserInputService.InputEnded:Connect(function(inp)
        if inp.UserInputType == Enum.UserInputType.MouseButton1 then
            dragging = false
        end
    end)
end

-- ── Window controls ──────────────────────────────
local minimized = false
BTN_MINIMIZE.MouseButton1Click:Connect(function()
    minimized = not minimized
    tween(WIN, { Size = minimized
        and UDim2.new(0, 600, 0, 50)
        or  UDim2.new(0, 600, 0, 440)
    }, SPD, Enum.EasingStyle.Quart)
end)

local visible = true
BTN_CLOSE.MouseButton1Click:Connect(function()
    visible = false
    tween(WIN, { Size = UDim2.new(0, 600, 0, 0), BackgroundTransparency = 1 }, SPD)
    task.delay(SPD + 0.05, function() WIN.Visible = false end)
end)

UserInputService.InputBegan:Connect(function(inp, gp)
    if gp then return end
    if inp.KeyCode == Enum.KeyCode.Insert then
        visible = not visible
        WIN.Visible = true
        if visible then
            tween(WIN, { Size = UDim2.new(0, 600, 0, 440), BackgroundTransparency = 0 },
                SPD, Enum.EasingStyle.Back, Enum.EasingDirection.Out)
        else
            tween(WIN, { Size = UDim2.new(0, 600, 0, 0), BackgroundTransparency = 1 }, SPD)
            task.delay(SPD + 0.05, function() WIN.Visible = false end)
        end
    end
end)

-- ── Open animation ───────────────────────────────
WIN.Size                = UDim2.new(0, 600, 0, 0)
WIN.BackgroundTransparency = 1
task.defer(function()
    tween(WIN,
        { Size = UDim2.new(0, 600, 0, 440), BackgroundTransparency = 0 },
        0.38, Enum.EasingStyle.Back, Enum.EasingDirection.Out)
end)
