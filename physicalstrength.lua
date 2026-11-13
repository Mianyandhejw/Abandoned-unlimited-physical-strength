if type(getgenv) == "function" and getgenv().__StaminaAPILoaded == true then
    warn("[Mianyang] 体力脚本已加载，跳过重复执行")
    return
end
if type(getgenv) == "function" then
    getgenv().__StaminaAPILoaded = true
end

local Players           = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local LP = Players.LocalPlayer

local SprintingModule = ReplicatedStorage:WaitForChild("Systems")
    :WaitForChild("Character")
    :WaitForChild("Game")
    :WaitForChild("Sprinting")

local function GetSprinting() return require(SprintingModule) end

local originalDefaults = {}
local fallbackDefaults = {
    MaxStamina  = 100,
    StaminaGain = 25,
    StaminaLoss = 10,
    SprintSpeed = 28,
}
do
    local m = GetSprinting()
    for key, fallback in pairs(fallbackDefaults) do
        local val = m[key]
        if type(val) == "number" and val > 0 then
            originalDefaults[key] = val
        else
            originalDefaults[key] = fallback
            warn(string.format(
                "[Mianyang] Sprinting.%s 捕获异常 (值=%s)，使用 fallback=%s",
                key, tostring(val), tostring(fallback)
            ))
        end
    end
end

local StaminaSettings = {
    MaxStamina  = originalDefaults.MaxStamina,
    StaminaGain = originalDefaults.StaminaGain,
    StaminaLoss = originalDefaults.StaminaLoss,
    SprintSpeed = originalDefaults.SprintSpeed,
}

local SettingToggles = {
    MaxStamina  = false,
    StaminaGain = false,
    StaminaLoss = false,
    SprintSpeed = false,
}

task.spawn(function()
    while true do
        local m = GetSprinting()
        if SettingToggles.MaxStamina then
            local v = StaminaSettings.MaxStamina
            if type(v) == "number" and v > 0 then
                pcall(function() m.MaxStamina = v end)
            end
        end
        if SettingToggles.StaminaGain then
            pcall(function() m.StaminaGain = StaminaSettings.StaminaGain end)
        end
        if SettingToggles.StaminaLoss then
            pcall(function() m.StaminaLoss = StaminaSettings.StaminaLoss end)
        end
        if SettingToggles.SprintSpeed then
            pcall(function() m.SprintSpeed = StaminaSettings.SprintSpeed end)
        end
        task.wait(0.5)
    end
end)

local function SetMaxStaminaEnabled(state)
    SettingToggles.MaxStamina = state
    if state then
        local v = StaminaSettings.MaxStamina
        if type(v) ~= "number" or v <= 0 then
            warn("[Mianyang] MaxStamina 值 ≤ 0，使用原始默认值代替以避免破坏体力槽")
            v = originalDefaults.MaxStamina
        end
        pcall(function() GetSprinting().MaxStamina = v end)
    else
        pcall(function() GetSprinting().MaxStamina = originalDefaults.MaxStamina end)
    end
end
local function SetMaxStaminaValue(v)
    StaminaSettings.MaxStamina = v
    if SettingToggles.MaxStamina then
        if type(v) == "number" and v > 0 then
            pcall(function() GetSprinting().MaxStamina = v end)
        else
            warn("[Mianyang] MaxStamina 值 ≤ 0，拒绝写入模块")
        end
    end
end

local function SetStaminaGainEnabled(state)
    SettingToggles.StaminaGain = state
    pcall(function()
        GetSprinting().StaminaGain = state
            and StaminaSettings.StaminaGain
            or  originalDefaults.StaminaGain
    end)
end
local function SetStaminaGainValue(v)
    StaminaSettings.StaminaGain = v
    if SettingToggles.StaminaGain then
        pcall(function() GetSprinting().StaminaGain = v end)
    end
end

local function SetStaminaLossEnabled(state)
    SettingToggles.StaminaLoss = state
    pcall(function()
        GetSprinting().StaminaLoss = state
            and StaminaSettings.StaminaLoss
            or  originalDefaults.StaminaLoss
    end)
end
local function SetStaminaLossValue(v)
    StaminaSettings.StaminaLoss = v
    if SettingToggles.StaminaLoss then
        pcall(function() GetSprinting().StaminaLoss = v end)
    end
end

