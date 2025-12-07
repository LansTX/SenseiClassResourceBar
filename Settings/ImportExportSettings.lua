local _, addonTable = ...

local SettingsLib = addonTable.SettingsLib or LibStub("LibEQOLSettingsMode-1.0")

local featureId = "SCRB_IMPORT_EXPORT"

addonTable.AvailableFeatures = addonTable.AvailableFeatures or {}
table.insert(addonTable.AvailableFeatures, featureId)

addonTable.FeaturesMetadata = addonTable.FeaturesMetadata or {}
addonTable.FeaturesMetadata[featureId] = {
	searchTags = { "Import", "Export" },
	category = "Import / Export",
}

addonTable.SettingsPanelInitializers = addonTable.SettingsPanelInitializers or {}
addonTable.SettingsPanelInitializers[featureId] = function(category)
    SettingsLib:CreateButton(category, {
		text = "Export",
		func = function()
			local exportString = addonTable.exportProfileAsString()
			if not exportString then
				addonTable.prettyPrint("Export failed.")
				return
			end
			StaticPopupDialogs["SCRB_EXPORT_SETTINGS"] = StaticPopupDialogs["SCRB_EXPORT_SETTINGS"]
				or {
					text = "Export",
					button1 = CLOSE,
					hasEditBox = true,
					editBoxWidth = 320,
					timeout = 0,
					whileDead = true,
					hideOnEscape = true,
					preferredIndex = 3,
				}
			StaticPopupDialogs["SCRB_EXPORT_SETTINGS"].OnShow = function(self)
				self:SetFrameStrata("TOOLTIP")
				local editBox = self.editBox or self:GetEditBox()
				editBox:SetText(exportString)
				editBox:HighlightText()
				editBox:SetFocus()
			end
			StaticPopup_Show("SCRB_EXPORT_SETTINGS")
		end,
	})

	SettingsLib:CreateButton(category, {
		text = "Import",
		func = function()
			StaticPopupDialogs["SCRB_IMPORT_SETTINGS"] = StaticPopupDialogs["SCRB_IMPORT_SETTINGS"]
				or {
					text = "Import",
					button1 = OKAY,
					button2 = CANCEL,
					hasEditBox = true,
					editBoxWidth = 320,
					timeout = 0,
					whileDead = true,
					hideOnEscape = true,
					preferredIndex = 3,
				}
			StaticPopupDialogs["SCRB_IMPORT_SETTINGS"].OnShow = function(self)
				self:SetFrameStrata("TOOLTIP")
				local editBox = self.editBox or self:GetEditBox()
				editBox:SetText("")
				editBox:SetFocus()
			end
			StaticPopupDialogs["SCRB_IMPORT_SETTINGS"].EditBoxOnEnterPressed = function(editBox)
				local parent = editBox:GetParent()
				if parent and parent.button1 then parent.button1:Click() end
			end
			StaticPopupDialogs["SCRB_IMPORT_SETTINGS"].OnAccept = function(self)
				local editBox = self.editBox or self:GetEditBox()
				local input = editBox:GetText() or ""

				local ok, error = addonTable.importProfileFromString(input)
				if not ok then
					addonTable.prettyPrint("Import failed with the following error: "..error)
				end

				addonTable.fullUpdateBars()
			end
			StaticPopup_Show("SCRB_IMPORT_SETTINGS")
		end,
	})
end