local ADDON_NAME, _ = ...

--constants
local ROLE_ICON_SIZE = 18
local CLASS_ICON_SIZE = 12
local ICON_GROUP_SIZE = 2 * CLASS_ICON_SIZE

local ICONS = LFG_LIST_GROUP_DATA_ATLASES
local ROLES = LFG_LIST_GROUP_DATA_ROLE_ORDER

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
local CLASSES_BY_ROLE = {
	TANK = {
		PALADIN = true,
		MONK = true,
		DRUID = true,
		WARRIOR = true,
		DEATHKNIGHT = true,
		DEMONHUNTER = true,
	},
	HEALER = {
		PRIEST = true,
		SHAMAN = true,
		PALADIN = true,
		MONK = true,
		DRUID = true,
	},
	DAMAGER = {
		ROGUE = true,
		MAGE = true,
		WARLOCK = true,
		HUNTER = true,
		WARRIOR = true,
		DEATHKNIGHT = true,
		DEMONHUNTER = true,
		PRIEST = true,
		SHAMAN = true,
		PALADIN = true,
		MONK = true,
		DRUID = true
	}
}
local ALL_CLASSES = {
	ROGUE = {DAMAGER = true},
	MAGE = {DAMAGER = true},
	WARLOCK = {DAMAGER = true},
	HUNTER = {DAMAGER = true},
	WARRIOR = {TANK = true, DAMAGER = true},
	DEATHKNIGHT = {TANK = true, DAMAGER = true},
	DEMONHUNTER = {TANK = true, DAMAGER = true},
	PRIEST = {HEALER = true, DAMAGER = true},
	SHAMAN = {HEALER = true, DAMAGER = true},
	PALADIN = {TANK = true, HEALER = true, DAMAGER = true},
	MONK = {TANK = true, HEALER = true, DAMAGER = true},
	DRUID = {TANK = true, HEALER = true, DAMAGER = true},
}


local function copyTable(tbl)
	local newTable = {}
	for k, v in tbl do
		newTable[k] = v
	end
	return newTable
end

local function tableSize(tbl)
	local num = 0
	for _, _ in pairs(tbl) do
		num = num + 1
	end
	return num
end

local hasAssigned = false
local function assignClass(displayData, player, class)
	if player.isAssigned then
		error("tried to assign player that was already assigned")
	end
	player.isAssigned = true
	hasAssigned = true

	displayData[player.role] = displayData[player.role] - 1
	for _, tbl in pairs(displayData.freeClasses) do
		if tbl.potentialRoles[player.role] then
			tbl.potentialRoles[player.role] = tbl.potentialRoles[player.role] - 1
			if tbl.potentialRoles[player.role] == 0 then
				tbl.potentialRoles[player.role] = nil
				tbl.potentialRoles.num = tbl.potentialRoles.num - 1
			end
		end
	end

	player.assignedClass = class
	player.icons.class = ICONS[class]
	displayData[class] = displayData[class] - 1
	for _, currPlayer in ipairs(displayData.players) do
		if not currPlayer.isAssigned then 
			currPlayer.potentialClasses[class] = player.potentialClasses[class] - 1
			if currPlayer.potentialClasses[class] == 0 then
				currPlayer.potentialClasses[class] = nil
				currPlayer.potentialClasses.num = currPlayer.potentialClasses.num - 1
			end
		end
	end

end

local function assignDoouble(displayData, player1, player2, class1, class2)
	if player1.isAssigned or player2.isAssigned then
		error("tried to assign player that was already assigned")
	end
	player.isAssigned = true
	hasAssigned = true

	displayData[player1.role] = displayData[player1.role] - 1
	for _, tbl in pairs(displayData.freeClasses) do
		if tbl.potentialRoles[player1.role] then
			tbl.potentialRoles[player1.role] = tbl.potentialRoles[player1.role] - 1
			if tbl.potentialRoles[player1.role] == 0 then
				tbl.potentialRoles[player1.role] = nil
				tbl.potentialRoles.num = tbl.potentialRoles.num - 1
			end
		end
	end
	displayData[player2.role] = displayData[player2.role] - 1
	for _, tbl in pairs(displayData.freeClasses) do
		if tbl.potentialRoles[player2.role] then
			tbl.potentialRoles[player2.role] = tbl.potentialRoles[player2.role] - 1
			if tbl.potentialRoles[player2.role] == 0 then
				tbl.potentialRoles[player2.role] = nil
				tbl.potentialRoles.num = tbl.potentialRoles.num - 1
			end
		end
	end

	player.assignedClass = class
	player.icons.class = ICONS[class]
	displayData[class] = displayData[class] - 1
	for _, currPlayer in ipairs(displayData.players) do
		if not currPlayer.isAssigned then 
			currPlayer.potentialClasses[class] = player.potentialClasses[class] - 1
			if currPlayer.potentialClasses[class] == 0 then
				currPlayer.potentialClasses[class] = nil
				currPlayer.potentialClasses.num = currPlayer.potentialClasses.num - 1
			end
		end
	end
	
