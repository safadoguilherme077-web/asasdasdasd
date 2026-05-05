-- 🔐 KEY SYSTEM ONLINE
local HttpService = game:GetService("HttpService")

local KEYS_URL = "https://raw.githubusercontent.com/safadoguilherme077-web/akiescirpt/main/key.json"

local function getKeys()
    local success, result = pcall(function()
        return HttpService:JSONDecode(game:HttpGet(KEYS_URL))
    end)

    if success then
        return result
    else
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
-- 🎮 RAYFIELD (KEY MENU)
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
-- 🔓 LIBERAR SCRIPT
---------------------------------------------------
local function startScript()

-- 🔽🔽🔽 SEU SCRIPT ORIGINAL (NÃO MEXI) 🔽🔽🔽

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local Workspace = game:GetService("Workspace")

local LP = Players.LocalPlayer
local Camera = Workspace.CurrentCamera

local settings = {
    ESP = true,
    AimAssist = false,
    WallCheck = true,
    AimStrength = 0.12,
    FOV = 120,

    Fly = false,
    FlySpeed = 50,

    HeroFly = false,
    HeroSpeed = 200,

    Noclip = false,
    TeamCheck = true
}

local aiming = false
local highlights = {}

local Window = Rayfield:CreateWindow({
    Name = "FPS System",
    LoadingTitle = "Loading...",
    LoadingSubtitle = "Client Menu",
    ConfigurationSaving = {Enabled = false}
})

local CombatTab = Window:CreateTab("Combat")
local MoveTab = Window:CreateTab("Movement")

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

local bv, bg
local function toggleFly(state)
    local char = LP.Character
    if not char then return end
    local root = char:FindFirstChild("HumanoidRootPart")
    if not root then return end

    if state then
        bv = Instance.new("BodyVelocity", root)
        bv.MaxForce = Vector3.new(1e5,1e5,1e5)

        bg = Instance.new("BodyGyro", root)
        bg.MaxTorque = Vector3.new(1e5,1e5,1e5)
    else
        if bv then bv:Destroy() end
        if bg then bg:Destroy() end
    end
end

MoveTab:CreateToggle({
    Name = "✈️ Fly",
    CurrentValue = false,
    Callback = function(v)
        settings.Fly = v
        if v then settings.HeroFly = false end
        toggleFly(v)
    end
})

MoveTab:CreateSlider({
    Name = "⚡ Fly Speed",
    Range = {20,200},
    Increment = 5,
    CurrentValue = 50,
    Callback = function(v) settings.FlySpeed = v end
})

local heroBV, heroBG
local currentVelocity = Vector3.zero

local function toggleHeroFly(state)
    local char = LP.Character
    if not char then return end
    local root = char:FindFirstChild("HumanoidRootPart")
    if not root then return end

    if state then
        heroBV = Instance.new("BodyVelocity", root)
        heroBV.MaxForce = Vector3.new(1e7,1e7,1e7)

        heroBG = Instance.new("BodyGyro", root)
        heroBG.MaxTorque = Vector3.new(1e7,1e7,1e7)
        heroBG.P = 5e5
    else
        currentVelocity = Vector3.zero
        if heroBV then heroBV:Destroy() end
        if heroBG then heroBG:Destroy() end
    end
end

MoveTab:CreateToggle({
    Name = "🦸 Hero Fly",
    CurrentValue = false,
    Callback = function(v)
        settings.HeroFly = v
        if v then settings.Fly = false toggleFly(false) end
        toggleHeroFly(v)
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
    Name = "🚪 Noclip",
    CurrentValue = false,
    Callback = function(v)
        settings.Noclip = v
    end
})

RunService.RenderStepped:Connect(function()

    if settings.Fly and bv and bg then
        local moveDir = Vector3.zero
        local cam = Camera.CFrame

        if UserInputService:IsKeyDown(Enum.KeyCode.W) then moveDir += cam.LookVector end
        if UserInputService:IsKeyDown(Enum.KeyCode.S) then moveDir -= cam.LookVector end
        if UserInputService:IsKeyDown(Enum.KeyCode.A) then moveDir -= cam.RightVector end
        if UserInputService:IsKeyDown(Enum.KeyCode.D) then moveDir += cam.RightVector end

        bv.Velocity = moveDir * settings.FlySpeed
        bg.CFrame = cam
    end

    if settings.HeroFly and heroBV and heroBG then
        local moveDir = Vector3.zero
        local cam = Camera.CFrame

        if UserInputService:IsKeyDown(Enum.KeyCode.W) then moveDir += cam.LookVector end
        if UserInputService:IsKeyDown(Enum.KeyCode.S) then moveDir -= cam.LookVector end
        if UserInputService:IsKeyDown(Enum.KeyCode.A) then moveDir -= cam.RightVector end
        if UserInputService:IsKeyDown(Enum.KeyCode.D) then moveDir += cam.RightVector end
        if UserInputService:IsKeyDown(Enum.KeyCode.Space) then moveDir += Vector3.new(0,1,0) end
        if UserInputService:IsKeyDown(Enum.KeyCode.LeftControl) then moveDir -= Vector3.new(0,1,0) end

        local targetVelocity = moveDir * settings.HeroSpeed
        currentVelocity = currentVelocity:Lerp(targetVelocity, 0.15)

        heroBV.Velocity = currentVelocity

        if moveDir.Magnitude > 0 then
            local root = LP.Character.HumanoidRootPart
            heroBG.CFrame = CFrame.new(root.Position, root.Position + moveDir) * CFrame.Angles(math.rad(-75),0,0)
        else
            heroBG.CFrame = cam
        end
    end

    if settings.Noclip then
        local char = LP.Character
        if char then
            for _, v in pairs(char:GetDescendants()) do
                if v:IsA("BasePart") then
                    v.CanCollide = false
                end
            end
        end
    end

end)

-- 🔼🔼🔼 SEU SCRIPT TERMINA AQUI 🔼🔼🔼
end

---------------------------------------------------
-- BOTÃO DE VERIFICAR
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
