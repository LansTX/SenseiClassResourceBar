local addonName, addonTable = ...

local SettingsLib = addonTable.SettingsLib or LibStub("LibEQOLSettingsMode-1.0")

local function Register()
	if not SenseiClassResourceBarDB then
		SenseiClassResourceBarDB = {}
	end

	if not SenseiClassResourceBarDB["_Settings"] then
		SenseiClassResourceBarDB["_Settings"] = {}
	end

	if not SenseiClassResourceBarDB["_Settings"]["NewFeaturesShown"] then
		SenseiClassResourceBarDB["_Settings"]["NewFeaturesShown"] = {}
	end

	local rootCategory, layout = SettingsLib:CreateRootCategory(addonName)
    addonTable.rootSettingsCategory = rootCategory

	local categories = {
		["root"] = rootCategory,
	}

    for _, feature in pairs(addonTable.AvailableFeatures or {}) do
		local metadata = addonTable.FeaturesMetadata[feature] or {}
		local settingsPanelInitializer = addonTable.SettingsPanelInitializers[feature] or nil
		if metadata then
			local data

			-- Until we do everything with LibEQOL, we keep it that way
			if not metadata.category then
				data = Mixin(metadata.data or {}, { categoryID = rootCategory:GetID() })

				local initializer = Settings.CreatePanelInitializer(metadata.panel, data)
				initializer:AddSearchTags(unpack(metadata.searchTags or {}))
				layout:AddInitializer(initializer)
			else
				local category = categories[metadata.category] or SettingsLib:CreateCategory(rootCategory, metadata.category)
				categories[metadata.category] = category

				if settingsPanelInitializer then
					settingsPanelInitializer(category)
				end
			end
		end
    end
end

addonTable.SettingsRegistrar = Register