end

local function sort(players)
	local newPlayers = {}
	for i, role in ipairs(ROLES) do
		for j, player in ipairs(players) do
			if player.role == ICONS[role] then
				table.insert(newPlayers, player)
			end
		end
	end
	return newPlayers
end

local function getPotentialClassTable(displayData, role)
	if not CLASSES_BY_ROLE[role] then
		print(role)
	end
	local classes = {num = 0}
	for class in pairs(CLASSES_BY_ROLE[role]) do
		if displayData[class] > 0 then
			classes.num = classes.num + 1
			classes[class] = displayData[class]
		end
	end
	return classes
end

local function getPotentialRoleTable(displayData, class)
	local roles = {num = 0}
	for role in pairs(ALL_CLASSES[class]) do
		if displayData[role] > 0 then
			roles.num = roles.num + 1
			roles[role] = displayData[role]
		end
	end
	return roles
end

local function getClassesAsList(classes)
	local list = {}
	for class in pairs(classes) do
		if class ~= "num" then
			table.insert(list, class)
		end
	end
	return list
end

local function getNumUnassigned(players)
	local num = 0
	for _, player in pairs(players) do
		if not players.isAssigned then
			num = num + 1
		end
	end
	return num
end

local function getPotentialPlayerClasses(displayData, role)
	local tbl = {}
	for class, numClass in pairs(displayData) do
		if ALL_CLASSES[class] and ALL_CLASSES[class][role] then
			for i = 1, numClass do
				table.insert(tbl, class)
			end
		end
	end
	return tbl
end

local function iconListFromPlayers(players)
	local iconList = {}
	for i, player in ipairs(players) do
		iconList[i] = player.icons
	end
	return iconList
end

local function getIconList(numPlayers, displayData)
	local roleList = {}
	for i, role in ipairs(ROLES) do
		for j = 1, displayData[role] do
			table.insert(roleList, role)
		end
	end

	local freeClasses = {}
	for class, classNum in pairs(displayData) do
		if ALL_CLASSES[class] then
			freeClasses[class] = {
				count = classNum,
				potentialRoles = getPotentialRoleTable(displayData, class),
			}
		end
	end
	displayData.freeClasses = freeClasses

	local players = {
		TANK = {},
		HEALER = {},
		DAMAGER = {},
	}
	for i = 1, numPlayers do
		local role = roleList[i]
		players[i] = {
			icons = {
				role = ICONS[role],
				class = false,
				class1 = false,
				class2 = false,
			},
			role = role,
			potentialClasses = getPotentialClassTable(displayData, role),
			assignedClasses = {},
			isAssigned = false
		}
		table.insert(players[role], players[i])
	end
	displayData.players = players


	repeat
		hasAssigned = false
		
		if displayData.TANK == 0 then
			for class, classTbl in pairs(freeClasses) do
				if classTbl.potentialRoles.TANK then
					classTbl.potentialRoles.TANK = nil
					classTbl.potentialRoles.num = classTbl.potentialRoles.num - 1
				end
			end
		end
		if displayData.HEALER == 0 then
			for class, classTbl in pairs(freeClasses) do
				if classTbl.potentialRoles.HEALER then
					classTbl.potentialRoles.HEALER = nil
					classTbl.potentialRoles.num = classTbl.potentialRoles.num - 1
				end
			end
		end

		for i, player in ipairs(players) do
			if not player.isAssigned and player.potentialClasses.num == 1 then
				assignClass(displayData, player, getClassesAsList(player.potentialClasses)[1])
			end
		end

		for class, classTbl in pairs(freeClasses) do
			if classTbl.potentialRoles.num == 1 then
				for i = 1, classTbl.count do
					for i, player in ipairs(players) do
						if not player.isAssigned and classTbl.potentialRoles[player.role] and player.potentialClasses[class] then
							assignClass(displayData, player, class)
						end
					end
				end
			end
		end

		for i, role in ipairs(ROLES) do
			if displayData[role] > 0 and displayData[role] == #getPotentialPlayerClasses(displayData, role) then
				local classList = getPotentialPlayerClasses(displayData, role)
				for i, player in ipairs(players[role]) do
					assignClass(displayData, player, classList[i])
				end
			end
		end

	until not hasAssigned

	return iconListFromPlayers(players)
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