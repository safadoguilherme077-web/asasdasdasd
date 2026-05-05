-- 🔐 KEY SYSTEM ONLINE
local HttpService = game:GetService("HttpService")

local KEYS_URL = "https://akiescirpt-production.up.railway.app/keys"

local function getKeys()
    local success, result = pcall(function()
        return HttpService:JSONDecode(game:HttpGet(KEYS_URL))
    end)

    return success and result or {}
end

local function verificarKey(key, Keys)
    local data = Keys[key]

    if not data then return "invalid" end
    if data == "perm" then return "valid" end
    if os.time()*1000 > data then return "expired" end

    return "valid"
end

---------------------------------------------------
-- 🎮 RAYFIELD KEY MENU
---------------------------------------------------
local Rayfield = loadstring(game:HttpGet("https://sirius.menu/rayfield"))()

local Window = Rayfield:CreateWindow({
    Name = "Sistema de Key",
    LoadingTitle = "Verificando...",
    LoadingSubtitle = "Digite sua key",
    ConfigurationSaving = {Enabled = false}
})

local KeyTab = Window:CreateTab("Key")
local keyInput = ""

KeyTab:CreateInput({
    Name = "Digite sua key",
    PlaceholderText = "KEY AQUI",
    Callback = function(text)
        keyInput = text
    end
})

---------------------------------------------------
-- 🔓 SCRIPT PRINCIPAL
---------------------------------------------------
local function startScript()

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local Workspace = game:GetService("Workspace")

local LP = Players.LocalPlayer
local Camera = Workspace.CurrentCamera

---------------------------------------------------
-- ⚙️ SETTINGS
---------------------------------------------------
local settings = {
    ESP = true,
    AimAssist = false,
    WallCheck = true,
    AimStrength = 0.12,
    FOV = 120,
    TeamCheck = true,

    Fly = false,
    FlySpeed = 50,

    HeroFly = false,
    HeroSpeed = 200,

    AlignToCamera = true -- 🔥 FIX ROTAÇÃO
}

local aiming = false
local highlights = {}

---------------------------------------------------
-- 🎮 MENU
---------------------------------------------------
local Window = Rayfield:CreateWindow({
    Name = "FPS System",
    LoadingTitle = "Loading...",
    LoadingSubtitle = "Client Menu",
    ConfigurationSaving = {Enabled = false}
})

local CombatTab = Window:CreateTab("Combat")
local MoveTab = Window:CreateTab("Movement")

---------------------------------------------------
-- ⚔️ COMBAT
---------------------------------------------------
CombatTab:CreateToggle({
    Name = "👁️ ESP",
    CurrentValue = true,
    Callback = function(v) settings.ESP = v end
})

CombatTab:CreateToggle({
    Name = "🎯 Aim Assist",
    CurrentValue = false,
    Callback = function(v) settings.AimAssist = v end
})

CombatTab:CreateToggle({
    Name = "🧱 Wall Check",
    CurrentValue = true,
    Callback = function(v) settings.WallCheck = v end
})

CombatTab:CreateToggle({
    Name = "👥 Team Check",
    CurrentValue = true,
    Callback = function(v) settings.TeamCheck = v end
})

CombatTab:CreateSlider({
    Name = "💪 Aim Strength",
    Range = {0,1},
    Increment = 0.01,
    CurrentValue = 0.12,
    Callback = function(v) settings.AimStrength = v end
})

CombatTab:CreateSlider({
    Name = "📐 Aim FOV",
    Range = {50,300},
    Increment = 5,
    CurrentValue = 120,
    Callback = function(v) settings.FOV = v end
})

CombatTab:CreateButton({
    Name = "🧹 Clear ESP",
    Callback = function()
        for _, hl in pairs(highlights) do
            if hl then hl:Destroy() end
        end
        table.clear(highlights)
    end
})

---------------------------------------------------
-- ✈️ MOVEMENT
---------------------------------------------------
MoveTab:CreateToggle({
    Name = "✈️ Fly",
    CurrentValue = false,
    Callback = function(v)
        settings.Fly = v
        if v then settings.HeroFly = false end
    end
})

MoveTab:CreateSlider({
    Name = "⚡ Fly Speed",
    Range = {20,200},
    Increment = 5,
    CurrentValue = 50,
    Callback = function(v) settings.FlySpeed = v end
})

MoveTab:CreateToggle({
    Name = "🦸 Hero Fly",
    CurrentValue = false,
    Callback = function(v)
        settings.HeroFly = v
        if v then settings.Fly = false end
    end
})

