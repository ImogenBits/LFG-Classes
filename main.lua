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

local function enumerateUpdate(self, numPlayers, displayData, disabled, iconOrder)
	
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

local function LFGListGroupDataDisplay_UpdateHook(self, activityID, displayData, disabled)
	local fullName, shortName, categoryID, groupID, iLevel, filters, minLevel, maxPlayers, displayType = C_LFGList.GetActivityInfo(activityID)
	if (displayType == LE_LFG_LIST_DISPLAY_TYPE_ROLE_ENUMERATE) then
		enumerateUpdate(self.Enumerate, maxPlayers, displayData, disabled, LFG_LIST_GROUP_DATA_CLASS_ORDER)
	end
end

hooksecurefunc("LFGListGroupDataDisplay_Update", LFGListGroupDataDisplay_UpdateHook)

local function LFGListSearchPanel_OnLoadHook(self)
	local scrollButtons = {LFGListSearchPanelScrollFrameScrollChild:GetChildren()}
	for i, button in pairs(scrollButtons) do
		print(i)
		local dataEnum = button.DataDisplay.Enumerate
		dataEnum:ClearAllPoints()
		dataEnum:SetPoint("TOPLEFT", button.DataDisplay, "TOPLEFT", 0, 8)
		dataEnum:SetPoint("BOTTOMRIGHT", button.DataDisplay, "BOTTOMRIGHT", 0, 8)
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