local function SetSprintSpeedEnabled(state)
    SettingToggles.SprintSpeed = state
    pcall(function()
        GetSprinting().SprintSpeed = state
            and StaminaSettings.SprintSpeed
            or  originalDefaults.SprintSpeed
    end)
end
local function SetSprintSpeedValue(v)
    StaminaSettings.SprintSpeed = v
    if SettingToggles.SprintSpeed then
        pcall(function() GetSprinting().SprintSpeed = v end)
    end
end

local function GetActiveValues()
    local m = GetSprinting()
    return {
        CurrentStamina     = m.Stamina,
        CurrentMaxStamina  = m.MaxStamina,
        CurrentStaminaGain = m.StaminaGain,
        CurrentStaminaLoss = m.StaminaLoss,
        CurrentSprintSpeed = m.SprintSpeed,
        SettingValues = {
            MaxStamina  = StaminaSettings.MaxStamina,
            Gain        = StaminaSettings.StaminaGain,
            Loss        = StaminaSettings.StaminaLoss,
            SprintSpeed = StaminaSettings.SprintSpeed,
        },
        Toggles = {
            Max   = SettingToggles.MaxStamina,
            Gain  = SettingToggles.StaminaGain,
            Loss  = SettingToggles.StaminaLoss,
            Speed = SettingToggles.SprintSpeed,
        },
        OriginalDefaults = originalDefaults,
    }
end

local StaminaAPI = {
    GetDefaults = function() return originalDefaults end,
    GetSettings = function() return StaminaSettings end,
    GetToggles  = function() return SettingToggles  end,
    GetActiveValues = GetActiveValues,

    SetMaxStaminaEnabled = SetMaxStaminaEnabled,
    SetMaxStaminaValue   = SetMaxStaminaValue,
    IsMaxStaminaEnabled  = function() return SettingToggles.MaxStamina end,
    GetMaxStaminaValue   = function() return StaminaSettings.MaxStamina end,

    SetStaminaGainEnabled = SetStaminaGainEnabled,
    SetStaminaGainValue   = SetStaminaGainValue,
    IsStaminaGainEnabled  = function() return SettingToggles.StaminaGain end,
    GetStaminaGainValue   = function() return StaminaSettings.StaminaGain end,

    SetStaminaLossEnabled = SetStaminaLossEnabled,
    SetStaminaLossValue   = SetStaminaLossValue,
    IsStaminaLossEnabled  = function() return SettingToggles.StaminaLoss end,
    GetStaminaLossValue   = function() return StaminaSettings.StaminaLoss end,

    SetSprintSpeedEnabled = SetSprintSpeedEnabled,
    SetSprintSpeedValue   = SetSprintSpeedValue,
    IsSprintSpeedEnabled  = function() return SettingToggles.SprintSpeed end,
    GetSprintSpeedValue   = function() return StaminaSettings.SprintSpeed end,
}

local RoleConfig = {
    Survivor = {
        MaxEnabled         = false, Max = 0,
        GainEnabled        = false, Gain = 0,
        LossEnabled        = false, Loss = 0,
        SprintSpeedEnabled = false, SprintSpeed = 0,
    },
    Killer = {
        MaxEnabled         = false, Max = 0,
        GainEnabled        = false, Gain = 0,
        LossEnabled        = false, Loss = 0,
        SprintSpeedEnabled = false, SprintSpeed = 0,
    },
}

local currentRole = nil

local function FindModelByPlayer(folder)
    if not folder then return nil end
    for _, child in ipairs(folder:GetChildren()) do
        if child:IsA("Model") then
            if child:GetAttribute("Username") == LP.Name then return child end
            if child.Name == LP.Name then return child end
        end
    end
    return nil
end

local function GetRole()
    local plrs = workspace:FindFirstChild("Players")
    if not plrs then return nil end
    local char = LP.Character
    local k = plrs:FindFirstChild("Killers")
    local s = plrs:FindFirstChild("Survivors")

    if char then
        if k and char:IsDescendantOf(k) then return "Killer" end
        if s and char:IsDescendantOf(s) then return "Survivor" end
    end

    if char then
        if k then
            for _, child in ipairs(k:GetChildren()) do
                if child:GetAttribute("Username") == LP.Name then return "Killer" end
                if child.Name == char.Name and child.Name ~= LP.Name then
                    if child.Name == char.Name then
                        return "Killer"
                    end
                end
            end
        end
        if s then
            for _, child in ipairs(s:GetChildren()) do
                if child:GetAttribute("Username") == LP.Name then return "Survivor" end
            end
        end
    end

    if FindModelByPlayer(k) then return "Killer" end
    if FindModelByPlayer(s) then return "Survivor" end
    return nil
