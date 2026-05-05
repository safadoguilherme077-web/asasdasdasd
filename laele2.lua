-- 🔐 KEY SYSTEM ONLINE
local HttpService = game:GetService("HttpService")

local KEYS_URL = "https://akiescirpt-production.up.railway.app/keys"

local function getKeys()
    local success, result = pcall(function()
        return HttpService:JSONDecode(game:HttpGet(KEYS_URL))
    end)

    if success then
        return result
    else
        warn("Erro ao pegar keys")
        return {}
    end
end

local function verificarKey(key, Keys)
    local data = Keys[key]

    if not data then return "invalid" end
    if data == "perm" then return "valid" end

    if os.time()*1000 > data then
        return "expired"
    end

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
    RemoveTextAfterFocusLost = false,
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
    TeamCheck = true
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

local Tab = Window:CreateTab("Combat")

Tab:CreateToggle({
    Name = "👁️ ESP",
    CurrentValue = true,
    Callback = function(v)
        settings.ESP = v
    end
})

Tab:CreateToggle({
    Name = "🎯 Aim Assist",
    CurrentValue = false,
    Callback = function(v)
        settings.AimAssist = v
    end
})

Tab:CreateToggle({
    Name = "🧱 Wall Check",
    CurrentValue = true,
    Callback = function(v)
        settings.WallCheck = v
    end
})

Tab:CreateToggle({
    Name = "👥 Team Check",
    CurrentValue = true,
    Callback = function(v)
        settings.TeamCheck = v
    end
})

Tab:CreateSlider({
    Name = "💪 Aim Strength",
    Range = {0, 1},
    Increment = 0.01,
    CurrentValue = 0.12,
    Callback = function(v)
        settings.AimStrength = v
    end
})

Tab:CreateSlider({
    Name = "📐 Aim FOV",
    Range = {50, 300},
    Increment = 5,
    CurrentValue = 120,
    Callback = function(v)
        settings.FOV = v
    end
})

Tab:CreateButton({
    Name = "🧹 Clear ESP",
    Callback = function()
        for _, hl in pairs(highlights) do
            if hl then hl:Destroy() end
        end
        table.clear(highlights)
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
-- 🎯 INPUT AIM
---------------------------------------------------
UserInputService.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton2 then
        aiming = true
    end
end)

UserInputService.InputEnded:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton2 then
        aiming = false
    end
end)

---------------------------------------------------
-- 👁️ VISIBILITY CHECK
---------------------------------------------------
local function isVisible(part)
    if not settings.WallCheck then return true end

    local origin = Camera.CFrame.Position
    local direction = (part.Position - origin)

    local params = RaycastParams.new()
    params.FilterType = Enum.RaycastFilterType.Blacklist
    params.FilterDescendantsInstances = {LP.Character}

    local result = Workspace:Raycast(origin, direction, params)

    return not result or result.Instance:IsDescendantOf(part.Parent)
end

---------------------------------------------------
-- 👁️ ESP
---------------------------------------------------
local function createESP(char)
    if highlights[char] then return end

    local hl = Instance.new("Highlight")
    hl.FillColor = Color3.fromRGB(255, 60, 60)
    hl.OutlineColor = Color3.fromRGB(255,255,255)
    hl.FillTransparency = 0.5
    hl.OutlineTransparency = 0
    hl.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop

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
-- 🎯 TARGET
---------------------------------------------------
local function getClosestTarget()
    local closest = nil
    local shortest = math.huge

    for _, plr in ipairs(Players:GetPlayers()) do
        if plr ~= LP and plr.Character and isEnemy(plr) then

            local head = plr.Character:FindFirstChild("Head")
            if head then

                if not isVisible(head) then continue end

                local screenPos, onScreen = Camera:WorldToViewportPoint(head.Position)

                if onScreen then
                    local mousePos = UserInputService:GetMouseLocation()
                    local dist = (Vector2.new(screenPos.X, screenPos.Y) - mousePos).Magnitude

                    if dist < shortest and dist <= settings.FOV then
                        shortest = dist
                        closest = head
                    end
                end
            end
        end
    end

    return closest
end

---------------------------------------------------
-- 🎯 AIM
---------------------------------------------------
local function applyAimAssist()
    local target = getClosestTarget()
    if not target then return end

    local cam = Camera.CFrame
    local targetCF = CFrame.new(cam.Position, target.Position)

    Camera.CFrame = cam:Lerp(targetCF, settings.AimStrength)
end

---------------------------------------------------
-- 🔁 LOOP
---------------------------------------------------
RunService.RenderStepped:Connect(function()

    for _, plr in ipairs(Players:GetPlayers()) do
        if plr ~= LP and isEnemy(plr) then
            local char = plr.Character
            local root = char and char:FindFirstChild("HumanoidRootPart")

            if char and root then
                if settings.ESP then
                    createESP(char)
                else
                    removeESP(char)
                end
            end
        end
    end

    if settings.AimAssist and aiming then
        applyAimAssist()
    end
end)

end

---------------------------------------------------
-- BOTÃO VERIFICAR
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

        elseif result == "expired" then
            Rayfield:Notify({
                Title = "Erro",
                Content = "Key expirada!",
                Duration = 3
            })
        else
            Rayfield:Notify({
                Title = "Erro",
                Content = "Key inválida!",
                Duration = 3
            })
        end

    end
})
