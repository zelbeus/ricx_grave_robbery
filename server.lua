data = {}
local VorpCore
local VorpInv

if Config.framework == "redemrp" then
    TriggerEvent("redemrp_inventory:getData",function(call)
        data = call
    end)
elseif Config.framework == "vorp" then
    TriggerEvent("getCore",function(core)
        VorpCore = core
    end)
    
    VorpInv = exports.vorp_inventory:vorp_inventoryApi()
end

local TEXTS = Config.Texts
local TEXTURES = Config.Textures

local DiggedGraves = {}

RegisterServerEvent("ricx_grave_robbery:check_shovel")
AddEventHandler("ricx_grave_robbery:check_shovel", function(id)
    local _source = source
    if DiggedGraves[id] == true then 
        TriggerClientEvent("Notification:left_grave_robbery", _source, TEXTS.GraveRobbery, TEXTS.GraveRobbed, TEXTURES.alert[1], TEXTURES.alert[2], 2000)
        return 
    end
    local count = nil
    if Config.framework == "redemrp" then
        local itemD = data.getItem(_source, Config.ShovelItem)
        if itemD and itemD.ItemAmount > 0 then 
            count = itemD.ItemAmount
        end
    elseif Config.framework == "vorp" then
        count = VorpInv.getItemCount(_source, Config.ShovelItem)
    end
    if count and count > 0 then
        TriggerClientEvent("ricx_grave_robbery:start_dig", _source, id)
    else
        TriggerClientEvent("Notification:left_grave_robbery", _source, TEXTS.GraveRobbery, TEXTS.NoShovel, TEXTURES.alert[1], TEXTURES.alert[2], 2000)
    end
end)

RegisterServerEvent("ricx_grave_robbery:reward")
AddEventHandler("ricx_grave_robbery:reward", function(id)
    local _source = source
    Citizen.Wait(math.random(200,800))
    if DiggedGraves[id] == true then 
        TriggerClientEvent("Notification:left_grave_robbery", _source, TEXTS.GraveRobbery, TEXTS.GraveRobbed, TEXTURES.alert[1], TEXTURES.alert[2], 2000)
        return 
    end
    DiggedGraves[id] = true 
    local itemnr = math.random(1,#Config.Rewards)
    local item = Config.Rewards[itemnr].item
    local label = Config.Rewards[itemnr].label
    if Config.framework == "redemrp" then
        local itemD = data.getItem(_source, item)
        itemD.AddItem(1)
    elseif Config.framework == "vorp" then
        VorpInv.addItem(_source, item, 1)
    end
    TriggerClientEvent("Notification:left_grave_robbery", _source, TEXTS.GraveRobbery, TEXTS.FoundItem.."\n+ "..label, TEXTURES.alert[1], TEXTURES.alert[2], 2000)
end)