end

local function ApplyRoleConfig(role)
    role = role or GetRole()
    if not role then return false end
    local cfg = RoleConfig[role]
    if not cfg then return false end

    pcall(function()
        if SettingToggles.MaxStamina  then SetMaxStaminaEnabled(false)  end
        if SettingToggles.StaminaGain then SetStaminaGainEnabled(false) end
        if SettingToggles.StaminaLoss then SetStaminaLossEnabled(false) end
        if SettingToggles.SprintSpeed then SetSprintSpeedEnabled(false) end
    end)

    pcall(function()
        SetMaxStaminaValue(cfg.Max)
        SetStaminaGainValue(cfg.Gain)
        SetStaminaLossValue(cfg.Loss)
        SetSprintSpeedValue(cfg.SprintSpeed)
    end)

    pcall(function()
        if cfg.MaxEnabled         then SetMaxStaminaEnabled(true)  end
        if cfg.GainEnabled        then SetStaminaGainEnabled(true) end
        if cfg.LossEnabled        then SetStaminaLossEnabled(true) end
        if cfg.SprintSpeedEnabled then SetSprintSpeedEnabled(true) end
    end)

    currentRole = role
    return true
end

local RoleStaminaAPI = {
    GetRole          = GetRole,
    GetCurrentRole   = function() return currentRole or GetRole() end,
    GetConfig        = function(role) return RoleConfig[role or GetRole()] end,
    GetRoleTable     = function() return RoleConfig end,
    Apply            = ApplyRoleConfig,
    GetActiveValues  = GetActiveValues,

    ForceReapply = function()
        local role = GetRole()
        if role then ApplyRoleConfig(role) end
        return role
    end,

    Debug = function()
        local v = GetActiveValues()
        local role = GetRole()
        print("========== 体力状态诊断 ==========")
        print(string.format("当前角色: %s", tostring(role or "未知")))
        print("----- 模块实时值 -----")
        print(string.format("  Stamina      = %s", tostring(v.CurrentStamina)))
        print(string.format("  MaxStamina   = %s", tostring(v.CurrentMaxStamina)))
        print(string.format("  StaminaGain  = %s", tostring(v.CurrentStaminaGain)))
        print(string.format("  StaminaLoss  = %s", tostring(v.CurrentStaminaLoss)))
        print(string.format("  SprintSpeed  = %s", tostring(v.CurrentSprintSpeed)))
        print("----- 用户设置值（UI 显示值）-----")
        print(string.format("  Max   = %s (开关: %s)", tostring(v.SettingValues.MaxStamina), tostring(v.Toggles.Max)))
        print(string.format("  Gain  = %s (开关: %s)", tostring(v.SettingValues.Gain),       tostring(v.Toggles.Gain)))
        print(string.format("  Loss  = %s (开关: %s)", tostring(v.SettingValues.Loss),       tostring(v.Toggles.Loss)))
        print(string.format("  Speed = %s (开关: %s)", tostring(v.SettingValues.SprintSpeed), tostring(v.Toggles.Speed)))
        print("----- 原始默认值 -----")
        print(string.format("  Max=%s Gain=%s Loss=%s Speed=%s",
            tostring(v.OriginalDefaults.MaxStamina),
            tostring(v.OriginalDefaults.StaminaGain),
            tostring(v.OriginalDefaults.StaminaLoss),
            tostring(v.OriginalDefaults.SprintSpeed)))
        print("==================================")
        return v
    end,

    SetField = function(role, key, value)
        if not role then return end
        local cfg = RoleConfig[role]
        if not cfg then return end
        cfg[key] = value
        if GetRole() == role then ApplyRoleConfig(role) end
    end,

    SetMaxEnabled         = function(role, v) RoleStaminaAPI.SetField(role, "MaxEnabled",         v) end,
    SetMax                = function(role, v) RoleStaminaAPI.SetField(role, "Max",                v) end,
    SetGainEnabled        = function(role, v) RoleStaminaAPI.SetField(role, "GainEnabled",        v) end,
    SetGain               = function(role, v) RoleStaminaAPI.SetField(role, "Gain",               v) end,
    SetLossEnabled        = function(role, v) RoleStaminaAPI.SetField(role, "LossEnabled",        v) end,
    SetLoss               = function(role, v) RoleStaminaAPI.SetField(role, "Loss",               v) end,
    SetSprintSpeedEnabled = function(role, v) RoleStaminaAPI.SetField(role, "SprintSpeedEnabled", v) end,
    SetSprintSpeed        = function(role, v) RoleStaminaAPI.SetField(role, "SprintSpeed",        v) end,

    Current = function()
        local role = GetRole()
        return {
            SetMaxEnabled         = function(v) RoleStaminaAPI.SetField(role, "MaxEnabled",         v) end,
            SetMax                = function(v) RoleStaminaAPI.SetField(role, "Max",                v) end,
            SetGainEnabled        = function(v) RoleStaminaAPI.SetField(role, "GainEnabled",        v) end,
            SetGain               = function(v) RoleStaminaAPI.SetField(role, "Gain",               v) end,
            SetLossEnabled        = function(v) RoleStaminaAPI.SetField(role, "LossEnabled",        v) end,
            SetLoss               = function(v) RoleStaminaAPI.SetField(role, "Loss",               v) end,
            SetSprintSpeedEnabled = function(v) RoleStaminaAPI.SetField(role, "SprintSpeedEnabled", v) end,
            SetSprintSpeed        = function(v) RoleStaminaAPI.SetField(role, "SprintSpeed",        v) end,
        }
    end,
}

