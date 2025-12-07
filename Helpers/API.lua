local addonName, addonTable = ...

local LEM = addonTable.LEM or LibStub("LibEQOLEditMode-1.0")
local LibSerialize = addonTable.LibSerialize or LibStub("LibSerialize")
local LibDeflate = addonTable.LibDeflate or LibStub("LibDeflate")

addonTable.updateBar = function(name)
    local bar = addonTable.barInstances[name]
    if not bar then return end

    bar:ApplyLayout()
end

addonTable.updateBars = function()
    for name, _ in pairs(addonTable.barInstances) do
        addonTable.updateBar(name)
    end
end

addonTable.fullUpdateBar = function(name)
    local bar = addonTable.barInstances[name]
    if not bar then return end

    bar:InitCooldownManagerWidthHook()
    bar:ApplyVisibilitySettings()
    bar:ApplyLayout()
    bar:UpdateDisplay()
end

addonTable.fullUpdateBars = function()
    for name, _ in pairs(addonTable.barInstances) do
        addonTable.fullUpdateBar(name)
    end
end

addonTable.exportProfileAsString = function()
    local EXPORT_VERSION = 1

    local data = {}
    local layoutName = LEM.GetActiveLayoutName() or "Default"
    for _, barSettings in pairs(addonTable.RegistereredBar or {}) do
        if barSettings
        and barSettings.dbName
        and SenseiClassResourceBarDB
        and SenseiClassResourceBarDB[barSettings.dbName]
        and SenseiClassResourceBarDB[barSettings.dbName][layoutName] then
            data[barSettings.dbName] = SenseiClassResourceBarDB[barSettings.dbName][layoutName] or nil
        end
    end

    local serialized = LibSerialize:Serialize(data)
    local compressed = LibDeflate:CompressDeflate(serialized, {level = 9})
    local encoded = LibDeflate:EncodeForPrint(compressed)

    return addonName .. ":" .. EXPORT_VERSION .. ":" .. encoded
	end

addonTable.importProfileFromString = function(importString)
    local prefix, version, encoded = importString:match("^([^:]+):(%d+):(.+)$")
    if prefix ~= addonName then
        return nil, "This import string is not suitable for " .. addonName
    end
    if not encoded then
        return nil, "Invalid import string"
    end

    local compressed = LibDeflate:DecodeForPrint(encoded)
    if not compressed then
        return nil, "Decode failed"
    end

    local serialized = LibDeflate:DecompressDeflate(compressed)
    if not serialized then
        return nil, "Decompression failed"
    end

    local success, data = LibSerialize:Deserialize(serialized)
    if not success then
        return nil, "Deserialization failed"
    end

    local layoutName = LEM.GetActiveLayoutName() or "Default"
    for dbName, barSettings in pairs(data) do
        if not SenseiClassResourceBarDB then
            SenseiClassResourceBarDB = {}
        end

        if not SenseiClassResourceBarDB[dbName] then
            SenseiClassResourceBarDB[dbName] = {}
        end

        SenseiClassResourceBarDB[dbName][layoutName] = barSettings
    end

    return data
end

addonTable.prettyPrint = function(...)
  print("|cffb5a707"..addonName..":|r", ...)
end