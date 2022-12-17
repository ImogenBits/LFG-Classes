local ADDON_NAME, _ = ...

LFGClasses = {
	CLASS_ICON_SIZE = 12,
}


local ICONS = LFG_LIST_GROUP_DATA_ATLASES
ICONS["EVOKER"] = "classicon-evoker"
local ROLES = LFG_LIST_GROUP_DATA_ROLE_ORDER

local eventFrame = CreateFrame("Frame", ADDON_NAME.."EventFrame", UIParent)


local function getClassList(resultID)
    local searchResultInfo = C_LFGList.GetSearchResultInfo(resultID)
    local players = {}
    for i = 1, searchResultInfo.numMembers do
        local role, class = C_LFGList.GetSearchResultMemberInfo(resultID, i)
        tinsert(players, {role = role, class = class})
    end

    local sorted = {}
    for _, role in ipairs(ROLES) do
        for _, player in ipairs(players) do
            if player.role == role then
                tinsert(sorted, ICONS[player.class])
            end
        end
    end

    return sorted
end

local function update(self, numPlayers, displayData, disabled, iconOrder)
    if iconOrder == LFG_LIST_GROUP_DATA_ROLE_ORDER then
        local resultID = self:GetParent():GetParent().resultID
        if not resultID then
            return
        end
        if not self.ClassIcons then
            self.ClassIcons = {}
            for i = 1, 5 do
                self.ClassIcons[i] = self:CreateTexture(nil, "ARTWORK")
                self.ClassIcons[i]:SetSize(LFGClasses.CLASS_ICON_SIZE, LFGClasses.CLASS_ICON_SIZE)
                self.ClassIcons[i]:SetPoint("CENTER", self.Icons[i], "BOTTOM", 0, 0)
                self.ClassIcons[i]:SetAtlas("groupfinder-icon-role-large-tank")
            end
        end

        for i, icon in ipairs(self.ClassIcons) do
            if i > numPlayers then
                icon:Hide()
            else
                icon:Show()
                icon:SetDesaturated(disabled)
                icon:SetAlpha(disabled and .5 or 1)
            end
        end

        local classes = getClassList(resultID)
        local iconIndex = numPlayers
        for i = 1, #classes do
            self.ClassIcons[iconIndex]:SetAtlas(classes[i], false)
            iconIndex = iconIndex - 1
        end

        for i = 1, iconIndex do
            self.ClassIcons[i]:Hide()
        end
    else
        if self.ClassIcons then
            for _, icon in ipairs(self.ClassIcons) do
                icon:Hide()
            end
        end
    end
end


eventFrame:RegisterEvent("ADDON_LOADED")
eventFrame:HookScript("OnEvent", function(self, event, ...)
	if event == "ADDON_LOADED" and ... == ADDON_NAME then
		hooksecurefunc("LFGListGroupDataDisplayEnumerate_Update", update)
	end
end)