task.spawn(function()
    task.wait(1)
    local role = GetRole()
    if role then ApplyRoleConfig(role) end
end)

LP.CharacterAdded:Connect(function()
    task.spawn(function()
        for _ = 1, 10 do
            task.wait(0.5)
            local role = GetRole()
            if role then
                ApplyRoleConfig(role)
                return
            end
        end
    end)
end)

task.spawn(function()
    while true do
        task.wait(0.5)
        local role = GetRole()
        if role and role ~= currentRole then
            ApplyRoleConfig(role)
        end
    end
end)

if type(getgenv) == "function" then
    pcall(function()
        getgenv().StaminaAPI     = StaminaAPI
        getgenv().RoleStaminaAPI = RoleStaminaAPI
    end)
end
_G.StaminaAPI     = StaminaAPI
_G.RoleStaminaAPI = RoleStaminaAPI

local uiOK, uiErr = pcall(function()
    local Library = loadstring(game:HttpGet(
        "https://raw.githubusercontent.com/deividcomsono/Obsidian/refs/heads/main/Library.lua"
    ))()

    local Window = Library:CreateWindow({
        Title         = "Mianyang",
        Footer        = "Forsaken",
        Center        = true,
        AutoShow      = true,
        ToggleKeybind = Enum.KeyCode.RightControl,
    })

    local Tab = Window:AddTab("体力修改", "zap")

    local SurvBox = Tab:AddLeftGroupbox("幸存者体力设置")

    SurvBox:AddToggle("Surv_MaxEnabled", {
        Text = "最大体力", Default = RoleConfig.Survivor.MaxEnabled,
        Callback = function(v) RoleStaminaAPI.SetMaxEnabled("Survivor", v) end,
    })
    SurvBox:AddSlider("Surv_Max", {
        Text = "最大体力调整", Default = RoleConfig.Survivor.Max,
        Min = 0, Max = 99999, Rounding = 0,
        Callback = function(v) RoleStaminaAPI.SetMax("Survivor", v) end,
    })

    SurvBox:AddToggle("Surv_GainEnabled", {
        Text = "体力恢复速度", Default = RoleConfig.Survivor.GainEnabled,
        Callback = function(v) RoleStaminaAPI.SetGainEnabled("Survivor", v) end,
    })
    SurvBox:AddSlider("Surv_Gain", {
        Text = "体力恢复速度调整", Default = RoleConfig.Survivor.Gain,
        Min = 0, Max = 250, Rounding = 0,
        Callback = function(v) RoleStaminaAPI.SetGain("Survivor", v) end,
    })

    SurvBox:AddToggle("Surv_LossEnabled", {
        Text = "体力消耗速度", Default = RoleConfig.Survivor.LossEnabled,
        Callback = function(v) RoleStaminaAPI.SetLossEnabled("Survivor", v) end,
    })
    SurvBox:AddSlider("Surv_Loss", {
        Text = "体力消耗速度调整", Default = RoleConfig.Survivor.Loss,
        Min = 0, Max = 100, Rounding = 1,
        Callback = function(v) RoleStaminaAPI.SetLoss("Survivor", v) end,
    })

    SurvBox:AddToggle("Surv_SprintSpeedEnabled", {
        Text = "奔跑速度", Default = RoleConfig.Survivor.SprintSpeedEnabled,
        Callback = function(v) RoleStaminaAPI.SetSprintSpeedEnabled("Survivor", v) end,
    })
    SurvBox:AddSlider("Surv_SprintSpeed", {
        Text = "奔跑速度调整", Default = RoleConfig.Survivor.SprintSpeed,
        Min = 0, Max = 200, Rounding = 0,
        Callback = function(v) RoleStaminaAPI.SetSprintSpeed("Survivor", v) end,
    })

    local KillerBox = Tab:AddRightGroupbox("杀手 · 体力设置")

    KillerBox:AddToggle("Killer_MaxEnabled", {
        Text = "最大体力", Default = RoleConfig.Killer.MaxEnabled,
        Callback = function(v) RoleStaminaAPI.SetMaxEnabled("Killer", v) end,
    })
    KillerBox:AddSlider("Killer_Max", {
        Text = "最大体力调整", Default = RoleConfig.Killer.Max,
        Min = 0, Max = 99999, Rounding = 0,
        Callback = function(v) RoleStaminaAPI.SetMax("Killer", v) end,
    })

    KillerBox:AddToggle("Killer_GainEnabled", {
        Text = "体力恢复", Default = RoleConfig.Killer.GainEnabled,
        Callback = function(v) RoleStaminaAPI.SetGainEnabled("Killer", v) end,
    })
    KillerBox:AddSlider("Killer_Gain", {
        Text = "体力恢复速度调整", Default = RoleConfig.Killer.Gain,
        Min = 0, Max = 250, Rounding = 0,
        Callback = function(v) RoleStaminaAPI.SetGain("Killer", v) end,
    })

    KillerBox:AddToggle("Killer_LossEnabled", {
        Text = "体力消耗", Default = RoleConfig.Killer.LossEnabled,
        Callback = function(v) RoleStaminaAPI.SetLossEnabled("Killer", v) end,
    })
    KillerBox:AddSlider("Killer_Loss", {
        Text = "体力消耗速度调整", Default = RoleConfig.Killer.Loss,
        Min = 0, Max = 100, Rounding = 1,
        Callback = function(v) RoleStaminaAPI.SetLoss("Killer", v) end,
    })

    KillerBox:AddToggle("Killer_SprintSpeedEnabled", {
        Text = "奔跑速度", Default = RoleConfig.Killer.SprintSpeedEnabled,
        Callback = function(v) RoleStaminaAPI.SetSprintSpeedEnabled("Killer", v) end,
    })
    KillerBox:AddSlider("Killer_SprintSpeed", {
        Text = "奔跑速度调整", Default = RoleConfig.Killer.SprintSpeed,
        Min = 0, Max = 200, Rounding = 0,
        Callback = function(v) RoleStaminaAPI.SetSprintSpeed("Killer", v) end,
    })

    local DebugBox = Tab:AddRightGroupbox("诊断")

    DebugBox:AddButton({
        Text = "打印当前体力状态到控制台",
        Func = function() RoleStaminaAPI.Debug() end,
    })
    DebugBox:AddButton({
        Text = "强制重新应用当前角色配置",
        Func = function()
            local role = RoleStaminaAPI.ForceReapply()
            print("[Mianyang] 已重新应用角色：" .. tostring(role or "未知"))
        end,
    })
end)

if not uiOK then
    warn("[Mianyang] Obsidian UI 加载失败：" .. tostring(uiErr))
    warn("  功能逻辑仍可用，请用 getgenv().RoleStaminaAPI 控制")
end

print("[Mianyang] 体力修改功能已就绪")
print("  原始值快照：",
    "Max=" .. tostring(originalDefaults.MaxStamina),
    "Gain=" .. tostring(originalDefaults.StaminaGain),
    "Loss=" .. tostring(originalDefaults.StaminaLoss),
    "Speed=" .. tostring(originalDefaults.SprintSpeed)
)
print("  底层 API：getgenv().StaminaAPI")
print("  角色 API：getgenv().RoleStaminaAPI")
if uiOK then
    print("  UI：Obsidian 窗口已打开（RightControl 切换显示）")
end