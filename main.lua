local ADDON_NAME, _ = ...

--constants
local ROLE_ICON_SIZE = 18
local CLASS_ICON_SIZE = 12
local ICON_GROUP_SIZE = 2 * CLASS_ICON_SIZE

local ICONS = LFG_LIST_GROUP_DATA_ATLASES

local DPS_CLASSES = {
	ROGUE = true,
	MAGE = true,
	WARLOCK = true,
	HUNTER = true,
}
local TANK_CLASSES = {
	WARRIOR = true,
	DEATHKNIGHT = true,
	DEMONHUNTER = true,
}
local HEAL_CLASSES = {
	PRIEST = true,
	SHAMAN = true,
}
local MULTI_CLASSES = {
	PALADIN = true,
	MONK = true,
	DRUID = true
}



local function getIconListOLD(numPlayers, displayData, iconOrder)
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

	local iconList = getIconListOLD(numPlayers, displayData, iconOrder)
	local iconIndex = numPlayers
	for i = 1, #iconList do
		self.Icons[iconIndex]:SetAtlas(iconList[i], false)
		iconIndex = iconIndex - 1
	end

	for i=1, iconIndex do
		self.Icons[i]:SetAtlas("groupfinder-icon-emptyslot", false);
	end
end

local function assignPlayer(displayData, player, role, class, class2)
	player.role = ICONS[role]
	displayData[role] = displayData[role] - 1
	if class and not class2 then
		player.class = ICONS[class]
		player.class1 = false
		player.class2 = false
		displayData[class] = displayData[class] - 1
	elseif class and class2 then
		player.class = false
		player.class1 = ICONS[class]
		player.class2 = ICONS[class2]
		displayData[class] = displayData[class] - 1
	end
end

local function sort(players)
	local newPlayers = {}
	for i, role in ipairs(LFG_LIST_GROUP_DATA_ROLE_ORDER) do
		for j, player in ipairs(players) do
			if player.role == ICONS[role] then
				table.insert(newPlayers, player)
			end
		end
	end
	return newPlayers
end

