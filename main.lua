local ADDON_NAME, _ = ...

--constants
local ROLE_ICON_SIZE = 18
local CLASS_ICON_SIZE = 12
local ICON_GROUP_SIZE = ROLE_ICON_SIZE + CLASS_ICON_SIZE / 2

local ICONS = LFG_LIST_GROUP_DATA_ATLASES
local ROLES = LFG_LIST_GROUP_DATA_ROLE_ORDER

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

local function getPlayerList(resultID)
	local playerList = {}
	local i = 1
	local playerRole, playerClass = C_LFGList.GetSearchResultMemberInfo(resultID, i)
	while playerRole do
		playerList[i] = {role = ICONS[playerRole], class = ICONS[playerClass]}
		i = i + 1
		playerRole, playerClass = C_LFGList.GetSearchResultMemberInfo(resultID, i)
	end
	return sort(playerList)
end

function LFGListGroupDataDisplayRoleClassEnum_Update(self, numPlayers, displayData, disabled)
	local resultID = self:GetParent():GetParent().resultID
	--Show/hide the required icons
	for i = 1, #self.iconGroups do
		local group = self.iconGroups[i]
		if ( i > numPlayers ) then
			group:Hide()
		else
			group:Show()
			group.role:Show()
			group.class:Show()
			group:SetAlpha(disabled and 0.5 or 1.0)
			for j = 1, #group.icons do
				group.icons[j]:SetDesaturated(disabled)
			end
		end
	end

	local iconList = getPlayerList(resultID)
	local iconIndex = numPlayers
	for i = 1, #iconList do
		local group, icons = self.iconGroups[iconIndex], iconList[i]
		group.role:SetAtlas(icons.role, false)
		group.class:SetAtlas(icons.class, false)
		iconIndex = iconIndex - 1
	end

	for i=1, iconIndex do
		self.iconGroups[i].role:SetAtlas("groupfinder-icon-emptyslot", false)
		self.iconGroups[i].class:Hide()
	end
end

local function LFGListGroupDataDisplay_UpdateHook(self, activityID, displayData, disabled)
	local fullName, shortName, categoryID, groupID, iLevel, filters, minLevel, maxPlayers, displayType = C_LFGList.GetActivityInfo(activityID)
	if (displayType == LE_LFG_LIST_DISPLAY_TYPE_ROLE_ENUMERATE) then
		self.Enumerate:Hide()
		self.RoleClassEnum:Show()
		LFGListGroupDataDisplayRoleClassEnum_Update(self.RoleClassEnum, maxPlayers, displayData, disabled)
	else
		self.RoleClassEnum:Hide()
	end
end


hooksecurefunc("LFGListGroupDataDisplay_Update", LFGListGroupDataDisplay_UpdateHook)

for i, button in pairs({LFGListSearchPanelScrollFrameScrollChild:GetChildren()}) do
	button.DataDisplay.RoleClassEnum =  CreateFrame("Frame", nil, button.DataDisplay)
	local enum = button.DataDisplay.RoleClassEnum
	enum:SetAllPoints(button.DataDisplay)

	enum.iconGroups = {}
	for i = 1, 5 do
		enum.iconGroups[i] = CreateFrame("Frame", nil, enum)
		local iconGroup = enum.iconGroups[i]
		iconGroup:SetSize(ICON_GROUP_SIZE, ICON_GROUP_SIZE)
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
		classIcon:SetPoint("BOTTOMRIGHT", iconGroup, "BOTTOMRIGHT", 0, 0)
		classIcon:SetAtlas("groupfinder-icon-role-large-tank")
		table.insert(iconGroup.icons, classIcon)
	end
end



local eventFrame = CreateFrame("Frame", ADDON_NAME.."EventFrame", UIParent)
eventFrame:RegisterEvent("PLAYER_ENTERING_WORLD")
eventFrame:SetScript("OnEvent", function(self, ...)
	PVEFrame_ToggleFrame("GroupFinderFrame")
	GroupFinderFrameGroupButton4:Click()
	LFGListCategorySelection_SelectCategory(LFGListFrame.CategorySelection, 2, 0)
	--dLFGListFrame.CategorySelection.FindGroupButton:Click()
end)