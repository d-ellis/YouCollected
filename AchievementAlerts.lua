local function initAchievementFrame(frame)
    frame:ClearAllPoints()
    frame:Hide()
    table.insert(UISpecialFrames, "YouCollected_AchievementFrame")

    frame:RegisterForDrag("LeftButton")
    frame:SetScript("OnDragStart", function(self)
        self:StartMoving()
    end)
    frame:SetScript("OnDragStop", function(self)
        self:StopMovingOrSizing()
    end)
    frame:SetScript("OnMouseDown", function(self, button)
        if button == "RightButton" then
            self:Hide()
        end
    end)
end

local achFrame = CreateFrame("Frame", "YouCollected_AchievementFrame", UIParent, "YouCollected_AchievementFrame")
initAchievementFrame(achFrame)
local guildAchFrame = CreateFrame("Frame", "YouCollected_GuildAchievementFrame", UIParent, "YouCollected_GuildAchievementFrame")
initAchievementFrame(guildAchFrame)

-- AchievementAlertSystem:AddAlert(achievementID, alreadyEarned)
---@param achievementID integer
local function showAchievementAlert(achievementID)
    achFrame:Hide();
    guildAchFrame:Hide();

    local _,name,points,_,_,_,_,_,_,icon,_,isGuild = GetAchievementInfo(achievementID)

    local relevantFrame;
    if isGuild then
        relevantFrame = guildAchFrame;
        local guildName = GetGuildInfo("player");
        relevantFrame.GuildName:SetText(guildName);
		SetSmallGuildTabardTextures("player", nil, relevantFrame.GuildBanner, relevantFrame.GuildBorder);
    else
        relevantFrame = achFrame;
    end

    relevantFrame.AchievementName:SetText(name)
    relevantFrame.Icon:SetTexture(icon)
    if points == 0 then
        relevantFrame.Shield:SetAtlas("UI-Achievement-Shield-NoPoints", true)
        relevantFrame.AchievementPoints:SetText("")
    else
        if points < 100 then
            relevantFrame.AchievementPoints:SetFontObject(GameFontNormal)
        else
            relevantFrame.AchievementPoints:SetFontObject(GameFontNormalSmall)
        end
        relevantFrame.Shield:SetAtlas("UI-Achievement-Shield-2", true)
        relevantFrame.AchievementPoints:SetText(tostring(points))
    end
    relevantFrame:Show();
end

AchievementFrame_LoadUI();
hooksecurefunc(AchievementTemplateMixin, "Init", function(self, elementData)

    local function createContextMenu(_, description)
        description:SetTag("YOU_COLLECTED_ACHIEVEMENT_MENU");
        description:CreateButton("Show Collected Alert", showAchievementAlert, elementData.id);
    end

    self:SetScript("OnMouseUp", function(_,button)
        if button == "RightButton" then
            local _,_,_,isCollected = GetAchievementInfo(elementData.id)
            if isCollected then
                MenuUtil.CreateContextMenu(self, createContextMenu);
            end
        end
    end)
end)
function PrintTableContents(table)
    for key,value in pairs(table) do print(key,value) end
end

AchievementAlertSystem:AddAlert(5011, false)
showAchievementAlert(5011)