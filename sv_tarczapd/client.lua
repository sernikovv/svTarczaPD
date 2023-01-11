local tarczaon = false
local tarczaentity = nil
local trzymapistola = false

-- Animacja
local DICT = "combat@gestures@gang@pistol_1h@beckon"
local NAME = "0"

local prop = "prop_ballistic_shield"
local pistol = GetHashKey("WEAPON_PISTOL")

RegisterCommand("tarcza", function()
    if tarczaon then
        DisableShield()
    else
        EnableShield()
    end
end, false)

function EnableShield()
    tarczaon = true
    local ped = GetPlayerPed(-1)
    local pedPos = GetEntityCoords(ped, false)
    
    RequestAnimDict(DICT)
    while not HasAnimDictLoaded(DICT) do
        Citizen.Wait(100)
    end

    TaskPlayAnim(ped, DICT, NAME, 8.0, -8.0, -1, (2 + 16 + 32), 0.0, 0, 0, 0)

    RequestModel(GetHashKey(prop))
    while not HasModelLoaded(GetHashKey(prop)) do
        Citizen.Wait(100)
    end

    local tarcza = CreateObject(GetHashKey(prop), pedPos.x, pedPos.y, pedPos.z, 1, 1, 1)
    tarczaentity = tarcza
    AttachEntityToEntity(tarczaentity, ped, GetEntityBoneIndexByName(ped, "IK_L_Hand"), 0.0, -0.05, -0.10, -30.0, 180.0, 40.0, 0, 0, 1, 0, 0, 1)
    SetWeaponAnimationOverride(ped, GetHashKey("Gang1H"))

    if HasPedGotWeapon(ped, pistol, 0) or GetSelectedPedWeapon(ped) == pistol then
        SetCurrentPedWeapon(ped, pistol, 1)
        trzymapistola = true
    end
end

function DisableShield()
    local ped = GetPlayerPed(-1)
    DeleteEntity(tarczaentity)
    ClearPedTasksImmediately(ped)
    SetWeaponAnimationOverride(ped, GetHashKey("Default"))

    if not trzymapistola then
        RemoveWeaponFromPed(ped, pistol)
    end
    SetEnableHandcuffs(ped, false)
    trzymapistola = false
    tarczaon = false
end

Citizen.CreateThread(function()
    while true do
        if tarczaon then
            local ped = GetPlayerPed(-1)
            if not IsEntityPlayingAnim(ped, DICT, NAME, 1) then
                RequestAnimDict(DICT)
                while not HasAnimDictLoaded(DICT) do
                    Citizen.Wait(100)
                end
            
                TaskPlayAnim(ped, DICT, NAME, 8.0, -8.0, -1, (2 + 16 + 32), 0.0, 0, 0, 0)
            end
        end
        Citizen.Wait(500)
    end
end)

RegisterNetEvent('tarcza:useitem', function()
    if tarczaon then
        DisableShield()
    else
        EnableShield()
    end
end, false)