MoveTab:CreateSlider({
    Name = "🚀 Hero Speed",
    Range = {50,500},
    Increment = 10,
    CurrentValue = 200,
    Callback = function(v) settings.HeroSpeed = v end
})

MoveTab:CreateToggle({
    Name = "🔄 Align To Camera",
    CurrentValue = true,
    Callback = function(v)
        settings.AlignToCamera = v
    end
})

---------------------------------------------------
-- 🎯 TEAM CHECK
---------------------------------------------------
local function isEnemy(plr)
    if not settings.TeamCheck then return true end
    if not plr.Team or not LP.Team then return true end
    return plr.Team ~= LP.Team
end

---------------------------------------------------
-- 🎯 AIM
---------------------------------------------------
UserInputService.InputBegan:Connect(function(i)
    if i.UserInputType == Enum.UserInputType.MouseButton2 then
        aiming = true
    end
end)

UserInputService.InputEnded:Connect(function(i)
    if i.UserInputType == Enum.UserInputType.MouseButton2 then
        aiming = false
    end
end)

local function isVisible(part)
    if not settings.WallCheck then return true end

    local result = Workspace:Raycast(
        Camera.CFrame.Position,
        (part.Position - Camera.CFrame.Position),
        RaycastParams.new()
    )

    return not result or result.Instance:IsDescendantOf(part.Parent)
end

---------------------------------------------------
-- ESP
---------------------------------------------------
local function createESP(char)
    if highlights[char] then return end

    local hl = Instance.new("Highlight")
    hl.FillColor = Color3.fromRGB(255,60,60)
    hl.Parent = char

    highlights[char] = hl
end

local function removeESP(char)
    if highlights[char] then
        highlights[char]:Destroy()
        highlights[char] = nil
    end
end

---------------------------------------------------
-- TARGET
---------------------------------------------------
local function getClosestTarget()
    local closest, dist = nil, math.huge

    for _, plr in pairs(Players:GetPlayers()) do
        if plr ~= LP and plr.Character and isEnemy(plr) then
            local head = plr.Character:FindFirstChild("Head")
            if head and isVisible(head) then
                local pos, onScreen = Camera:WorldToViewportPoint(head.Position)
                if onScreen then
                    local mag = (Vector2.new(pos.X,pos.Y) - UserInputService:GetMouseLocation()).Magnitude
                    if mag < dist and mag <= settings.FOV then
                        dist = mag
                        closest = head
                    end
                end
            end
        end
    end

    return closest
end

---------------------------------------------------
-- LOOP
---------------------------------------------------
RunService.RenderStepped:Connect(function()

    local char = LP.Character
    local root = char and char:FindFirstChild("HumanoidRootPart")

    -- ESP
    for _, plr in pairs(Players:GetPlayers()) do
        if plr ~= LP and plr.Character and isEnemy(plr) then
            if settings.ESP then
                createESP(plr.Character)
            else
                removeESP(plr.Character)
            end
        end
    end

    -- AIM
    if settings.AimAssist and aiming then
        local t = getClosestTarget()
        if t then
            Camera.CFrame = Camera.CFrame:Lerp(
                CFrame.new(Camera.CFrame.Position, t.Position),
                settings.AimStrength
            )
        end
    end

    -- FLY
    if root then
        local cam = Camera.CFrame
        local move = Vector3.zero

        if UserInputService:IsKeyDown(Enum.KeyCode.W) then move += cam.LookVector end
        if UserInputService:IsKeyDown(Enum.KeyCode.S) then move -= cam.LookVector end
        if UserInputService:IsKeyDown(Enum.KeyCode.A) then move -= cam.RightVector end
        if UserInputService:IsKeyDown(Enum.KeyCode.D) then move += cam.RightVector end

        if settings.Fly then
            root.Velocity = move * settings.FlySpeed
        end

        if settings.HeroFly then
            root.Velocity = move * settings.HeroSpeed
        end

        -- 🔥 FIX ROTAÇÃO (NÃO FICA DE COSTAS)
        if settings.AlignToCamera then
            root.CFrame = CFrame.new(root.Position, root.Position + cam.LookVector)
        end
    end
end)

end

---------------------------------------------------
-- BOTÃO KEY
---------------------------------------------------
KeyTab:CreateButton({
    Name = "Verificar Key",
    Callback = function()

        local Keys = getKeys()
        local result = verificarKey(keyInput, Keys)

        if result == "valid" then
            Rayfield:Notify({
                Title = "Sucesso",
                Content = "Key válida!",
                Duration = 3
            })

            startScript()

        else
            Rayfield:Notify({
                Title = "Erro",
                Content = result == "expired" and "Key expirada!" or "Key inválida!",
                Duration = 3
            })
        end
    end
})
