local ADDON_NAME, _ = ...

local function getIconList(numPlayers, displayData, iconOrder)
	local iconList = {}

	for i = 1, #iconOrder do
		for j = 1, displayData[iconOrder[i]] do
			table.insert(iconList, LFG_LIST_GROUP_DATA_ATLASES[iconOrder[i]])
		end
	end
	
	return iconList
end

local function enumerateUpdateOLD(self, numPlayers, displayData, disabled, iconOrder)
	
	--Show/hide the required icons
	for i=1, #self.Icons do
		if ( i > numPlayers ) then
			self.Icons[i]:Hide();
		else
			self.Icons[i]:Show();
			self.Icons[i]:SetDesaturated(disabled);
			self.Icons[i]:SetAlpha(disabled and 0.5 or 1.0);
		end
	end

	local iconList = getIconList(numPlayers, displayData, iconOrder)
	local iconIndex = numPlayers
	for i = 1, #iconList do
		self.Icons[iconIndex]:SetAtlas(iconList[i], false)
		iconIndex = iconIndex - 1
	end

	for i=1, iconIndex do
		self.Icons[i]:SetAtlas("groupfinder-icon-emptyslot", false);
	end
end

local function getIconLists(numPlayers, displayData)
	local players = {}
	for i = 1, numPlayers do
		players[i] = {class = "", role = ""}
	end
end

local function updateEnumPair(self, numPlayers, displayData, disabled)
	local iconLists = getIconLists(numPlayers, displayData)
	for i, enum in pairs({self.Class, self.Role}) do
		--Show/hide the required icons
		for i=1, #enum.Icons do
			if ( i > numPlayers ) then
				enum.Icons[i]:Hide();
			else
				enum.Icons[i]:Show();
				enum.Icons[i]:SetDesaturated(disabled);
				enum.Icons[i]:SetAlpha(disabled and 0.5 or 1.0);
			end
		end

		local iconList = iconLists[i]
		local iconIndex = numPlayers
		for i = 1, #iconList do
			self.Icons[iconIndex]:SetAtlas(iconList[i], false)
			iconIndex = iconIndex - 1
		end

		for i=1, iconIndex do
			self.Icons[i]:SetAtlas("groupfinder-icon-emptyslot", false);
		end
	end
end

local function LFGListGroupDataDisplay_UpdateHook(self, activityID, displayData, disabled)
	local fullName, shortName, categoryID, groupID, iLevel, filters, minLevel, maxPlayers, displayType = C_LFGList.GetActivityInfo(activityID)
	if (displayType == LE_LFG_LIST_DISPLAY_TYPE_ROLE_ENUMERATE) then
		self.Enumerate:Hide()
		self.EnumeratePair:Show()
		--updateEnumPair(self.EnumeratePair, maxPlayers, displayData, disabled)

		enumerateUpdateOLD(self.EnumeratePair.Role.Enumerate, maxPlayers, displayData, disabled, LFG_LIST_GROUP_DATA_ROLE_ORDER)
		enumerateUpdateOLD(self.EnumeratePair.Class.Enumerate, maxPlayers * 2, displayData, disabled, LFG_LIST_GROUP_DATA_CLASS_ORDER)
	else
		self.EnumeratePair:Hide()
	end
end

hooksecurefunc("LFGListGroupDataDisplay_Update", LFGListGroupDataDisplay_UpdateHook)

local function LFGListSearchPanel_OnLoadHook(self)
	local scrollButtons = {LFGListSearchPanelScrollFrameScrollChild:GetChildren()}
	for i, button in pairs(scrollButtons) do
		button.DataDisplay.EnumeratePair =  CreateFrame("Frame", button:GetName().."EnumPair", button.DataDisplay)
		local enumPair = button.DataDisplay.EnumeratePair
		enumPair:SetSize(125, 24)
		enumPair:SetPoint("RIGHT", button, "RIGHT", 5, -1)
		
		
		enumPair.Role = CreateFrame("Frame", enumPair:GetName().."Role", enumPair, "LFGListGroupDataDisplayTemplate")
		local roleEnum = enumPair.Role
		roleEnum:SetPoint("RIGHT", enumPair, "RIGHT", 0, 7)
		roleEnum:Show()
		roleEnum.RoleCount:Hide()
		roleEnum.PlayerCount:Hide()
		roleEnum.Enumerate:Show()

		enumPair.Class = CreateFrame("Frame", enumPair:GetName().."Class", enumPair, "LFGListGroupDataDisplayTemplate")
		local classEnum = enumPair.Class
		classEnum:SetPoint("RIGHT", enumPair, "RIGHT", 3, -7)
		classEnum:Show()
		classEnum.RoleCount:Hide()
		classEnum.PlayerCount:Hide()
		classEnum.Enumerate:Show()
		for i = 1, 5 do
			local texture = classEnum.Enumerate:CreateTexture(nil, "ARTWORK")
			classEnum.Enumerate["Icon"..(i + 5)] = texture
			classEnum.Enumerate.Icons[i + 5] = texture
			texture:SetAtlas("groupfinder-icon-role-large-tank")
		end
		for i = 1, 10 do
			local icon = classEnum.Enumerate.Icons[i]
			icon:SetSize(9, 9)
			if i == 1 then
				icon:SetPoint("RIGHT", classEnum.Enumerate, "RIGHT", -12, 0)
			else
				icon:SetPoint("CENTER", classEnum.Enumerate.Icons[i - 1], "CENTER", -9, 0)
			end
		end
	end
end









LFGListSearchPanel_OnLoadHook()











local eventFrame = CreateFrame("Frame", ADDON_NAME.."EventFrame", UIParent)
eventFrame:RegisterEvent("PLAYER_ENTERING_WORLD")
eventFrame:SetScript("OnEvent", function(self, ...)
	PVEFrame_ToggleFrame("GroupFinderFrame")
	GroupFinderFrameGroupButton4:Click()
	LFGListCategorySelection_SelectCategory(LFGListFrame.CategorySelection, 2, 0)
	--dLFGListFrame.CategorySelection.FindGroupButton:Click()
end)