local function getIconList(numPlayers, displayData)
	local players = {}
	for i = 1, numPlayers do
		players[i] = {role = ICONS.MONK, class = false, class1 = false, class2 = false}
	end
	local numAssignedPlayers = 0

	for class, _ in pairs(DPS_CLASSES) do
		while displayData[class] > 0 do
			numAssignedPlayers = numAssignedPlayers + 1
			assignPlayer(displayData, players[numAssignedPlayers], "DAMAGER", class)
		end
	end

		

	--assign classes that are completely determined

	local changed = false
	repeat
		changed = false
		local numPotentialTanks, numPotentialHealers, numPotentialDps = 0, 0, 0
		local tanks, healers, dps = {}, {}, {}
		for class, _ in pairs(TANK_CLASSES) do
			numPotentialTanks = numPotentialTanks + displayData[class]
			numPotentialDps = numPotentialDps + displayData[class]
			tanks[class] = displayData[class]
			dps[class] = displayData[class]
		end
		for class, _ in pairs(HEAL_CLASSES) do
			numPotentialHealers = numPotentialHealers + displayData[class]
			numPotentialDps = numPotentialDps + displayData[class]
			healers[class] = displayData[class]
			dps[class] = displayData[class]
		end
		for class, _ in pairs(MULTI_CLASSES) do
			numPotentialTanks = numPotentialTanks + displayData[class]
			numPotentialHealers = numPotentialHealers + displayData[class]
			numPotentialDps = numPotentialDps + displayData[class]
			tanks[class] = (tanks[class] or 0) + displayData[class]
			healers[class] = displayData[class]
			dps[class] = displayData[class]
		end

		if numPotentialTanks > 0 and numPotentialTanks == displayData.TANK then
			for class, num in pairs(tanks) do
				for i = 1, num do
					numAssignedPlayers = numAssignedPlayers + 1
					assignPlayer(displayData, players[numAssignedPlayers], "TANK", class)
				end
			end
			changed = true
		end
		if numPotentialHealers > 0 and numPotentialHealers == displayData.HEALER then
			for class, num in pairs(healers) do
				for i = 1, num do
					numAssignedPlayers = numAssignedPlayers + 1
					assignPlayer(displayData, players[numAssignedPlayers], "HEALER", class)
				end
			end
			changed = true
		end
		if numPotentialDps > 0 and numPotentialDps == displayData.DAMAGER then
			for class, num in pairs(dps) do
				for i = 1, num do
					numAssignedPlayers = numAssignedPlayers + 1
					assignPlayer(displayData, players[numAssignedPlayers], "DAMAGER", class)
				end
			end
			changed = true
		end
	until not changed

	
	if displayData.HEALER == 0 then
		for class, _ in pairs(HEAL_CLASSES) do
			while displayData[class] > 0 do
				numAssignedPlayers = numAssignedPlayers + 1
				assignPlayer(displayData, players[numAssignedPlayers], "DAMAGER", class)
			end
		end
	end
	if displayData.TANK == 0 then
		for class, _ in pairs(TANK_CLASSES) do
			while displayData[class] > 0 do
				numAssignedPlayers = numAssignedPlayers + 1
				assignPlayer(displayData, players[numAssignedPlayers], "DAMAGER", class)
			end
		end
	end
	if displayData.HEALER == 0 and displayData.TANK == 0 then
		for class, _ in pairs(MULTI_CLASSES) do
			while displayData[class] > 0 do
				numAssignedPlayers = numAssignedPlayers + 1
				assignPlayer(displayData, players[numAssignedPlayers], "DAMAGER", class)
			end
		end
	end

	--assign roles that could be one of two classes


	--assign remaining roles without classes
	for _, class in ipairs({"TANK", "HEALER", "DAMAGER"}) do
		for i = 1, displayData[class] do
			numAssignedPlayers = numAssignedPlayers + 1
			assignPlayer(displayData, players[numAssignedPlayers], class)
		end
	end
	return sort(players)
end

local function updateRoleClassEnum(self, numPlayers, displayData, disabled)

	--Show/hide the required icons
	for i = 1, #self.iconGroups do
		local group = self.iconGroups[i]
		if ( i > numPlayers ) then
			group:Hide()
		else
			group:Show()
			group:SetAlpha(disabled and 0.5 or 1.0)
			for j = 1, #group.icons do
				group.icons[j]:SetDesaturated(disabled)
			end
		end
	end

	local numPlayersInGroup = displayData.NOROLE + displayData.TANK + displayData.HEALER + displayData.DAMAGER
	local iconList = getIconList(numPlayersInGroup, displayData)
	local iconIndex = numPlayers
	for i = 1, #iconList do
		local group, icons = self.iconGroups[iconIndex], iconList[i]
		group.role:SetAtlas(icons.role, false)
		if icons.class then
			group.class:Show()
			group.class:SetAtlas(icons.class, false)
			group.class1:Hide()
			group.class2:Hide()
		elseif icons.class1 then
			group.class:Hide()
			group.class1:Show()
			group.class1:SetAtlas(icons.class1, false)
			group.class2:Show()
			group.class2:SetAtlas(icons.class2, false)
		else
			group.class:Hide()
			group.class1:Hide()
			group.class2:Hide()

		end
		iconIndex = iconIndex - 1
	end

	for i=1, iconIndex do
		self.iconGroups[i].role:SetAtlas("groupfinder-icon-emptyslot", false)
		self.iconGroups[i].class:Hide()
		self.iconGroups[i].class1:Hide()
		self.iconGroups[i].class2:Hide()
	end
	--! DEBUG info
	self.displayData = displayData
end

local function LFGListGroupDataDisplay_UpdateHook(self, activityID, displayData, disabled)
	local fullName, shortName, categoryID, groupID, iLevel, filters, minLevel, maxPlayers, displayType = C_LFGList.GetActivityInfo(activityID)
	if (displayType == LE_LFG_LIST_DISPLAY_TYPE_ROLE_ENUMERATE) then
		self.Enumerate:Hide()
		self.RoleClassEnum:Show()
		updateRoleClassEnum(self.RoleClassEnum, maxPlayers, displayData, disabled)
	else
		self.RoleClassEnum:Hide()
	end
end

hooksecurefunc("LFGListGroupDataDisplay_Update", LFGListGroupDataDisplay_UpdateHook)

local function LFGListSearchPanel_OnLoadHook(self)
	for i, button in pairs({LFGListSearchPanelScrollFrameScrollChild:GetChildren()}) do
		button.DataDisplay.RoleClassEnum =  CreateFrame("Frame", nil, button.DataDisplay)
		local enum = button.DataDisplay.RoleClassEnum
		enum:SetSize(125, 24)
		enum:SetPoint("RIGHT", button, "RIGHT", -5, -1)

		enum.iconGroups = {}
		for i = 1, 5 do
			enum.iconGroups[i] = CreateFrame("Frame", nil, enum)
			local iconGroup = enum.iconGroups[i]
			iconGroup:SetSize(ICON_GROUP_SIZE, ICON_GROUP_SIZE + 3)
			if i == 1 then
				iconGroup:SetPoint("RIGHT", enum, "RIGHT", 0, 0)
			else
				iconGroup:SetPoint("CENTER", enum.iconGroups[i - 1], "CENTER", -1 * ICON_GROUP_SIZE, 0)
			end
			iconGroup.icons = {}

			iconGroup.role = iconGroup:CreateTexture(nil, "ARTWORK")
			local roleIcon = iconGroup.role
			roleIcon:SetSize(ROLE_ICON_SIZE, ROLE_ICON_SIZE)
			roleIcon:SetPoint("TOP", iconGroup, "TOP", 0, 0)
			roleIcon:SetAtlas("groupfinder-icon-role-large-tank")
			table.insert(iconGroup.icons, roleIcon)

			iconGroup.class = iconGroup:CreateTexture(nil, "ARTWORK")
			local classIcon = iconGroup.class
			classIcon:SetSize(CLASS_ICON_SIZE, CLASS_ICON_SIZE)
			classIcon:SetPoint("BOTTOM", iconGroup, "BOTTOM", 0, 0)
			classIcon:SetAtlas("groupfinder-icon-role-large-tank")
			table.insert(iconGroup.icons, classIcon)

			iconGroup.class1 = iconGroup:CreateTexture(nil, "ARTWORK")
			local classIcon1 = iconGroup.class1
			classIcon1:SetSize(CLASS_ICON_SIZE, CLASS_ICON_SIZE)
			classIcon1:SetPoint("BOTTOMLEFT", iconGroup, "BOTTOMLEFT", 0, 0)
			classIcon1:SetAtlas("groupfinder-icon-role-large-tank")
			classIcon1:Hide()
			table.insert(iconGroup.icons, class1Icon)

			iconGroup.class2 = iconGroup:CreateTexture(nil, "ARTWORK")
			local classIcon2 = iconGroup.class2
			classIcon2:SetSize(CLASS_ICON_SIZE, CLASS_ICON_SIZE)
			classIcon2:SetPoint("BOTTOMRIGHT", iconGroup, "BOTTOMRIGHT", 0, 0)
			classIcon2:SetAtlas("groupfinder-icon-role-large-tank")
			classIcon2:Hide()
			table.insert(iconGroup.icons, class2Icon)
		end

		enum:SetScript("OnEnter", function(self, ...)
			print("-----")
			DevTools_Dump(self.displayData)
		end)



		
		
		--[[enumPair.Role = CreateFrame("Frame", enumPair:GetName().."Role", enumPair, "LFGListGroupDataDisplayTemplate")
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
		end]]
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